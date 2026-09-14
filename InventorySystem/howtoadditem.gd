extends Node

func _ready() -> void:
	await get_tree().process_frame

	var inventory = get_tree().get_first_node_in_group("inventory")

	if inventory == null:
		print("Inventory not found!")
		return

	inventory.add_item("clover")
	inventory.add_item("gold_wings")
	inventory.add_item("new_pickaxe")
	inventory.add_item("hammer")
