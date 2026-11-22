shader_type canvas_item;
render_mode unshaded;

uniform sampler2D ground_texture : source_color, filter_linear, repeat_disable;
uniform sampler2D accent_texture : source_color, filter_linear, repeat_disable;
uniform sampler2D water_texture : source_color, filter_linear, repeat_disable;
uniform vec2 saturation_contrast = vec2(0.68, 0.66);
uniform vec4 ground_tint : source_color = vec4(0.48, 0.53, 0.36, 1.0);
uniform vec2 grid_origin;
uniform vec2 cell_size;
uniform vec2 grid_size;
uniform vec2 stage_size;
uniform ivec2 water_rows = ivec2(-1);
uniform ivec2 island_columns = ivec2(-1);
uniform ivec2 deep_columns = ivec2(-1);
uniform bool moon_water;
uniform bool ember_ground;
uniform bool ice_ground;
uniform float lane_emphasis = 1.0;
uniform float water_time;
uniform float pond_bridge_x;

varying vec2 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

float value_hash(vec2 cell) {
	vec3 p = fract(vec3(cell.xyx) * 0.1031);
	p += dot(p, p.yzx + 33.33);
	return fract((p.x + p.y) * p.z);
}

float value_noise(vec2 p) {
	vec2 cell = floor(p);
	vec2 f = fract(p);
	vec2 smoothed = f * f * (3.0 - 2.0 * f);
	return mix(
		mix(value_hash(cell), value_hash(cell + vec2(1.0, 0.0)), smoothed.x),
		mix(value_hash(cell + vec2(0.0, 1.0)), value_hash(cell + vec2(1.0, 1.0)), smoothed.x),
		smoothed.y);
}

vec2 mirrored_uv(vec2 p) {
	return 1.0 - abs(fract(p * 0.5) * 2.0 - 1.0);
}

float segment_distance(vec2 point, vec2 start, vec2 end) {
	vec2 axis = end - start;
	float ratio = clamp(dot(point - start, axis) / dot(axis, axis), 0.0, 1.0);
	return length(point - start - axis * ratio);
}

void fragment() {
	vec2 p = world_position;
	vec2 board = (p - grid_origin) / cell_size;
	float path_noise = value_noise(p / vec2(330.0, 138.0) + vec2(8.5, 2.0));
	float detail = value_noise(p / 34.0 + vec2(7.0, 2.0));
	vec2 warp = vec2(detail, path_noise) * 24.0;
	vec3 ground = texture(ground_texture, mirrored_uv((p + warp) / vec2(176.0, 146.0))).rgb;
	vec3 offset_ground = texture(ground_texture, mirrored_uv((p.yx - warp) / vec2(229.0, 192.0) + vec2(0.39, 0.61))).rgb;
	ground = mix(ground, offset_ground, mix(0.13, 0.46, path_noise));
	vec3 accent = texture(accent_texture, mirrored_uv((p - warp) / vec2(186.0, 151.0) + vec2(0.28, 0.46))).rgb;

	// Broad irregular patches continue across the grid and into the side gardens.
	float patch = smoothstep(0.42, 0.69, path_noise + (detail - 0.5) * 0.24);
	vec3 rgb = mix(ground, accent, patch * 0.86);
	float luminance = dot(rgb, vec3(0.2126, 0.7152, 0.0722));
	rgb = mix(vec3(luminance), rgb, saturation_contrast.x);
	rgb = mix(ground_tint.rgb, rgb, saturation_contrast.y);
	rgb *= 0.96 + path_noise * 0.075 + detail * 0.035;

	if (water_rows.x >= 0) {
		float water_y = grid_origin.y + (float(water_rows.x) + 0.5) * cell_size.y;
		float west_bank_x = grid_origin.x - 41.0;
		float east_bank_x = grid_origin.x + grid_size.x * cell_size.x + 152.0;
		float bank_distance = segment_distance(p, vec2(west_bank_x, water_y), vec2(east_bank_x, water_y));
		if (water_rows.y >= 0) {
			float second_y = grid_origin.y + (float(water_rows.y) + 0.5) * cell_size.y;
			bank_distance = min(bank_distance, segment_distance(p, vec2(west_bank_x, second_y), vec2(east_bank_x, second_y)));
		}
		if (moon_water) {
			float inlet = segment_distance(p, vec2(pond_bridge_x, water_y - 77.0), vec2(pond_bridge_x, water_y)) + 22.0;
			float join_water = segment_distance(p, vec2(pond_bridge_x, water_y), vec2(west_bank_x, water_y)) + 22.0;
			bank_distance = min(bank_distance, min(inlet, join_water));
		}
		float shore_shape = (value_noise(vec2(p.x / 51.0, 4.6)) - 0.5) * 7.0;
		float bank = bank_distance + shore_shape;
		float island = 0.0;
		if (island_columns.x >= 0) {
			float left = float(island_columns.x);
			float right = float(island_columns.y);
			island = smoothstep(left - 0.12, left + 0.12, board.x) * (1.0 - smoothstep(right - 0.12, right + 0.12, board.x));
			rgb = mix(rgb, rgb * 0.87 + vec3(0.11, 0.09, 0.06), island * (1.0 - smoothstep(24.0, 42.0, bank)));
		}
		float wet_ground = (1.0 - smoothstep(43.0, 60.0, bank)) * (1.0 - island);
		rgb *= 1.0 - 0.18 * wet_ground;
		if (bank < 50.0) {
			vec2 flow = vec2(water_time * 8.0, sin(p.x * 0.018 + water_time) * 3.5);
			vec3 surface = texture(water_texture, mirrored_uv((p + warp + flow) / vec2(229.0, 115.0))).rgb;
			vec3 water = mix(vec3(0.09, 0.24, 0.28), surface, 0.35);
			water += vec3(0.14, 0.16, 0.14) * smoothstep(36.0, 48.0, bank);
			if (deep_columns.x >= 0) {
				float deep = min(abs(board.x - float(deep_columns.x) - 0.5), abs(board.x - float(deep_columns.y) - 0.5));
				water *= mix(0.64, 1.0, smoothstep(0.26, 0.54, deep));
			}
			if (moon_water) {
				float gleam = exp(-pow((p.x - stage_size.x * 0.67 + flow.y * 4.0) / 105.0, 2.0));
				float ripples = smoothstep(0.48, 0.89, value_noise(p / vec2(43.0, 5.0) + vec2(water_time * 0.6, 0.0)));
				water += vec3(0.25, 0.25, 0.16) * gleam * ripples;
			}
			rgb = mix(water, rgb, max(island, smoothstep(41.0, 49.0, bank)));
		}
	}

	if (ember_ground) {
		float apron_light = smoothstep(7.5, 10.6, board.x) * (0.31 + path_noise * 0.32);
		rgb += vec3(0.15, 0.047, 0.017) * apron_light;
	}

	if (ice_ground) {
		vec2 crystal = p / 45.0;
		vec2 cell = floor(crystal);
		float id = value_hash(cell);
		vec2 offset = vec2(id, value_hash(cell + 17.0)) * 0.64 + 0.18;
		vec2 ray = abs(fract(crystal) - offset);
		float shape = 1.0 - smoothstep(0.017, 0.044, min(ray.x + ray.y * 2.9, ray.y + ray.x * 2.9));
		float twinkle = smoothstep(0.94, 0.998, sin(id * 31.4 + TIME * 1.15));
		rgb += vec3(0.16, 0.22, 0.24) * shape * twinkle;
	}

	if (all(greaterThanEqual(board, vec2(0.0))) && all(lessThanEqual(board, grid_size))) {
		// Low-contrast lane edges and short corner marks suggest the playable cells.
		vec2 edge = abs(fract(board + vec2(0.5)) - 0.5) * cell_size;
		float lane_edge = 1.0 - smoothstep(0.0, 2.4, edge.y);
		float corner = (1.0 - smoothstep(0.0, 1.8, edge.x)) * (1.0 - smoothstep(2.0, 8.0, edge.y));
		rgb = mix(rgb, ground_tint.rgb * 0.49, (lane_edge * 0.20 + corner * 0.30) * lane_emphasis);
	}
	// The extra apron in wide or tall windows recedes into the seasonal palette.
	float apron_distance = max(max(-p.x, p.x - stage_size.x), p.y - stage_size.y);
	float apron = smoothstep(8.0, 340.0, apron_distance);
	rgb = mix(rgb, mix(ground_tint.rgb * 0.86, rgb * 0.92, 0.46), apron);
	COLOR = vec4(rgb, 1.0);
}
