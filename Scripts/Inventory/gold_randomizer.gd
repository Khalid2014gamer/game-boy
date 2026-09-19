extends Node
@export var map_size = Vector2(20,20)
@export var gold = preload("res://rock.tscn")
@export var amount = 100
# Called when the node enters .the scene tree for the first time.
func _ready() -> void:
	randomize()
	for i in range(amount):
		randomize_gold()
func randomize_gold() -> void:
	var goldi = gold.instantiate()
	goldi.position = Vector2(randf_range(0,map_size.x),randf_range(0,map_size.y))
	add_child(goldi)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
