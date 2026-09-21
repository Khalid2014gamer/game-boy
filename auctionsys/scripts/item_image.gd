extends AnimatedSprite2D

var index
var items
var game_node
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		position.x -= 72
		index = get_parent().get_index()
		game_node = get_node("/root/game")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	items = game_node.ITEMS
	self.play(items[index])
