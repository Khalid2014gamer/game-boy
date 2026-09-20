extends Area2D
@onready var craft: AudioStreamPlayer2D = $craft
var index = 1
var INDEX = 0
var array
var resources
func _ready() -> void:
	array = get_parent().get_parent().ARRAY
	resources = get_parent().get_parent().resources
func add_array(item):
	
	for i in range(array.size()):
		if array[i] == "" or array[i] =="0":
			array[i] = str(item)
			break
	
func _process(delta: float) -> void:
	index = get_index() +1
	INDEX = get_parent().get_parent().button_index
	resources = get_parent().get_parent().resources
	if Input.is_action_just_pressed("select"):
		if index == INDEX:
			if index < 4:
				if resources[index-1] > 0:
					add_array(index)
					get_parent().get_parent().rearange_array()
					get_parent().get_parent().update_resources(index-1)
			elif index == 4:
				get_parent().get_parent().ARRAY.assign(["0", "0", "0", "0", "0", "0", "0", "0", "0"])
				get_parent().get_parent().clear_board()
				print("ho")
			else:
				print("huh")
				get_parent().get_parent().craft_recipe()
				craft.play()
