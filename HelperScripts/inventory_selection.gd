extends RefCounted

var inventory
var storage
var current_grid = "main"
var selected_cell = Vector2i(0, 0)
var selected_item_id = -1
var selected_item_grid = "main"
var selection_visible = false
var holding = false
var held = {}

func setup(controller):
	inventory = controller
	storage = controller.grid

func reset():
	current_grid = "main"
	selected_cell = Vector2i(0, 0)
	selected_item_id = -1
	selected_item_grid = "main"
	selection_visible = false
	holding = false
	held = {}

func update_visuals():
	inventory.visuals.update_selection_visual()

func switch_grid(new_grid):
	if new_grid != "main" and new_grid != "have":
		return
	if current_grid == new_grid:
		return
	if holding:
		var old_grid = current_grid
		current_grid = new_grid
		
		if move_held_item_to_valid_grid_position():
			selected_item_id = -1
			update_visuals()
			return
			
		current_grid = old_grid
		update_visuals()
		
		return
	if selected_item_id != -1:
		current_grid = new_grid
		update_visuals()
		
		return
	current_grid = new_grid
	
	clamp_selection_to_grid()
	update_visuals()

func clamp_selection_to_grid():
	selected_cell.x = clampi(selected_cell.x, 0, storage.get_cols(current_grid) - 1)
	selected_cell.y = clampi(selected_cell.y, 0, storage.get_rows(current_grid) - 1)

func move_selection(direction):
	if holding:
		move_held_item(direction)
		return
		
	var new_cell = selected_cell + direction
	
	new_cell.x = clampi(new_cell.x, 0, storage.get_cols(current_grid) - 1)
	new_cell.y = clampi(new_cell.y, 0, storage.get_rows(current_grid) - 1)
	
	selected_cell = new_cell
	
	update_selected_item()
	update_visuals()

func update_selected_item():
	var thing = storage.get_cell(current_grid, selected_cell)
	
	if thing == null:
		selected_item_id = -1
		return
		
	selected_item_id = thing["id"]
	selected_item_grid = current_grid

func grab_selected_item():
	if selected_item_id == -1:
		return
		
	var data = storage.find_item(selected_item_grid, selected_item_id)
	if data == null:
		selected_item_id = -1
		update_visuals()
		return
		
	held = {
		"name": data["name"], "id": data["id"], "from": selected_item_grid,
		"x": data["x"], "y": data["y"],
		"grab_x": selected_cell.x - data["x"], "grab_y": selected_cell.y - data["y"],
		"shape": data["shape"].duplicate(true), "old_shape": data["shape"].duplicate(true),
		"old_x": data["x"], "old_y": data["y"],
		"rotation": data.get("rotation", 0), "old_rotation": data.get("rotation", 0)
	}
	
	storage.remove_item(selected_item_grid, data["id"])
	holding = true
	selected_item_id = -1
	inventory.trigger_camera_shake()
	
	if not move_held_item_to_valid_grid_position():
		inventory.place_item(selected_item_grid, data["name"], data["id"], data["shape"], data["x"], data["y"], data.get("rotation", 0))
		
		holding = false
		held = {}
		selected_item_id = data["id"]
		
		inventory.refresh()
		return
		
	inventory.refresh()

func move_held_item(direction):
	if not holding:
		return
		
	var new_x = held["x"] + direction.x
	var new_y = held["y"] + direction.y
	
	if not storage.can_place(current_grid, held["shape"], new_x, new_y):
		return
		
	held["x"] = new_x
	held["y"] = new_y
	selected_cell = Vector2i(held["x"] + held["grab_x"], held["y"] + held["grab_y"])
	
	update_visuals()

func move_held_item_to_valid_grid_position():
	if not holding:
		return false
	var wanted_x = selected_cell.x - held["grab_x"]
	var wanted_y = selected_cell.y - held["grab_y"]
	
	var position = storage.find_valid_position(current_grid, held["shape"], wanted_x, wanted_y)
	
	if position == Vector2i(-1, -1):
		return false
		
	held["x"] = position.x
	held["y"] = position.y
	
	selected_cell = Vector2i(held["x"] + held["grab_x"], held["y"] + held["grab_y"])
	
	clamp_selection_to_grid()
	return true

func try_keyboard_drop():
	if not holding:
		return false
		
	var x = selected_cell.x - held["grab_x"]
	var y = selected_cell.y - held["grab_y"]
	
	return inventory.place_item(current_grid, held["name"], held["id"], held["shape"], x, y, held.get("rotation", 0))

func rotate_item():
	if not holding:
		return
		
	var old_shape = held["shape"].duplicate(true)
	var old_grab_x = held["grab_x"]
	var old_grab_y = held["grab_y"]
	
	if old_shape.is_empty():
		return
		
	var new_shape = storage.rotate_shape(old_shape)
	var new_grab_x = old_shape.size() - 1 - old_grab_y
	var new_grab_y = old_grab_x
	
	if not storage.can_place(current_grid, new_shape, held["x"], held["y"]):
		return
		
	held["shape"] = new_shape
	held["grab_x"] = new_grab_x
	held["grab_y"] = new_grab_y
	held["rotation"] = (held.get("rotation", 0) + 1) % 4
	
	selected_cell = Vector2i(held["x"] + held["grab_x"], held["y"] + held["grab_y"])
	update_visuals()

func put_back():
	if not holding:
		return
		
	var grid_name = held["from"]
	var x = held["old_x"]
	var y = held["old_y"]
	var shape = held["old_shape"]
	
	if storage.can_place(grid_name, shape, x, y):
		inventory.place_item(grid_name, held["name"], held["id"], shape, x, y, held.get("old_rotation", 0))
	else:
		var placed = false
		
		for test_y in range(storage.get_rows(grid_name)):
			for test_x in range(storage.get_cols(grid_name)):
				if storage.can_place(grid_name, shape, test_x, test_y):
					inventory.place_item(grid_name, held["name"], held["id"], shape, test_x, test_y, held.get("old_rotation", 0))
					placed = true
					
					break
			if placed:
				break
	stop_holding()

func stop_holding():
	held = {}
	holding = false
	selected_item_id = -1
	
	inventory.refresh()
