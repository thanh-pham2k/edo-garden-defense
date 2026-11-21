extends Node2D

## Places a damaged unit's health bar above the combat artwork.
var fill_color := Color(1.0, 0.66, 0.32, 0.90)
var _ratio := 1.0


func _ready() -> void:
	z_as_relative = false
	z_index = 100
	hide()


func set_health_ratio(value: float) -> void:
	_ratio = clampf(value, 0.0, 1.0)
	visible = _ratio < 1.0
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-26.0, -3.0, 52.0, 6.0), Color(0.1, 0.08, 0.06, 0.82))
	draw_rect(Rect2(-25.0, -2.0, 50.0 * _ratio, 4.0), fill_color)
