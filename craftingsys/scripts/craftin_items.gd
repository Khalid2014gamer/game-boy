extends Area2D
@onready var animation: AnimatedSprite2D = $animation
var item = ""
func _process(delta: float) -> void:
	if owner and "recipe_crafting" in owner:
		item = str(owner.recipe_crafting)
	#print(item)
	animation.play(item)
