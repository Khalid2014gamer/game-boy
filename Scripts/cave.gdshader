shader_type canvas_item;

uniform float radius = 0.025;
uniform float softness = 0.0;

void fragment() {
    vec2 center = vec2(0.5, 0.5);

    float distance_from_player = distance(UV, center);

    float darkness = smoothstep(
        radius - softness,
        radius + softness,
        distance_from_player
    );

    COLOR = vec4(0.0, 0.0, 0.0, darkness);
}