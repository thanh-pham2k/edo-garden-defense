extends Node2D
class_name SpiritFlame

## Collectible Spirit Flame orb dropped from sky or produced by Thần Đèn.
## Supports mouse click/hover, touch tap/swipe, and optional auto-collection.

var amount: int = 25
var collected: bool = false

var _battle: Node = null
var _sprite: Sprite2D
var _target_ground_pos: Vector2 = Vector2.ZERO
var _frame_accum: float = 0.0
var _frame_idx: int = 0
var _age: float = 0.0
var _landed: bool = false
var _drop_speed: float = 64.0
var _pop_elapsed: float = 0.0
var _pop_start: Vector2 = Vector2.ZERO
var _is_sky_drop: bool = false


func setup(
	battle_ref: Node,
	start_pos: Vector2,
	ground_pos: Vector2,
	p_amount: int = 25,
	sky_drop: bool = false
) -> void:
	_battle = battle_ref
	position = start_pos
	_pop_start = start_pos
	_target_ground_pos = ground_pos
	amount = p_amount
	_is_sky_drop = sky_drop
	z_index = 95

	_sprite = Sprite2D.new()
	_sprite.texture = load("res://assets/sprites/ui/ui_spirit_flame_anim.png") as Texture2D
	_sprite.hframes = 3
	_sprite.vframes = 2
	_sprite.frame = 0
	_sprite.scale = Vector2(0.56, 0.56)
	add_child(_sprite)


func is_point_inside(world_pos: Vector2) -> bool:
	return not collected and world_pos.distance_to(position) <= 46.0


func collect() -> void:
	if collected:
		return
	collected = true
	AudioManager.play_sfx("collect_flame", -6.0)
	var hud_target := position
	if is_instance_valid(_battle):
		_battle.add_flame(amount)
		hud_target = _battle.get_flame_hud_target()
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "position", hud_target, 0.36).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(self, "scale", Vector2(0.45, 0.45), 0.36)
	tw.tween_property(self, "modulate:a", 0.25, 0.36)
	tw.chain().tween_callback(queue_free)


func _process(delta: float) -> void:
	_frame_accum += delta * 11.0
	if _frame_accum >= 1.0:
		var elapsed_frames := int(_frame_accum)
		_frame_accum -= float(elapsed_frames)
		_frame_idx = (_frame_idx + elapsed_frames) % 6
		if _sprite:
			_sprite.frame = _frame_idx

	if collected:
		return

	_age += delta
	if not _landed:
		if _is_sky_drop:
			position.y += _drop_speed * delta
			if position.y >= _target_ground_pos.y:
				position.y = _target_ground_pos.y
				_landed = true
				_age = 0.0
		else:
			_pop_elapsed += delta
			var t := clampf(_pop_elapsed / 0.55, 0.0, 1.0)
			var base := _pop_start.lerp(_target_ground_pos, t)
			base.y -= sin(t * PI) * 44.0
			position = base
			if t >= 1.0:
				_landed = true
				_age = 0.0
	else:
		if _sprite:
			_sprite.position.y = sin(_age * 3.8) * 4.5
		if GameData.auto_collect_flame and _age >= 3.6:
			collect()
			return
		if _age >= 11.0:
			modulate.a = clampf(1.0 - (_age - 11.0) / 1.0, 0.0, 1.0)
			if _age >= 12.0:
				queue_free()
