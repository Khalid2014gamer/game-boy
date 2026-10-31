
extends Button

signal gold(value)

const NEW_GOLD = preload("res://new_gold.tscn")
const OLD_GOLD = preload("res://anc_gold.tscn")

const MINING_FPS = 10.0
const MINING_FRAMES = 3

# Each hit cycle takes 0.45 seconds instead of 0.3.
const CYCLE_TIME = 0.45

# Hit when the second frame should be visible.
const HIT_TIME = 0.15
const MINING_TIME = 3.0
var original_gold_scale: Vector2
var original_rock_scale: Vector2
var effect_tween: Tween
var mining_in_progress = false


func _ready() -> void:
	original_gold_scale = $GoldIMG.scale
	original_rock_scale = $Rock.scale


func hit_effect() -> void:
	# Stop an unfinished effect so hits never overlap incorrectly.
	if effect_tween and effect_tween.is_running():
		effect_tween.kill()

	$GoldIMG.scale = original_gold_scale
	$GoldIMG.modulate = Color.WHITE

	effect_tween = create_tween()

	# Flash and squish the gold together.
	$GoldIMG.modulate = Color(4.0, 4.0, 4.0, 1.0)

	effect_tween.tween_property(
		$GoldIMG,
		"scale",
		original_gold_scale * Vector2(1.15, 0.85),
		0.06
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Return the gold to its normal color.
	effect_tween.parallel().tween_property(
		$GoldIMG,
		"modulate",
		Color.WHITE,
		0.12
	)

	# Pop back to the original size.
	effect_tween.tween_property(
		$GoldIMG,
		"scale",
		original_gold_scale,
		0.10
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func rock_hit_effect() -> void:
	if effect_tween and effect_tween.is_running():
		effect_tween.kill()

	# Reset both objects before the next hit.
	$GoldIMG.scale = original_gold_scale
	$GoldIMG.modulate = Color.WHITE
	$Rock.scale = original_rock_scale
	$Rock.modulate = Color.WHITE

	# Gold flashes and squishes on the hit frame.
	$GoldIMG.modulate = Color(4.0, 4.0, 4.0, 1.0)

	effect_tween = create_tween()

	effect_tween.tween_property(
		$GoldIMG,
		"scale",
		original_gold_scale * Vector2(1.15, 0.85),
		0.06
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	effect_tween.parallel().tween_property(
		$GoldIMG,
		"modulate",
		Color.WHITE,
		0.12
	)

	effect_tween.tween_property(
		$GoldIMG,
		"scale",
		original_gold_scale,
		0.10
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _pressed() -> void:
	if mining_in_progress:
		return

	var player = get_tree().get_first_node_in_group("Player")

	if not is_instance_valid(player):
		print("ERROR: Player group not found!")
		return

	mining_in_progress = true
	disabled = true

	print("Started mining!")

	player.Mine()

	$GoldIMG.visible = true
	$GoldIMG.play("default")
	$Rock.visible = true

	$GoldIMG.scale = original_gold_scale
	$GoldIMG.modulate = Color.WHITE

	# Ten hits over 3 seconds, one hit every 0.3 seconds.
	var hit_count = int(MINING_TIME / CYCLE_TIME)

	for i in range(hit_count):
		# Wait until the second animation frame.
		await get_tree().create_timer(HIT_TIME).timeout

		if not is_instance_valid(player):
			break

		# Gold flash and squish on the exact hit timing.
		rock_hit_effect()

		# Camera shake at the same time as the hit.
		if is_instance_valid(player.camera):
			player.camera.trigger_shake()

		# Restart particles on every hit.
		$GPUParticles2D.restart()
		$GPUParticles2D.emitting = true

		# Wait for the rest of the 3-frame animation cycle.
		await get_tree().create_timer(
			CYCLE_TIME - HIT_TIME
		).timeout

	$GPUParticles2D.emitting = false

	# Finish the final visual effect before changing the scene.
	if effect_tween and effect_tween.is_running():
		await effect_tween.finished

	if is_instance_valid(player):
		player.StopMine()

	# Mining is complete.
	var new_gold = NEW_GOLD.instantiate()
	new_gold.position = $GoldIMG.position
	add_child(new_gold)

	print("Finished mining!")

	$GoldIMG.visible = false
	$Rock.visible = true
	$GoldIMG.scale = original_gold_scale
	$GoldIMG.modulate = Color.WHITE
	$Rock.scale = original_rock_scale
	$Rock.modulate = Color.WHITE

	await get_tree().create_timer(3.0).timeout

	$HBoxContainer.visible = false
	mining_in_progress = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if $GoldIMG.visible and body.is_in_group("Player"):
		disabled = false


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		disabled = true
