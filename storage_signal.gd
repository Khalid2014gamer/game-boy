extends Node

var player_cdata = {
	"gold": 0
}

func _ready() -> void:
	# 1. Directly grab your Gold button node
	var gold_button = get_parent()
	
	gold_button.gold.connect(_on_gold_mined)

func _on_gold_mined(value: int) -> void:
	player_cdata["gold"] += value
	print("Current Gold in dictionary: ", player_cdata["gold"])
	
	$HBoxContainer/GoldValueLabel.start_popup(str(player_cdata["gold"]) + " Gold")

func _process(delta: float) -> void:
	pass
