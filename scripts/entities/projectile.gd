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

var _battle: Node = null
var _sprite: Sprite2D
var _spin_speed: float = 0.0
var _age: float = 0.0


func setup(battle_ref: Node, start_pos: Vector2, p_lane: int, p_kind: String, p_damage: float) -> void:
	_battle = battle_ref
	position = start_pos
	lane = p_lane
	kind = p_kind
	damage = p_damage
	z_index = 40 + lane * 2

	_sprite = Sprite2D.new()
	var tex_path := "res://assets/sprites/fx/proj_sakura_petal.png"
	match kind:
		"petal":
			tex_path = "res://assets/sprites/fx/proj_sakura_petal.png"
			speed = 380.0
			_spin_speed = 4.0
		"dart":
			tex_path = "res://assets/sprites/fx/proj_bamboo_dart.png"
			speed = 490.0
			_spin_speed = 0.0
		"ice":
			tex_path = "res://assets/sprites/fx/proj_ice_orb.png"
			speed = 360.0
			slow_ratio = 0.45
			slow_duration = 4.5
			_spin_speed = 3.0
		"poison":
			tex_path = "res://assets/sprites/fx/proj_poison_glob.png"
			speed = 340.0
			armor_piercing = true
		"spirit":
			tex_path = "res://assets/sprites/fx/proj_spirit_fireball.png"
			speed = 430.0
	_sprite.texture = load(tex_path) as Texture2D
	_sprite.scale = Vector2(0.64, 0.64)
	add_child(_sprite)


func _process(delta: float) -> void:
	_age += delta
	position.x += speed * delta
	if _sprite and _spin_speed != 0.0:
		_sprite.rotation = sin(_age * _spin_speed) * 0.22

	if _battle == null:
		queue_free()
		return

	var enemies: Array = _battle.get_enemies_in_lane(lane)
	for enemy in enemies:
		if not is_instance_valid(enemy) or enemy.is_dying():
			continue
		if absf(enemy.position.x - position.x) <= 34.0:
			enemy.take_damage(damage, armor_piercing)
			if slow_ratio > 0.0:
				enemy.apply_slow(slow_ratio, slow_duration)
			_battle.spawn_vfx("res://assets/sprites/fx/fx_hit_spark.png", Vector2i(4, 3), enemy.position + Vector2(-10.0, -8.0), 22.0, 0.68)
			AudioManager.play_sfx("hit", -11.0)
			queue_free()
			return

	if position.x > 1340.0:
		queue_free()
