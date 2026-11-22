shader_type canvas_item;
render_mode unshaded;

uniform sampler2D painted_sky : source_color, filter_linear, repeat_disable;

void fragment() {
	vec2 offset = UV - 0.5;
	float radius = length(offset);
	float globe = 1.0 - smoothstep(0.374, 0.382, radius);
	float halo = (1.0 - smoothstep(0.31, 0.50, radius)) * 0.18;
	vec2 moon_uv = offset / 0.76 + 0.5;
	vec2 source_px = vec2(332.0, 4.0) + moon_uv * vec2(199.0, 199.0);
	vec3 moon = texture(painted_sky, source_px / vec2(textureSize(painted_sky, 0))).rgb;
	COLOR = vec4(mix(vec3(0.91, 0.28, 0.17), moon, globe), max(globe, halo));
}
