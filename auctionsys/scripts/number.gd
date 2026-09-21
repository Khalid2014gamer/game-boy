extends RichTextLabel
var index = 0

func _ready() -> void:
	index = get_parent().get_index()
	var game_node = get_node_or_null("/root/game")
	text = "[color=4a3b16]$"	
	self.add_theme_font_size_override("normal_font_size", 9)
	self.text = text
	position.x = 15
	position.y -= 27
func _process(delta: float) -> void:
	var game_node = get_node_or_null("/root/game")
	text = "[color=4a3b16]$"
	text += str(game_node.ITEM_VALUES[index])

	
	
