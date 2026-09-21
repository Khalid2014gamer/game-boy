extends Node2D


#defining variables

var text = ""
var desired_pos = 0
var desired_pos_x = 0
var index = 0
var selected = 0
var desired_brightness = 0.7
var current_brightness = 0.7

#Defining
func _ready():
	index = get_index()

#forever
func _process(delta: float) -> void:
	var current_index = get_parent().get_parent().WINDOW_INDEX
	desired_pos = (current_index - index)*-33 + 50
	position.y += (desired_pos - position.y)/3
	position.x += (desired_pos_x - position.x)/3
	if Input.is_action_just_pressed("auction_select") and current_index == index:
		selected = 1
				
	if current_index == index:
		desired_pos_x = 40
	else:
		desired_pos_x = 30
	current_brightness = current_brightness + (desired_brightness - current_brightness)/3
	
		


		
	

	
