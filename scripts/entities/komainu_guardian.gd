extends Node2D
class_name KomainuGuardian

## Last line of defense stone lion-dog statue on the left edge of each lane.
## Triggers once per lane when an enemy breaches column 0, sweeping all enemies in that lane.

const BODY_ATLAS := preload("res://scripts/entities/body_atlas.gd")

var lane: int = 0
var active: bool = false
var spent: bool = false

var _battle: Node = null
var _sprite: Sprite2D
var _wake_timer: float = 0.0
var _frame_accum: float = 0.0
var _dash_frame: int = 6
var _speed: float = 580.0


func setup(battle_ref: Node, p_lane: int, start_pos: Vector2) -> void:
	_battle = battle_ref
	lane = p_lane
	position = start_pos
	z_index = 25 + lane * 2

	_sprite = Sprite2D.new()
	BODY_ATLAS.set_sheet(_sprite, preload("res://assets/sprites/props/prop_komainu_dash.png"), Vector2i(4, 3))
	_sprite.scale = Vector2(0.74, 0.74)
	_sprite.position.y = GameData.LANE_CONTACT_OFFSET
	add_child(_sprite)


func _draw() -> void:
	draw_set_transform(Vector2(0.0, GameData.LANE_CONTACT_OFFSET), 0.0, Vector2(1.0, 0.34))
	draw_circle(Vector2.ZERO, 26.0, Color(0.0, 0.0, 0.0, 0.24))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func trigger() -> void:
	if active or spent:
		return
	active = true
	spent = true
	_wake_timer = 0.0
	AudioManager.play_sfx("komainu_roar", -3.0)


func _process(delta: float) -> void:
	if not active:
		return

	if _wake_timer < 0.24:
		_wake_timer += delta
		var idx := clampi(1 + int((_wake_timer / 0.24) * 4.0), 1, 5)
		if _sprite:
			_sprite.frame = idx
		return

	position.x += _speed * delta
	_frame_accum += delta * 15.0
	while _frame_accum >= 1.0:
		_frame_accum -= 1.0
		_dash_frame = 6 + ((_dash_frame - 6 + 1) % 6)
		if _sprite:
			_sprite.frame = _dash_frame

	if _battle:
		var enemies: Array = _battle.get_enemies_in_lane(lane)
		for enemy in enemies:
			if not is_instance_valid(enemy) or enemy.is_dying():
				continue
			if enemy.position.x <= position.x + 48.0 and enemy.position.x >= position.x - 140.0:
				enemy.take_damage(99999.0, true)
				_battle.spawn_vfx("res://assets/sprites/fx/fx_hit_spark.png", Vector2i(4, 3), enemy.position + Vector2(0, -10), 20.0, 0.7)

	if position.x > 1340.0:
		queue_free()
