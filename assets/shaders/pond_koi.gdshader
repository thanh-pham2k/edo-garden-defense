shader_type canvas_item;
render_mode unshaded;

varying vec4 tint;

void vertex() {
	tint = COLOR;
}

void fragment() {
	// The source atlas paints orange and cream koi on blue water.
	// Keep the warm shapes so the water surface stays continuous beneath them.
	vec4 source_pixel = texture(TEXTURE, UV);
	float fish = smoothstep(0.015, 0.14, source_pixel.r - source_pixel.b);
	COLOR = vec4(source_pixel.rgb * tint.rgb, source_pixel.a * fish * tint.a);
}
