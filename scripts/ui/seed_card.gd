extends Control
class_name SeedCard

## Interactive defender seed card supporting Tap-Select, Drag-and-Drop, and Cooldown visuals.

signal card_pressed(defender_id: String, index: int)
signal card_drag_started(defender_id: String, index: int, global_pos: Vector2)

var defender_id: String = ""
var card_index: int = 0
var cost: int = 100
var cooldown_total: float = 7.0
var cooldown_left: float = 0.0
var is_selected: bool = false
var can_afford: bool = false

var _bg_rect: TextureRect
var _icon_rect: TextureRect
var _cooldown_mask: ColorRect
var _cost_label: Label
var _hotkey_label: Label

var _tex_ready: Texture2D
var _tex_selected: Texture2D
var _tex_disabled: Texture2D

var _pointer_down: bool = false
var _press_pos: Vector2 = Vector2.ZERO
var _drag_triggered: bool = false


func setup(p_id: String, p_idx: int) -> void:
	defender_id = p_id
	card_index = p_idx
	var data: Dictionary = GameData.DEFENDERS[p_id]
	cost = int(data["cost"])
	cooldown_total = float(data["cooldown"]) * GameData.get_cooldown_mult()
	cooldown_left = 0.0

	custom_minimum_size = Vector2(74.0, 92.0)
	size = Vector2(74.0, 92.0)
	mouse_filter = Control.MOUSE_FILTER_STOP
	tooltip_text = "%s (%d) — %s" % [data["name"], cost, data["desc"]]

	_tex_ready = load("res://assets/sprites/ui/ui_card_ready.png") as Texture2D
	_tex_selected = load("res://assets/sprites/ui/ui_card_selected.png") as Texture2D
	_tex_disabled = load("res://assets/sprites/ui/ui_card_disabled.png") as Texture2D

	_bg_rect = TextureRect.new()
	_bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_bg_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_bg_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bg_rect.texture = _tex_ready
	add_child(_bg_rect)

	_icon_rect = TextureRect.new()
	_icon_rect.position = Vector2(12.0, 17.0)
	_icon_rect.size = Vector2(50.0, 48.0)
	_icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_icon_rect.texture = load(data["icon"]) as Texture2D
	add_child(_icon_rect)

	_cooldown_mask = ColorRect.new()
	_cooldown_mask.color = Color(0.05, 0.04, 0.08, 0.62)
	_cooldown_mask.position = Vector2(7.0, 10.0)
	_cooldown_mask.size = Vector2(60.0, 0.0)
	_cooldown_mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cooldown_mask.visible = false
	add_child(_cooldown_mask)

	_cost_label = Label.new()
	_cost_label.text = str(cost)
	_cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_cost_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_cost_label.position = Vector2(12.0, 71.0)
	_cost_label.size = Vector2(50.0, 18.0)
	_cost_label.add_theme_font_size_override("font_size", 13)
	_cost_label.add_theme_color_override("font_color", Color(0.24, 0.12, 0.04))
	_cost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_cost_label)

	_hotkey_label = Label.new()
	_hotkey_label.text = str(card_index + 1)
	_hotkey_label.position = Vector2(8.0, 8.0)
	_hotkey_label.size = Vector2(18.0, 16.0)
	_hotkey_label.add_theme_font_size_override("font_size", 10)
	_hotkey_label.add_theme_color_override("font_color", Color(0.38, 0.22, 0.08, 0.85))
	_hotkey_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_hotkey_label)

	_refresh_visual()


func is_ready_to_plant(current_flame: int) -> bool:
	return cooldown_left <= 0.0 and current_flame >= cost


func start_cooldown() -> void:
	cooldown_left = cooldown_total
	is_selected = false
	_refresh_visual()


func update_state(delta: float, current_flame: int, selected: bool) -> void:
	if cooldown_left > 0.0:
		cooldown_left = maxf(0.0, cooldown_left - delta)
	can_afford = current_flame >= cost
	is_selected = selected
	_refresh_visual()


func _refresh_visual() -> void:
	if _bg_rect == null:
		return
	var ready := cooldown_left <= 0.0 and can_afford
	if is_selected and ready:
		_bg_rect.texture = _tex_selected
		scale = Vector2(1.05, 1.05)
	elif ready:
		_bg_rect.texture = _tex_ready
		scale = Vector2.ONE
	else:
		_bg_rect.texture = _tex_disabled
		scale = Vector2.ONE

	_icon_rect.modulate = Color.WHITE if ready else Color(0.7, 0.7, 0.75, 0.85)
	_cost_label.add_theme_color_override(
		"font_color",
		Color(0.22, 0.10, 0.04) if can_afford else Color(0.75, 0.12, 0.12)
	)

	if cooldown_left > 0.0:
		var ratio := clampf(cooldown_left / maxf(0.1, cooldown_total), 0.0, 1.0)
		_cooldown_mask.visible = true
		_cooldown_mask.size = Vector2(60.0, 66.0 * ratio)
	else:
		_cooldown_mask.visible = false


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_pointer_down = true
			_drag_triggered = false
			_press_pos = event.global_position
		else:
			if _pointer_down and not _drag_triggered:
				card_pressed.emit(defender_id, card_index)
			_pointer_down = false
			_drag_triggered = false
	elif event is InputEventMouseMotion and _pointer_down and not _drag_triggered:
		if event.global_position.distance_to(_press_pos) >= 10.0:
			_drag_triggered = true
			card_drag_started.emit(defender_id, card_index, event.global_position)
