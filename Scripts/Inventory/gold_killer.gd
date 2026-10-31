extends Node

@onready var darkness_sprite: Sprite2D = $"../../Player/Sprite2D"

var countdown_running := false


func _countdown() -> void:
	if countdown_running:
		return

	countdown_running = true

	var duration := 10.0
	var time_left := duration

	while time_left > 0.0:
		time_left -= get_process_delta_time()

		var danger := 1.0 - (time_left / duration)
		danger = clampf(danger, 0.0, 1.0)

		if is_instance_valid(darkness_sprite):
			if darkness_sprite.material is ShaderMaterial:
				darkness_sprite.material.set_shader_parameter(
					"danger",
					danger
				)

		await get_tree().process_frame

	if is_instance_valid(darkness_sprite):
		if darkness_sprite.material is ShaderMaterial:
			darkness_sprite.material.set_shader_parameter(
				"danger",
				1.0
			)

	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.kill()

	countdown_running = false
