extends Control

@onready var canvas: CanvasLayer = $CanvasLayer
@onready var main_grid: GridContainer = $CanvasLayer/HBoxContainer/Panel/MainInvGrid
@onready var have_grid: GridContainer = $CanvasLayer/HBoxContainer/VBoxContainer/Panel3/WhatYouHave

const SLOT_SIZE := 40
const SLOT_GAP := 2
const DRAG_SNAP := 6.0

const MAIN_COLS := 10
const MAIN_ROWS := 10

const HAVE_COLS := 5
const HAVE_ROWS := 5


# =========================================================
# ITEM TYPES
#
# This only defines what each TYPE of item is.
# It does NOT mean the player owns them.
# =========================================================

var item_definitions: Dictionary = {
	"new_pickaxe": {
		"name": "New Pickaxe",
		"description": "Pickaxe forged from new gold.",
		"color": Color(0.88, 0.46, 0.38),
		"shape": [
			[1, 1, 1],
			[0, 1, 0],
			[0, 1, 0]
		]
	},
		"old_pickaxe": {
		"name": "old_pickaxe",
		"description": "Pickaxe forged from old gold.",
		"color": Color(0.368, 0.641, 0.748, 1.0),
		"shape": [
			[1, 1, 1],
			[0, 1, 0],
			[0, 1, 0]
		]
	},
	"clover": {
		"name": "clover",
		"description": "A 4 leaf clover . . .",
		"color": Color(0.525, 0.659, 0.0, 1.0),
		"shape": [
			[1, 0, 1],
			[0, 1, 0],
			[1, 0, 1]
		]
	},
	"clock": {
		"name": "clock",
		"description": "A 4 leaf clover . . .",
		"color": Color(0.831, 0.323, 1.0, 1.0),
		"shape": [
			[0, 1, 0],
			[1, 1, 1],
			[0, 1, 0]
		]
	},
	"new_boots": {
		"name": "new boots",
		"description": "At least I dont burn.",
		"color": Color(0.568, 0.581, 0.763, 1.0),
		"shape": [
			[0, 0, 0],
			[0, 1, 1],
			[0, 1, 1]
		]
	},
	"old_boots": {
		"name": "old boots",
		"description": "Bye bye lava, never knew ya . .",
		"color": Color(0.681, 0.575, 0.496, 1.0),
		"shape": [
			[1, 0, 1],
			[1, 0, 1],
			[1, 1, 1]
		]
	},
	"gold_wings": {
		"name": "gold wings",
		"description": "Im with the air!",
		"color": Color(0.399, 0.661, 0.559, 1.0),
		"shape": [
			[1, 0, 1],
			[1, 1, 1],
			[0, 1, 0]
		]
	},
	"mining_rad": {
		"name": "mining radius",
		"description": "My arms are longer!",
		"color": Color(0.853, 0.445, 0.402, 1.0),
		"shape": [
			[1, 1, 1],
			[1, 0, 1],
			[1, 1, 1]
		]
	},
	"hammer": {
		"name": "hammer",
		"description": "Someones breaking it -_-",
		"color": Color(0.629, 0.466, 0.282, 1.0),
		"shape": [
			[1, 1, 0],
			[0, 1, 0],
			[0, 1, 0]
		]
	},
}


# =========================================================
# LIVE INVENTORY
# =========================================================

var main_inventory: Array = []
var have_inventory: Array = []

var next_instance_id := 1

var holding_item: Dictionary = {}
var is_holding_item := false
var drag_preview: Control = null


# =========================================================
# SETUP
# =========================================================

func _ready() -> void:
	add_to_group("inventory")

	setup_layout()

	main_inventory = create_grid(MAIN_ROWS, MAIN_COLS)
	have_inventory = create_grid(HAVE_ROWS, HAVE_COLS)

	clear_grid_nodes(main_grid)
	clear_grid_nodes(have_grid)

	create_grid_nodes(main_grid, MAIN_COLS, MAIN_ROWS)
	create_grid_nodes(have_grid, HAVE_COLS, HAVE_ROWS)

	update_visuals()

	canvas.visible = false


func setup_layout() -> void:
	var hbox = $CanvasLayer/HBoxContainer
	var left_vbox = $CanvasLayer/HBoxContainer/VBoxContainer
	var left_panel = $CanvasLayer/HBoxContainer/VBoxContainer/Panel3
	var right_panel = $CanvasLayer/HBoxContainer/Panel

	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.alignment = BoxContainer.ALIGNMENT_BEGIN
	hbox.add_theme_constant_override("separation", 0)

	left_vbox.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	left_vbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	var have_size := get_grid_size(HAVE_COLS, HAVE_ROWS)
	var main_size := get_grid_size(MAIN_COLS, MAIN_ROWS)

	left_panel.custom_minimum_size = have_size
	have_grid.custom_minimum_size = have_size

	right_panel.custom_minimum_size = main_size
	main_grid.custom_minimum_size = main_size

	right_panel.size_flags_horizontal = Control.SIZE_SHRINK_END
	right_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	var empty_style := StyleBoxEmpty.new()

	left_panel.add_theme_stylebox_override("panel", empty_style)
	right_panel.add_theme_stylebox_override("panel", empty_style)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	hbox.add_child(spacer)
	hbox.move_child(spacer, 1)


func get_grid_size(cols: int, rows: int) -> Vector2:
	return Vector2(
		cols * SLOT_SIZE + (cols - 1) * SLOT_GAP,
		rows * SLOT_SIZE + (rows - 1) * SLOT_GAP
	)


func create_grid(rows: int, cols: int) -> Array:
	var grid: Array = []

	for row_index in range(rows):
		var row: Array = []

		for col_index in range(cols):
			row.append(null)

		grid.append(row)

	return grid


func clear_grid_nodes(container: GridContainer) -> void:
	for child in container.get_children():
		child.free()


func create_grid_nodes(
	container: GridContainer,
	cols: int,
	rows: int
) -> void:

	container.columns = cols

	container.add_theme_constant_override(
		"h_separation",
		SLOT_GAP
	)

	container.add_theme_constant_override(
		"v_separation",
		SLOT_GAP
	)

	for i in range(cols * rows):
		var slot := Panel.new()

		slot.custom_minimum_size = Vector2(
			SLOT_SIZE,
			SLOT_SIZE
		)

		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var style := StyleBoxFlat.new()

		style.bg_color = Color(
			0.15,
			0.15,
			0.15,
			0.5
		)

		slot.add_theme_stylebox_override(
			"panel",
			style
		)

		container.add_child(slot)


# =========================================================
# ADD NEW ITEM
#
# New items ONLY go into have_inventory.
#
# If it cannot fit:
# return false
#
# NO automatic main_inventory overflow.
# =========================================================

func add_item(item_id: String) -> bool:
	if not item_definitions.has(item_id):
		push_warning("Unknown item: " + item_id)
		return false

	var definition = item_definitions[item_id]

	var shape: Array = (
		definition["shape"].duplicate(true)
	)

	var instance_id := next_instance_id

	if auto_place(
		have_inventory,
		HAVE_COLS,
		HAVE_ROWS,
		item_id,
		shape,
		instance_id
	):
		next_instance_id += 1
		update_visuals()

		print(
			"Added ",
			get_item_name(item_id),
			" to What You Have."
		)

		return true

	print(
		"No room for ",
		get_item_name(item_id),
		". Goodbye item 💀"
	)

	return false


func auto_place(
	grid: Array,
	cols: int,
	rows: int,
	item_id: String,
	start_shape: Array,
	instance_id: int
) -> bool:

	var shape: Array = start_shape.duplicate(true)

	# Try all 4 rotations automatically.
	for rotation in range(4):

		for row in range(rows):

			for col in range(cols):

				if can_place(
					grid,
					shape,
					col,
					row,
					cols,
					rows
				):

					place_item(
						grid,
						item_id,
						instance_id,
						shape,
						col,
						row
					)

					return true

		shape = rotate_shape(shape)

	return false


# =========================================================
# INPUT
# =========================================================

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo:
		return


	# E opens / closes inventory.
	if event.is_action_pressed("inventory"):

		if is_holding_item:
			snap_back()

		canvas.visible = !canvas.visible
		return


	if not canvas.visible:
		return


	# R rotates currently held item.
	if (
		event.is_action_pressed("rotate_item")
		and is_holding_item
	):
		rotate_held_item()
		return


	# Mouse drag/drop.
	if event is InputEventMouseButton:

		if event.button_index != MOUSE_BUTTON_LEFT:
			return

		if event.pressed:

			if not is_holding_item:
				try_pick_up()

		else:

			if is_holding_item:

				if try_drop():
					clear_held_item()

				else:
					snap_back()


# =========================================================
# PICK UP
# =========================================================

func try_pick_up() -> void:
	var cell := get_mouse_cell(
		have_grid,
		HAVE_COLS
	)

	if cell.x >= 0:
		pick_up_from(
			have_inventory,
			"have",
			cell.x,
			cell.y,
			HAVE_COLS,
			HAVE_ROWS
		)

		return


	cell = get_mouse_cell(
		main_grid,
		MAIN_COLS
	)


	if cell.x >= 0:
		pick_up_from(
			main_inventory,
			"main",
			cell.x,
			cell.y,
			MAIN_COLS,
			MAIN_ROWS
		)


func pick_up_from(
	grid: Array,
	grid_name: String,
	col: int,
	row: int,
	cols: int,
	rows: int
) -> void:

	var data = grid[row][col]

	if data == null:
		return


	holding_item = {
		"item_id": data["item_id"],

		"instance_id":
			data["instance_id"],

		"source_grid":
			grid_name,

		"original_col":
			data["origin_col"],

		"original_row":
			data["origin_row"],

		"offset_x":
			col - int(data["origin_col"]),

		"offset_y":
			row - int(data["origin_row"]),

		"shape":
			data["shape"].duplicate(true),

		"original_shape":
			data["shape"].duplicate(true)
	}


	remove_instance(
		grid,
		data["instance_id"],
		cols,
		rows
	)


	is_holding_item = true

	create_drag_preview()
	update_visuals()


# =========================================================
# DROP
# =========================================================

func try_drop() -> bool:
	var target_grid: Array
	var cols: int
	var rows: int


	var cell := get_mouse_cell(
		have_grid,
		HAVE_COLS
	)


	if cell.x >= 0:
		target_grid = have_inventory
		cols = HAVE_COLS
		rows = HAVE_ROWS

	else:
		cell = get_mouse_cell(
			main_grid,
			MAIN_COLS
		)

		if cell.x < 0:
			return false

		target_grid = main_inventory
		cols = MAIN_COLS
		rows = MAIN_ROWS


	var start_col: int = (
		cell.x
		- int(holding_item["offset_x"])
	)

	var start_row: int = (
		cell.y
		- int(holding_item["offset_y"])
	)

	var shape: Array = (
		holding_item["shape"]
	)


	if not can_place(
		target_grid,
		shape,
		start_col,
		start_row,
		cols,
		rows
	):
		return false


	place_item(
		target_grid,
		holding_item["item_id"],
		holding_item["instance_id"],
		shape,
		start_col,
		start_row
	)


	return true


# =========================================================
# ROTATION
# =========================================================

func rotate_held_item() -> void:
	var old_shape: Array = (
		holding_item["shape"]
	)

	if old_shape.is_empty():
		return


	var old_height: int = (
		old_shape.size()
	)

	var old_x: int = (
		holding_item["offset_x"]
	)

	var old_y: int = (
		holding_item["offset_y"]
	)


	holding_item["shape"] = (
		rotate_shape(old_shape)
	)


	# Keeps the grabbed square underneath the cursor.
	holding_item["offset_x"] = (
		old_height - 1 - old_y
	)

	holding_item["offset_y"] = old_x


	create_drag_preview()


func rotate_shape(shape: Array) -> Array:
	var old_rows: int = shape.size()

	if old_rows == 0:
		return []


	var old_cols: int = (
		shape[0].size()
	)

	var rotated: Array = []


	for row in range(old_cols):
		var new_row: Array = []

		for col in range(old_rows):
			new_row.append(0)

		rotated.append(new_row)


	for row in range(old_rows):

		for col in range(old_cols):

			rotated[col][
				old_rows - 1 - row
			] = shape[row][col]


	return rotated


# =========================================================
# DRAG PREVIEW
# =========================================================

func create_drag_preview() -> void:
	if drag_preview != null:
		drag_preview.queue_free()


	drag_preview = Control.new()

	drag_preview.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	canvas.add_child(drag_preview)


	var item_id: String = (
		holding_item["item_id"]
	)

	var shape: Array = (
		holding_item["shape"]
	)

	var color: Color = (
		get_item_color(item_id)
	)


	for row in range(shape.size()):

		for col in range(shape[row].size()):

			if shape[row][col] != 1:
				continue


			var tile := ColorRect.new()

			tile.color = color

			tile.size = Vector2(
				SLOT_SIZE,
				SLOT_SIZE
			)

			tile.position = Vector2(
				col * (SLOT_SIZE + SLOT_GAP),
				row * (SLOT_SIZE + SLOT_GAP)
			)

			tile.mouse_filter = (
				Control.MOUSE_FILTER_IGNORE
			)

			drag_preview.add_child(tile)


func _process(_delta: float) -> void:
	if (
		not is_holding_item
		or drag_preview == null
	):
		return


	var spacing := (
		SLOT_SIZE + SLOT_GAP
	)


	var offset := Vector2(
		int(holding_item["offset_x"])
			* spacing
			+ SLOT_SIZE / 2.0,

		int(holding_item["offset_y"])
			* spacing
			+ SLOT_SIZE / 2.0
	)


	var target := (
		get_global_mouse_position()
		- offset
	)


	# Chunky Game Boy-style movement.
	drag_preview.global_position = (
		target.snapped(
			Vector2(
				DRAG_SNAP,
				DRAG_SNAP
			)
		)
	)


# =========================================================
# GRID LOGIC
# =========================================================

func can_place(
	grid: Array,
	shape: Array,
	start_col: int,
	start_row: int,
	cols: int,
	rows: int
) -> bool:

	for row in range(shape.size()):

		for col in range(shape[row].size()):

			if shape[row][col] != 1:
				continue


			var target_col := (
				start_col + col
			)

			var target_row := (
				start_row + row
			)


			if target_col < 0:
				return false

			if target_col >= cols:
				return false

			if target_row < 0:
				return false

			if target_row >= rows:
				return false


			if grid[target_row][target_col] != null:
				return false


	return true


func place_item(
	grid: Array,
	item_id: String,
	instance_id: int,
	shape: Array,
	start_col: int,
	start_row: int
) -> void:

	for row in range(shape.size()):

		for col in range(shape[row].size()):

			if shape[row][col] != 1:
				continue


			grid[
				start_row + row
			][
				start_col + col
			] = {
				"item_id":
					item_id,

				"instance_id":
					instance_id,

				"shape":
					shape.duplicate(true),

				"origin_col":
					start_col,

				"origin_row":
					start_row
			}


func remove_instance(
	grid: Array,
	instance_id: int,
	cols: int,
	rows: int
) -> void:

	for row in range(rows):

		for col in range(cols):

			var data = (
				grid[row][col]
			)

			if data == null:
				continue


			if data["instance_id"] == instance_id:
				grid[row][col] = null


func get_mouse_cell(
	container: GridContainer,
	cols: int
) -> Vector2i:

	var mouse := (
		get_global_mouse_position()
	)


	for i in range(
		container.get_child_count()
	):

		var slot = (
			container.get_child(i)
			as Control
		)

		if slot == null:
			continue


		if slot.get_global_rect().has_point(mouse):

			return Vector2i(
				i % cols,
				int(i / cols)
			)


	return Vector2i(-1, -1)


# =========================================================
# SNAP BACK
# =========================================================

func snap_back() -> void:
	var grid: Array = main_inventory


	if holding_item["source_grid"] == "have":
		grid = have_inventory


	place_item(
		grid,
		holding_item["item_id"],
		holding_item["instance_id"],
		holding_item["original_shape"],
		holding_item["original_col"],
		holding_item["original_row"]
	)


	clear_held_item()


func clear_held_item() -> void:
	if drag_preview != null:
		drag_preview.queue_free()
		drag_preview = null


	holding_item = {}

	is_holding_item = false

	update_visuals()


# =========================================================
# ITEM INFO
# =========================================================

func get_item_color(item_id: String) -> Color:
	if not item_definitions.has(item_id):
		return Color.WHITE


	var definition = (
		item_definitions[item_id]
	)


	return definition.get(
		"color",
		Color.WHITE
	)


func get_item_name(item_id: String) -> String:
	if not item_definitions.has(item_id):
		return item_id


	return str(
		item_definitions[item_id].get(
			"name",
			item_id
		)
	)


func get_item_description(item_id: String) -> String:
	if not item_definitions.has(item_id):
		return ""


	return str(
		item_definitions[item_id].get(
			"description",
			""
		)
	)


# =========================================================
# VISUALS
# =========================================================

func update_visuals() -> void:
	update_grid_visuals(
		main_inventory,
		main_grid,
		MAIN_ROWS,
		MAIN_COLS
	)

	update_grid_visuals(
		have_inventory,
		have_grid,
		HAVE_ROWS,
		HAVE_COLS
	)


func update_grid_visuals(
	grid: Array,
	container: GridContainer,
	rows: int,
	cols: int
) -> void:

	for row in range(rows):

		for col in range(cols):

			var index := (
				row * cols + col
			)

			var slot = (
				container.get_child(index)
				as Panel
			)

			if slot == null:
				continue


			var style = (
				slot.get_theme_stylebox("panel")
				as StyleBoxFlat
			)

			if style == null:
				continue


			var data = (
				grid[row][col]
			)


			if data == null:

				style.bg_color = Color(
					0.15,
					0.15,
					0.15,
					0.5
				)

			else:

				style.bg_color = (
					get_item_color(
						data["item_id"]
					)
				)
