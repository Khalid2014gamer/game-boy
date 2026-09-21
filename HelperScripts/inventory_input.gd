extends Node

var inventory

func setup(controller):
	inventory = controller

func key_pressed(event, action_name, fallback_key):
	if InputMap.has_action(action_name):
		if event.is_action_pressed(action_name):
			return true
	return event.physical_keycode == fallback_key

func _input(event):
	if event is not InputEventKey:
		return
	if event.echo or not event.pressed:
		return
	var selection = inventory.selection
	if not inventory.canvas.visible:
		if key_pressed(event, "inventory", KEY_E):
			inventory.open_inventory()
		return
	if key_pressed(event, "inventory", KEY_E):
		if selection.holding:
			if selection.try_keyboard_drop():
				selection.stop_holding()
			return
		if selection.selected_item_id != -1:
			selection.grab_selected_item()
			return
		inventory.close_inventory()
		return
	if key_pressed(event, "inventory_main", KEY_1):
		selection.switch_grid("main")
		inventory.visuals.show_selection_boxes()
		return
	if key_pressed(event, "inventory_hotbar", KEY_2):
		selection.switch_grid("have")
		inventory.visuals.show_selection_boxes()
		return
	if key_pressed(event, "inventory_up", KEY_W):
		selection.move_selection(Vector2i(0, -1))
		return
	if key_pressed(event, "inventory_down", KEY_S):
		selection.move_selection(Vector2i(0, 1))
		return
	if key_pressed(event, "inventory_left", KEY_A):
		selection.move_selection(Vector2i(-1, 0))
		return
	if key_pressed(event, "inventory_right", KEY_D):
		selection.move_selection(Vector2i(1, 0))
		return
	if key_pressed(event, "rotate_item", KEY_R) and selection.holding:
		selection.rotate_item()
		return
