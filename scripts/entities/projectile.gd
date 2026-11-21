extends Node2D
class_name Projectile

## Lane projectile launched by ranged defenders (Sakura petal, Bamboo dart, Ice orb).

var lane: int = 0
var kind: String = "petal"
var damage: float = 24.0
var speed: float = 390.0
var slow_ratio: float = 0.0
var slow_duration: float = 0.0
var armor_piercing: bool = false
var knockback_px: float = 0.0
var max_range: float = 0.0
var is_piercing: bool = false

var _battle: Node = null
var _sprite: Sprite2D
var _spin_speed: float = 0.0
var _age: float = 0.0
var _traveled: float = 0.0
var _frame_accum: float = 0.0
var _frame_idx: int = 0
var _total_frames: int = 1
var _hit_enemies: Array = []


func setup(battle_ref: Node, start_pos: Vector2, p_lane: int, p_kind: String, p_damage: float) -> void:
	_battle = battle_ref
	position = start_pos
	lane = p_lane
	kind = p_kind
	damage = p_damage
	z_index = (45 if kind == "wind" else 40) + lane * 2

	_sprite = Sprite2D.new()
	var tex_path := "res://assets/sprites/fx/proj_sakura_petal_anim.png"
	var grid := Vector2i(1, 1)
	match kind:
		"petal":
			tex_path = "res://assets/sprites/fx/proj_sakura_petal_anim.png"
			grid = Vector2i(3, 2)
			speed = 380.0
			_spin_speed = 2.0
		"dart":
			tex_path = "res://assets/sprites/fx/proj_bamboo_dart_anim.png"
			grid = Vector2i(3, 1)
			speed = 490.0
			_spin_speed = 0.0
		"ice":
			tex_path = "res://assets/sprites/fx/proj_ice_orb_anim.png"
			grid = Vector2i(3, 2)
			speed = 360.0
			slow_ratio = 0.45
			slow_duration = 4.5
			_spin_speed = 1.5
		"poison":
			tex_path = "res://assets/sprites/fx/proj_poison_glob_anim.png"
			grid = Vector2i(3, 1)
			speed = 340.0
			armor_piercing = true
		"wind":
			tex_path = "res://assets/sprites/fx/fx_wind_gust.png"
			grid = Vector2i(4, 3)
			speed = 460.0
			_spin_speed = 0.0
			is_piercing = true
			knockback_px = float(GameData.DEFENDERS["gio_loc"].get("knockback_px", 115.0))
			max_range = float(GameData.DEFENDERS["gio_loc"].get("range_cells", 5.5)) * GameData.CELL_SIZE.x
		"spirit":
			tex_path = "res://assets/sprites/fx/proj_spirit_fireball.png"
			speed = 430.0
	_sprite.texture = load(tex_path) as Texture2D
	_sprite.hframes = grid.x
	_sprite.vframes = grid.y
	_sprite.frame = 0
	_total_frames = grid.x * grid.y
	_sprite.scale = Vector2(1.18, 1.18) if kind == "wind" else Vector2(0.62, 0.62)
	add_child(_sprite)


func _process(delta: float) -> void:
	_age += delta
	var step_x := speed * delta
	position.x += step_x
	_traveled += step_x
	if kind == "wind" and max_range > 0.0:
		if _sprite and _total_frames > 1:
			_sprite.frame = clampi(int(clampf(_traveled / max_range, 0.0, 1.0) * float(_total_frames - 1)), 0, _total_frames - 1)
		if _traveled >= max_range:
			queue_free()
			return
	elif _sprite and _total_frames > 1:
		_frame_accum += delta * 14.0
		while _frame_accum >= 1.0:
			_frame_accum -= 1.0
			_frame_idx = (_frame_idx + 1) % _total_frames
		_sprite.frame = _frame_idx
	if _sprite and _spin_speed != 0.0:
		_sprite.rotation = sin(_age * _spin_speed) * 0.16

	if _battle == null:
		queue_free()
		return

	var hit_radius := 44.0 if kind == "wind" else 34.0
	var enemies: Array = _battle.get_enemies_in_lane(lane)
	for enemy in enemies:
		if not is_instance_valid(enemy) or enemy.is_dying():
			continue
		if is_piercing and enemy in _hit_enemies:
			continue
		if absf(enemy.position.x - position.x) <= hit_radius:
			if kind == "wind":
				_hit_enemies.append(enemy)
				if enemy.is_flying:
					enemy.ground_from_wind()
					enemy.take_damage(180.0, true)
				else:
					enemy.take_damage(damage, false)
				enemy.knockback(knockback_px)
				continue
			enemy.take_damage(damage, armor_piercing)
			if slow_ratio > 0.0:
				enemy.apply_slow(slow_ratio, slow_duration)
			var hit_vfx := "res://assets/sprites/fx/fx_ice_hit_splash.png" if kind == "ice" else "res://assets/sprites/fx/fx_hit_spark.png"
			var hit_scale := 0.72 if kind == "ice" else 0.68
			_battle.spawn_vfx(hit_vfx, Vector2i(4, 3), enemy.position + Vector2(-10.0, -8.0), 22.0, hit_scale)
			AudioManager.play_sfx("hit", -11.0)
			queue_free()
			return

	if position.x > 1340.0:
		queue_free()
