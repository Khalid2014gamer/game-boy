extends Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _pressed() -> void:
	print("gold was clicked!")
	
	disabled = false
	
	await get_tree().create_timer(3.0).timeout
	
	print("finished mining!")
	
	$GoldIMG.visible = false
	%Rock.visible = true
