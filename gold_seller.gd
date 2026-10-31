extends Node2D

var goldworth := 2.3
var gs
var gk

func _ready():
	gs = get_tree().get_first_node_in_group("GameStorage")

	if gs == null:
		print("GameStorage not found!")
		return

	gk = gs.get_child(0)
# gs be having diabetes
func SellGold():
	gs.edit_data(goldworth,"Money")
	gk.running_change(false)
	
