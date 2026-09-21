extends Node

const Data = preload("res://InventorySystem/HelperScripts/inventory_data.gd")

var inventory
var storage

var selection
var canvas

var main_grid
var have_grid

var item_fill_layer
var item_visual_layer
var selection_layer
var name_label
var item_fill_nodes = []
var item_visual_nodes = []
var selection_boxes = []
var held_fill_nodes = []
var held_visual_node = null
var rotated_texture_cache = {}

func setup(controller):
	inventory = controller
	storage = controller.grid
	
	canvas = inventory.get_node("CanvasLayer")
	
	main_grid = inventory.get_node("CanvasLayer/HBoxContainer/Panel/MainInvGrid")
	have_grid = inventory.get_node("CanvasLayer/HBoxContainer/VBoxContainer/Panel3/WhatYouHave")
	
	setup_layout()
	
	main_grid.columns = Data.MAIN_COLS
	have_grid.columns = Data.HAVE_COLS
	
	make_slots(main_grid, Data.MAIN_COLS * Data.MAIN_ROWS)
	make_slots(have_grid, Data.HAVE_COLS * Data.HAVE_ROWS)
	
	item_fill_layer = make_layer("ItemFillLayer")
	item_visual_layer = make_layer("ItemVisualLayer")
	
	selection_layer = make_layer("SelectionLayer")
	
	name_label = Label.new()
	name_label.name = "ItemNameLabel"
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	name_label.add_theme_font_override("font", Data.select_font)
	name_label.add_theme_font_size_override("font_size", 12)
	name_label.add_theme_color_override("font_color", Color(1.0, 0.933, 0.761, 1.0))
	
	name_label.visible = false
	selection_layer.add_child(name_label)

func make_layer(layer_name):
	var layer = Control.new()
	
	layer.name = layer_name
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	canvas.add_child(layer)
	
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	return layer

func setup_layout():
	var hbox = inventory.get_node("CanvasLayer/HBoxContainer")
	var main_panel = inventory.get_node("CanvasLayer/HBoxContainer/Panel")
	var have_box = inventory.get_node("CanvasLayer/HBoxContainer/VBoxContainer")
	var have_panel = inventory.get_node("CanvasLayer/HBoxContainer/VBoxContainer/Panel3")
	
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 5)
	
	main_grid.add_theme_constant_override("h_separation", Data.GAP)
	main_grid.add_theme_constant_override("v_separation", Data.GAP)
	have_grid.add_theme_constant_override("h_separation", Data.GAP)
	have_grid.add_theme_constant_override("v_separation", Data.GAP)
	
	var main_size = Vector2(Data.MAIN_COLS * Data.STEP - Data.GAP, Data.MAIN_ROWS * Data.STEP - Data.GAP)
	var have_size = Vector2(Data.HAVE_COLS * Data.STEP - Data.GAP, Data.HAVE_ROWS * Data.STEP - Data.GAP)
	
	main_panel.custom_minimum_size = main_size
	main_grid.custom_minimum_size = main_size
	have_panel.custom_minimum_size = have_size
	have_grid.custom_minimum_size = have_size
	
	main_panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	main_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	have_box.size_flags_horizontal = Control.SIZE_SHRINK_END
	have_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER

func make_slots(grid_node, amount):
	for child in grid_node.get_children():
		child.free()
		
	for i in range(amount):
		var slot = TextureRect.new()
		
		slot.texture = Data.slot_texture
		slot.custom_minimum_size = Vector2(Data.SLOT_SIZE, Data.SLOT_SIZE)
		slot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		slot.stretch_mode = TextureRect.STRETCH_SCALE
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		var item = TextureRect.new()
		
		item.name = "Item"
		item.size = Vector2(Data.SLOT_SIZE, Data.SLOT_SIZE)
		item.mouse_filter = Control.MOUSE_FILTER_IGNORE
		item.visible = false
		item.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		item.stretch_mode = TextureRect.STRETCH_SCALE
		
		slot.add_child(item)
		grid_node.add_child(slot)

func get_grid_node(grid_name):
	if grid_name == "have":
		return have_grid
	return main_grid

func refresh():
	update_grid("main")
	update_grid("have")
	
	draw_item_fills()
	draw_item_visuals()
	
	update_selection_visual()

func update_grid(grid_name):
	var node = get_grid_node(grid_name)
	var cols = storage.get_cols(grid_name)
	var rows = storage.get_rows(grid_name)
	
	for y in range(rows):
		for x in range(cols):
			var slot = node.get_child(y * cols + x)
			
			slot.get_node("Item").visible = false

func clear_nodes(nodes):
	for node in nodes:
		if is_instance_valid(node):
			node.queue_free()
	nodes.clear()

func clear_item_fills():
	clear_nodes(item_fill_nodes)

func clear_item_visuals():
	clear_nodes(item_visual_nodes)

func clear_selection_visual():
	clear_nodes(selection_boxes)

func clear_held_visual():
	if is_instance_valid(held_visual_node):
		held_visual_node.queue_free()
	held_visual_node = null
	
	clear_nodes(held_fill_nodes)

func draw_item_fills():
	clear_item_fills()
	
	if not canvas.visible:
		return
		
	draw_item_fills_for_grid("main")
	draw_item_fills_for_grid("have")

func draw_item_fills_for_grid(grid_name):
	var target = storage.get_grid(grid_name)
	var node = get_grid_node(grid_name)
	
	for y in range(target.size()):
		for x in range(target[y].size()):
			var thing = target[y][x]
			
			if thing == null:
				continue
			var color = storage.item_colors.get(thing["id"], Color(1.0, 0.816, 0.345, 1.0))
			add_item_fill_box(Vector2i(x, y), node, color, item_fill_layer, item_fill_nodes)

func add_item_fill_box(cell, grid_node, color, target_layer, target_list):
	var box = Panel.new()
	
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.position = grid_node.global_position + Vector2(cell.x * Data.STEP, cell.y * Data.STEP) - target_layer.global_position
	box.size = Vector2(Data.SLOT_SIZE, Data.SLOT_SIZE)
	
	var style = StyleBoxFlat.new()
	
	style.bg_color = color
	style.set_border_width_all(0)
	
	box.add_theme_stylebox_override("panel", style)
	
	target_layer.add_child(box)
	target_list.append(box)

func draw_item_visuals():
	clear_item_visuals()
	
	if not canvas.visible:
		return
		
	draw_item_visuals_for_grid("main")
	draw_item_visuals_for_grid("have")

func draw_item_visuals_for_grid(grid_name):
	var target = storage.get_grid(grid_name)
	var grid_node = get_grid_node(grid_name)
	var drawn_ids = {}
	
	for row in target:
		for thing in row:
			if thing == null or drawn_ids.has(thing["id"]):
				continue
				
			drawn_ids[thing["id"]] = true
			var visual = build_item_visual(thing, grid_node, item_visual_layer)
			
			if visual != null:
				item_visual_layer.add_child(visual)
				item_visual_nodes.append(visual)

func get_rotated_texture(base_texture, rotation_steps):
	rotation_steps = ((rotation_steps % 4) + 4) % 4
	
	if base_texture == null:
		return null
	if rotation_steps == 0:
		return base_texture
		
	var cache_key = str(base_texture.get_instance_id()) + "_" + str(rotation_steps)
	
	if rotated_texture_cache.has(cache_key):
		return rotated_texture_cache[cache_key]
		
	var image = base_texture.get_image()
	
	if image == null:
		return base_texture
	image = image.duplicate()
	
	for i in range(rotation_steps):
		image.rotate_90(CLOCKWISE)
		
	var rotated_texture = ImageTexture.create_from_image(image)
	rotated_texture_cache[cache_key] = rotated_texture
	
	return rotated_texture

func build_item_visual(item_data, grid_node, target_layer):
	var definition = Data.ITEMS.get(item_data["name"])
	
	if definition == null:
		return null
		
	var shape = item_data["shape"]
	var width = storage.get_shape_width(shape)
	var height = storage.get_shape_height(shape)
	var base_texture = definition["color"]
	var item_scale = definition.get("scale", 1.0)
	var rotation_steps = item_data.get("rotation", 0)
	var texture = get_rotated_texture(base_texture, rotation_steps)
	
	if texture == null:
		return null
		
	var visual = TextureRect.new()
	
	visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	visual.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	visual.stretch_mode = TextureRect.STRETCH_SCALE
	visual.texture = texture
	
	var base_size = Vector2(width * Data.STEP - Data.GAP, height * Data.STEP - Data.GAP)
	var final_size = base_size * item_scale
	var base_position = grid_node.global_position + Vector2(item_data["x"] * Data.STEP, item_data["y"] * Data.STEP) - target_layer.global_position
	
	visual.position = base_position - (final_size - base_size) / 2.0
	visual.size = final_size
	
	return visual

func draw_held_visual():
	clear_held_visual()
	
	if not selection.holding or not canvas.visible:
		return
		
	var held = selection.held
	var grid_node = get_grid_node(selection.current_grid)
	var shape = held["shape"]
	var color = storage.item_colors.get(held["id"], Color(1.0, 0.816, 0.345, 1.0))
	
	for sy in range(shape.size()):
		for sx in range(shape[sy].size()):
			if shape[sy][sx] == 0:
				continue
			var cell = Vector2i(held["x"] + sx, held["y"] + sy)
			
			if storage.is_inside(selection.current_grid, cell):
				add_item_fill_box(cell, grid_node, color, item_fill_layer, held_fill_nodes)
				
	var visual = build_item_visual(held, grid_node, item_visual_layer)
	if visual != null:
		item_visual_layer.add_child(visual)
		held_visual_node = visual

func show_name_label(item_name, top_left_cell, shape_width, grid_node):
	if not Data.ITEMS.has(item_name):
		hide_name_label()
		return
		
	name_label.text = Data.ITEMS[item_name]["name"]
	name_label.visible = true
	
	var item_pixel_width = shape_width * Data.STEP - Data.GAP
	var target_pos = grid_node.global_position + Vector2(top_left_cell.x * Data.STEP, top_left_cell.y * Data.STEP) - selection_layer.global_position
	
	name_label.reset_size()
	name_label.position = Vector2(target_pos.x + (item_pixel_width - name_label.size.x) / 2.0, target_pos.y - name_label.size.y - 2)

func hide_name_label():
	if name_label != null:
		name_label.visible = false

func add_selection_box(cell, grid_name):
	if not storage.is_inside(grid_name, cell):
		return
		
	var grid_node = get_grid_node(grid_name)
	var box = Panel.new()
	
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.position = grid_node.global_position + Vector2(cell.x * Data.STEP, cell.y * Data.STEP) - selection_layer.global_position
	box.size = Vector2(Data.SLOT_SIZE, Data.SLOT_SIZE)
	
	var style = StyleBoxFlat.new()
	
	style.bg_color = Color(1, 1, 1, 0)
	style.border_color = Color(1.0, 0.816, 0.345, 1.0)
	style.set_border_width_all(1)
	
	box.add_theme_stylebox_override("panel", style)
	box.visible = selection.selection_visible
	
	selection_layer.add_child(box)
	selection_boxes.append(box)

func draw_shape_selection(shape, x, y, grid_name):
	for sy in range(shape.size()):
		for sx in range(shape[sy].size()):
			if shape[sy][sx] != 0:
				add_selection_box(Vector2i(x + sx, y + sy), grid_name)

func update_selection_visual():
	clear_selection_visual()
	
	if selection == null:
		return
	if not canvas.visible:
		hide_name_label()
		clear_held_visual()
		return
	if selection.holding:
		var held = selection.held
		draw_shape_selection(held["shape"], held["x"], held["y"], selection.current_grid)
		draw_held_visual()
		show_name_label(held["name"], Vector2i(held["x"], held["y"]), storage.get_shape_width(held["shape"]), get_grid_node(selection.current_grid))
		return
	clear_held_visual()
	
	if selection.selected_item_id != -1:
		var grid_name = selection.selected_item_grid
		var thing = storage.find_item(grid_name, selection.selected_item_id)
		
		if thing != null:
			draw_shape_selection(thing["shape"], thing["x"], thing["y"], grid_name)
			show_name_label(thing["name"], Vector2i(thing["x"], thing["y"]), storage.get_shape_width(thing["shape"]), get_grid_node(grid_name))
			
			return
	hide_name_label()
	add_selection_box(selection.selected_cell, selection.current_grid)

func show_selection_boxes():
	selection.selection_visible = true
	
	for box in selection_boxes:
		if is_instance_valid(box):
			box.visible = true

func spawn_place_particle(grid_name, x, y):
	var grid_node = get_grid_node(grid_name)
	var cols = storage.get_cols(grid_name)
	var slot_index = y * cols + x
	var slot = grid_node.get_child(slot_index)
	var particle = Data.place_particle.instantiate()
	
	canvas.add_child(particle)
	
	particle.global_position = slot.get_global_rect().get_center() + Vector2(Data.STEP, Data.STEP)
	particle.emitting = true
	
	if particle.one_shot:
		particle.finished.connect(particle.queue_free)
	else:
		var lifetime = particle.lifetime
		get_tree().create_timer(lifetime + 0.1).timeout.connect(particle.queue_free)
