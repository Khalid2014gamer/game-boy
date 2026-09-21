extends Node2D
const SELLABLE_ITEMS = {
	"new_pickaxe": 30,
	"old_pickaxe": 60,
	"clock": 40,
	"clover": 100,
	"new_bundle": 20,
	"gold_wings": 300,
	"new_boots": 15,
	"old_boots": 40,
	"old_bundle": 40,
	"hammer": 50,
	"mining_ring": 200
}
var WINDOW_INDEX = 0
var SCORE = 0
@onready var move: AudioStreamPlayer2D = $move
@onready var WINDOW_MAX = $windows.get_child_count()
var ITEMS = []
var player_inv = ["3", "clover"]
var ITEM_VALUES = []

func create_shop_items():
	var available_items = SELLABLE_ITEMS.keys()
	for i in range(6):
		var random_item = available_items.pick_random()
		var item_value = SELLABLE_ITEMS[random_item]
		ITEMS.append(random_item)
		ITEM_VALUES.append(item_value)
		available_items.erase(random_item)
	print(ITEMS)
	print(ITEM_VALUES)
	
func _ready():
	create_shop_items()
	print(WINDOW_MAX)
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("auction_move_up"):
		if WINDOW_INDEX !=0:	
			WINDOW_INDEX -=1
		move.play()
	elif Input.is_action_just_pressed("auction_move_down"):
		if !(WINDOW_INDEX +1 == WINDOW_MAX):
			WINDOW_INDEX +=1
		move.play()
