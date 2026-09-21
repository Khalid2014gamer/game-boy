extends Control

@onready var canvas = $CanvasLayer

const Data = preload("res://InventorySystem/HelperScripts/inventory_data.gd")
const GridScript = preload("res://InventorySystem/HelperScripts/inventory_grid.gd")
const VisualsScript = preload("res://InventorySystem/HelperScripts/inventory_visuals.gd")
const SelectionScript = preload("res://InventorySystem/HelperScripts/inventory_selection.gd")
const InputScript = preload("res://InventorySystem/HelperScripts/inventory_input.gd")

var grid
var visuals
var selection
var input_handler

func _ready():
	add_to_group("inventory")
	
	grid = GridScript.new()
	
	selection = SelectionScript.new()
	selection.setup(self)
	
	visuals = VisualsScript.new()
	visuals.name = "InventoryVisuals"
	
	add_child(visuals)
	
	visuals.setup(self)
	visuals.selection = selection
	
	input_handler = InputScript.new()
	input_handler.name = "InventoryInput"
	
	add_child(input_handler)
	
	input_handler.setup(self)
	
	await get_tree().process_frame
	
	refresh()
	canvas.visible = false
	
	visuals.update_selection_visual()

func fetch_inv():
	return grid.main

func fetch_current():
	return grid.have

func add_item(item_name):
	if not Data.ITEMS.has(item_name):
		print("Item not found: ", item_name)
		return false

	grid.pending_items.append(item_name)
	refresh()
	return true

func try_place_item(item_name):
	if not Data.ITEMS.has(item_name):
		return false

	var shape = Data.ITEMS[item_name]["shape"].duplicate(true)

	var rotation_steps = 0
	for turn in range(4):
		for y in range(Data.HAVE_ROWS):
			for x in range(Data.HAVE_COLS):
				if not grid.can_place("have", shape, x, y):
					continue

				var item = grid.create_item(item_name)

				if item == null:
					return false

				return place_item("have", item_name, item["id"], shape, x, y, rotation_steps)
		shape = grid.rotate_shape(shape)
		rotation_steps = (rotation_steps + 1) % 4
	return false

func process_pending_items():
	if grid.pending_items.is_empty():
		return

	var still_pending = []
	for item_name in grid.pending_items:
		if not try_place_item(item_name):
			still_pending.append(item_name)
			
	grid.pending_items = still_pending

func place_item(grid_name, item_name, id, shape, x, y, rotation_steps = 0):
	var placed = grid.put_item(grid_name, item_name, id, shape, x, y, rotation_steps)

	if not placed:
		return false

	if canvas.visible:
		visuals.spawn_place_particle(grid_name, x, y)
		trigger_camera_shake()
	return true

func refresh():
	process_pending_items()

	if visuals != null:
		visuals.refresh()

func trigger_camera_shake():
	var camera = get_tree().get_first_node_in_group("Camera")

	if camera != null and camera.has_method("trigger_shake"):
		camera.trigger_shake()

func set_player_camera_enabled(enabled):
	var player = get_tree().get_first_node_in_group("Player")

	if player == null:
		return

	var player_camera = player.get_node_or_null("Camera2D")

	if player_camera != null:
		player_camera.enabled = enabled

func open_inventory():
	canvas.visible = true
	$Camera2D.enabled = true
	set_player_camera_enabled(false)
	selection.selected_item_id = -1
	selection.selected_item_grid = selection.current_grid
	selection.selected_cell = Vector2i(0, 0)
	selection.selection_visible = false
	refresh()

func close_inventory():
	if selection.holding:
		selection.put_back()
	canvas.visible = false
	$Camera2D.enabled = false
	set_player_camera_enabled(true)
	selection.selected_item_id = -1
	selection.selection_visible = false
	visuals.update_selection_visual()

func get_item_at(grid_name, x, y):
	return grid.get_cell(grid_name, Vector2i(x, y))

func has_item(item_name):
	for grid_name in ["main", "have"]:
		for row in grid.get_grid(grid_name):
			for thing in row:
				if thing != null and thing["name"] == item_name:
					return true

	return false

func get_all_items():
	var result = []
	var seen_ids = {}
	for grid_name in ["main", "have"]:
		for row in grid.get_grid(grid_name):
			for thing in row:
				if thing == null or seen_ids.has(thing["id"]):
					continue

				seen_ids[thing["id"]] = true
				result.append(thing.duplicate(true))
	return result
