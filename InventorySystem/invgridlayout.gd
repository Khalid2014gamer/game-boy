extends Control

@onready var canvas = $CanvasLayer
@onready var main_grid = $CanvasLayer/HBoxContainer/Panel/MainInvGrid
@onready var have_grid = $CanvasLayer/HBoxContainer/VBoxContainer/Panel3/WhatYouHave
@onready var inventory_label = $CanvasLayer/Inventory
@onready var hotbar_label = $CanvasLayer/Hotbar

const SLOT_SIZE = 9
const GAP = 1
const STEP = SLOT_SIZE + GAP

var main_cols = 10
var main_rows = 10

var have_cols = 5
var have_rows = 5

var slot_texture = preload("res://Assets/Images/Slots2.png")
var title_font = preload("res://Assets/Images/GrapeSoda.ttf")

var items = {
	"new_pickaxe": {
		"name": "New Pickaxe",
		"color": preload("res://Assets/Images/pick4.tres"),
		"shape": [
			[0, 0, 0],
			[0, 1, 0],
			[0, 0, 0]
		]
	}
}

var main = []
var have = []

var inventory_items = []
var hotbar_items = []

var item_id_count = 0
var holding = false
var held = {}
var current_grid = "main"

var selected_cell = Vector2i(0, 0)
var selected_item_id = -1
var selected_item_grid = "main"
var selection_layer = null
var selection_boxes = []

func _ready():
	add_to_group("inventory")
	setup_layout()
	
	main = make_empty_grid(main_rows, main_cols)
	have = make_empty_grid(have_rows, have_cols)
	
	main_grid.columns = main_cols
	have_grid.columns = have_cols
	
	make_slots(main_grid, main_cols * main_rows)
	make_slots(have_grid, have_cols * have_rows)
	
	call_deferred("setup_inventory_labels")
	
	selection_layer = Control.new()
	selection_layer.name = "SelectionLayer"
	selection_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	selection_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	canvas.add_child(selection_layer)
	
	refresh()

	inventory_label.text = "Inventory"
	hotbar_label.text = "Hotbar"

	canvas.visible = false

	clear_selection_visual()
	selection_layer.visible = false

func fetch_inv():
	return main

func fetch_current():
	return have

func setup_layout():
	var hbox = $CanvasLayer/HBoxContainer
	var main_panel = $CanvasLayer/HBoxContainer/Panel
	var have_box = $CanvasLayer/HBoxContainer/VBoxContainer
	var have_panel = $CanvasLayer/HBoxContainer/VBoxContainer/Panel3
	
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 5)
	
	main_grid.add_theme_constant_override("h_separation", GAP)
	main_grid.add_theme_constant_override("v_separation", GAP)
	have_grid.add_theme_constant_override("h_separation", GAP)
	have_grid.add_theme_constant_override("v_separation", GAP)
	
	var main_size = Vector2(main_cols * STEP - GAP, main_rows * STEP - GAP)
	var have_size = Vector2(have_cols * STEP - GAP, have_rows * STEP - GAP)
	
	main_panel.custom_minimum_size = main_size
	main_grid.custom_minimum_size = main_size
	have_panel.custom_minimum_size = have_size
	have_grid.custom_minimum_size = have_size
	
	main_panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	main_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	have_box.size_flags_horizontal = Control.SIZE_SHRINK_END
	have_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER

func setup_inventory_labels():
	inventory_label.reparent(canvas)
	hotbar_label.reparent(canvas)

	inventory_label.visible = true
	hotbar_label.visible = true

	inventory_label.modulate.a = 1.0
	hotbar_label.modulate.a = 1.0

	inventory_label.text = "Inventory"
	hotbar_label.text = "Hotbar"

	inventory_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hotbar_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	inventory_label.add_theme_font_size_override("font_size", 8)
	hotbar_label.add_theme_font_size_override("font_size", 8)

	var inventory_rect = main_grid.get_global_rect()
	var hotbar_rect = have_grid.get_global_rect()

	inventory_label.size = Vector2(inventory_rect.size.x, 12)
	hotbar_label.size = Vector2(hotbar_rect.size.x, 12)

	inventory_label.position = Vector2(
		inventory_rect.position.x,
		inventory_rect.position.y - 16
	)

	hotbar_label.position = Vector2(
		hotbar_rect.position.x,
		hotbar_rect.position.y - 16
	)

func position_inventory_labels():
	inventory_label.text = "Inventory"
	hotbar_label.text = "Hotbar"
	
	inventory_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hotbar_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	inventory_label.size = Vector2(main_grid.size.x, 12)
	hotbar_label.size = Vector2(have_grid.size.x, 12)
	
	var inventory_rect = main_grid.get_global_rect()
	var hotbar_rect = have_grid.get_global_rect()
	
	inventory_label.position = Vector2(
		inventory_rect.get_center().x - inventory_label.size.x / 2,
		inventory_rect.position.y - 16
	)
	
	hotbar_label.position = Vector2(
		hotbar_rect.get_center().x - hotbar_label.size.x / 2,
		hotbar_rect.position.y - 16
	)

func make_empty_grid(rows, cols):
	var grid = []
	for y in range(rows):
		var row = []
		for x in range(cols):
			row.append(null)
		grid.append(row)
	return grid

func make_slots(grid, amount):
	for child in grid.get_children():
		child.free()
	for i in range(amount):
		var slot = TextureRect.new()
		
		slot.texture = slot_texture
		slot.custom_minimum_size = Vector2(SLOT_SIZE, SLOT_SIZE)
		slot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		slot.stretch_mode = TextureRect.STRETCH_SCALE
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		var item = TextureRect.new()
		
		item.name = "Item"
		item.size = Vector2(SLOT_SIZE, SLOT_SIZE)
		item.mouse_filter = Control.MOUSE_FILTER_IGNORE
		item.visible = false
		item.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		item.stretch_mode = TextureRect.STRETCH_SCALE
		
		slot.add_child(item)
		grid.add_child(slot)

func add_item(name):
	if not items.has(name):
		print("item not found: ", name)
		return false
	var shape = items[name]["shape"].duplicate(true)
	item_id_count += 1
	
	for turn in range(4):
		for y in range(have_rows):
			for x in range(have_cols):
				if can_put(have, shape, x, y, have_cols, have_rows):
					put_item(have, name, item_id_count, shape, x, y)
					refresh()
					update_selection_visual()
					
					return true
		shape = rotate_shape(shape)
	print("no space for ", name)
	return false

func _input(event):
	if event is InputEventKey and event.echo:
		return
	if event is not InputEventKey:
		return
	if not event.pressed:
		return
	if not canvas.visible:
		if key_pressed(event, "inventory", KEY_E):
			open_inventory()
		return
		
	if key_pressed(event, "inventory", KEY_E):
		if holding:
			if try_keyboard_drop():
				stop_holding()
			return
		if selected_item_id != -1:
			grab_selected_item()
			return
		close_inventory()
		return
		
	if key_pressed(event, "inventory_main", KEY_1):
		switch_grid("main")
		return
	if key_pressed(event, "inventory_hotbar", KEY_2):
		switch_grid("have")
		return
	if key_pressed(event, "inventory_up", KEY_W):
		move_selection(Vector2i(0, -1))
		return
	if key_pressed(event, "inventory_down", KEY_S):
		move_selection(Vector2i(0, 1))
		return
	if key_pressed(event, "inventory_left", KEY_A):
		move_selection(Vector2i(-1, 0))
		return
	if key_pressed(event, "inventory_right", KEY_D):
		move_selection(Vector2i(1, 0))
		return
	if key_pressed(event, "rotate_item", KEY_R) and holding:
		rotate_item()
		return

func key_pressed(event, action_name, fallback_key):
	if InputMap.has_action(action_name):
		if event.is_action_pressed(action_name):
			return true
			
	return event.physical_keycode == fallback_key

func open_inventory():
	canvas.visible = true
	$Camera2D.enabled = true
	
	var player = get_tree().get_first_node_in_group("Player")
	
	if player != null:
		var player_camera = player.get_node_or_null("Camera2D")
		
		if player_camera != null:
			player_camera.enabled = false
			
	selected_item_id = -1
	selected_item_grid = current_grid
	selected_cell = Vector2i(0, 0)
	
	update_selection_visual()

func close_inventory():

	if holding:
		put_back()
		
	canvas.visible = false
	$Camera2D.enabled = false
	
	var player = get_tree().get_first_node_in_group("Player")
	
	if player != null:
		var player_camera = player.get_node_or_null("Camera2D")
		if player_camera != null:
			player_camera.enabled = true
			
	selected_item_id = -1
	
	update_selection_visual()

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
			update_selection_visual()
			return
		current_grid = old_grid
		
		update_selection_visual()
		
		return
		
	if selected_item_id != -1:
		current_grid = new_grid
		
		update_selection_visual()
		
		return
	current_grid = new_grid
	
	clamp_selection_to_grid()
	update_selection_visual()

func move_selection(direction):
	if holding:
		move_held_item(direction)
		return
		
	var cols = get_current_cols()
	var rows = get_current_rows()
	var new_cell = selected_cell + direction
	
	new_cell.x = clampi(new_cell.x, 0, cols - 1)
	new_cell.y = clampi(new_cell.y, 0, rows - 1)
	
	selected_cell = new_cell
	update_selected_item()
	update_selection_visual()

func clamp_selection_to_grid():
	var cols = get_current_cols()
	var rows = get_current_rows()
	
	selected_cell.x = clampi(selected_cell.x, 0, cols - 1)
	selected_cell.y = clampi(selected_cell.y, 0, rows - 1)

func update_selected_item():
	var grid = get_current_grid()
	
	if selected_cell.y < 0:
		selected_item_id = -1
		return
	if selected_cell.y >= grid.size():
		selected_item_id = -1
		return
	if selected_cell.x < 0:
		selected_item_id = -1
		return
	if selected_cell.x >= grid[selected_cell.y].size():
		selected_item_id = -1
		return
		
	var data = grid[
		selected_cell.y
	][
		selected_cell.x
	]
	
	if data == null:
		selected_item_id = -1
	else:
		selected_item_id = data["id"]
		selected_item_grid = current_grid

func grab_selected_item():
	if selected_item_id == -1:
		return
		
	var source_grid
	var source_cols
	var source_rows
	
	if selected_item_grid == "have":
		source_grid = have
		source_cols = have_cols
		source_rows = have_rows
	else:
		source_grid = main
		source_cols = main_cols
		source_rows = main_rows
		
	var data = null
	for y in range(source_rows):
		for x in range(source_cols):
			var thing = source_grid[y][x]
			
			if thing == null:
				continue
				
			if thing["id"] == selected_item_id:
				data = thing
				break
				
		if data != null:
			break
			
	if data == null:
		selected_item_id = -1
		
		update_selection_visual()
		
		return
		
	held = {
		"name": data["name"],
		"id": data["id"],
		"from": selected_item_grid,
		"x": data["x"],
		"y": data["y"],
		"grab_x":
			selected_cell.x - data["x"],
		"grab_y":
			selected_cell.y - data["y"],
		"shape":
			data["shape"].duplicate(true),
		"old_shape":
			data["shape"].duplicate(true),
		"old_x":
			data["x"],
		"old_y":
			data["y"]
	}
	
	remove_item(source_grid, data["id"], source_cols, source_rows)
	
	holding = true
	selected_item_id = -1
	
	var camera = get_tree().get_first_node_in_group("Camera")
	if camera != null:
		camera.trigger_shake()
		
	if not move_held_item_to_valid_grid_position():
		put_item(source_grid, data["name"], data["id"], data["shape"], data["x"], data["y"])
		
		holding = false
		held = {}
		selected_item_id = data["id"]
		selected_item_grid = get_grid_name_from_grid(source_grid)
		
		refresh()
		update_selection_visual()
		
		return
		
	refresh()
	update_selection_visual()

func move_held_item(direction):
	if not holding:
		return
		
	var grid = get_current_grid()
	var cols = get_current_cols()
	var rows = get_current_rows()
	
	var new_x = held["x"] + direction.x
	var new_y = held["y"] + direction.y
	
	if not can_put(grid, held["shape"], new_x, new_y, cols, rows):
		return
		
	held["x"] = new_x
	held["y"] = new_y
	
	selected_cell = Vector2i(held["x"] + held["grab_x"], held["y"] + held["grab_y"])
	
	update_selection_visual()

func move_held_item_to_valid_grid_position():
	if not holding:
		return false
		
	var grid = get_current_grid()
	var cols = get_current_cols()
	var rows = get_current_rows()
	var shape_width = get_shape_width(held["shape"])
	var shape_height = get_shape_height(held["shape"])
	
	if shape_width > cols:
		return false
	if shape_height > rows:
		return false
		
	var wanted_x = (selected_cell.x - held["grab_x"])
	var wanted_y = (selected_cell.y - held["grab_y"])
	var max_x = cols - shape_width
	var max_y = rows - shape_height
	
	wanted_x = clampi(wanted_x, 0, max_x)
	wanted_y = clampi(wanted_y, 0, max_y)
	if can_put(grid, held["shape"], wanted_x, wanted_y, cols, rows):
		
		held["x"] = wanted_x
		held["y"] = wanted_y
		selected_cell = Vector2i(wanted_x + held["grab_x"], wanted_y + held["grab_y"])
		selected_cell.x = clampi(selected_cell.x, 0, cols - 1)
		selected_cell.y = clampi(selected_cell.y, 0, rows - 1)
		return true
		
	for radius in range(max(cols, rows) + 1):
		for dy in range(-radius, radius + 1):
			for dx in range(-radius, radius + 1):
				var test_x = wanted_x + dx
				var test_y = wanted_y + dy
				
				if test_x < 0:
					continue
				if test_y < 0:
					continue
				if test_x > max_x:
					continue
				if test_y > max_y:
					continue
					
				if can_put(grid, held["shape"], test_x, test_y, cols, rows):
					held["x"] = test_x
					held["y"] = test_y
					
					selected_cell = Vector2i(test_x + held["grab_x"], test_y + held["grab_y"])
					selected_cell.x = clampi(selected_cell.x, 0, cols - 1)
					selected_cell.y = clampi(selected_cell.y, 0, rows - 1)
					
					return true
					
	return false

func try_keyboard_drop():
	if not holding:
		return false
		
	var grid = get_current_grid()
	var cols = get_current_cols()
	var rows = get_current_rows()
	
	var x = selected_cell.x - held["grab_x"]
	var y = selected_cell.y - held["grab_y"]
	
	if not can_put(grid, held["shape"], x, y, cols, rows):
		return false
		
	put_item(grid, held["name"], held["id"], held["shape"], x, y)
	
	return true

func rotate_item():
	if not holding:
		return
		
	var old_shape = held["shape"].duplicate(true)
	var old_grab_x = held["grab_x"]
	var old_grab_y = held["grab_y"]
	
	if old_shape.size() == 0:
		return
		
	var new_shape = rotate_shape(old_shape)
	var new_grab_x = (old_shape.size() - 1 - old_grab_y)
	var new_grab_y = old_grab_x
	
	var cols = get_current_cols()
	var rows = get_current_rows()
	var grid = get_current_grid()
	
	if not can_put(grid, new_shape, held["x"], held["y"], cols, rows):
		return
		
	held["shape"] = new_shape
	held["grab_x"] = new_grab_x
	held["grab_y"] = new_grab_y
	
	selected_cell = Vector2i(held["x"] + held["grab_x"], held["y"] + held["grab_y"])
	
	update_selection_visual()

func rotate_shape(shape):
	var h = shape.size()
	var w = shape[0].size()
	var new_shape = []
	
	for y in range(w):
		var row = []
		
		for x in range(h):
			row.append(0)
		new_shape.append(row)
		
	for y in range(h):
		for x in range(w):
			new_shape[x][h - 1 - y] = shape[y][x]
			
	return new_shape

func get_shape_width(shape):
	if shape.size() == 0:
		return 0
	return shape[0].size()

func get_shape_height(shape):
	return shape.size()

func can_put(grid, shape, x, y, cols, rows):
	for sy in range(shape.size()):
		for sx in range(shape[sy].size()):
			if shape[sy][sx] == 0:
				continue
				
			var gx = x + sx
			var gy = y + sy
			
			if gx < 0 or gx >= cols:
				return false
			if gy < 0 or gy >= rows:
				return false
			if grid[gy][gx] != null:
				return false
				
	return true

func put_item(grid, name, id, shape, x, y):
	var location = "main"
	var visual_grid = main_grid
	var columns = 10

	if grid == have:
		location = "hotbar"
		visual_grid = have_grid
		columns = 5

	print(location)

	var slot_index = y * columns + x
	var slot = visual_grid.get_child(slot_index)

	var particle = preload("res://InventorySystem/place_particle.tscn").instantiate()
	canvas.add_child(particle)

	particle.global_position = slot.get_global_rect().get_center() + Vector2(STEP, STEP)
	particle.emitting = true

	get_tree().get_first_node_in_group("Camera").trigger_shake()

	for sy in range(shape.size()):
		for sx in range(shape[sy].size()):
			if shape[sy][sx] == 0:
				continue

			grid[y + sy][x + sx] = {
				"name": name,
				"id": id,
				"x": x,
				"y": y,
				"shape": shape.duplicate(true)
			}

func remove_item(grid, id, cols, rows):
	for y in range(rows):
		for x in range(cols):
			var thing = grid[y][x]
			
			if thing == null:
				continue
			if thing["id"] == id:
				grid[y][x] = null

func get_grid_name_from_grid(grid):
	if grid == have:
		return "have"
		
	return "main"

func put_back():
	if not holding:
		return
		
	var grid
	var cols
	var rows
	
	if held["from"] == "have":
		grid = have
		cols = have_cols
		rows = have_rows
	else:
		grid = main
		cols = main_cols
		rows = main_rows
		
	var x = held["old_x"]
	var y = held["old_y"]
	
	if can_put(grid, held["old_shape"], x, y, cols, rows):
		put_item(grid, held["name"], held["id"], held["old_shape"], x, y)
	else:
		var placed = false
		for test_y in range(rows):
			for test_x in range(cols):
				if can_put(grid, held["old_shape"], test_x, test_y, cols, rows):
					put_item(grid, held["name"], held["id"], held["old_shape"], test_x, test_y)
					placed = true
					break
					
			if placed:
				break
				
	stop_holding()

func stop_holding():
	held = {}
	holding = false
	selected_item_id = -1
	
	refresh()
	update_selection_visual()

func clear_selection_visual():
	for box in selection_boxes:
		if is_instance_valid(box):
			box.queue_free()
	selection_boxes.clear()

func update_selection_visual():
	clear_selection_visual()
	if not canvas.visible:
		return
	if holding:
		var shape = held["shape"]
		for sy in range(shape.size()):
			for sx in range(shape[sy].size()):
				if shape[sy][sx] == 0:
					continue
					
				var cell = Vector2i(held["x"] + sx, held["y"] + sy)
				if is_cell_inside_current_grid(cell):
					add_selection_box(cell)
					
		return
	if selected_item_id != -1:
		var grid
		var grid_node
		var cols
		var rows
		
		if selected_item_grid == "have":
			grid = have
			grid_node = have_grid
			cols = have_cols
			rows = have_rows
		else:
			grid = main
			grid_node = main_grid
			cols = main_cols
			rows = main_rows
			
		var data = null
		for y in range(rows):
			for x in range(cols):
				var thing = grid[y][x]
				if thing == null:
					continue
				if thing["id"] == selected_item_id:
					data = thing
					break
			if data != null:
				break
				
		if data != null:
			var shape = data["shape"]
			for sy in range(shape.size()):
				for sx in range(shape[sy].size()):
					if shape[sy][sx] == 0:
						continue
						
					var cell = Vector2i(data["x"] + sx, data["y"] + sy)
					add_selection_box_on_grid(cell, grid_node, cols, rows)
			return
	add_selection_box(selected_cell)

func is_cell_inside_current_grid(cell):
	return (cell.x >= 0 and cell.x < get_current_cols() and cell.y >= 0 and cell.y < get_current_rows())

func add_selection_box(cell):
	if selection_layer == null:
		return
	if not is_cell_inside_current_grid(cell):
		return
	add_selection_box_on_grid(cell, get_current_grid_node(), get_current_cols(), get_current_rows())

func add_selection_box_on_grid(cell, grid_node, cols, rows):
	if selection_layer == null:
		return
	if cell.x < 0 or cell.x >= cols:
		return
	if cell.y < 0 or cell.y >= rows:
		return
		
	var box = Panel.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var local_position = (grid_node.global_position + Vector2(cell.x * STEP, cell.y * STEP) - selection_layer.global_position)
	
	box.position = local_position
	box.size = Vector2(SLOT_SIZE, SLOT_SIZE)
	
	var style = StyleBoxFlat.new()
	
	style.bg_color = Color(1.0, 1.0, 1.0, 0)
	style.border_color = Color(1.0, 0.816, 0.345, 1.0)
	style.set_border_width_all(1)
	
	box.add_theme_stylebox_override("panel", style)
	
	selection_layer.add_child(box)
	selection_boxes.append(box)

func get_current_grid():
	if current_grid == "have":
		return have
	return main

func get_current_grid_node():
	if current_grid == "have":
		return have_grid
	return main_grid

func get_current_cols():
	if current_grid == "have":
		return have_cols
	return main_cols

func get_current_rows():
	if current_grid == "have":
		return have_rows
	return main_rows

func refresh():
	update_grid(main, main_grid, main_cols, main_rows)
	update_grid(have, have_grid, have_cols, have_rows)

func update_grid(grid, node, cols, rows):

	for y in range(rows):
		for x in range(cols):
			var slot = node.get_child(y * cols + x)
			var item = slot.get_node("Item")
			var data = grid[y][x]
			if data == null:
				item.visible = false
			else:
				item.visible = true
				item.texture = items[
					data["name"]
				]["color"]
