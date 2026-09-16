extends Control

@onready var canvas = $CanvasLayer
@onready var main_grid = $CanvasLayer/HBoxContainer/Panel/MainInvGrid
@onready var have_grid = $CanvasLayer/HBoxContainer/VBoxContainer/Panel3/WhatYouHave

const SLOT_SIZE = 9
const GAP = 1
const STEP = SLOT_SIZE + GAP

var main_cols = 10
var main_rows = 10
var have_cols = 5
var have_rows = 5

var items = { # khalididdy youy can put the items here, alr, the color is random for now but ofc have to change later
	"new_pickaxe": {
		"name": "New Pickaxe",
		"color": Color(0.88, 0.46, 0.38),
		"shape": [ # ts matrix, 0 is empty, 1 is filled, can be as big as u want
			[1, 1, 1],
			[0, 1, 0],
			[0, 1, 0]
		]
	}
}

var main = []
var have = []

var holding = false
var held = {}
var preview = null

var item_id_count = 0


func _ready():
	add_to_group("inventory")

	setup_layout()

	main = make_empty_grid(main_rows, main_cols)
	have = make_empty_grid(have_rows, have_cols)

	main_grid.columns = main_cols
	have_grid.columns = have_cols

	make_slots(main_grid, main_cols * main_rows)
	make_slots(have_grid, have_cols * have_rows)

	refresh()

	canvas.visible = false


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

	var main_size = Vector2(
		main_cols * STEP - GAP,
		main_rows * STEP - GAP
	)

	var have_size = Vector2(
		have_cols * STEP - GAP,
		have_rows * STEP - GAP
	)

	main_panel.custom_minimum_size = main_size
	main_grid.custom_minimum_size = main_size

	have_panel.custom_minimum_size = have_size
	have_grid.custom_minimum_size = have_size

	main_panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	main_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	have_box.size_flags_horizontal = Control.SIZE_SHRINK_END
	have_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER

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
		var slot = ColorRect.new()

		slot.color = Color(0.15, 0.15, 0.15, 0.5)
		slot.custom_minimum_size = Vector2(SLOT_SIZE, SLOT_SIZE)
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE

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
					put_item(
						have,
						name,
						item_id_count,
						shape,
						x,
						y
					)

					refresh()
					return true
		shape = rotate_shape(shape)

	print("no space for ", name)
	return false

func _input(event):
	if event is InputEventKey and event.echo:
		return

	if event.is_action_pressed("inventory"):
		if holding:
			put_back()

		canvas.visible = !canvas.visible
		return

	if not canvas.visible:
		return

	if event.is_action_pressed("rotate_item") and holding:
		rotate_item()
		return

	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT:
			return

		if event.pressed:
			if not holding:
				try_grab()
			else:
				if try_drop():
					stop_holding()
				else:
					put_back()

func try_grab():
	var cell = get_cell(have_grid, have_cols, have_rows)

	if cell.x != -1:
		grab_item(
			have,
			"have",
			cell,
			have_cols,
			have_rows
		)
		return

	cell = get_cell(main_grid, main_cols, main_rows)
	if cell.x != -1:
		grab_item(
			main,
			"main",
			cell,
			main_cols,
			main_rows
		)

func grab_item(grid, from, cell, cols, rows):
	var data = grid[cell.y][cell.x]

	if data == null:
		return

	held = {
		"name": data["name"],
		"id": data["id"],
		"from": from,
		"x": data["x"],
		"y": data["y"],
		"grab_x": cell.x - data["x"],
		"grab_y": cell.y - data["y"],
		"shape": data["shape"].duplicate(true),
		"old_shape": data["shape"].duplicate(true)
	}

	remove_item(
		grid,
		data["id"],
		cols,
		rows
	)

	holding = true

	make_preview()
	refresh()

func try_drop():
	var cell = get_cell(
		have_grid,
		have_cols,
		have_rows
	)

	var grid
	var cols
	var rows

	if cell.x != -1:
		grid = have
		cols = have_cols
		rows = have_rows
	else:
		cell = get_cell(
			main_grid,
			main_cols,
			main_rows
		)

		if cell.x == -1:
			return false
		grid = main
		cols = main_cols
		rows = main_rows

	var x = cell.x - held["grab_x"]
	var y = cell.y - held["grab_y"]

	if not can_put(
		grid,
		held["shape"],
		x,
		y,
		cols,
		rows
	):
		return false

	put_item(
		grid,
		held["name"],
		held["id"],
		held["shape"],
		x,
		y
	)

	return true

func rotate_item():
	var old = held["shape"]

	if old.size() == 0:
		return

	var old_x = held["grab_x"]
	var old_y = held["grab_y"]

	held["shape"] = rotate_shape(old)

	held["grab_x"] = old.size() - 1 - old_y
	held["grab_y"] = old_x

	make_preview()

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

func get_cell(grid, cols, rows):
	var pos = grid.get_local_mouse_position()

	var grid_width = cols * STEP - GAP
	var grid_height = rows * STEP - GAP

	if pos.x < 0 or pos.x >= grid_width:
		return Vector2i(-1, -1)

	if pos.y < 0 or pos.y >= grid_height:
		return Vector2i(-1, -1)

	var x = int(pos.x / STEP)
	var y = int(pos.y / STEP)

	var inside_x = pos.x - x * STEP
	var inside_y = pos.y - y * STEP

	if inside_x >= SLOT_SIZE:
		return Vector2i(-1, -1)

	if inside_y >= SLOT_SIZE:
		return Vector2i(-1, -1)

	if x < 0 or x >= cols:
		return Vector2i(-1, -1)

	if y < 0 or y >= rows:
		return Vector2i(-1, -1)

	return Vector2i(x, y)

func make_preview():
	if preview != null:
		preview.queue_free()

	preview = Control.new()
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE

	canvas.add_child(preview)

	var shape = held["shape"]
	var color = items[held["name"]]["color"]

	for y in range(shape.size()):
		for x in range(shape[y].size()):

			if shape[y][x] == 0:
				continue

			var square = ColorRect.new()

			square.color = color

			square.size = Vector2(
				SLOT_SIZE,
				SLOT_SIZE
			)

			square.position = Vector2(
				x * STEP,
				y * STEP
			)
			square.mouse_filter = Control.MOUSE_FILTER_IGNORE

			preview.add_child(square)

func _process(_delta):
	if not holding:
		return

	if preview == null:
		return

	var offset = Vector2(
		held["grab_x"] * STEP + SLOT_SIZE / 2.0,
		held["grab_y"] * STEP + SLOT_SIZE / 2.0
	)

	var pos = preview.get_global_mouse_position() - offset

	preview.global_position = pos

func put_back():
	var grid

	if held["from"] == "have":
		grid = have
	else:
		grid = main

	put_item(
		grid,
		held["name"],
		held["id"],
		held["old_shape"],
		held["x"],
		held["y"]
	)

	stop_holding()

func stop_holding():
	if preview != null:
		preview.queue_free()
		preview = null

	held = {}
	holding = false

	refresh()


func refresh():
	update_grid(
		main,
		main_grid,
		main_cols,
		main_rows
	)
	update_grid(
		have,
		have_grid,
		have_cols,
		have_rows
	)

func update_grid(grid, node, cols, rows):
	for y in range(rows):
		for x in range(cols):
			var slot = node.get_child(
				y * cols + x
			)
			var data = grid[y][x]

			if data == null:
				slot.color = Color(
					0.15,
					0.15,
					0.15,
					0.5
				)
			else:
				slot.color = items[data["name"]]["color"]
