extends Node2D
@onready var cursor: Area2D = $cursor
@onready var move: AudioStreamPlayer2D = $move
@onready var select: AudioStreamPlayer2D = $select

var ARRAY = ["", "", "", "", "", "", "", "", "" ]
@onready var buttons: Node = $buttons
var button_index = 1
var CRAFTING_RECIPES = {
	"new_bundle" : ["1","1","1","1","0","1","1","1", "1"],
	"old_bundle" : ["2","2","2","2","0","2","2","2","2"],
	"clock" : ["0","2","0","2","1","2","0","2","0"],
	"clover" : ["1","0","1","0","2","0","1","0","1"],
	"new_boots" : ["0","0","0","1","0","1","1","0","1"],
	"old_boots" : ["0","0","0","2","0","2","2","0","2"],
	"condensed_gold" : ["2","2","2","2","2","2","2","2","2"],
	"hammer" : ["2","1","0","0","1","0","0","1","0"],
	"gold_wings" : ["2","0","2","2","3","2","2","2","2"],
	"mining_ring" : ["0","2","0","2","3","2","0","2","0"],
	"new_pickaxe" : ["1","1","1","0", "1","0","0","1","0"],
	"old_pickaxe" : ["2","2","2","0","2","0","0","2","0"]
	
	}
var resources = [9,9,1]
var crafted = []
var temp_resources = [0,0,0]
var craft_0 = 0
var craft_1 = 0
var craft_2 = 0
var craft = 0
var recipe_crafting = "0"
func clear_board():
	for i in range(temp_resources.size()):
		resources[i] += temp_resources[i]
		temp_resources[i] = 0
	recipe_crafting = "0"
func update_resources(item):
	resources[item] = resources[item] - 1
	temp_resources[item] = temp_resources[item] + 1
	print(resources)
	print(temp_resources)
func craft_recipe():
	craft_0 = ARRAY.count("0")
	craft_1 = ARRAY.count("1")
	craft_2 = ARRAY.count("2")
	for recipe_name in CRAFTING_RECIPES:
		var recipe = CRAFTING_RECIPES[recipe_name]
		var recipe_0 = recipe.count("0")
		var recipe_1 = recipe.count("1")
		var recipe_2 = recipe.count("2")
		if recipe_0 == craft_0 and recipe_1 == craft_1 and recipe_2 == craft_2:
			print("CRAFTED: ", recipe_name)
			ARRAY.assign([
				"0", "0", "0",
				"0", "0", "0",
				"0", "0", "0"
			])
			crafted.append(recipe_name)
			print(crafted)
			temp_resources = [0,0,0]
			craft = 0
			recipe_crafting = "0"
			return
func rearange_array():
	print(CRAFTING_RECIPES)
	craft_0 = ARRAY.count("0")
	craft_0 += ARRAY.count("")
	craft_1 = ARRAY.count("1")
	craft_2 = ARRAY.count("2")
	print(craft_0)
	print(craft_1)
	for recipe_name in CRAFTING_RECIPES:
		var recipe = CRAFTING_RECIPES[recipe_name]
		var recipe_0 = recipe.count("0") 
		var recipe_1 = recipe.count("1")
		var recipe_2 = recipe.count("2")
		var craft_empty = ARRAY.count("")

		if craft_empty == 9:
			return
		print(recipe_0)
		print(recipe_1)
		if recipe_0 == craft_0 and recipe_1 == craft_1 and recipe_2 == craft_2:
			ARRAY.assign(recipe)
			recipe_crafting = recipe_name
			craft = 1
			break
		else:
			craft = 0
			recipe_crafting = "0"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("move_down"):
		button_index += 1
		if button_index > 5:
			button_index = 1
		move.play(0.1)
		#print(button_index)
	if Input.is_action_just_pressed("move_up"):
		button_index -=1
		if button_index < 1:
			button_index = 5
		move.play(0.1)
	if Input.is_action_just_pressed("select"):
		select.play(0.2)
	cursor.position = buttons.get_child(button_index - 1).position
