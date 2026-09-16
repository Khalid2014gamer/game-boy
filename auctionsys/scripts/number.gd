extends RichTextLabel
var index = 0

func _ready() -> void:
	var values = get_parent().get_parent().get_parent().ITEM_VALUES
	index = get_parent().get_index()
	text = str(values[index])
	self.add_theme_font_size_override("normal_font_size", 45
	)
	self.text = text
	position.x = 370
	
