extends Node2D
class_name Obstacle

## Battlefield obstacle (rock, spike barricade, wood fence, crate, haystack, explosive sake barrel).

const BODY_ATLAS := preload("res://scripts/entities/body_atlas.gd")
const HEALTH_BAR := preload("res://scripts/entities/health_bar.gd")

var obstacle_id: String = "obs_rock"
var row: int = 0
var col: int = 0
var max_hp: float = 400.0
var hp: float = 400.0
var thorns_damage: float = 0.0
var explodes_on_destroy: bool = false
var is_consuming: bool = false

var _battle: Node = null
var _sprite: Sprite2D
var _health_bar: Node2D
var _hit_flash: float = 0.0
var _aura_timer: float = 0.0


func setup(battle_ref: Node, p_id: String, p_row: int, p_col: int, world_pos: Vector2) -> void:
	_battle = battle_ref
	obstacle_id = p_id
	row = p_row
	col = p_col
	position = world_pos
	z_index = 20 + row * 2

	var data: Dictionary = GameData.OBSTACLES[p_id]
	max_hp = float(data["hp"])
	hp = max_hp
	thorns_damage = float(data.get("thorns", 0.0))
	explodes_on_destroy = bool(data.get("explodes", false))

	_sprite = Sprite2D.new()
	BODY_ATLAS.set_sheet(_sprite, load(data["sheet"]) as Texture2D, Vector2i(2, 2))
	_sprite.scale = Vector2(0.74, 0.74)
	_sprite.position.y = GameData.LANE_CONTACT_OFFSET
	add_child(_sprite)
	_health_bar = HEALTH_BAR.new()
	_health_bar.position.y = -58.0 if obstacle_id == "obs_wood_fence" else -45.0
	_health_bar.fill_color = Color(0.92, 0.60, 0.26) if explodes_on_destroy else Color(0.81, 0.78, 0.68)
	add_child(_health_bar)


func on_enemy_melee_hit(amount: float, attacker: Node = null) -> void:
	if thorns_damage > 0.0 and attacker != null and is_instance_valid(attacker) and attacker.has_method("take_damage"):
		attacker.take_damage(thorns_damage, false)
	take_damage(amount)


func take_damage(amount: float) -> void:
	if is_consuming or hp <= 0.0:
		return
	hp -= amount
	_hit_flash = 0.12
	var ratio := hp / max_hp
	if _sprite:
		if ratio > 0.66:
			_sprite.frame = 0
		elif ratio > 0.33:
			_sprite.frame = 1
		else:
			_sprite.frame = 2
	_health_bar.set_health_ratio(ratio)
	if hp <= 0.0:
		hp = 0.0
		destroy(true)


func destroy(play_effects: bool = true) -> void:
	if is_consuming:
		return
	is_consuming = true
	if _battle:
		if explodes_on_destroy and play_effects:
			AudioManager.play_sfx("explosion", -1.0)
			_battle.trigger_screen_shake(8.5, 0.32)
			_battle.spawn_vfx("res://assets/sprites/fx/fx_explosion.png", Vector2i(4, 4), position + Vector2(0, -8), 20.0, 1.25)
			for enemy in _battle.get_all_enemies():
				if is_instance_valid(enemy) and not enemy.is_dying():
					if absi(enemy.lane - row) <= 1 and absf(enemy.position.x - position.x) <= GameData.CELL_SIZE.x * 1.65:
						enemy.take_damage(480.0, true)
						enemy.apply_poison(14.0, 3.5)
						_battle.spawn_vfx("res://assets/sprites/fx/fx_burn_flame.png", Vector2i(4, 3), enemy.position + Vector2(0, -8), 16.0, 0.65, 1.2)
			_battle.spawn_spirit_flame(position + Vector2(0, -14), position + Vector2(8, 14), 25, false)
		elif obstacle_id == "obs_ice_block" and play_effects:
			_battle.spawn_vfx("res://assets/sprites/fx/fx_ice_hit_splash.png", Vector2i(4, 3), position + Vector2(0, -8), 20.0, 0.9)
			for enemy in _battle.get_all_enemies():
				if is_instance_valid(enemy) and not enemy.is_dying():
					if absi(enemy.lane - row) <= 1 and absf(enemy.position.x - position.x) <= GameData.CELL_SIZE.x * 1.65:
						enemy.apply_slow(0.40, 4.0)
		elif obstacle_id == "obs_incense_burner" and play_effects:
			AudioManager.play_sfx("heal_chime", -4.0)
			for ally in _battle.get_all_defenders():
				if is_instance_valid(ally) and not ally.is_consuming:
					if absi(ally.row - row) <= 1 and absi(ally.col - col) <= 1:
						ally.heal(120.0)
						_battle.spawn_vfx("res://assets/sprites/fx/fx_heal_aura.png", Vector2i(4, 3), ally.position + Vector2(0, -8), 16.0, 0.85)
		elif play_effects:
			_battle.spawn_vfx("res://assets/sprites/fx/fx_smoke_puff.png", Vector2i(4, 3), position + Vector2(0, -8), 24.0, 0.55)
		_battle.remove_obstacle(self)
	if play_effects and (obstacle_id == "obs_wood_fence" or obstacle_id == "obs_crate"):
		_sprite.frame = 3
		_hit_flash = 0.0
		_sprite.modulate = Color.WHITE
		_health_bar.hide()
		queue_redraw()
		var debris_fade := create_tween()
		debris_fade.tween_interval(0.32)
		debris_fade.tween_property(self, "modulate:a", 0.0, 0.28)
		debris_fade.tween_callback(queue_free)
		return
	queue_free()


func _draw() -> void:
	var shadow_color := Color(0.0, 0.0, 0.0, 0.24)
	if obstacle_id == "obs_wood_fence" and not is_consuming:
		# Each of the diagonal fence's wooden runners touches a different part of the lane.
		draw_set_transform(Vector2(-24, -23), -0.55, Vector2(0.68, 0.24))
		draw_circle(Vector2.ZERO, 26.0, shadow_color)
		draw_set_transform(Vector2(18, 14), -0.55, Vector2(0.98, 0.30))
		draw_circle(Vector2.ZERO, 26.0, shadow_color)
	else:
		draw_set_transform(Vector2(0.0, GameData.LANE_CONTACT_OFFSET), 0.0, Vector2(1.0, 0.34))
		draw_circle(Vector2.ZERO, 26.0, shadow_color)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _process(delta: float) -> void:
	if _hit_flash > 0.0:
		_hit_flash = maxf(0.0, _hit_flash - delta)
		if _sprite:
			_sprite.modulate = Color(1.5, 1.3, 1.3, 1.0) if _hit_flash > 0.0 else Color.WHITE
	if obstacle_id == "obs_cursed_lantern" and not is_consuming and _battle != null:
		_aura_timer += delta
		if _aura_timer >= 1.5:
			_aura_timer = 0.0
			for enemy in _battle.get_all_enemies():
				if is_instance_valid(enemy) and not enemy.is_dying():
					if absi(enemy.lane - row) <= 1 and absf(enemy.position.x - position.x) <= GameData.CELL_SIZE.x * 1.8:
						enemy.apply_speed_buff(1.8)
