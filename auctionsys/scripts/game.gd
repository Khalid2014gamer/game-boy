extends Node2D

var WINDOW_INDEX = 0
var SCORE = 0
@onready var WINDOW_MAX = $windows.get_child_count()
var ITEMS = ["2 Gold Pickaxes", "Five Gold Pickaxes", "HUh", "What", "ye", "math","igowallah","5","tbh", "idk"]
var ITEM_VALUES = [10, 20, 30, 40, 5, 6, 8 , 9, 7, 200]
func _ready():
	WINDOW_MAX -=1
	print(WINDOW_MAX)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("move_up"):
		if WINDOW_INDEX !=0:	
			WINDOW_INDEX -=1
			print(WINDOW_INDEX)
	elif Input.is_action_just_pressed("move_down"):
		if !(WINDOW_INDEX +1 == WINDOW_MAX):
			WINDOW_INDEX +=1
			print(WINDOW_INDEX)
	elif Input.is_action_just_pressed("select"):
		SCORE += ITEM_VALUES[WINDOW_INDEX]
		print(SCORE)
