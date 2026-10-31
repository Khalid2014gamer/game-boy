
extends Node2D

signal room_completed

# Gold scene
@export var gold_scene: PackedScene

# Room size
@export var room_width: int = 20
@export var room_height: int = 15

@export var gold_count: int = 12

# Grass settings
@export var floor_source_id: int = 0
@export var floor_atlas_coords: Vector2i = Vector2i(0, 0)

@export var grass_chance: float = 0.65
@export var grass_patch_count: int = 8
@export var grass_patch_size: int = 3

# Wall source
@export var wall_source_id: int = 0

# Keep your atlas coordinates here
@export_group("Wall Tiles")

@export var top_left_corner: Vector2i = Vector2i(0, 0)
@export var top_right_corner: Vector2i = Vector2i(1, 0)
@export var bottom_left_corner: Vector2i = Vector2i(2, 0)
@export var bottom_right_corner: Vector2i = Vector2i(3, 0)

@export var top_wall_tile: Vector2i = Vector2i(0, 1)
@export var bottom_wall_tile: Vector2i = Vector2i(0, 1)
@export var left_wall_tile: Vector2i = Vector2i(0, 2)
@export var right_wall_tile: Vector2i = Vector2i(0, 2)

# Nodes
@onready var floor_layer: TileMapLayer = $Floor
@onready var walls: TileMapLayer = $Walls
@onready var generated: Node2D = $Generated
@onready var player: Node2D = $Player
@onready var exit_area: Area2D = $Exit

# Room state
var room_number: int = 1
var changing_room: bool = false

var room_cells: Dictionary = {}
var used_cells: Dictionary = {}
var grass_cells: Array[Vector2i] = []


func _ready() -> void:
	randomize()

	if not exit_area.body_entered.is_connected(_on_exit_body_entered):
		exit_area.body_entered.connect(_on_exit_body_entered)

	generate_room()


func generate_room() -> void:
	changing_room = false

	floor_layer.clear()
	walls.clear()

	for child in generated.get_children():
		generated.remove_child(child)
		child.queue_free()

	room_cells.clear()
	used_cells.clear()
	grass_cells.clear()

	create_random_shape()

	if room_cells.is_empty():
		return

	generate_grass_patches()
	place_outline_walls()

	# Choose player starting position.
	var start_cell: Vector2i = room_cells.keys()[0]

	if not grass_cells.is_empty():
		start_cell = grass_cells.pick_random()

	player.position = floor_layer.map_to_local(start_cell)
	used_cells[start_cell] = true

	# Choose an exit away from the player.
	var possible_exits: Array[Vector2i] = []

	for cell in room_cells.keys():
		var exit_distance: float = Vector2(cell - start_cell).length()

		if exit_distance >= 5.0:
			possible_exits.append(cell)

	var exit_cell: Vector2i = start_cell

	if not possible_exits.is_empty():
		exit_cell = possible_exits.pick_random()

	exit_area.position = floor_layer.map_to_local(exit_cell)
	used_cells[exit_cell] = true

	spawn_gold()


func create_random_shape() -> void:
	var center_x: int = room_width / 2
	var center_y: int = room_height / 2

	var base_width: int = randi_range(7, 11)
	var base_height: int = randi_range(6, 9)

	# Central room.
	for y in range(center_y - base_height / 2, center_y + base_height / 2):
		for x in range(center_x - base_width / 2, center_x + base_width / 2):
			if x >= 1 and x < room_width - 1:
				if y >= 1 and y < room_height - 1:
					room_cells[Vector2i(x, y)] = true

	# Random extensions.
	var extension_count: int = randi_range(3, 7)

	for i in range(extension_count):
		var side: int = randi_range(0, 3)
		var extension_length: int = randi_range(3, 7)
		var extension_depth: int = randi_range(2, 4)

		var cells: Array = room_cells.keys()

		if cells.is_empty():
			break

		var anchor: Vector2i = cells.pick_random()

		for j in range(extension_length):
			for k in range(extension_depth):
				var cell: Vector2i = anchor

				match side:
					0:
						cell += Vector2i(-k - 1, j)
					1:
						cell += Vector2i(k + 1, j)
					2:
						cell += Vector2i(j, -k - 1)
					3:
						cell += Vector2i(j, k + 1)

				if cell.x >= 1 and cell.x < room_width - 1:
					if cell.y >= 1 and cell.y < room_height - 1:
						room_cells[cell] = true


func generate_grass_patches() -> void:
	floor_layer.clear()

	for i in range(grass_patch_count):
		var cells: Array = room_cells.keys()

		if cells.is_empty():
			return

		var center: Vector2i = cells.pick_random()

		for x in range(-grass_patch_size, grass_patch_size + 1):
			for y in range(-grass_patch_size, grass_patch_size + 1):
				var cell: Vector2i = center + Vector2i(x, y)

				if not room_cells.has(cell):
					continue

				if Vector2(x, y).length() > grass_patch_size:
					continue

				if randf() < grass_chance:
					floor_layer.set_cell(
						cell,
						floor_source_id,
						floor_atlas_coords
					)

					if not grass_cells.has(cell):
						grass_cells.append(cell)


# --------------------------------------------------
# WALL GENERATION
# --------------------------------------------------

func place_outline_walls() -> void:
	var wall_cells: Dictionary = {}

	# First collect every position that needs a wall.
	for cell in room_cells.keys():
		var north: Vector2i = cell + Vector2i(0, -1)
		var south: Vector2i = cell + Vector2i(0, 1)
		var west: Vector2i = cell + Vector2i(-1, 0)
		var east: Vector2i = cell + Vector2i(1, 0)

		if not room_cells.has(north):
			wall_cells[north] = true

		if not room_cells.has(south):
			wall_cells[south] = true

		if not room_cells.has(west):
			wall_cells[west] = true

		if not room_cells.has(east):
			wall_cells[east] = true

	# Add diagonal outside corners.
	for cell in room_cells.keys():
		var diagonals: Array[Vector2i] = [
			Vector2i(-1, -1),
			Vector2i(1, -1),
			Vector2i(-1, 1),
			Vector2i(1, 1)
		]

		for offset in diagonals:
			var corner_cell: Vector2i = cell + offset

			var side_x: Vector2i = cell + Vector2i(offset.x, 0)
			var side_y: Vector2i = cell + Vector2i(0, offset.y)

			if not room_cells.has(side_x) and not room_cells.has(side_y):
				wall_cells[corner_cell] = true

	# Now place each wall exactly once.
	for wall_cell in wall_cells.keys():
		var tile: Vector2i = get_wall_tile(wall_cell)

		place_wall(wall_cell, tile)


func get_wall_tile(cell: Vector2i) -> Vector2i:
	# Check which sides of this wall position touch the room.
	var room_north: bool = room_cells.has(cell + Vector2i(0, -1))
	var room_south: bool = room_cells.has(cell + Vector2i(0, 1))
	var room_west: bool = room_cells.has(cell + Vector2i(-1, 0))
	var room_east: bool = room_cells.has(cell + Vector2i(1, 0))

	# Outside corners.
	if room_south and room_east:
		return top_left_corner

	if room_south and room_west:
		return top_right_corner

	if room_north and room_east:
		return bottom_left_corner

	if room_north and room_west:
		return bottom_right_corner

	# Edge tiles.
	if room_south:
		return top_wall_tile

	if room_north:
		return bottom_wall_tile

	if room_east:
		return left_wall_tile

	if room_west:
		return right_wall_tile

	return top_wall_tile


func place_wall(cell: Vector2i, atlas_coords: Vector2i) -> void:
	if walls.get_cell_source_id(cell) != -1:
		return

	walls.set_cell(cell, wall_source_id, atlas_coords)


# --------------------------------------------------
# GOLD
# --------------------------------------------------

func spawn_gold() -> void:
	if gold_scene == null:
		return

	var available_cells: Array[Vector2i] = []

	for cell in grass_cells:
		if not used_cells.has(cell):
			available_cells.append(cell)

	available_cells.shuffle()

	var amount: int = min(gold_count, available_cells.size())

	for i in range(amount):
		var cell: Vector2i = available_cells[i]

		var gold = gold_scene.instantiate()
		generated.add_child(gold)

		gold.position = floor_layer.map_to_local(cell)


# --------------------------------------------------
# ROOM PROGRESSION
# --------------------------------------------------

func _on_exit_body_entered(body: Node2D) -> void:
	if changing_room:
		return

	if body.is_in_group("Player"):
		changing_room = true
		room_number += 1
		room_completed.emit()

		call_deferred("generate_room")
