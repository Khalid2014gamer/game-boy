extends Node2D

@onready var inventory: Node = $Control
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _get_items_in_inv():
	return inventory.fetch_inv()
func _get_items_in_hotbar():
	return inventory.fetch_current()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#if Input.is_action_just_pressed("inventory"):
		#get_tree().change_scene_to_file("res://items.tscn")
