extends AnimatedSprite2D

var INDEX
var index
var craft
var resources
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if owner and "button_index" in owner:
		INDEX = owner.button_index
	index = get_parent().get_index()
	print(str(index+1) + "_yes")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if index+1 < 4 or index+1 == 5:
		resources = get_parent().resources
		if index+1 == 5:
			craft = get_parent().get_parent().get_parent().craft
			if craft == 1:
				self.play("5_yes")
			else:
				self.play("5_no")
		else:
			if resources[index] == 0:
				self.play(str(index+1) + "_no")
			else:
				self.play(str(index+1) + "_yes")
	if index+1 == 4:
		self.play("4")
		
		
