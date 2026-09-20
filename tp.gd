extends Area2D

@export var tp_loc: Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.global_position = tp_loc
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
