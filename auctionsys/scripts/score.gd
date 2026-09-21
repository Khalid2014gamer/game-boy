extends RichTextLabel
func _ready() -> void:
	self.add_theme_font_size_override("normal_font_size", 15)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	text = "[color=ffecc1] [right]$ "
	text += str(get_parent().SCORE)
	text += "[/right]"
