extends Node

var inventory

func _ready() -> void:
	await get_tree().process_frame

	inventory = get_tree().get_first_node_in_group("inventory")

	if inventory == null:
		print("Inventory not found!")
		return

	print("Inventory found!")

	inventory.add_item("old_pickaxe")
	inventory.add_item("new_pickaxe")
	inventory.add_item("hammer")
	inventory.add_item("wings")
	inventory.add_item("old_boots")
	inventory.add_item("new_boots")
	inventory.add_item("ring")
	inventory.add_item("old_bundle")
	inventory.add_item("new_bundle")

func _add_item(item: String) -> void:
	if inventory == null:
		inventory = get_tree().get_first_node_in_group("inventory")

	if inventory != null:
		inventory.add_item(item)
	else:
		print("Inventory Not Found")
# IMPORTANT THE SCRIPT ADDING A ITEM MUST BE IN SOME KIND OF NODE, JUST HAS TO BE IN THE SCENE ALR CHAT
