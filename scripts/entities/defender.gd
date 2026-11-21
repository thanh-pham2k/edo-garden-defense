extends Node2D
class_name Defender

## Base defender controller handling all 10 Edo Garden Defense units.

const BODY_ATLAS := preload("res://scripts/entities/body_atlas.gd")
const HEALTH_BAR := preload("res://scripts/entities/health_bar.gd")

var defender_id: String = "dao_tien"
var row: int = 0
var col: int = 0
var max_hp: float = 320.0
var hp: float = 320.0
var cost: int = 100
var damage: float = 24.0
var attack_interval: float = 1.35

var frozen_timer: float = 0.0
var is_consuming: bool = false

var _battle: Node = null
var _data: Dictionary = {}
var _sprite: Sprite2D
var _health_bar: Node2D
var _frost_sprite: Sprite2D
var _idle_tex: Texture2D
var _action_tex: Texture2D
var _idle_grid: Vector2i = Vector2i(3, 2)
var _action_grid: Vector2i = Vector2i(4, 3)

var _state: String = "idle" # "idle", "action", "consume"
var _action_timer: float = 0.0
var _frame_accum: float = 0.0
var _frame_idx: int = 0
var _action_fired: bool = false
var _double_shot_fired: bool = false
var _hit_flash: float = 0.0
var _age: float = 0.0


func setup(battle_ref: Node, p_id: String, p_row: int, p_col: int, world_pos: Vector2) -> void:
	_battle = battle_ref
	defender_id = p_id
	row = p_row
	col = p_col
	position = world_pos
	z_index = 20 + row * 2

	_data = GameData.DEFENDERS[p_id]
	var hp_mult := 1.0 if (p_id == "phao_hoa" or p_id == "phu_chu") else GameData.get_defender_hp_mult()
	max_hp = float(_data.get("hp", 320.0)) * hp_mult
	hp = max_hp
	cost = int(_data.get("cost", 100))
	damage = float(_data.get("damage", 0.0))
	attack_interval = float(_data.get("attack_interval", 1.5))

	_idle_tex = load(_data["idle_sheet"]) as Texture2D
	_action_tex = load(_data["action_sheet"]) as Texture2D
	_idle_grid = _data["idle_grid"]
	_action_grid = _data["action_grid"]

	_sprite = Sprite2D.new()
	BODY_ATLAS.set_sheet(_sprite, _idle_tex, _idle_grid)
	_sprite.scale = Vector2(0.74, 0.74)
	_sprite.position.y = GameData.LANE_CONTACT_OFFSET
	add_child(_sprite)

	_frost_sprite = Sprite2D.new()
	_frost_sprite.texture = load("res://assets/sprites/fx/fx_freeze_overlay.png") as Texture2D
	_frost_sprite.hframes = 4
	_frost_sprite.vframes = 3
	_frost_sprite.frame = 5
	_frost_sprite.scale = Vector2.ONE * 0.53
	_frost_sprite.position.y = GameData.LANE_CONTACT_OFFSET - 25.0
	_frost_sprite.hide()
	_frost_sprite.modulate.a = 0.66
	_frost_sprite.show_behind_parent = true
	add_child(_frost_sprite)

	if defender_id not in ["phao_hoa", "phu_chu"]:
		_health_bar = HEALTH_BAR.new()
		_health_bar.position.y = -53.0
		_health_bar.fill_color = Color(0.28, 0.87, 0.47)
		add_child(_health_bar)

	# Slight random phase offset so idle plants don't sway in robotic unison
	_age = randf() * TAU
	# First action triggers slightly sooner so newly planted defenders feel responsive
	if defender_id == "than_den":
		_action_timer = attack_interval - float(_data["first_action_delay"])
	elif defender_id == "phao_hoa":
		_action_timer = 0.0
	else:
		_action_timer = attack_interval * 0.45


func take_damage(amount: float) -> void:
	if is_consuming or hp <= 0.0:
		return
	if defender_id == "phao_hoa" or defender_id == "phu_chu":
		return
	hp -= amount
	_hit_flash = 0.14
	_health_bar.set_health_ratio(hp / max_hp)
	if hp <= 0.0:
		hp = 0.0
		if _battle:
			_battle.spawn_vfx("res://assets/sprites/fx/fx_smoke_puff.png", Vector2i(4, 3), position + Vector2(0, -8), 18.0, 0.62)
			_battle.remove_defender(self)
		queue_free()


func heal(amount: float) -> void:
	if is_consuming or hp <= 0.0:
		return
	hp = minf(max_hp, hp + amount)
	frozen_timer = 0.0
	if _frost_sprite:
		_frost_sprite.visible = false
	if _health_bar:
		_health_bar.set_health_ratio(hp / max_hp)


func apply_freeze(duration: float) -> void:
	if is_consuming or defender_id == "phao_hoa" or defender_id == "phu_chu":
		return
	frozen_timer = maxf(frozen_timer, duration)
	if _frost_sprite:
		_frost_sprite.visible = true


func _draw() -> void:
	# Soft ground shadow
	draw_set_transform(Vector2(0.0, GameData.LANE_CONTACT_OFFSET), 0.0, Vector2(1.0, 0.34))
	draw_circle(Vector2.ZERO, 26.0, Color(0.0, 0.0, 0.0, 0.24))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _process(delta: float) -> void:
	_age += delta
	if _hit_flash > 0.0:
		_hit_flash = maxf(0.0, _hit_flash - delta)

	if frozen_timer > 0.0:
		frozen_timer = maxf(0.0, frozen_timer - delta)
		if _frost_sprite:
			_frost_sprite.visible = frozen_timer > 0.0
		if _sprite:
			_sprite.modulate = Color(0.65, 0.88, 1.0, 1.0)
		return

	if _sprite:
		if _hit_flash > 0.0:
			_sprite.modulate = Color(1.5, 1.3, 1.3, 1.0)
		else:
			_sprite.modulate = Color.WHITE

	# 60 FPS subtle squash-and-stretch breathing & wind sway
	if _sprite and _state == "idle":
		var breath := 1.0 + sin(_age * 3.1) * 0.025
		_sprite.scale = Vector2(0.74 * (2.0 - breath), 0.74 * breath)
		_sprite.rotation = sin(_age * 2.2) * 0.022

	match defender_id:
		"bi_ngo":
			_process_bi_ngo(delta)
		"phao_hoa":
			_process_phao_hoa(delta)
		"phu_chu":
			_process_phu_chu(delta)
		_:
			_process_standard_defender(delta)


func _process_bi_ngo(delta: float) -> void:
	var ratio := hp / max_hp
	if ratio > 0.66:
		_frame_accum += delta * 6.0
		while _frame_accum >= 1.0:
			_frame_accum -= 1.0
			_frame_idx = (_frame_idx + 1) % 3
			_sprite.frame = _frame_idx
	elif ratio > 0.42:
		_sprite.frame = 3
	elif ratio > 0.20:
		_sprite.frame = 4
	else:
		_sprite.frame = 5


func _process_phao_hoa(delta: float) -> void:
	_action_timer += delta
	var progress := clampf(_action_timer / attack_interval, 0.0, 1.0)
	var f_idx := clampi(int(progress * 11.0), 0, 11)
	_sprite.frame = f_idx
	var swell := 0.74 + progress * 0.16
	_sprite.scale = Vector2(swell, swell)
	if _action_timer >= attack_interval and not is_consuming:
		_detonate_phao_hoa()


func _detonate_phao_hoa() -> void:
	is_consuming = true
	AudioManager.play_sfx("explosion", -1.0)
	if _battle:
		_battle.trigger_screen_shake(9.0, 0.35)
		_battle.spawn_vfx("res://assets/sprites/defenders/phao_hoa_explode.png", Vector2i(4, 4), position + Vector2(0, -8), 20.0, 1.38)
		var enemies: Array = _battle.get_all_enemies()
		for enemy in enemies:
			if not is_instance_valid(enemy) or enemy.is_dying():
				continue
			if absf(enemy.lane - row) <= 1 and absf(enemy.position.x - position.x) <= GameData.CELL_SIZE.x * 1.7:
				enemy.take_damage(damage, true)
		for obs in _battle.get_all_obstacles():
			if is_instance_valid(obs) and not obs.is_consuming:
				if absi(obs.row - row) <= 1 and absf(obs.position.x - position.x) <= GameData.CELL_SIZE.x * 1.7:
					obs.take_damage(damage)
		_battle.remove_defender(self)
	queue_free()


func _process_phu_chu(delta: float) -> void:
	if _state == "consume":
		_frame_accum += delta * 15.0
		while _frame_accum >= 1.0:
			_frame_accum -= 1.0
			_frame_idx += 1
			if _frame_idx > 11:
				if _battle:
					_battle.remove_defender(self)
				queue_free()
				return
			_sprite.frame = _frame_idx
		return

	# Idle loop frames 0..5
	_frame_accum += delta * 9.0
	while _frame_accum >= 1.0:
		_frame_accum -= 1.0
		_frame_idx = (_frame_idx + 1) % 6
		_sprite.frame = _frame_idx

	if _battle == null:
		return
	var enemies: Array = _battle.get_enemies_in_lane(row)
	for enemy in enemies:
		if not is_instance_valid(enemy) or enemy.is_dying():
			continue
		if absf(enemy.position.x - position.x) <= GameData.CELL_SIZE.x * 1.05:
			_trigger_phu_chu()
			return


func _trigger_phu_chu() -> void:
	_state = "consume"
	is_consuming = true
	_frame_idx = 6
	_frame_accum = 0.0
	_sprite.frame = 6
	AudioManager.play_sfx("stun_chime", -3.0)
	if _battle:
		var enemies: Array = _battle.get_enemies_in_lane(row)
		for enemy in enemies:
			if not is_instance_valid(enemy) or enemy.is_dying():
				continue
			if absf(enemy.position.x - position.x) <= GameData.CELL_SIZE.x * 1.65:
				enemy.take_damage(damage, true)
				enemy.apply_stun(4.0)


func _process_standard_defender(delta: float) -> void:
	if _state == "idle":
		var idle_total := _idle_grid.x * _idle_grid.y
		_frame_accum += delta * 8.0
		while _frame_accum >= 1.0:
			_frame_accum -= 1.0
			_frame_idx = (_frame_idx + 1) % idle_total
			_sprite.frame = _frame_idx

		_action_timer += delta
		if _action_timer >= attack_interval and _should_trigger_action():
			_start_action()
	elif _state == "action":
		var action_total := _action_grid.x * _action_grid.y
		_frame_accum += delta * 15.0
		while _frame_accum >= 1.0:
			_frame_accum -= 1.0
			_frame_idx += 1
			if not _action_fired and _frame_idx >= 4:
				_action_fired = true
				_execute_action_effect()
			if defender_id == "tre_no" and not _double_shot_fired and _frame_idx >= 7:
				_double_shot_fired = true
				_fire_projectile("dart", damage)
			if _frame_idx >= action_total:
				_end_action()
				return
			_sprite.frame = _frame_idx


func _should_trigger_action() -> bool:
	if _battle == null:
		return false
	match defender_id:
		"than_den":
			return true
		"chua_lanh":
			return _has_ally_needing_heal()
		"nam_doc":
			var rng_px := float(_data.get("range_cells", 3.8)) * GameData.CELL_SIZE.x
			for enemy in _battle.get_enemies_in_lane(row):
				if is_instance_valid(enemy) and not enemy.is_dying():
					var dx: float = enemy.position.x - position.x
					if dx >= -20.0 and dx <= rng_px:
						return true
			return false
		"gio_loc":
			var wind_rng := float(_data.get("range_cells", 5.5)) * GameData.CELL_SIZE.x
			for enemy in _battle.get_enemies_in_lane(row):
				if is_instance_valid(enemy) and not enemy.is_dying():
					var dx: float = enemy.position.x - position.x
					if dx >= -16.0 and dx <= wind_rng:
						return true
			return false
		_:
			for enemy in _battle.get_enemies_in_lane(row):
				if is_instance_valid(enemy) and not enemy.is_dying() and enemy.position.x >= position.x - 20.0:
					return true
			return false


func _has_ally_needing_heal() -> bool:
	if _battle == null:
		return false
	for ally in _battle.get_all_defenders():
		if not is_instance_valid(ally) or ally.is_consuming:
			continue
		if absi(ally.row - row) <= 1 and absi(ally.col - col) <= 1:
			if ally.hp < ally.max_hp or ally.frozen_timer > 0.0:
				return true
	return false


func _start_action() -> void:
	_state = "action"
	_action_timer = 0.0
	_frame_accum = 0.0
	_frame_idx = 0
	_action_fired = false
	_double_shot_fired = false
	BODY_ATLAS.set_sheet(_sprite, _action_tex, _action_grid)
	_sprite.scale = Vector2(0.74, 0.74)
	_sprite.rotation = 0.0


func _end_action() -> void:
	_state = "idle"
	_frame_accum = 0.0
	_frame_idx = 0
	BODY_ATLAS.set_sheet(_sprite, _idle_tex, _idle_grid)


func _execute_action_effect() -> void:
	if _battle == null:
		return
	match defender_id:
		"dao_tien":
			_fire_projectile("petal", damage)
		"tre_no":
			_fire_projectile("dart", damage)
		"ho_lo_bang":
			_fire_projectile("ice", damage)
		"than_den":
			var target := position + Vector2(randf_range(-24.0, 26.0), randf_range(8.0, 24.0))
			var amount := GameData.get_flame_value() + GameData.LANTERN_FLAME_BONUS
			_battle.spawn_spirit_flame(position + Vector2(0, -14), target, amount, false)
		"nam_doc":
			AudioManager.play_sfx("poison_puff", -6.0)
			_battle.spawn_vfx(
				"res://assets/sprites/fx/fx_poison_cloud.png",
				Vector2i(4, 3),
				position + Vector2(86.0, -8.0),
				16.0,
				1.35,
				0.0,
				Vector2(140.0, 0.0)
			)
			var rng_px := float(_data.get("range_cells", 3.8)) * GameData.CELL_SIZE.x
			for enemy in _battle.get_enemies_in_lane(row):
				if is_instance_valid(enemy) and not enemy.is_dying():
					var dx: float = enemy.position.x - position.x
					if dx >= -20.0 and dx <= rng_px:
						enemy.take_damage(damage, true)
						enemy.apply_poison(8.0, 3.0)
		"gio_loc":
			AudioManager.play_sfx("wind_gust", -4.0)
			_battle.spawn_projectile(position + Vector2(36.0, -8.0), row, "wind", damage)
		"chua_lanh":
			AudioManager.play_sfx("heal_chime", -5.0)
			for ally in _battle.get_all_defenders():
				if not is_instance_valid(ally) or ally.is_consuming:
					continue
				if absi(ally.row - row) <= 1 and absi(ally.col - col) <= 1:
					ally.heal(90.0)
					_battle.spawn_vfx("res://assets/sprites/fx/fx_heal_aura.png", Vector2i(4, 3), ally.position + Vector2(0, -8), 16.0, 0.8)


func _fire_projectile(kind: String, dmg: float) -> void:
	if _battle == null:
		return
	match kind:
		"petal":
			AudioManager.play_sfx("shoot_petal", -10.0)
		"dart":
			AudioManager.play_sfx("shoot_dart", -10.0)
		"ice":
			AudioManager.play_sfx("shoot_ice", -9.0)
	_battle.spawn_projectile(position + Vector2(28.0, -16.0), row, kind, dmg)
