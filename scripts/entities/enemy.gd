extends Node2D
class_name Enemy

## Yokai enemy controller supporting all 10 unique Yokai behaviors.

var enemy_id: String = "tieu_yeu"
var lane: int = 0
var max_hp: float = 180.0
var hp: float = 180.0
var max_armor_hp: float = 0.0
var armor_hp: float = 0.0
var base_speed: float = 30.0
var damage: float = 48.0
var attack_interval: float = 1.0
var damage_reduction: float = 0.0
var is_flying: bool = false
var is_boss: bool = false

var stun_timer: float = 0.0
var slow_timer: float = 0.0
var slow_ratio: float = 0.0
var poison_timer: float = 0.0
var poison_dps: float = 0.0

var has_vaulted: bool = false
var has_switched_lane: bool = false

var _battle: Node = null
var _data: Dictionary = {}
var _sprite: Sprite2D
var _stun_sprite: Sprite2D
var _move_tex: Texture2D
var _attack_tex: Texture2D
var _die_tex: Texture2D
var _grid: Vector2i = Vector2i(4, 3)

var _state: String = "walk" # "walk", "attack", "skill", "vault", "die"
var _frame_accum: float = 0.0
var _frame_idx: int = 0
var _attack_timer: float = 0.0
var _skill_timer: float = 0.0
var _attack_hit_done: bool = false
var _skill_done: bool = false
var _hit_flash: float = 0.0
var _blocking_defender: Node = null

var _vault_elapsed: float = 0.0
var _vault_start_x: float = 0.0
var _vault_end_x: float = 0.0


func setup(battle_ref: Node, p_id: String, p_lane: int, spawn_pos: Vector2) -> void:
	_battle = battle_ref
	enemy_id = p_id
	lane = p_lane
	position = spawn_pos
	z_index = 21 + lane * 2

	_data = GameData.ENEMIES[p_id]
	max_hp = float(_data["hp"])
	hp = max_hp
	max_armor_hp = float(_data.get("armor_hp", 0.0))
	armor_hp = max_armor_hp
	base_speed = float(_data["speed"])
	damage = float(_data["damage"])
	attack_interval = float(_data["attack_interval"])
	damage_reduction = float(_data.get("damage_reduction", 0.0))
	is_flying = bool(_data.get("is_flying", false))
	is_boss = bool(_data.get("is_boss", false))

	_move_tex = load(_data["move_sheet"]) as Texture2D
	_attack_tex = load(_data["attack_sheet"]) as Texture2D
	_die_tex = load(_data["die_sheet"]) as Texture2D
	_grid = _data["grid"]

	_sprite = Sprite2D.new()
	_sprite.texture = _move_tex
	_sprite.hframes = _grid.x
	_sprite.vframes = _grid.y
	_sprite.frame = 0
	var sc := 0.80 if is_boss else 0.76
	_sprite.scale = Vector2(sc, sc)
	_sprite.offset = Vector2(0.0, -30.0 if is_boss else -10.0)
	add_child(_sprite)

	_stun_sprite = Sprite2D.new()
	_stun_sprite.texture = load("res://assets/sprites/fx/fx_stun_stars.png") as Texture2D
	_stun_sprite.hframes = 4
	_stun_sprite.vframes = 3
	_stun_sprite.frame = 0
	_stun_sprite.scale = Vector2(0.55, 0.55)
	_stun_sprite.position = Vector2(0.0, -64.0 if is_boss else -42.0)
	_stun_sprite.visible = false
	add_child(_stun_sprite)

	_skill_timer = randf_range(2.5, 4.5)


func is_dying() -> bool:
	return _state == "die"


func take_damage(amount: float, armor_piercing: bool = false) -> void:
	if is_dying():
		return
	var eff := amount
	if not armor_piercing and damage_reduction > 0.0:
		eff *= (1.0 - damage_reduction)

	if not armor_piercing and armor_hp > 0.0:
		var absorbed := minf(armor_hp, eff)
		armor_hp -= absorbed
		eff -= absorbed

	hp -= eff
	_hit_flash = 0.12
	queue_redraw()
	if hp <= 0.0:
		hp = 0.0
		_start_die()


func apply_slow(ratio: float, duration: float) -> void:
	if is_dying():
		return
	slow_ratio = maxf(slow_ratio, ratio)
	slow_timer = maxf(slow_timer, duration)


func apply_stun(duration: float) -> void:
	if is_dying():
		return
	stun_timer = maxf(stun_timer, duration)
	if _stun_sprite:
		_stun_sprite.visible = true


func apply_poison(dps: float, duration: float) -> void:
	if is_dying():
		return
	poison_dps = maxf(poison_dps, dps)
	poison_timer = maxf(poison_timer, duration)


func knockback(pixels: float) -> void:
	if is_dying():
		return
	var kb := pixels * (0.45 if is_boss else 1.0)
	position.x = minf(1195.0, position.x + kb)


func ground_from_wind() -> void:
	is_flying = false
	has_vaulted = true
	if _sprite:
		_sprite.position.y = 0.0


func _start_die() -> void:
	_state = "die"
	_frame_accum = 0.0
	_frame_idx = 0
	if _stun_sprite:
		_stun_sprite.visible = false
	_sprite.texture = _die_tex
	_sprite.hframes = _grid.x
	_sprite.vframes = _grid.y
	_sprite.frame = 0
	AudioManager.play_sfx("enemy_die", -7.0)
	if _battle:
		_battle.on_enemy_killed(self)


func _set_anim(tex: Texture2D) -> void:
	if _sprite.texture != tex:
		_sprite.texture = tex
		_sprite.hframes = _grid.x
		_sprite.vframes = _grid.y
		_frame_idx = 0
		_frame_accum = 0.0
		_sprite.frame = 0


func _draw() -> void:
	if is_dying():
		return
	# Shadow
	draw_set_transform(Vector2(0.0, 30.0), 0.0, Vector2(1.0, 0.34))
	draw_circle(Vector2.ZERO, 34.0 if is_boss else 25.0, Color(0.0, 0.0, 0.0, 0.26))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# HP bar (shown when damaged or boss)
	var bar_w := 76.0 if is_boss else 52.0
	var bar_y := -66.0 if is_boss else -43.0
	if hp < max_hp or is_boss:
		var ratio := clampf(hp / max_hp, 0.0, 1.0)
		draw_rect(Rect2(Vector2(-bar_w * 0.5, bar_y), Vector2(bar_w, 6.0)), Color(0.08, 0.06, 0.06, 0.82))
		draw_rect(Rect2(Vector2(-bar_w * 0.5 + 1, bar_y + 1), Vector2((bar_w - 2.0) * ratio, 4.0)), Color(0.92, 0.24, 0.24))

	if max_armor_hp > 0.0 and armor_hp > 0.0:
		var ar := clampf(armor_hp / max_armor_hp, 0.0, 1.0)
		draw_rect(Rect2(Vector2(-bar_w * 0.5, bar_y - 7.0), Vector2(bar_w, 5.0)), Color(0.08, 0.06, 0.06, 0.82))
		draw_rect(Rect2(Vector2(-bar_w * 0.5 + 1, bar_y - 6.0), Vector2((bar_w - 2.0) * ar, 3.0)), Color(0.96, 0.80, 0.22))


func _process(delta: float) -> void:
	if _state == "die":
		var total_die := _grid.x * _grid.y
		_frame_accum += delta * 15.0
		while _frame_accum >= 1.0:
			_frame_accum -= 1.0
			_frame_idx += 1
			if _frame_idx >= total_die:
				queue_free()
				return
			_sprite.frame = _frame_idx
		return

	if _hit_flash > 0.0:
		_hit_flash = maxf(0.0, _hit_flash - delta)

	if poison_timer > 0.0:
		poison_timer = maxf(0.0, poison_timer - delta)
		take_damage(poison_dps * delta, true)
		if is_dying():
			return

	if slow_timer > 0.0:
		slow_timer = maxf(0.0, slow_timer - delta)
		if slow_timer == 0.0:
			slow_ratio = 0.0

	if _sprite:
		if _hit_flash > 0.0:
			_sprite.modulate = Color(1.6, 1.3, 1.3, 1.0)
		elif slow_timer > 0.0:
			_sprite.modulate = Color(0.58, 0.84, 1.05, 1.0)
		elif poison_timer > 0.0:
			_sprite.modulate = Color(0.86, 0.65, 1.05, 1.0)
		else:
			_sprite.modulate = Color.WHITE

	if stun_timer > 0.0:
		stun_timer = maxf(0.0, stun_timer - delta)
		if _stun_sprite:
			_stun_sprite.visible = stun_timer > 0.0
			var sf := int(Time.get_ticks_msec() / 70.0) % 12
			_stun_sprite.frame = sf
		return
	elif _stun_sprite and _stun_sprite.visible:
		_stun_sprite.visible = false

	var speed_mult := 1.0 - slow_ratio
	var anim_fps := 13.5 * speed_mult

	if _state == "vault":
		_process_vault(delta)
		return

	if _state == "skill":
		_process_skill_anim(delta, anim_fps)
		return

	# Check special active skills (Miko Ma summon, Yuki-onna freeze cast)
	if _try_special_skill(delta):
		return

	# Check if a defender blocks our path in this lane
	_blocking_defender = _find_blocking_defender()
	if _blocking_defender != null:
		# Tengu flying leap over first blocking defender
		if enemy_id == "tengu" and is_flying and not has_vaulted:
			_start_vault(_blocking_defender.position.x - GameData.CELL_SIZE.x * 0.72)
			return
		# Rắn Ống switches lane once when blocked by a high-HP wall (Bí Ngô)
		if enemy_id == "ran_ong" and not has_switched_lane and _blocking_defender.max_hp > 400.0:
			if _switch_adjacent_lane():
				return
		_process_melee_attack(delta, anim_fps)
	else:
		_process_walk(delta, speed_mult, anim_fps)


func _find_blocking_defender() -> Node:
	if _battle == null:
		return null
	var best: Node = null
	var best_x := -9999.0
	for def in _battle.get_defenders_in_lane(lane):
		if not is_instance_valid(def) or def.is_consuming:
			continue
		if def.defender_id == "phu_chu" or def.defender_id == "phao_hoa":
			continue
		var dx: float = position.x - def.position.x
		if dx >= -8.0 and dx <= 46.0 and def.position.x > best_x:
			best_x = def.position.x
			best = def
	if not is_flying:
		for obs in _battle.get_obstacles_in_lane(lane):
			if not is_instance_valid(obs) or obs.is_consuming:
				continue
			var dx: float = position.x - obs.position.x
			if dx >= -8.0 and dx <= 46.0 and obs.position.x > best_x:
				best_x = obs.position.x
				best = obs
	return best


func _process_walk(delta: float, speed_mult: float, anim_fps: float) -> void:
	_state = "walk"
	_set_anim(_move_tex)
	var move_spd := base_speed * speed_mult
	if enemy_id == "kappa" and _battle and _battle.is_water_lane(lane):
		move_spd *= 1.35
	position.x -= move_spd * delta

	if _sprite and is_flying:
		_sprite.position.y = -18.0 + sin(position.x * 0.06) * 5.0

	var total := _grid.x * _grid.y
	_frame_accum += delta * anim_fps
	if _frame_accum >= 1.0:
		_frame_accum -= 1.0
		_frame_idx = (_frame_idx + 1) % total
		_sprite.frame = _frame_idx

	if _battle:
		# Trigger Komainu last line guardian or lose condition
		if position.x <= GameData.GRID_ORIGIN.x - 12.0:
			_battle.on_enemy_reached_left(self)


func _process_melee_attack(delta: float, anim_fps: float) -> void:
	_state = "attack"
	_set_anim(_attack_tex)
	var total := _grid.x * _grid.y
	_attack_timer += delta * (1.0 - slow_ratio)
	_frame_accum += delta * anim_fps
	if _frame_accum >= 1.0:
		_frame_accum -= 1.0
		_frame_idx += 1
		if _frame_idx >= total:
			_frame_idx = 0
			_attack_hit_done = false
		_sprite.frame = _frame_idx

	if not _attack_hit_done and _frame_idx >= int(total * 0.45):
		_attack_hit_done = true
		_deal_melee_hit()
	elif _attack_timer >= attack_interval:
		_attack_timer = 0.0
		_attack_hit_done = false


func _deal_melee_hit() -> void:
	if _blocking_defender == null or not is_instance_valid(_blocking_defender):
		return
	if _blocking_defender.has_method("on_enemy_melee_hit"):
		_blocking_defender.on_enemy_melee_hit(damage, self)
	else:
		_blocking_defender.take_damage(damage)
	if is_boss and _battle:
		_battle.trigger_screen_shake(4.0, 0.16)
	# Rắn Ống multi-target cleave: also hits the defender 1 cell behind the front target
	if enemy_id == "ran_ong" and _battle:
		for def in _battle.get_defenders_in_lane(lane):
			if is_instance_valid(def) and def != _blocking_defender and not def.is_consuming:
				if def.position.x < _blocking_defender.position.x and (_blocking_defender.position.x - def.position.x) <= GameData.CELL_SIZE.x * 1.15:
					def.take_damage(damage * 0.65)
					break


func _start_vault(end_x: float) -> void:
	has_vaulted = true
	_state = "vault"
	_vault_elapsed = 0.0
	_vault_start_x = position.x
	_vault_end_x = end_x


func _process_vault(delta: float) -> void:
	_vault_elapsed += delta
	var t := clampf(_vault_elapsed / 0.55, 0.0, 1.0)
	position.x = lerpf(_vault_start_x, _vault_end_x, t)
	if _sprite:
		_sprite.position.y = -18.0 - sin(t * PI) * 44.0
	var total := _grid.x * _grid.y
	_frame_accum += delta * 16.0
	if _frame_accum >= 1.0:
		_frame_accum -= 1.0
		_frame_idx = (_frame_idx + 1) % total
		_sprite.frame = _frame_idx
	if t >= 1.0:
		_state = "walk"
		if _sprite:
			_sprite.position.y = -18.0 if is_flying else 0.0


func _switch_adjacent_lane() -> bool:
	has_switched_lane = true
	var candidates: Array[int] = []
	if lane > 0:
		candidates.append(lane - 1)
	if lane < GameData.GRID_ROWS - 1:
		candidates.append(lane + 1)
	if candidates.is_empty():
		return false
	var target_lane := candidates[randi() % candidates.size()]
	var old_lane := lane
	lane = target_lane
	z_index = 21 + lane * 2
	var target_y := GameData.GRID_ORIGIN.y + (lane + 0.5) * GameData.CELL_SIZE.y
	var tw := create_tween()
	tw.tween_property(self, "position:y", target_y, 0.38).set_trans(Tween.TRANS_SINE)
	if _battle:
		_battle.notify_enemy_lane_change(self, old_lane, lane)
	return true


func _try_special_skill(delta: float) -> bool:
	if _battle == null or position.x > 1060.0:
		return false
	if enemy_id == "miko_ma":
		_skill_timer += delta * (1.0 - slow_ratio)
		if _skill_timer >= 9.5:
			_skill_timer = 0.0
			_state = "skill"
			_skill_done = false
			_set_anim(_attack_tex)
			return true
	elif enemy_id == "yuki_onna":
		_skill_timer += delta * (1.0 - slow_ratio)
		if _skill_timer >= 6.8:
			var target := _find_freeze_target()
			if target != null:
				_skill_timer = 0.0
				_state = "skill"
				_skill_done = false
				_set_anim(_attack_tex)
				return true
	return false


func _find_freeze_target() -> Node:
	if _battle == null:
		return null
	for def in _battle.get_defenders_in_lane(lane):
		if is_instance_valid(def) and not def.is_consuming and def.frozen_timer <= 0.0:
			var dx: float = position.x - def.position.x
			if dx > 0.0 and dx <= GameData.CELL_SIZE.x * 2.6:
				return def
	return null


func _process_skill_anim(delta: float, anim_fps: float) -> void:
	var total := _grid.x * _grid.y
	_frame_accum += delta * anim_fps
	while _frame_accum >= 1.0:
		_frame_accum -= 1.0
		_frame_idx += 1
		if not _skill_done and _frame_idx >= int(total * 0.5):
			_skill_done = true
			_execute_special_skill()
		if _frame_idx >= total:
			_state = "walk"
			_set_anim(_move_tex)
			return
		_sprite.frame = _frame_idx


func _execute_special_skill() -> void:
	if _battle == null:
		return
	if enemy_id == "miko_ma":
		var lanes := [clampi(lane - 1, 0, GameData.GRID_ROWS - 1), clampi(lane + 1, 0, GameData.GRID_ROWS - 1)]
		for target_lane in lanes:
			var spawn_pos := Vector2(clampf(position.x + 22.0, 260.0, 1140.0), GameData.GRID_ORIGIN.y + (target_lane + 0.5) * GameData.CELL_SIZE.y)
			_battle.spawn_vfx("res://assets/sprites/fx/fx_smoke_puff.png", Vector2i(4, 3), spawn_pos + Vector2(0, -8), 18.0, 0.72)
			_battle.spawn_enemy("tieu_yeu", target_lane, spawn_pos.x)
	elif enemy_id == "yuki_onna":
		var target := _find_freeze_target()
		if target != null and is_instance_valid(target):
			target.apply_freeze(4.5)
			_battle.spawn_vfx("res://assets/sprites/fx/fx_freeze_overlay.png", Vector2i(4, 3), target.position + Vector2(0, -8), 16.0, 0.85)
