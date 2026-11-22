shader_type canvas_item;
render_mode unshaded;

uniform sampler2D opacity_map : filter_linear, repeat_disable;
uniform float fog_time;
uniform vec3 fog_tint : source_color = vec3(0.50, 0.57, 0.65);

float vapor_hash(vec2 cell) {
	vec3 p = fract(vec3(cell.xyx) * 0.1031);
	p += dot(p, p.yzx + 33.33);
	return fract((p.x + p.y) * p.z);
}

float vapor(vec2 p) {
	vec2 cell = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(
		mix(vapor_hash(cell), vapor_hash(cell + vec2(1.0, 0.0)), f.x),
		mix(vapor_hash(cell + vec2(0.0, 1.0)), vapor_hash(cell + vec2(1.0, 1.0)), f.x),
		f.y);
}

void fragment() {
	float density = texture(opacity_map, UV).r;
	vec2 uv = UV + vec2(fog_time * 0.013, 0.0);
	float low = vapor(uv * vec2(4.0, 8.0));
	float high = vapor(uv * vec2(8.5, 21.0) + vec2(fog_time * -0.31, 4.0));
	float wisps = smoothstep(0.18, 0.80, low * 0.73 + high * 0.27);
	float bank = smoothstep(0.0, 0.07, UV.y) * (1.0 - smoothstep(0.88, 1.0, UV.y));
	vec3 tint = mix(fog_tint * 0.72, fog_tint + vec3(0.20, 0.19, 0.16), wisps);
	COLOR = vec4(tint, density * bank * (0.75 + 0.25 * wisps));
}
