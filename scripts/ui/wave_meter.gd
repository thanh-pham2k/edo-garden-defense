extends Control

const FRAME := preload("res://assets/sprites/ui/ui_wave_bar.png")
const ONI := preload("res://assets/sprites/ui/ui_oni_head.png")
# Interior of the painted frame, in source texture pixels.
const CHANNEL := Rect2(70, 33, 402, 68)

var _track := StyleBoxFlat.new()
var _fill := StyleBoxFlat.new()
var _wave_count := 0
var _target_ratio := 0.0
var _tween: Tween
var _ratio := 0.0:
	set(value):
		_ratio = value
		queue_redraw()


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_track.bg_color = Color("#392420")
	_track.border_color = Color("#814e29")
	_track.set_border_width_all(1)
	_track.set_corner_radius_all(10)
	_fill.bg_color = Color("#4d8e72")
	_fill.border_color = Color("#8cb784")
	_fill.set_border_width_all(1)
	_fill.set_corner_radius_all(8)


func set_wave(wave: int, total: int) -> void:
	if _wave_count != total:
		_wave_count = total
		queue_redraw()
	var next := clampf(float(wave) / total, 0.0, 1.0) if total > 0 else 0.0
	if is_equal_approx(next, _target_ratio):
		return
	_target_ratio = next
	if _tween:
		_tween.kill()
	_tween = create_tween().set_ignore_time_scale(true)
	_tween.tween_property(self, "_ratio", next, 0.24).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _draw() -> void:
	var artwork_size := FRAME.get_size()
	var fit := minf(size.x / artwork_size.x, size.y / artwork_size.y)
	var artwork := Rect2((size - artwork_size * fit) * 0.5, artwork_size * fit)
	draw_texture_rect(FRAME, artwork, false, Color("#dfc297"))

	var channel := Rect2(artwork.position + CHANNEL.position * fit, CHANNEL.size * fit)
	draw_style_box(_track, channel)
	var filled := channel.grow(-2.0)
	filled.size.x *= _ratio
	if filled.size.x > 0.0:
		draw_style_box(_fill, filled)
		if filled.size.x > 14.0:
			var shine := filled.position + Vector2(7.0, 4.0)
			draw_line(shine, shine + Vector2(filled.size.x - 14.0, 0), Color("#b5d294"), 1.0, true)

	var inner := channel.grow(-3.0)
	for wave in range(1, _wave_count):
		var x := lerpf(inner.position.x, inner.end.x, float(wave) / _wave_count)
		var foot := Vector2(x, inner.end.y)
		draw_line(foot - Vector2(0, 4), foot - Vector2(0, 1), Color(1, 0.85, 0.62, 0.32), 1.0, true)

	if _ratio > 0.0:
		var diameter := minf(channel.size.y - 1.0, 19.0)
		var center_x := clampf(filled.end.x, inner.position.x + diameter * 0.5, inner.end.x - diameter * 0.5)
		var marker := Rect2(Vector2(center_x, channel.get_center().y) - Vector2.ONE * diameter * 0.5, Vector2.ONE * diameter)
		draw_texture_rect(ONI, marker, false)
