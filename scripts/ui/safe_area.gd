extends RefCounted


static func viewport_insets(window: Window) -> Vector4:
	if not (OS.has_feature("android") or OS.has_feature("ios")):
		return Vector4.ZERO
	var window_rect := Rect2i(DisplayServer.window_get_position(window.get_window_id()), window.size)
	return scaled_insets(window_rect, DisplayServer.get_display_safe_area(), window.get_visible_rect().size)


static func scaled_insets(window_rect: Rect2i, display_safe: Rect2i, viewport_size: Vector2) -> Vector4:
	var safe := window_rect.intersection(display_safe)
	if not safe.has_area():
		return Vector4.ZERO
	var ratio := viewport_size / Vector2(window_rect.size)
	var start := Vector2(safe.position - window_rect.position) * ratio
	var end := Vector2(window_rect.end - safe.end) * ratio
	return Vector4(start.x, start.y, end.x, end.y)
