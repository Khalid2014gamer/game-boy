extends Node

var player_cdata = {
	"gold": 0
}

func _ready() -> void:
	# 1. Directly grab your Gold button node
	var gold_button = get_node("../Gold")
	
	gold_button.gold.connect(_on_gold_mined)

func _on_gold_mined(value: int) -> void:
	player_cdata["gold"] += value
	print("Current Gold in dictionary: ", player_cdata["gold"])
	
	%GoldValueLabel.text = str(player_cdata["gold"]) + " Gold"

func _process(delta: float) -> void:
	pass
