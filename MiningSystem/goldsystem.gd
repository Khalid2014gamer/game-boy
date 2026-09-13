extends Button
signal gold(value)

func _ready() -> void:
	self.disabled = true

func _process(delta: float) -> void:
	pass
	
func _pressed() -> void:
	print("gold was clicked!")
	
	self.disabled = true
	
	await get_tree().create_timer(3.0).timeout
	
	print("finished mining!")
	
	emit_signal("gold", 1)
	
	%GoldIMG.visible = false
	$Rock.visible = true
	%HBoxContainer.visible = true
	
	await get_tree().create_timer(3.0).timeout
	
	%HBoxContainer.visible = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if %GoldIMG.visible and body.name == "Player": 
		self.disabled = false

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		self.disabled = true
