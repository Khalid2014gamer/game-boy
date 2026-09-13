extends Sprite2D

const TILE_SIZE: Vector2 = Vector2(8,8)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	global_position = get_global_mouse_position()
	global_position = global_position.snapped(TILE_SIZE)
