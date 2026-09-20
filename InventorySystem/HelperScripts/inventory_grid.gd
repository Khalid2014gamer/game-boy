extends RefCounted

const Data = preload("res://InventorySystem/HelperScripts/inventory_data.gd")
var main = []
var have = []
var pending_items = []
var item_colors = {}
var item_id_count = 0

func _init():
	main = make_empty_grid(Data.MAIN_ROWS, Data.MAIN_COLS)
	have = make_empty_grid(Data.HAVE_ROWS, Data.HAVE_COLS)

func make_empty_grid(rows, cols):
	var result = []
	for y in range(rows):
		var row = []
		for x in range(cols):
			row.append(null)
		result.append(row)
	return result

func get_grid(grid_name):
	if grid_name == "have":
		return have
	return main

func get_cols(grid_name):
	if grid_name == "have":
		return Data.HAVE_COLS
	return Data.MAIN_COLS

func get_rows(grid_name):
	if grid_name == "have":
		return Data.HAVE_ROWS
	return Data.MAIN_ROWS

func get_cell(grid_name, cell):
	var target = get_grid(grid_name)
	if cell.y < 0 or cell.y >= target.size():
		return null
	if cell.x < 0 or cell.x >= target[cell.y].size():
		return null
	return target[cell.y][cell.x]

func can_put(target, shape, x, y, cols, rows):
	for sy in range(shape.size()):
		for sx in range(shape[sy].size()):
			if shape[sy][sx] == 0:
				continue
				
			var gx = x + sx
			var gy = y + sy
			
			if gx < 0 or gx >= cols or gy < 0 or gy >= rows:
				return false
			if target[gy][gx] != null:
				return false
	return true

func can_place(grid_name, shape, x, y):
	return can_put(get_grid(grid_name), shape, x, y, get_cols(grid_name), get_rows(grid_name))

func put_item(grid_name, item_name, id, shape, x, y, rotation_steps = 0):
	if not can_place(grid_name, shape, x, y):
		return false
		
	var target = get_grid(grid_name)
	var item_data = {"name": item_name, "id": id, "x": x, "y": y, "shape": shape.duplicate(true), "rotation": rotation_steps}
	
	for sy in range(shape.size()):
		for sx in range(shape[sy].size()):
			if shape[sy][sx] != 0:
				target[y + sy][x + sx] = item_data
	return true

func remove_item(grid_name, id):
	var target = get_grid(grid_name)
	
	for y in range(target.size()):
		for x in range(target[y].size()):
			var thing = target[y][x]
			if thing != null and thing["id"] == id:
				target[y][x] = null

func find_item(grid_name, id):
	for row in get_grid(grid_name):
		for thing in row:
			if thing != null and thing["id"] == id:
				return thing
	return null

func create_item(item_name):
	if not Data.ITEMS.has(item_name):
		return null
		
	item_id_count += 1
	var id = item_id_count
	item_colors[id] = Data.ITEM_FILL_COLORS[randi() % Data.ITEM_FILL_COLORS.size()]
	
	return {"name": item_name, "id": id, "shape": Data.ITEMS[item_name]["shape"].duplicate(true), "rotation": 0}

func rotate_shape(shape):
	if shape.is_empty():
		return []
		
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
	if shape.is_empty():
		return 0
	return shape[0].size()

func get_shape_height(shape):
	return shape.size()

func is_inside(grid_name, cell):
	return cell.x >= 0 and cell.y >= 0 and cell.x < get_cols(grid_name) and cell.y < get_rows(grid_name)

func find_valid_position(grid_name, shape, wanted_x, wanted_y):
	var cols = get_cols(grid_name)
	var rows = get_rows(grid_name)
	var width = get_shape_width(shape)
	var height = get_shape_height(shape)
	
	if width > cols or height > rows:
		return Vector2i(-1, -1)
		
	var max_x = cols - width
	var max_y = rows - height
	
	wanted_x = clampi(wanted_x, 0, max_x)
	wanted_y = clampi(wanted_y, 0, max_y)
	
	if can_place(grid_name, shape, wanted_x, wanted_y):
		return Vector2i(wanted_x, wanted_y)
		
	for radius in range(max(cols, rows) + 1):
		for dy in range(-radius, radius + 1):
			for dx in range(-radius, radius + 1):
				var test_x = wanted_x + dx
				var test_y = wanted_y + dy
				
				if test_x < 0 or test_y < 0 or test_x > max_x or test_y > max_y:
					continue
				if can_place(grid_name, shape, test_x, test_y):
					return Vector2i(test_x, test_y)
	return Vector2i(-1, -1)
