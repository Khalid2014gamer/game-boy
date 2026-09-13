extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func start_popup(text_to_show: String) -> void:
	text = text_to_show
	
	scale = Vector2(0.5, 0.5)
	modulate.a = 1.0
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 16.0, 0.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
		
	tween.tween_property(self, "scale", Vector2.ONE, 0.2)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
		
	tween.chain().tween_property(self, "modulate:a", 0.0, 0.4)\
		.set_trans(Tween.TRANS_LINEAR)
