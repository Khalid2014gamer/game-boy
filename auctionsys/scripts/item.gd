extends RichTextLabel
var index = 0

func _ready() -> void:
	index = get_parent().get_index()
	var game_node = get_node("/root/game")
	if game_node and index < game_node.ITEMS.size():
		text = game_node.ITEMS[index]
	self.add_theme_font_size_override("normal_font_size", 7)
	self.text = text
	position.x = -20
	
