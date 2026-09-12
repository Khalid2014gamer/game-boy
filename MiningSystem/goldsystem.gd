extends Button
signal gold(value)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _pressed() -> void:
	print("gold was clicked!")
	
	self.disabled = true
	
	await get_tree().create_timer(3.0).timeout
	
	print("finished mining!")
	
	emit_signal("gold", 1)
	
	%GoldIMG.visible = false
	%Rock.visible = true
	%HBoxContainer.visible = true
	
	await get_tree().create_timer(3.0).timeout
	
	$HBoxContainer.visible = false
