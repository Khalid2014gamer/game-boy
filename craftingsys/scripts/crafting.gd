extends Area2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var index = 0; 
var array = []
func _process(delta: float) -> void:
	index = get_index()
	array = get_parent().get_parent().ARRAY
	#print(array)
	animated_sprite_2d.play(str(array[index]))
