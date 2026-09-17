extends Node
@onready var inventory = get_tree().get_first_node_in_group("inventory")
func _ready() -> void:
	await get_tree().process_frame

	var inventory = get_tree().get_first_node_in_group("inventory")

	if inventory == null:
		print("Inventory not found!")
		return
	inventory.add_item("new_pickaxe")
func _add_item(item: String) -> void:
	inventory.add_item(item)
# IMPORTANT THE SCRIPT ADDING A ITEM MUST BE IN SOME KIND OF NODE, JUST HAS TO BE IN THE SCENE ALR CHAT
 
