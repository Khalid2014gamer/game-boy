extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.add_theme_font_size_override("normal_font_size", 100)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.text = str(get_parent().SCORE)
