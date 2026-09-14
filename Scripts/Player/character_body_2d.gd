extends CharacterBody2D


const SPEED = 70.0
const acc = 350.0
const friction = 1050.0
var mining = false
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var blood: GPUParticles2D = $GPUParticles2D
@onready var camera: Camera2D = get_tree().get_first_node_in_group("Camera")
@onready var gold_inv: Array = []
@onready var gs = get_tree().get_first_node_in_group("GameStorage")
func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right","ui_up","ui_down")
	var is_kill_pressed := Input.is_key_pressed(KEY_K)
	if is_kill_pressed:
		kill()
		return # Stop executing physics for this frame
	else:
		blood.emitting = false
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction*SPEED,acc*delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO,friction*delta)
	update_animation(direction)
	#if velocity == Vector2.ZERO:
		#if camera.position_smoothing_enabled == true:
			#await get_tree().create_timer(0.5).timeout
			#camera.position_smoothing_enabled = false
	#else:
		#camera.position_smoothing_enabled = true
	move_and_slide()
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var colider := collision.get_collider()
		if colider.is_in_group("Damagers"):
			kill()
		if colider.is_in_group("Items"):
			gs.countdown()
			if not is_instance_valid(colider):
				continue
	
			colider.remove_from_group("Items")
			colider.queue_free()
			gs.edit_player_data(gs.get_player_data()["gold"]+1)
			get_tree().get_first_node_in_group("GoldLabels").global_position = colider.global_position
			get_tree().get_first_node_in_group("GoldLabels").start_popup(str(get_tree().get_nodes_in_group("GameStorage")[0].get_player_data()["gold"]) + " Gold")
		else:
			pass
				
func update_animation(input_dir: Vector2) -> void:
	if mining == false:
		if input_dir != Vector2.ZERO:
			animated_sprite.play("Run",2.0)
			if animated_sprite.animation == "Run":
				if animated_sprite.frame == 1 or animated_sprite.frame == 3:
					if not $Footstep.playing:
						$Footstep.pitch_scale = randf_range(0.9, 1.1) # Optional slight pitch variation
						$Footstep.play()
			# Flip sprite left or right based on horizontal movement
			if input_dir.x != 0:
				animated_sprite.flip_h = (input_dir.x < 0)
		else:
			$Footstep.stop()
			animated_sprite.play("Idle")
func kill() -> void:
		camera.trigger_shake()
		blood.emitting = true
		velocity = Vector2.ZERO
		animated_sprite.visible = false
		await get_tree().create_timer(0.14).timeout
		blood.emitting = false
		set_physics_process(false)
func Mine() -> void:
	$AnimatedSprite2D.play("Mining")
	mining = true
func StopMine() -> void:
	mining = false
