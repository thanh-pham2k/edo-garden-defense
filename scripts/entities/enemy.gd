extends Node2D
class_name Enemy

## Yokai enemy controller supporting all 10 unique Yokai behaviors.

const BODY_ATLAS := preload("res://scripts/entities/body_atlas.gd")
const FLIGHT_HEIGHT := 18.0
# Foot row of the opaque body in each Tengu frame. Flight art includes its own lift.
const TENGU_FLY_CONTACT := [106, 106, 103, 109, 108, 104, 103, 103, 104, 105, 108, 104]
const TENGU_ATTACK_CONTACT := [104, 103, 104, 110, 107, 103, 102, 102, 100, 102, 103, 104]
const TENGU_DEATH_CONTACT := 105.0
const BADGE_ARMOR := preload("res://assets/sprites/ui/badge_armor.png")
const BADGE_POISON := preload("res://assets/sprites/ui/badge_poison.png")
const BADGE_SLOW := preload("res://assets/sprites/ui/badge_slow.png")
const BADGE_FLYING := preload("res://assets/sprites/ui/badge_flying.png")
const BADGE_BOSS := preload("res://assets/sprites/ui/badge_boss.png")

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
var _stun_anim_time: float = 0.0
var slow_timer: float = 0.0
var slow_ratio: float = 0.0
var poison_timer: float = 0.0
var poison_dps: float = 0.0
var _kb_remaining: float = 0.0
var _kb_cooldown: float = 0.0
var speed_buff_timer: float = 0.0

var has_vaulted: bool = false
var has_switched_lane: bool = false
var _transformed: bool = false
var lantern_revealed := false

var _battle: Node = null
var _data: Dictionary = {}
var _sprite: Sprite2D
var _stun_sprite: Sprite2D
var _status_display: Node2D
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
	BODY_ATLAS.set_sheet(_sprite, _move_tex, _grid)
	var sc := 0.80 if is_boss else 0.76
	_sprite.scale = Vector2(sc, sc)
	_sprite.position.y = GameData.LANE_CONTACT_OFFSET - (FLIGHT_HEIGHT if is_flying else 0.0)
	add_child(_sprite)

	_status_display = Node2D.new()
	_status_display.z_as_relative = false
	_status_display.z_index = 100
	_status_display.position.y = -23.0 if is_boss else -11.0
	_status_display.draw.connect(_draw_status)
	add_child(_status_display)
	if is_flying:
		_update_flying_status_position()

	_stun_sprite = Sprite2D.new()
	_stun_sprite.texture = load("res://assets/sprites/fx/fx_stun_stars.png") as Texture2D
	_stun_sprite.hframes = 4
	_stun_sprite.vframes = 3
	_stun_sprite.frame = 0
	_stun_sprite.scale = Vector2(0.55, 0.55)
	_stun_sprite.position = Vector2(0.0, -64.0 if is_boss else -42.0)
	_stun_sprite.visible = false
	_status_display.add_child(_stun_sprite)

	_skill_timer = randf_range(2.5, 4.5)


func set_fog_visibility(target: float, delta: float) -> void:
	modulate.a = move_toward(modulate.a, target, delta * 7.0)
	visible = modulate.a > 0.02


func set_lantern_revealed(in_light: bool) -> void:
	var revealed := in_light and _transformed
	if revealed != lantern_revealed:
		lantern_revealed = revealed
		_status_display.queue_redraw()


func is_dying() -> bool:
	return _state == "die"


func take_damage(amount: float, armor_piercing: bool = false) -> void:
	if is_dying():
		return
	var eff := amount
	if not armor_piercing and damage_reduction > 0.0:
		eff *= (1.0 - damage_reduction)

	var was_armored := armor_hp > 0.0
	if not armor_piercing and armor_hp > 0.0:
		var absorbed := minf(armor_hp, eff)
		armor_hp -= absorbed
		eff -= absorbed
		if was_armored and armor_hp <= 0.0 and _battle:
			_battle.spawn_vfx("res://assets/sprites/fx/fx_armor_break.png", Vector2i(4, 3), position + Vector2(0, -10), 20.0, 0.85)

	hp -= eff
	_hit_flash = 0.12
	_status_display.queue_redraw()
	if hp <= 0.0:
		hp = 0.0
		_start_die()


func apply_slow(ratio: float, duration: float) -> void:
	if is_dying():
		return
	var had := slow_timer > 0.0
	slow_ratio = maxf(slow_ratio, ratio)
	slow_timer = maxf(slow_timer, duration)
	if not had:
		_status_display.queue_redraw()


func apply_speed_buff(duration: float) -> void:
	if is_dying():
		return
	speed_buff_timer = maxf(speed_buff_timer, duration)


func apply_stun(duration: float) -> void:
	if is_dying():
		return
	if stun_timer <= 0.0:
		_stun_anim_time = 0.0
		_stun_sprite.frame = 0
	stun_timer = maxf(stun_timer, duration)
	if _stun_sprite:
		_stun_sprite.visible = true


func apply_poison(dps: float, duration: float) -> void:
	if is_dying():
		return
	var had := poison_timer > 0.0
	poison_dps = maxf(poison_dps, dps)
	poison_timer = maxf(poison_timer, duration)
	if not had:
		_status_display.queue_redraw()


func knockback(pixels: float) -> void:
	if is_dying() or _kb_cooldown > 0.0:
		return
	var kb := pixels * (0.22 if is_boss else 1.0)
	if kb <= 1.0:
		return
	var max_slide := 32.0 if is_boss else 130.0
	_kb_remaining = minf(max_slide, _kb_remaining + kb)
	_kb_cooldown = 8.0 if is_boss else 2.6


func ground_from_wind() -> void:
	is_flying = false
	has_vaulted = true
	if _state == "vault":
		_state = "walk"
	if _sprite:
		_sprite.position.y = GameData.LANE_CONTACT_OFFSET
		_set_body_frame(_frame_idx)
	_status_display.position.y = -11.0
	_status_display.queue_redraw()


func _start_die() -> void:
	_state = "die"
	_status_display.hide()
	queue_redraw()
	_kb_remaining = 0.0
	_sprite.rotation = 0.0
	if _stun_sprite:
		_stun_sprite.visible = false
	_set_anim(_die_tex)
	if enemy_id == "tengu" and is_flying:
		create_tween().tween_property(_sprite, "position:y", GameData.LANE_CONTACT_OFFSET, 0.28).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	AudioManager.play_sfx("enemy_die", -7.0)
	if _battle:
		_battle.on_enemy_killed(self)


func _set_anim(tex: Texture2D) -> void:
	if _sprite.texture != tex:
		BODY_ATLAS.set_sheet(_sprite, tex, _grid)
		_frame_idx = 0
		_frame_accum = 0.0
		_set_body_frame(0)


func _set_body_frame(frame: int) -> void:
	_sprite.frame = frame
	if enemy_id != "tengu":
		return
	if is_dying():
		BODY_ATLAS.set_contact_pixel(_sprite, TENGU_DEATH_CONTACT)
	elif not is_flying:
		var contacts := TENGU_ATTACK_CONTACT if _sprite.texture == _attack_tex else TENGU_FLY_CONTACT
		BODY_ATLAS.set_contact_pixel(_sprite, contacts[frame])


func _update_flying_status_position() -> void:
	_status_display.position.y = _sprite.position.y - GameData.LANE_CONTACT_OFFSET - 24.0


func _draw() -> void:
	if is_dying():
		return
	# Shadow
	draw_set_transform(Vector2(0.0, GameData.LANE_CONTACT_OFFSET), 0.0, Vector2(1.0, 0.34))
	draw_circle(Vector2.ZERO, 34.0 if is_boss else 25.0, Color(0.0, 0.0, 0.0, 0.26))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_status() -> void:
	# HP bar (shown when damaged or boss)
	var bar_w := 76.0 if is_boss else 52.0
	var bar_y := -66.0 if is_boss else -43.0
	if hp < max_hp or is_boss:
		var ratio := clampf(hp / max_hp, 0.0, 1.0)
		_status_display.draw_rect(Rect2(Vector2(-bar_w * 0.5, bar_y), Vector2(bar_w, 6.0)), Color(0.08, 0.06, 0.06, 0.82))
		_status_display.draw_rect(Rect2(Vector2(-bar_w * 0.5 + 1, bar_y + 1), Vector2((bar_w - 2.0) * ratio, 4.0)), Color(0.92, 0.24, 0.24))

	if max_armor_hp > 0.0 and armor_hp > 0.0:
		var ar := clampf(armor_hp / max_armor_hp, 0.0, 1.0)
		_status_display.draw_rect(Rect2(Vector2(-bar_w * 0.5, bar_y - 7.0), Vector2(bar_w, 5.0)), Color(0.08, 0.06, 0.06, 0.82))
		_status_display.draw_rect(Rect2(Vector2(-bar_w * 0.5 + 1, bar_y - 6.0), Vector2((bar_w - 2.0) * ar, 3.0)), Color(0.96, 0.80, 0.22))

	# Compact overhead combat status badges
	var badges: Array[Texture2D] = []
	if lantern_revealed:
		_status_display.draw_arc(Vector2(0.0, -16.0), 23.0, PI * 0.13, PI * 0.87, 14, Color(0.37, 0.91, 0.84, 0.88), 2.0, true)
	if is_boss:
		badges.append(BADGE_BOSS)
	if armor_hp > 0.0:
		badges.append(BADGE_ARMOR)
	if is_flying:
		badges.append(BADGE_FLYING)
	if slow_timer > 0.0:
		badges.append(BADGE_SLOW)
	if poison_timer > 0.0:
		badges.append(BADGE_POISON)
	if not badges.is_empty():
		var icon_sz := 17.0
		var gap := 2.0
		var total_w := badges.size() * icon_sz + (badges.size() - 1) * gap
		var start_x := -total_w * 0.5
		var badge_y := bar_y - (26.0 if armor_hp > 0.0 else 20.0)
		for i in range(badges.size()):
			_status_display.draw_texture_rect(badges[i], Rect2(start_x + i * (icon_sz + gap), badge_y, icon_sz, icon_sz), false)


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
		if poison_timer == 0.0:
			_status_display.queue_redraw()
		take_damage(poison_dps * delta, true)
		if is_dying():
			return

	if _kb_cooldown > 0.0:
		_kb_cooldown = maxf(0.0, _kb_cooldown - delta)

	if speed_buff_timer > 0.0:
		speed_buff_timer = maxf(0.0, speed_buff_timer - delta)

	if enemy_id == "tanuki" and not _transformed and hp > 0.0 and hp <= max_hp * 0.50:
		_transformed = true
		base_speed *= 1.45
		max_armor_hp = 120.0
		armor_hp = 120.0
		_status_display.queue_redraw()
		if _battle:
			_battle.spawn_vfx("res://assets/sprites/fx/fx_smoke_puff.png", Vector2i(4, 3), position + Vector2(0, -10), 18.0, 0.85)

	if slow_timer > 0.0:
		slow_timer = maxf(0.0, slow_timer - delta)
		if slow_timer == 0.0:
			slow_ratio = 0.0
			_status_display.queue_redraw()

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
			_stun_anim_time += delta
			_stun_sprite.frame = int(_stun_anim_time / 0.07) % 12
	elif _stun_sprite and _stun_sprite.visible:
		_stun_sprite.visible = false

	if _kb_remaining > 0.0:
		var slide_speed := maxf(140.0, _kb_remaining * 9.0)
		var step := minf(_kb_remaining, slide_speed * delta)
		var prev_x := position.x
		position.x = minf(1195.0, position.x + step)
		_kb_remaining = maxf(0.0, _kb_remaining - step)
		if position.x >= 1194.9 and is_equal_approx(position.x, prev_x):
			_kb_remaining = 0.0
		if _sprite:
			_sprite.rotation = clampf(_kb_remaining / 120.0, 0.0, 1.0) * (0.07 if is_boss else 0.16)
		return
	elif _sprite and _sprite.rotation != 0.0:
		_sprite.rotation = 0.0

	if stun_timer > 0.0:
		return

	var speed_mult := maxf(0.25, (1.0 - slow_ratio) * (1.35 if speed_buff_timer > 0.0 else 1.0))
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
		# Tengu flying leap or Karakasa one-time hop over first blocking defender/obstacle
		if (enemy_id == "tengu" and is_flying and not has_vaulted) or (enemy_id == "karakasa" and not has_vaulted):
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
	if enemy_id == "kappa" and _battle:
		var col := floori((position.x - GameData.GRID_ORIGIN.x) / GameData.CELL_SIZE.x)
		if _battle.is_water_cell(lane, col):
			move_spd *= 1.35
	if lantern_revealed:
		move_spd *= 0.88
	position.x -= move_spd * delta

	if _sprite and is_flying:
		_sprite.position.y = GameData.LANE_CONTACT_OFFSET - FLIGHT_HEIGHT + sin(position.x * 0.06) * 5.0
		_update_flying_status_position()

	var total := _grid.x * _grid.y
	_frame_accum += delta * anim_fps
	while _frame_accum >= 1.0:
		_frame_accum -= 1.0
		_frame_idx = (_frame_idx + 1) % total
		_set_body_frame(_frame_idx)

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
	var impact_frame := int(total * 0.45)
	var crossed_impact := false
	while _frame_accum >= 1.0:
		_frame_accum -= 1.0
		_frame_idx += 1
		if _frame_idx >= total:
			_frame_idx = 0
			_attack_hit_done = false
		crossed_impact = crossed_impact or _frame_idx == impact_frame
		_set_body_frame(_frame_idx)

	if not _attack_hit_done and (crossed_impact or _frame_idx >= impact_frame):
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
		var lift := FLIGHT_HEIGHT if is_flying else 0.0
		_sprite.position.y = GameData.LANE_CONTACT_OFFSET - lift - sin(t * PI) * 44.0
		if is_flying:
			_update_flying_status_position()
	var total := _grid.x * _grid.y
	_frame_accum += delta * 16.0
	while _frame_accum >= 1.0:
		_frame_accum -= 1.0
		_frame_idx = (_frame_idx + 1) % total
		_set_body_frame(_frame_idx)
	if t >= 1.0:
		_state = "walk"
		if _sprite:
			_sprite.position.y = GameData.LANE_CONTACT_OFFSET - (FLIGHT_HEIGHT if is_flying else 0.0)
			_update_flying_status_position()


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
	var target_y := GameData.cell_to_world(lane, 0).y
	var tw := create_tween()
	tw.tween_property(self, "position:y", target_y, 0.38).set_trans(Tween.TRANS_SINE)
	if _battle:
		_battle.notify_enemy_lane_change(self, old_lane, lane)
	return true


func _try_special_skill(delta: float) -> bool:
	if _battle == null or position.x > 1060.0:
		return false
	var step_delta := delta * (1.0 - slow_ratio)
	match enemy_id:
		"miko_ma", "boss_shogun":
			_skill_timer += step_delta
			var cd := 10.5 if enemy_id == "boss_shogun" else 9.5
			if _skill_timer >= cd:
				_skill_timer = 0.0
				_state = "skill"
				_skill_done = false
				_set_anim(_attack_tex)
				return true
		"yuki_onna", "boss_yuki_queen":
			_skill_timer += step_delta
			var ycd := 7.5 if enemy_id == "boss_yuki_queen" else 6.8
			if _skill_timer >= ycd:
				var target := _find_freeze_target()
				if target != null:
					_skill_timer = 0.0
					_state = "skill"
					_skill_done = false
					_set_anim(_attack_tex)
					return true
		"chochin_ma":
			_skill_timer += step_delta
			if _skill_timer >= 8.0:
				_skill_timer = 0.0
				_battle.drain_flame(15)
				_battle.spawn_vfx("res://assets/sprites/fx/fx_smoke_puff.png", Vector2i(4, 3), position + Vector2(0, -14), 18.0, 0.55)
		"kappa_phap_su", "boss_kyubi":
			_skill_timer += step_delta
			if enemy_id == "boss_kyubi" and not has_switched_lane and hp <= max_hp * 0.50:
				_switch_adjacent_lane()
				return true
			var rcd := 6.5 if enemy_id == "boss_kyubi" else 5.5
			if _skill_timer >= rcd and _find_lane_defender(GameData.CELL_SIZE.x * 4.8) != null:
				_skill_timer = 0.0
				_state = "skill"
				_skill_done = false
				_set_anim(_attack_tex)
				return true
		"boss_tengu_king":
			_skill_timer += step_delta
			if _skill_timer >= 8.5 and _find_lane_defender(GameData.CELL_SIZE.x * 3.5) != null:
				_skill_timer = 0.0
				_state = "skill"
				_skill_done = false
				_set_anim(_attack_tex)
				return true
		"boss_kappa_lord":
			_skill_timer += step_delta
			if _skill_timer >= 9.0 and hp < max_hp:
				_skill_timer = 0.0
				hp = minf(max_hp, hp + 220.0)
				_status_display.queue_redraw()
				_battle.spawn_vfx("res://assets/sprites/fx/fx_heal_aura.png", Vector2i(4, 3), position + Vector2(0, -10), 18.0, 0.95)
	return false


func _find_lane_defender(max_dist: float) -> Node:
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
		if dx >= 40.0 and dx <= max_dist and def.position.x > best_x:
			best_x = def.position.x
			best = def
	return best


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
	match enemy_id:
		"miko_ma", "boss_shogun":
			_battle.spawn_vfx("res://assets/sprites/fx/fx_miko_summon_circle.png", Vector2i(4, 3), position + Vector2(0, 12), 18.0, 0.92)
			var lanes := [clampi(lane - 1, 0, GameData.GRID_ROWS - 1), clampi(lane + 1, 0, GameData.GRID_ROWS - 1)]
			for target_lane in lanes:
				var spawn_pos := Vector2(clampf(position.x + 22.0, 260.0, 1140.0), GameData.cell_to_world(target_lane, 0).y)
				_battle.spawn_vfx("res://assets/sprites/fx/fx_smoke_puff.png", Vector2i(4, 3), spawn_pos + Vector2(0, -8), 18.0, 0.72)
				_battle.spawn_enemy("tieu_yeu", target_lane, spawn_pos.x)
		"yuki_onna":
			var target := _find_freeze_target()
			if target != null and is_instance_valid(target):
				var target_2d := target as Node2D
				var mid_pos: Vector2 = (position + target_2d.position) * 0.5 + Vector2(0, -8)
				_battle.spawn_vfx("res://assets/sprites/fx/fx_yuki_ice_breath.png", Vector2i(4, 3), mid_pos, 18.0, 0.88)
				target.apply_freeze(4.5)
				_battle.spawn_vfx("res://assets/sprites/fx/fx_freeze_overlay.png", Vector2i(4, 3), target_2d.position + Vector2(0, -8), 16.0, 0.85)
		"boss_yuki_queen":
			var frozen := 0
			for def in _battle.get_all_defenders():
				if not is_instance_valid(def) or def.is_consuming or def.frozen_timer > 0.0:
					continue
				if absi(def.row - lane) <= 1 and def.position.x < position.x and (position.x - def.position.x) <= GameData.CELL_SIZE.x * 3.2:
					var mid_pos: Vector2 = (position + def.position) * 0.5 + Vector2(0, -8)
					_battle.spawn_vfx("res://assets/sprites/fx/fx_yuki_ice_breath.png", Vector2i(4, 3), mid_pos, 18.0, 0.92)
					def.apply_freeze(4.0)
					_battle.spawn_vfx("res://assets/sprites/fx/fx_freeze_overlay.png", Vector2i(4, 3), def.position + Vector2(0, -8), 16.0, 0.85)
					frozen += 1
					if frozen >= 2:
						break
		"kappa_phap_su":
			_battle.spawn_projectile(position + Vector2(-28.0, -14.0), lane, "kappa_water", damage * 0.85)
		"boss_kyubi":
			_battle.spawn_projectile(position + Vector2(-34.0, -16.0), lane, "kyubi_fire", damage * 0.90)
		"boss_tengu_king":
			var target := _find_lane_defender(GameData.CELL_SIZE.x * 3.5)
			if target != null and is_instance_valid(target):
				_battle.spawn_vfx("res://assets/sprites/fx/fx_wind_gust.png", Vector2i(4, 3), position + Vector2(-50.0, -8.0), 18.0, 0.95, 0.0, Vector2(-180.0, 0.0))
				target.take_damage(damage * 0.65)
				target.apply_freeze(2.0)
