extends Node
@export var map_size = Vector2(20,20)
@export var gold = preload("res://rock.tscn")
@export var amount = 100
@onready var pos_bias = get_tree().get_first_node_in_group("Player").position
# Called when the node enters .the scene tree for the first time.
func _ready() -> void:
	randomize()
	for i in range(amount):
		randomize_gold()
func randomize_gold() -> void:
	var goldi = gold.instantiate()
	goldi.position = Vector2(randf_range(-map_size.x-pos_bias.x,map_size.x+pos_bias.x),randf_range(-map_size.y-pos_bias.y,map_size.y+pos_bias.y))
	add_child(goldi)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
