
shader_type canvas_item;

uniform float radius = 0.10;
uniform float softness = 0.025;

uniform vec4 darkness_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

// Timer danger: 0.0 = safe, 1.0 = danger
uniform float danger : hint_range(0.0, 1.0) = 0.0;

// Normal danger pulsing
uniform float base_pulse_speed = 0.8;
uniform float extra_pulse_speed = 1.2;

uniform float base_pulse_amount = 0.003;
uniform float extra_pulse_amount = 0.006;

// Gold pickup effect
uniform float pickup_scale : hint_range(0.0, 1.0) = 0.0;


void fragment() {
	vec2 center = vec2(0.5, 0.5);

	float danger_level = clamp(danger, 0.0, 1.0);
	float flash = clamp(pickup_scale, 0.0, 1.0);

	// Make pulsing faster as danger increases
	float pulse_speed = mix(
		base_pulse_speed,
		extra_pulse_speed,
		danger_level
	);

	float pulse_amount = mix(
		base_pulse_amount,
		extra_pulse_amount,
		danger_level
	);

	// Gentle breathing effect
	float animated_radius = radius
		+ sin(TIME * pulse_speed) * pulse_amount;

	// Shrink slightly as danger increases
	animated_radius -= danger_level * 0.008;

	// Grow outward when gold is collected
	animated_radius *= 1.0 + flash * 0.35;

	// Calculate distance from the center
	float distance_from_center = distance(UV, center);

	// Create the circular light
	float darkness = smoothstep(
		animated_radius - softness,
		animated_radius + softness,
		distance_from_center
	);

	// Normal darkness opacity
	float darkness_alpha = mix(
		darkness_color.a * 0.75,
		darkness_color.a,
		danger_level
	);

	// Make the darkness briefly disappear for a bright flash
	darkness_alpha *= 1.0 - flash * 0.85;
	darkness_alpha = clamp(darkness_alpha, 0.0, 1.0);

	COLOR = vec4(
		darkness_color.rgb,
		darkness * darkness_alpha
	);
}
