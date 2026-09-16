extends RichTextLabel
var index = 0

func _ready() -> void:
	var items = get_parent().get_parent().get_parent().ITEMS
	index = get_parent().get_index()
	text = items[index]
	self.add_theme_font_size_override("normal_font_size", 45)
	self.text = text
	position.x = -90
	
