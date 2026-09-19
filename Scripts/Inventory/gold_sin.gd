extends AnimatedSprite2D

@export var timer = 0.0
@onready var start_y = position.y
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += 10.0*delta
	position.y = sin(timer) * 2.0 + start_y
