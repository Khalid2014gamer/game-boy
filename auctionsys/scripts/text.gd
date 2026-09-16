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
	#debugging print(index)
	modulate = Color(0.7, 0.7, 0.7)


#forever
func _process(delta: float) -> void:
	var current_index = get_parent().get_parent().WINDOW_INDEX
	desired_pos = (current_index - index) * -250 + 100
	position.y += (desired_pos - position.y)/5
	position.x += (desired_pos_x - position.x)/5
	if Input.is_action_just_pressed("select") and current_index == index:
		selected = 1
		
	if selected != 1:
		if current_index != index:
			desired_brightness = 0.8
		else:
			desired_brightness = 1.1
	else:
		desired_brightness = 0.4
		
	if current_index == index:
		desired_pos_x = -90
	else:
		desired_pos_x = -190
	current_brightness = current_brightness + (desired_brightness - current_brightness)/3
	modulate = Color(current_brightness, current_brightness, current_brightness)
	
		


		
	

	
