extends AnimatedSprite2D
#defining variables
var desired_pos = 0
var desired_pos_x = 0
var index = 6
var selected = 0
var game_node: Node = null
#Defining
func _ready():
		game_node = get_parent().get_parent()
#forever
func _process(delta: float) -> void:
	if not game_node:
		return
	var current_index = game_node.WINDOW_INDEX
	desired_pos = (current_index - index)*-33 + 70
	position.y += (desired_pos - position.y)/3
	position.x += (desired_pos_x - position.x)/3

	if current_index == index:
		self.play("exit_selected")
		desired_pos_x = 40
	else:
		self.play("exit")
		desired_pos_x = 30

			
	if Input.is_action_just_pressed("auction_select") and current_index == index:
		get_tree().quit()



		
	

	
