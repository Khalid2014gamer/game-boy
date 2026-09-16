extends Node

var player_cdata = {
	"gold": 0
}

func _ready() -> void:
	# 1. Directly grab your Gold button node
	var gold_button = get_tree().get_nodes_in_group("gold")
	
	#gold_button.gold.connect(_on_gold_mined)

func _on_gold_mined(value: int) -> void:
	player_cdata["gold"] += value
	print("Current Gold in dictionary: ", player_cdata["gold"])
	
	#$GoldValueLabel.start_popup(str(player_cdata["gold"]) + " Gold")

func _process(delta: float) -> void:
	pass
func _input(event):
	if event is InputEventKey and event.echo:
		return

	if event.is_action_pressed("inventory"):
		
func get_player_data():
	return player_cdata
func edit_player_data(value: int) -> void:
	player_cdata["gold"] = value
func countdown() -> void:
	get_tree().get_first_node_in_group("GameStorage").get_child(0)._countdown()
