extends Area2D 
#defining variables
var desired_pos = 0
var desired_pos_x = 0
var index = 0
var selected = 0
var desired_brightness = 0.7
var current_brightness = 0.7 
var game_node: Node = null
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var select: AudioStreamPlayer2D = $select
@onready var reject: AudioStreamPlayer2D = $reject
#Defining
func _ready():
	index = get_index()
	#debugging print(index)
	if get_parent() and get_parent().get_parent():
		game_node = get_parent().get_parent()

#forever
func _process(delta: float) -> void:
	if not game_node:
		return
	var current_index = game_node.WINDOW_INDEX
	var player_inv = game_node.player_inv
	var items = game_node.ITEMS
	var trade = 0
	var value = game_node.ITEM_VALUES[index]
	desired_pos = (current_index - index)*-33 + 70
	position.y += (desired_pos - position.y)/3
	position.x += (desired_pos_x - position.x)/3
	if current_index == index:
			if items[index] in player_inv:
				animated_sprite_2d.play("selected_yes_trade")
				trade = 1
			else:
				animated_sprite_2d.play("selected_no_trade")
				trade = 0
	else:
		if items[index] in player_inv:
			animated_sprite_2d.play("_yes_trade")
			trade = 1
		else:
			animated_sprite_2d.play("_no_trade")
			trade = 0
			
	if Input.is_action_just_pressed("auction_select") and current_index == index:
		if trade == 1:
			game_node.SCORE += value
			game_node.player_inv.remove_at(player_inv.find(items[index]))
			select.play()
		else:
			reject.play()
	if current_index == index:
		desired_pos_x = 40
	else:
		desired_pos_x = 30
	current_brightness = current_brightness + (desired_brightness - current_brightness)/3
		


		
	

	
