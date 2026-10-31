
extends CharacterBody2D

const SPEED = 70.0
const acc = 350.0
const friction = 1050.0
const TileSize: Vector2 = Vector2(16, 16)

var walktween: Tween
var mining = false
var is_moving = false
var target_position: Vector2
var pickup_tween: Tween

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var blood: GPUParticles2D = $GPUParticles2D
@onready var camera: Camera2D = get_tree().get_first_node_in_group("Camera")
@onready var gold_inv: Array = []
@onready var dis = false
@onready var dead = false
@onready var gs = get_tree().get_first_node_in_group("GameStorage")
@onready var darkness_sprite: Sprite2D = $Sprite2D


func play_pickup_pop() -> void:
	var mat := darkness_sprite.material as ShaderMaterial

	if mat == null:
		print("ERROR: Sprite2D has no ShaderMaterial!")
		return

	if pickup_tween and pickup_tween.is_running():
		pickup_tween.kill()

	# Start from normal size.
	mat.set_shader_parameter("pickup_scale", 0.0)

	pickup_tween = create_tween()

	# Quickly grow outward with a pop.
	pickup_tween.tween_method(
		func(value: float):
			mat.set_shader_parameter("pickup_scale", value),
		0.0,
		1.0,
		0.10
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# Shrink back to normal.
	pickup_tween.tween_method(
		func(value: float):
			mat.set_shader_parameter("pickup_scale", value),
		1.0,
		0.0,
		0.20
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func PlayerCollision(obj: RayCast2D) -> bool:
	obj.force_raycast_update()

	if not obj.is_colliding():
		return true

	var collider = obj.get_collider()

	if not is_instance_valid(collider):
		return true

	if collider.is_in_group("Damagers"):
		kill()
		return false
	elif collider.is_in_group("Items"):
		collect_item(collider)
		return true
	else:
		$Camera2D.trigger_shake()
		return false
	# Walls and other obstacles block movement.
	return false


func collect_item(collider: Node2D) -> void:
	if not is_instance_valid(collider):
		return

	if not collider.is_in_group("Items"):
		return

	# Prevent double collection.
	collider.remove_from_group("Items")

	var item_position = collider.global_position

	# Update the countdown and gold count.
	gs.countdown()

	gs.edit_player_data(
		gs.get_player_data()["gold"] + 1
	)

	# Display the gold popup.
	var gold_label = get_tree().get_first_node_in_group("GoldLabels")

	if gold_label:
		gold_label.global_position = item_position
		gold_label.start_popup(
			str(gs.get_player_data()["gold"]) + " Gold"
		)

	# Pop the darkness light!
	play_pickup_pop()

	# Remove the collected item.
	collider.queue_free()


func _physics_process(delta: float) -> void:
	if dis:
		set_physics_process(false)
		return

	if is_moving:
		return

	if Input.is_action_just_pressed("ui_up"):
		if PlayerCollision($up):
			_move(Vector2(0, -1))

	elif Input.is_action_just_pressed("ui_down"):
		if PlayerCollision($down):
			_move(Vector2(0, 1))

	elif Input.is_action_just_pressed("ui_left"):
		if PlayerCollision($left):
			_move(Vector2(-1, 0))

	elif Input.is_action_just_pressed("ui_right"):
		if PlayerCollision($right):
			_move(Vector2(1, 0))

	# Handle collisions after movement as well.
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if not is_instance_valid(collider):
			continue

		if collider.is_in_group("Damagers"):
			kill()
			return

		if collider.is_in_group("Items"):
			collect_item(collider)


func _move(dir: Vector2) -> void:
	if is_moving or dis or dead:
		return

	is_moving = true

	update_animation(dir)

	target_position = global_position + dir * TileSize

	if walktween and walktween.is_running():
		walktween.kill()

	walktween = create_tween()
	walktween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	walktween.set_trans(Tween.TRANS_SINE)
	walktween.set_ease(Tween.EASE_IN_OUT)

	walktween.tween_property(
		self,
		"global_position",
		target_position,
		0.185
	)

	await walktween.finished

	global_position = target_position

	is_moving = false

	update_animation(Vector2.ZERO)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo:
		return

	if event.is_action_pressed("inventory"):
		if dis:
			if dead:
				return

			dis = false
			set_physics_process(true)
		else:
			dis = true


func update_animation(input_dir: Vector2) -> void:
	if mining:
		return

	if input_dir != Vector2.ZERO:
		animated_sprite.play("Run", 2.0)

		if animated_sprite.animation == "Run":
			if animated_sprite.frame == 1 or animated_sprite.frame == 3:
				if not $Footstep.playing:
					$Footstep.pitch_scale = randf_range(0.9, 1.1)
					$Footstep.play()

		if input_dir.x != 0:
			animated_sprite.flip_h = input_dir.x < 0

	else:
		$Footstep.stop()
		animated_sprite.play("Idle")


func kill() -> void:
	if dead:
		return

	dis = true
	dead = true
	is_moving = false

	if walktween and walktween.is_running():
		walktween.kill()

	set_physics_process(false)
	velocity = Vector2.ZERO

	camera.trigger_shake()

	blood.emitting = true

	animated_sprite.play("Die")

	await get_tree().create_timer(0.14).timeout

	blood.emitting = false

	await animated_sprite.animation_finished

	animated_sprite.visible = false


func Mine() -> void:
	animated_sprite.play("Mining")
	mining = true


func StopMine() -> void:
	mining = false

	if not dead:
		animated_sprite.play("Idle")
