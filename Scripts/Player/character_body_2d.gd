extends CharacterBody2D


const SPEED = 100.0
const acc = 700.0
const friction = 550.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var blood: GPUParticles2D = $GPUParticles2D
@onready var camera: Camera2D = get_tree().get_first_node_in_group("Camera")
func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right","ui_up","ui_down")
	var kill := Input.is_key_pressed(KEY_K)
	if kill:
		camera.trigger_shake()
		blood.emitting = true
		velocity = Vector2.ZERO
		animated_sprite.visible = false
		await get_tree().create_timer(0.1).timeout
		blood.emitting = false
		set_physics_process(false)
	else:
		blood.emitting = false
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction*SPEED,acc*delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO,friction*delta)
	update_animation(direction)
	move_and_slide()
func update_animation(input_dir: Vector2) -> void:
	if input_dir != Vector2.ZERO:
		animated_sprite.play("Run",2.0)
		
		# Flip sprite left or right based on horizontal movement
		if input_dir.x != 0:
			animated_sprite.flip_h = (input_dir.x < 0)
	else:
		animated_sprite.play("Idle")
