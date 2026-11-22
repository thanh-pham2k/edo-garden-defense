extends Node2D

## Main lane-based battle controller for Edo Garden Defense.

const BATTLEFIELD_TILE_SHADER := preload("res://assets/shaders/battlefield_tiles.gdshader")
const SCENERY := preload("res://scripts/battle/scenery.gd")
const POND_BRIDGE_X := 88.0
const KOI_ATLAS := preload("res://assets/sprites/tiles/env_koi_water_anim.png")
const KOI_TAIL_FRAMES := 8
const KOI_VARIANTS := 3
const FENCE_TILE_ORIGIN_X := -420.0
const BACKDROP_OVERSCAN := 24.0
const BATTLEFIELD_REFERENCE_SIZE := Vector2(1280.0, 720.0)
const HUD_SIDE_MARGIN := 12.0
const HUD_EDGE_MARGIN := 8.0
const BOTTOM_HUD_SCALE := 1.35
const SAFE_AREA := preload("res://scripts/ui/safe_area.gd")
const MAIN_MENU_PATH := "res://scenes/main/MainMenu.tscn"
const SEED_CARD_SCRIPT := preload("res://scripts/ui/seed_card.gd")
const DEFENDER_SCRIPT := preload("res://scripts/entities/defender.gd")
const ENEMY_SCRIPT := preload("res://scripts/entities/enemy.gd")
const PROJECTILE_SCRIPT := preload("res://scripts/entities/projectile.gd")
const VFX_SCRIPT := preload("res://scripts/entities/vfx_effect.gd")
const FLAME_SCRIPT := preload("res://scripts/entities/spirit_flame.gd")
const KOMAINU_SCRIPT := preload("res://scripts/entities/komainu_guardian.gd")
const OBSTACLE_SCRIPT := preload("res://scripts/entities/obstacle.gd")

const SPEED_STEPS: Array[float] = [1.0, 2.0, 5.0]
const PREPARATION_MAX_SPEED := 2.0
const FIRST_SKY_FLAME_DELAY := 4.0
const OPENING_SPAWN_STAGGER := 3.0
const COMBAT_WAVE_DELAY_MULTIPLIER := 1.35
const VFX_POOL_LIMIT := 32
# Scale, opacity and playback speed for cues that overlap the combat board.
const COMBAT_VFX := {
	"fx_armor_break": Vector3(0.78, 0.84, 1.15),
	"fx_burn_flame": Vector3(0.86, 0.75, 1.0),
	"fx_explosion": Vector3(0.82, 0.89, 1.15),
	"fx_freeze_overlay": Vector3(0.72, 0.71, 1.20),
	"fx_heal_aura": Vector3(0.82, 0.62, 1.25),
	"fx_frost_chime_wave": Vector3(0.78, 0.60, 1.25),
	"fx_poison_cloud": Vector3(0.73, 0.68, 1.25),
	"fx_hit_spark": Vector3(0.85, 0.82, 1.25),
	"fx_ice_hit_splash": Vector3(0.80, 0.75, 1.25),
	"fx_miko_summon_circle": Vector3(0.90, 0.80, 1.0),
	"fx_thunder_strike": Vector3(0.85, 0.78, 1.15),
	"fx_yuki_ice_breath": Vector3(0.86, 0.74, 1.10),
	"phao_hoa_explode": Vector3(0.76, 0.91, 1.15),
}
const GROUND_VFX_OFFSETS := {
	"fx_burn_flame": 14.0,
	"fx_explosion": 12.0,
	"fx_freeze_overlay": 12.0,
	"fx_frost_chime_wave": 20.0,
	"fx_heal_aura": 24.0,
	"fx_miko_summon_circle": 6.0,
	"fx_poison_cloud": 12.0,
	"fx_smoke_puff": 12.0,
	"fx_thunder_strike": 2.0,
	"phao_hoa_explode": 12.0,
}


var level_id: int = 1
var level_cfg: Dictionary = {}
var spirit_flame: int = 150
var speed_2x: bool = false
var speed_multiplier: float = 1.0
var battle_ended: bool = false

var selected_defender_id: String = ""
var selected_card_idx: int = -1
var shovel_mode: bool = false
var is_dragging_card: bool = false

var _grid_defenders: Array = [] # [row][col] -> Defender or null
var _grid_obstacles: Array = [] # [row][col] -> Obstacle or null
var _enemies_by_lane: Array = [] # [row] -> Array[Enemy]
var _komainu_by_lane: Array = [] # [row] -> KomainuGuardian or null
var _water_lily_overlays: Array = [] # [row][col] -> Sprite2D or null

var _world_root: Node2D
var _camera: Camera2D
var _fit_world_backdrop: Callable
var _grid_layer: Node2D
var _defender_layer: Node2D
var _enemy_layer: Node2D
var _projectile_layer: Node2D
var _vfx_layer: Node2D
var _idle_vfx: Array[VfxEffect] = []
var _vfx_textures: Dictionary[String, Texture2D] = {}
var _flame_layer: Node2D
var _ambient_layer: Node2D
var _ghost_sprite: Sprite2D
var _cell_highlight: ColorRect
var _occupied_hint: Label
var _plant_ring: Sprite2D

var _hud_layer: CanvasLayer
var _hud_root: Control
var _top_hud_row: HBoxContainer
var _bottom_hud: PanelContainer
var _flame_counter: Control
var _flame_label: Label
var _flame_hud_icon: TextureRect
var _seed_cards: Array = []
var _wave_label: Label
var _wave_fill_clip: Control
var _wave_oni_head: TextureRect
var _shovel_btn: TextureButton
var _speed_btn: TextureButton
var _speed_badge: Label
var _auto_btn: Button
var _sound_btn: TextureButton
var _skill_buttons: Dictionary = {}
var _skill_cooldowns: Dictionary = {}

var _banner_container: Control
var _banner_label: Label
var _modal_overlay: Control
var _modal_scroll: TextureRect
var _modal_banner: TextureRect
var _modal_portrait: TextureRect
var _modal_title: Label
var _modal_subtitle: Label
var _modal_stars_row: HBoxContainer
var _modal_btn_primary: TextureButton
var _modal_btn_primary_lbl: Label
var _modal_btn_secondary: TextureButton
var _modal_btn_secondary_lbl: Label
var _modal_btn_menu: Button
var _portrait_overlay: Control

var _wave_index: int = 0
var _wave_timer: float = 0.0
var _spawn_queue: Array[Dictionary] = []
var _spawn_stagger_timer: float = 0.0
var _natural_flame_timer: float = 0.0
var _shake_amp: float = 0.0
var _shake_timer: float = 0.0
var _ambient_particles: Array[Dictionary] = []
var _water_material: ShaderMaterial
var _pond_koi: Array[Sprite2D] = []
var _pond_koi_time := 0.0
var _pond_koi_center := Vector2.ZERO
var _pond_koi_span := 0.0
var _atmo_nodes: Array[Dictionary] = []
var _flora_nodes: Array[Dictionary] = []
var _glow_nodes: Array[Dictionary] = []
var _bg_time: float = 0.0
var _auto_ai_timer: float = 0.0
var _auto_highlight_timer: float = 0.0


func _ready() -> void:
	get_tree().paused = false
	level_id = GameData.selected_level
	level_cfg = GameData.get_level_config(level_id)
	spirit_flame = int(level_cfg.get("starting_flame", 150)) + GameData.get_starting_flame_bonus()
	_natural_flame_timer = maxf(0.0, _natural_flame_interval() - FIRST_SKY_FLAME_DELAY)

	_init_data_structures()
	_build_world()
	_build_hud()
	_build_modals()
	AudioManager.start_bgm(level_id)
	set_game_speed(5.0 if GameData.auto_play_active else GameData.game_speed_multiplier)
	_refresh_auto_btn()
	_update_flame_hud()
	if GameData.auto_play_active:
		_setup_auto_play_showcase_formation()


func _exit_tree() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false


func _init_data_structures() -> void:
	_grid_defenders.clear()
	_grid_obstacles.clear()
	_water_lily_overlays.clear()
	_enemies_by_lane.clear()
	_komainu_by_lane.clear()
	for r in range(GameData.GRID_ROWS):
		var row_arr: Array = []
		var obs_arr: Array = []
		var lily_arr: Array = []
		for c in range(GameData.GRID_COLS):
			row_arr.append(null)
			obs_arr.append(null)
			lily_arr.append(null)
		_grid_defenders.append(row_arr)
		_grid_obstacles.append(obs_arr)
		_water_lily_overlays.append(lily_arr)
		_enemies_by_lane.append([])
		_komainu_by_lane.append(null)


func _fit_sky_to_viewport(sky: Sprite2D) -> void:
	if not is_instance_valid(sky):
		return
	var texture_size := sky.texture.get_size()
	var viewport_size := get_viewport_rect().size / _camera.zoom
	var camera_center := _camera.position
	var sky_bottom := 96.0 + texture_size.y * 0.28
	var sky_top := minf(96.0 - texture_size.y * 0.28, camera_center.y - viewport_size.y * 0.5 - 12.0)
	sky.position = Vector2(camera_center.x, (sky_top + sky_bottom) * 0.5)
	sky.scale = Vector2(maxf(2.05, (viewport_size.x + 24.0) / texture_size.x), (sky_bottom - sky_top) / texture_size.y)


func _build_terrain(water_lane: int) -> ColorRect:
	var terrain := ColorRect.new()
	terrain.position.y = GameData.GRID_ORIGIN.y
	terrain.mouse_filter = Control.MOUSE_FILTER_IGNORE
	terrain.z_index = 2
	var material := ShaderMaterial.new()
	material.shader = BATTLEFIELD_TILE_SHADER
	var variants: Vector2i = level_cfg["terrain_variants"]
	material.set_shader_parameter("ground_texture", load("res://assets/sprites/tiles/%s_%d.png" % [level_cfg["tile_primary"], variants.x]))
	material.set_shader_parameter("accent_texture", load("res://assets/sprites/tiles/%s_%d.png" % [level_cfg["tile_alt"], variants.y]))
	material.set_shader_parameter("saturation_contrast", level_cfg["land_tone"])
	material.set_shader_parameter("ground_tint", level_cfg["terrain_tint"])
	material.set_shader_parameter("grid_origin", GameData.GRID_ORIGIN)
	material.set_shader_parameter("cell_size", GameData.CELL_SIZE)
	material.set_shader_parameter("grid_size", Vector2(GameData.GRID_COLS, GameData.GRID_ROWS))
	material.set_shader_parameter("stage_size", BATTLEFIELD_REFERENCE_SIZE)
	material.set_shader_parameter("water_lane", water_lane)
	if water_lane >= 0:
		material.set_shader_parameter("water_texture", preload("res://assets/sprites/tiles/tile_koi_water_1.png"))
		material.set_shader_parameter("pond_bridge_x", POND_BRIDGE_X)
		_water_material = material
	terrain.material = material
	_world_root.add_child(terrain)
	return terrain


func _build_pond_koi(water_lane: int) -> void:
	var left := GameData.GRID_ORIGIN.x - 32.0
	var right := GameData.GRID_ORIGIN.x + GameData.GRID_COLS * GameData.CELL_SIZE.x + 100.0
	_pond_koi_center = Vector2((left + right) * 0.5, GameData.cell_to_world(water_lane, 0).y)
	_pond_koi_span = (right - left) * 0.5
	for i in range(6):
		var koi := Sprite2D.new()
		koi.texture = KOI_ATLAS
		koi.hframes = KOI_TAIL_FRAMES
		koi.vframes = KOI_VARIANTS
		koi.scale = Vector2.ONE * (0.46 + 0.04 * (i % KOI_VARIANTS))
		koi.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		koi.modulate = Color(0.84, 0.93, 0.98, 0.80) if i < 3 else Color(0.76, 0.87, 0.95, 0.69)
		koi.z_index = 4
		_world_root.add_child(koi)
		_pond_koi.append(koi)
	_update_pond_koi(0.0)


func _update_pond_koi(real_delta: float) -> void:
	_pond_koi_time += real_delta
	for i in range(_pond_koi.size()):
		var koi := _pond_koi[i]
		# Two overlapping shoals cover the length of the pond on oval and figure-eight paths.
		var oval := i < 3
		var radius_x := _pond_koi_span * (0.59 if oval else 0.57)
		var radius_y := 19.0 if oval else 17.0
		var center_x := _pond_koi_span - radius_x
		var period := 30.0 if oval else 33.0
		var phase := fposmod(_pond_koi_time / period + float(i % 3) / 3.0 + (0.0 if oval else 0.14), 1.0) * TAU
		# Ease the phase at the narrow ends so the fish turn gradually.
		var angle := phase - 0.23 * sin(2.0 * phase)
		var vertical := angle if oval else 2.0 * angle
		koi.position = _pond_koi_center + Vector2(
			(-center_x if oval else center_x) + radius_x * cos(angle),
			radius_y * sin(vertical))
		var tangent := Vector2(-radius_x * sin(angle), radius_y * cos(vertical) * (1.0 if oval else 2.0))
		koi.rotation = tangent.angle()
		var tail_frame := posmod(floori(_pond_koi_time * 12.0) + i * 3, KOI_TAIL_FRAMES)
		koi.frame_coords = Vector2i(tail_frame, i % KOI_VARIANTS)


func _build_side_gardens(water_lane: int, atmo_style: String, yard_tint: Color) -> void:
	var scenery := SCENERY.new()
	var stone_path: String = level_cfg.get("stone_path_tex", "res://assets/sprites/environments/env_path_stepping_stones.png")
	var pond := water_lane >= 0
	var stone_tint := Color(0.76, 0.78, 0.83) if pond else yard_tint
	var stone_spots := [
		Vector3(54, 312, 74),
		Vector3(107, 579, 61),
		Vector3(1207, 302, 63),
		Vector3(1141, 523, 65),
	]
	for index in range(stone_spots.size()):
		var spot: Vector3 = stone_spots[index]
		scenery.place(_world_root, stone_path, Vector2(spot.x, spot.y), spot.z, 7, stone_tint, deg_to_rad(7.0 - 4.0 * index))

	_flora_nodes.clear()
	var flora_paths: Array = level_cfg["biome_flora"]
	var flora_spots := [
		Vector2(80, 258),
		Vector2(1220, 255),
		Vector2(1210, 629),
	]
	var flora_widths: Vector3 = level_cfg.get("biome_flora_widths", Vector3(90, 91, 80))
	for index in range(flora_paths.size()):
		var path: String = flora_paths[index]
		if pond and path.ends_with("/prop_red_bridge.png"):
			var bridge_foot := Vector2(POND_BRIDGE_X, GameData.cell_to_world(water_lane, 0).y - 32.0)
			scenery.place(_world_root, path, bridge_foot, 103, 10)
			continue
		var prop := scenery.place(_world_root, path, flora_spots[index], flora_widths[index], 11)
		_flora_nodes.append({"node": prop, "phase": float(index) * 1.7})

	var house_foot := Vector2(80, 529 if pond else 466)
	scenery.place(_world_root, level_cfg["house_tex"], house_foot, 145.0, 12)

	_glow_nodes.clear()
	if atmo_style != "day":
		var glow := Sprite2D.new()
		glow.texture = preload("res://assets/sprites/environments/env_atmo_lantern_glow.png")
		glow.position = house_foot + Vector2(9, -35)
		glow.scale = Vector2.ONE * 0.33
		glow.modulate = Color(1.0, 0.90, 0.70, 0.27)
		glow.z_index = 13
		_world_root.add_child(glow)
		_glow_nodes.append({"node": glow, "phase": glow.position.x * 0.01})


func _build_backdrop(water_lane: int) -> void:
	var sky_rect := ColorRect.new()
	sky_rect.color = level_cfg["sky_top"]
	sky_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_world_root.add_child(sky_rect)

	var horizon := ColorRect.new()
	horizon.color = level_cfg["sky_bottom"]
	horizon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_world_root.add_child(horizon)

	var sky := Sprite2D.new()
	sky.texture = load("res://assets/sprites/backgrounds/%s_0.png" % level_cfg["bg_stem"]) as Texture2D
	sky.z_index = 1
	_world_root.add_child(sky)
	var terrain := _build_terrain(water_lane)
	var fence_layer := Node2D.new()
	fence_layer.z_index = 3
	_world_root.add_child(fence_layer)
	var fence := load(level_cfg["top_border"]) as Texture2D
	_fit_world_backdrop = _fit_backdrop.bind(sky_rect, horizon, sky, terrain, fence_layer, fence)


func _fit_backdrop(sky_rect: ColorRect, horizon: ColorRect, sky: Sprite2D, terrain: ColorRect, fence_layer: Node2D, fence: Texture2D) -> void:
	var view := get_viewport_rect().size / _camera.zoom + Vector2.ONE * (BACKDROP_OVERSCAN * 2.0)
	var bounds := Rect2(_camera.position - view * 0.5, view)
	var ground_top := GameData.GRID_ORIGIN.y
	sky_rect.position = bounds.position
	sky_rect.size = Vector2(view.x, maxf(0.0, ground_top - bounds.position.y))
	horizon.position = Vector2(bounds.position.x, 80.0)
	horizon.size = Vector2(view.x, ground_top - horizon.position.y + 2.0)
	terrain.position.x = bounds.position.x
	terrain.size = Vector2(view.x, maxf(1.0, bounds.end.y - ground_top))
	if sky.texture:
		_fit_sky_to_viewport(sky)
	if fence:
		_fit_horizon_border(fence_layer, fence, bounds)


func _fit_horizon_border(layer: Node2D, texture: Texture2D, bounds: Rect2) -> void:
	var height := 94.0
	var scale_to_height := height / float(texture.get_height())
	var visible_width := float(texture.get_width()) * scale_to_height
	var step := maxf(64.0, visible_width - 4.0)
	var first := floori((bounds.position.x - FENCE_TILE_ORIGIN_X) / step)
	var count := ceili((bounds.end.x - FENCE_TILE_ORIGIN_X) / step) - first
	for index in range(count):
		var tile: Sprite2D
		if index < layer.get_child_count():
			tile = layer.get_child(index) as Sprite2D
		else:
			tile = Sprite2D.new()
			tile.texture = texture
			tile.scale = Vector2.ONE * scale_to_height
			layer.add_child(tile)
		var center_x := FENCE_TILE_ORIGIN_X + (first + index) * step + visible_width * 0.5
		tile.position = Vector2(center_x, 182.0 - height * 0.5)
		tile.show()
	for index in range(count, layer.get_child_count()):
		layer.get_child(index).hide()


func _build_world() -> void:
	_camera = Camera2D.new()
	_camera.position = BATTLEFIELD_REFERENCE_SIZE * 0.5
	_camera.enabled = true
	add_child(_camera)

	_world_root = Node2D.new()
	_world_root.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(_world_root)

	var water_lane: int = int(level_cfg.get("water_lane", -1))
	var atmo_style := str(level_cfg.get("atmosphere_style", "day"))
	var yard_tint := Color(0.84, 0.84, 0.90, 1.0)
	if atmo_style in ["night", "mist"]:
		yard_tint = Color(0.74, 0.76, 0.86, 1.0)
	_build_backdrop(water_lane)

	_build_side_gardens(water_lane, atmo_style, yard_tint)

	# Bottom lawn edge transition strip along Row 4 bottom
	var edge_path := str(level_cfg.get("lawn_edge", ""))
	if edge_path != "" and ResourceLoader.exists(edge_path):
		var edge_tex := load(edge_path) as Texture2D
		if edge_tex:
			var e_sc := 0.46
			var e_step := maxf(70.0, float(edge_tex.get_width()) * e_sc - 12.0)
			var ex := 240.0
			while ex < 1090.0:
				var esp := Sprite2D.new()
				esp.texture = edge_tex
				esp.position = Vector2(ex, 636.0)
				esp.scale = Vector2(e_sc, e_sc)
				if atmo_style == "night":
					esp.modulate = Color(0.63, 0.74, 0.72)
				esp.z_index = 8
				_world_root.add_child(esp)
				ex += e_step

	# The gameplay grid owns placement overlays. Its ground is painted below it.
	_grid_layer = Node2D.new()
	_grid_layer.z_index = 5
	_world_root.add_child(_grid_layer)
	if water_lane >= 0:
		_build_pond_koi(water_lane)
		var lily_tex := preload("res://assets/sprites/tiles/water_lily_pad.png")
		var lotus_tex := preload("res://assets/sprites/tiles/water_lily_lotus.png")
		for col in range(GameData.GRID_COLS):
			var lily := Sprite2D.new()
			lily.texture = lotus_tex if col % 2 == 1 else lily_tex
			lily.position = GameData.cell_to_world(water_lane, col)
			lily.scale = Vector2(0.76, 0.76)
			lily.hide()
			lily.z_index = 6
			_grid_layer.add_child(lily)
			_water_lily_overlays[water_lane][col] = lily

	# Cell highlight, Placement reticle ring & Ghost preview
	_cell_highlight = ColorRect.new()
	_cell_highlight.size = GameData.CELL_SIZE
	_cell_highlight.color = Color(0.3, 1.0, 0.45, 0.24)
	_cell_highlight.visible = false
	_cell_highlight.z_index = 15
	_cell_highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_world_root.add_child(_cell_highlight)

	_occupied_hint = Label.new()
	_occupied_hint.text = "Đã chiếm"
	_occupied_hint.position = Vector2(0.0, GameData.CELL_SIZE.y - 24.0)
	_occupied_hint.size.x = GameData.CELL_SIZE.x
	_occupied_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_occupied_hint.add_theme_font_size_override("font_size", 14)
	_occupied_hint.add_theme_color_override("font_outline_color", Color(0.13, 0.07, 0.04))
	_occupied_hint.add_theme_constant_override("outline_size", 6)
	_occupied_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_occupied_hint.z_as_relative = false
	_occupied_hint.z_index = 81
	_occupied_hint.hide()
	_cell_highlight.add_child(_occupied_hint)

	_plant_ring = Sprite2D.new()
	_plant_ring.texture = load("res://assets/sprites/ui/badge_plant_ring.png") as Texture2D
	_plant_ring.scale = Vector2(0.92, 0.92)
	_plant_ring.visible = false
	_plant_ring.z_index = 16
	_world_root.add_child(_plant_ring)

	_ghost_sprite = Sprite2D.new()
	_ghost_sprite.scale = Vector2(0.74, 0.74)
	_ghost_sprite.offset = Vector2(0.0, -10.0)
	_ghost_sprite.modulate = Color(1.0, 1.0, 1.0, 0.65)
	_ghost_sprite.visible = false
	_ghost_sprite.z_index = 80
	_world_root.add_child(_ghost_sprite)

	# Gameplay Entity Layers
	_defender_layer = Node2D.new()
	_enemy_layer = Node2D.new()
	_projectile_layer = Node2D.new()
	_vfx_layer = Node2D.new()
	_flame_layer = Node2D.new()
	_ambient_layer = Node2D.new()
	_ambient_layer.z_index = 17
	_world_root.add_child(_defender_layer)
	_world_root.add_child(_enemy_layer)
	_world_root.add_child(_projectile_layer)
	_world_root.add_child(_vfx_layer)
	_world_root.add_child(_flame_layer)
	_world_root.add_child(_ambient_layer)

	# Spawn 5 Komainu Guardians (Last Line of Defense)
	for r in range(GameData.GRID_ROWS):
		var k: KomainuGuardian = KOMAINU_SCRIPT.new()
		var pos := Vector2(188.0, GameData.cell_to_world(r, 0).y)
		if r == water_lane:
			var footing := Sprite2D.new()
			footing.texture = preload("res://assets/sprites/tiles/water_stepping_stone.png")
			footing.position = pos + Vector2(0, 14)
			footing.scale = Vector2.ONE * 0.64
			footing.z_index = 11
			_world_root.add_child(footing)
		k.setup(self, r, pos)
		_world_root.add_child(k)
		_komainu_by_lane[r] = k

	# Spawn Chapter Obstacles
	var obs_list: Array = level_cfg.get("obstacles", [])
	for obs_cfg in obs_list:
		spawn_obstacle(str(obs_cfg["id"]), int(obs_cfg["row"]), int(obs_cfg["col"]))

	# Living Atmospheric Overlays (Clouds, Sunbeams, Fireflies, Drifting Mist, Snow Wind)
	_atmo_nodes.clear()
	_build_atmosphere_effects(atmo_style)

	# Keep ambient wisps distinct from collectible Spirit Flames at night.
	var p_tex := load(level_cfg["ambient_particle"]) as Texture2D
	var night := atmo_style == "night"
	for i in range(12 if night else 26):
		var sp := Sprite2D.new()
		sp.texture = p_tex
		var sc := randf_range(0.10, 0.20) if night else randf_range(0.18, 0.37)
		sp.scale = Vector2(sc, sc)
		sp.position = Vector2(randf_range(0.0, 1280.0), randf_range(70.0, 700.0))
		sp.modulate.a = randf_range(0.14, 0.26) if night else randf_range(0.27, 0.48)
		_ambient_layer.add_child(sp)
		_ambient_particles.append({
			"node": sp,
			"vx": randf_range(-28.0, -8.0),
			"vy": randf_range(16.0, 42.0),
			"rot": randf_range(-1.6, 1.6),
		})


func _build_atmosphere_effects(style: String) -> void:
	match style:
		"day":
			var cloud_tex := load("res://assets/sprites/environments/env_atmo_clouds.png") as Texture2D
			var beam_tex := load("res://assets/sprites/environments/env_atmo_sunbeam.png") as Texture2D
			for i in range(3):
				if cloud_tex:
					var cs := Sprite2D.new()
					cs.texture = cloud_tex
					cs.position = Vector2(180.0 + i * 440.0, 88.0 + (i % 2) * 26.0)
					cs.scale = Vector2(0.75, 0.75)
					cs.modulate.a = 0.72
					cs.z_index = 2
					_world_root.add_child(cs)
					_atmo_nodes.append({"node": cs, "kind": "drift", "vx": 9.0 + float(i) * 2.5, "vy": 0.0, "base_a": 0.72, "phase": float(i)})
			for i in range(2):
				if beam_tex:
					var bs := Sprite2D.new()
					bs.texture = beam_tex
					bs.position = Vector2(360.0 + i * 520.0, 195.0)
					bs.scale = Vector2(1.1, 1.1)
					bs.modulate.a = 0.30
					_ambient_layer.add_child(bs)
					_atmo_nodes.append({"node": bs, "kind": "pulse", "vx": 0.0, "vy": 0.0, "base_a": 0.30, "phase": float(i) * 2.1})
		"sunset":
			var cloud_tex := load("res://assets/sprites/environments/env_atmo_clouds.png") as Texture2D
			var beam_tex := load("res://assets/sprites/environments/env_atmo_sunbeam.png") as Texture2D
			for i in range(2):
				if cloud_tex:
					var cs := Sprite2D.new()
					cs.texture = cloud_tex
					cs.position = Vector2(260.0 + i * 580.0, 96.0)
					cs.scale = Vector2(0.78, 0.78)
					cs.modulate = Color(1.0, 0.76, 0.56, 0.70)
					cs.z_index = 2
					_world_root.add_child(cs)
					_atmo_nodes.append({"node": cs, "kind": "drift", "vx": 10.0, "vy": 0.0, "base_a": 0.70, "phase": float(i)})
			for i in range(2):
				if beam_tex:
					var bs := Sprite2D.new()
					bs.texture = beam_tex
					bs.position = Vector2(380.0 + i * 480.0, 210.0)
					bs.scale = Vector2(1.15, 1.15)
					bs.modulate = Color(1.0, 0.78, 0.45, 0.38)
					_ambient_layer.add_child(bs)
					_atmo_nodes.append({"node": bs, "kind": "pulse", "vx": 0.0, "vy": 0.0, "base_a": 0.38, "phase": float(i) * 1.5})
		"night":
			var ff_tex := load("res://assets/sprites/environments/env_atmo_fireflies.png") as Texture2D
			for i in range(2):
				if ff_tex:
					var fs := Sprite2D.new()
					fs.texture = ff_tex
					fs.position = Vector2(106, 289) if i == 0 else Vector2(1218, 318)
					fs.scale = Vector2(0.52, 0.52)
					fs.modulate.a = 0.44
					_ambient_layer.add_child(fs)
					_atmo_nodes.append({"node": fs, "kind": "bob", "vx": 0.0, "vy": 0.0, "base_y": fs.position.y, "base_a": 0.44, "phase": float(i) * 1.9})
		"mist":
			var mist_tex := load("res://assets/sprites/environments/env_atmo_mist.png") as Texture2D
			var ff_tex := load("res://assets/sprites/environments/env_atmo_fireflies.png") as Texture2D
			for i in range(4):
				if mist_tex:
					var ms := Sprite2D.new()
					ms.texture = mist_tex
					ms.position = Vector2(120.0 + i * 360.0, 195.0 + (i % 2) * 320.0)
					ms.scale = Vector2(1.25, 1.0)
					ms.modulate.a = 0.30
					_ambient_layer.add_child(ms)
					_atmo_nodes.append({"node": ms, "kind": "drift", "vx": -16.0 - float(i) * 2.0, "vy": 0.0, "base_a": 0.50, "phase": float(i)})
			for i in range(2):
				if ff_tex:
					var fs := Sprite2D.new()
					fs.texture = ff_tex
					fs.position = Vector2(62.0 + i * 1140.0, 360.0)
					fs.scale = Vector2(0.46, 0.46)
					fs.modulate.a = 0.34
					_ambient_layer.add_child(fs)
					_atmo_nodes.append({"node": fs, "kind": "bob", "vx": 0.0, "vy": 0.0, "base_y": fs.position.y, "base_a": 0.34, "phase": float(i) * 2.3})
		"snow":
			var wind_tex := load("res://assets/sprites/environments/env_atmo_snow_wind.png") as Texture2D
			for i in range(3):
				if wind_tex:
					var ws := Sprite2D.new()
					ws.texture = wind_tex
					ws.position = Vector2(220.0 + i * 440.0, 220.0 + i * 165.0)
					ws.scale = Vector2(1.05, 0.90)
					ws.modulate.a = 0.28
					_ambient_layer.add_child(ws)
					_atmo_nodes.append({"node": ws, "kind": "drift", "vx": -62.0 - float(i) * 10.0, "vy": 8.0, "base_a": 0.45, "phase": float(i)})
		"volcano":
			var mist_tex := load("res://assets/sprites/environments/env_atmo_mist.png") as Texture2D
			var ff_tex := load("res://assets/sprites/environments/env_atmo_fireflies.png") as Texture2D
			for i in range(3):
				if mist_tex:
					var ms := Sprite2D.new()
					ms.texture = mist_tex
					ms.position = Vector2(180.0 + i * 440.0, 200.0 + (i % 2) * 310.0)
					ms.scale = Vector2(1.2, 0.95)
					ms.modulate = Color(1.0, 0.56, 0.44, 0.28)
					_ambient_layer.add_child(ms)
					_atmo_nodes.append({"node": ms, "kind": "drift", "vx": -18.0 - float(i) * 2.0, "vy": 0.0, "base_a": 0.40, "phase": float(i)})
			for i in range(2):
				if ff_tex:
					var fs := Sprite2D.new()
					fs.texture = ff_tex
					fs.position = Vector2(88.0 + i * 1100.0, 340.0)
					fs.scale = Vector2(0.48, 0.48)
					fs.modulate = Color(1.0, 0.72, 0.36, 0.42)
					_ambient_layer.add_child(fs)
					_atmo_nodes.append({"node": fs, "kind": "bob", "vx": 0.0, "vy": 0.0, "base_y": fs.position.y, "base_a": 0.42, "phase": float(i) * 2.1})


func _build_hud() -> void:
	_hud_layer = CanvasLayer.new()
	_hud_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_hud_layer)

	_hud_root = Control.new()
	_hud_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud_layer.add_child(_hud_root)

	var right_box := HBoxContainer.new()
	_top_hud_row = right_box
	right_box.add_theme_constant_override("separation", 6)
	right_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud_root.add_child(right_box)

	# Wave Bar
	var wave_wrap := VBoxContainer.new()
	wave_wrap.custom_minimum_size = Vector2(182.0, 66.0)
	wave_wrap.alignment = BoxContainer.ALIGNMENT_CENTER
	wave_wrap.add_theme_constant_override("separation", 2)
	wave_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	right_box.add_child(wave_wrap)

	_wave_label = Label.new()
	_wave_label.text = "Đợt 0 / 6"
	_wave_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_wave_label.add_theme_font_size_override("font_size", 14)
	_wave_label.add_theme_color_override("font_color", Color(0.98, 0.93, 0.80))
	_wave_label.add_theme_color_override("font_outline_color", Color(0.12, 0.08, 0.06, 0.94))
	_wave_label.add_theme_constant_override("outline_size", 4)
	wave_wrap.add_child(_wave_label)

	var bar_holder := Control.new()
	bar_holder.custom_minimum_size = Vector2(180.0, 34.0)
	bar_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wave_wrap.add_child(bar_holder)

	var bar_bg := TextureRect.new()
	bar_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bar_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	bar_bg.texture = load("res://assets/sprites/ui/ui_wave_bar.png") as Texture2D
	bar_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bar_bg.modulate = Color(0.62, 0.56, 0.52, 1.0)
	bar_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar_holder.add_child(bar_bg)

	_wave_fill_clip = Control.new()
	_wave_fill_clip.position = Vector2(22.0, 10.0)
	_wave_fill_clip.size = Vector2(136.0, 14.0)
	_wave_fill_clip.clip_contents = true
	_wave_fill_clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar_holder.add_child(_wave_fill_clip)

	var bar_fill := ColorRect.new()
	bar_fill.color = Color(0.24, 0.84, 0.22, 0.95)
	bar_fill.size = Vector2(136.0, 14.0)
	bar_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_wave_fill_clip.add_child(bar_fill)

	_wave_oni_head = TextureRect.new()
	_wave_oni_head.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_wave_oni_head.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_wave_oni_head.custom_minimum_size = Vector2(28.0, 28.0)
	_wave_oni_head.texture = load("res://assets/sprites/ui/ui_oni_head.png") as Texture2D
	_wave_oni_head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar_holder.add_child(_wave_oni_head)
	_wave_oni_head.position = Vector2(16.0, 3.0)
	_wave_oni_head.size = Vector2(28.0, 28.0)

	# Auto-Play 5x (10m) Button
	_auto_btn = Button.new()
	_auto_btn.text = "AUTO 5x"
	_auto_btn.custom_minimum_size = Vector2(114, 46)
	_auto_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_auto_btn.add_theme_font_size_override("font_size", 11)
	_auto_btn.icon = load("res://assets/sprites/ui/ui_kitsune_auto.png") as Texture2D
	_auto_btn.expand_icon = true
	_auto_btn.tooltip_text = "Tự chơi thông minh 5x trong 10 phút (Phím A)"
	_auto_btn.pressed.connect(_on_toggle_auto_play)
	right_box.add_child(_auto_btn)

	# Shovel Button
	_shovel_btn = _make_hud_icon_btn("res://assets/sprites/ui/ui_btn_shovel.png", Vector2(46, 46), "Xẻng thu hồi cây (Phím X)")
	_shovel_btn.pressed.connect(_on_toggle_shovel)
	right_box.add_child(_shovel_btn)

	# Speed Button (1x / 2x / 5x)
	_speed_btn = _make_hud_icon_btn("res://assets/sprites/ui/ui_btn_speed.png", Vector2(46, 46), "Tốc độ 1x / 2x / 5x (Phím Tab)")
	_speed_btn.pressed.connect(_on_toggle_speed)
	right_box.add_child(_speed_btn)

	_speed_badge = Label.new()
	_speed_badge.text = "1x"
	_speed_badge.position = Vector2(18, 28)
	_speed_badge.size = Vector2(28, 18)
	_speed_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_speed_badge.add_theme_font_size_override("font_size", 12)
	_speed_badge.add_theme_color_override("font_color", Color.WHITE)
	_speed_badge.add_theme_color_override("font_shadow_color", Color.BLACK)
	_speed_badge.add_theme_constant_override("shadow_offset_x", 1)
	_speed_badge.add_theme_constant_override("shadow_offset_y", 1)
	_speed_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_speed_btn.add_child(_speed_badge)

	# Sound Toggle Button
	var init_sound_tex := "res://assets/sprites/ui/ui_btn_sound_muted.png" if GameData.sound_muted else "res://assets/sprites/ui/ui_btn_sound.png"
	_sound_btn = _make_hud_icon_btn(init_sound_tex, Vector2(42, 42), "Bật / Tắt Âm Thanh")
	_sound_btn.pressed.connect(_on_toggle_sound)
	right_box.add_child(_sound_btn)

	# Pause Button
	var pause_btn := _make_hud_icon_btn("res://assets/sprites/ui/ui_btn_pause.png", Vector2(46, 46), "Tạm dừng (Phím Space)")
	pause_btn.pressed.connect(_on_toggle_pause)
	right_box.add_child(pause_btn)

	# Huge Wave Banner with Gardener Alert Portrait
	_banner_container = PanelContainer.new()
	_banner_container.anchor_left = 0.5
	_banner_container.anchor_right = 0.5
	_banner_container.anchor_top = 0.5
	_banner_container.anchor_bottom = 0.5
	_banner_container.offset_left = -280.0
	_banner_container.offset_right = 280.0
	_banner_container.offset_top = -48.0
	_banner_container.offset_bottom = 48.0
	_banner_container.visible = false
	_banner_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var b_sb := StyleBoxFlat.new()
	b_sb.bg_color = Color(0.68, 0.11, 0.09, 0.92)
	b_sb.border_color = Color(0.96, 0.78, 0.24)
	b_sb.set_border_width_all(4)
	b_sb.set_corner_radius_all(14)
	_banner_container.add_theme_stylebox_override("panel", b_sb)
	_hud_root.add_child(_banner_container)

	var banner_h := HBoxContainer.new()
	banner_h.alignment = BoxContainer.ALIGNMENT_CENTER
	banner_h.add_theme_constant_override("separation", 12)
	banner_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_banner_container.add_child(banner_h)

	var alert_ic := TextureRect.new()
	alert_ic.texture = load("res://assets/sprites/ui/gardener_alert.png") as Texture2D
	alert_ic.custom_minimum_size = Vector2(68, 68)
	alert_ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	alert_ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	alert_ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	banner_h.add_child(alert_ic)

	_banner_label = Label.new()
	_banner_label.text = "ĐỢT YÊU QUÁI LỚN ĐANG TRÀN TỚI!"
	_banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_banner_label.add_theme_font_size_override("font_size", 22)
	_banner_label.add_theme_color_override("font_color", Color(1.0, 0.94, 0.72))
	banner_h.add_child(_banner_label)

	_build_bottom_hud()
	get_viewport().size_changed.connect(_update_hud_safe_area)
	get_window().focus_entered.connect(_update_hud_safe_area)
	_update_hud_safe_area()


func _update_hud_safe_area() -> void:
	_apply_hud_safe_area(SAFE_AREA.viewport_insets(get_window()))


func _apply_hud_safe_area(insets: Vector4) -> void:
	_hud_root.offset_left = insets.x
	_hud_root.offset_top = insets.y
	_hud_root.offset_right = -insets.z
	_hud_root.offset_bottom = -insets.w

	var view_size := get_viewport_rect().size
	var safe_size := view_size - Vector2(insets.x + insets.z, insets.y + insets.w)
	var available_width := maxf(1.0, safe_size.x - HUD_SIDE_MARGIN * 2.0)
	_bottom_hud.size = _bottom_hud.get_combined_minimum_size()
	var bottom_scale := minf(BOTTOM_HUD_SCALE, available_width / _bottom_hud.size.x)
	_bottom_hud.scale = Vector2.ONE * bottom_scale
	var bottom_size := _bottom_hud.size * bottom_scale
	_bottom_hud.position = Vector2((safe_size.x - bottom_size.x) * 0.5, safe_size.y - bottom_size.y - HUD_EDGE_MARGIN)

	_top_hud_row.size = _top_hud_row.get_combined_minimum_size()
	var top_scale := minf(1.0, available_width / _top_hud_row.size.x)
	_top_hud_row.scale = Vector2.ONE * top_scale
	var top_size := _top_hud_row.size * top_scale
	var stage_right := (view_size.x + BATTLEFIELD_REFERENCE_SIZE.x) * 0.5
	var top_right := minf(safe_size.x, stage_right - insets.x) - HUD_SIDE_MARGIN
	_top_hud_row.position = Vector2(top_right - top_size.x, HUD_EDGE_MARGIN)

	# Reserve space for the toolbar while keeping both ends of the board in view.
	var field_top := GameData.GRID_ORIGIN.y - 34.0
	var field_bottom := GameData.GRID_ORIGIN.y + GameData.CELL_SIZE.y * GameData.GRID_ROWS + 28.0
	var view_top := insets.y + HUD_EDGE_MARGIN + top_size.y + 8.0
	var view_bottom := insets.y + _bottom_hud.position.y - 8.0
	var board_zoom := clampf((view_bottom - view_top) / (field_bottom - field_top), 0.5, 1.0)
	var original_origin := (view_size.y - BATTLEFIELD_REFERENCE_SIZE.y * board_zoom) * 0.5
	var origin_y := minf(original_origin, view_bottom - field_bottom * board_zoom)
	origin_y = maxf(origin_y, view_top - field_top * board_zoom)
	_camera.zoom = Vector2.ONE * board_zoom
	_camera.position.y = (view_size.y * 0.5 - origin_y) / board_zoom
	_camera.force_update_scroll()
	_fit_world_backdrop.call()

	var grid_left := view_size.x * 0.5 + (GameData.GRID_ORIGIN.x - _camera.position.x) * board_zoom - insets.x
	var counter_room := maxf(1.0, grid_left - HUD_SIDE_MARGIN * 2.0)
	var counter_scale := minf(1.10, counter_room / _flame_counter.size.x)
	_flame_counter.scale = Vector2.ONE * counter_scale
	var counter_size := _flame_counter.size * counter_scale
	var counter_left := minf(_bottom_hud.position.x + 8.0, grid_left - counter_size.x - HUD_SIDE_MARGIN)
	_flame_counter.position = Vector2(maxf(HUD_SIDE_MARGIN, counter_left), _bottom_hud.position.y - counter_size.y - 4.0)


func _build_bottom_hud() -> void:
	_bottom_hud = PanelContainer.new()
	_bottom_hud.custom_minimum_size = Vector2(994.0, 114.0)
	_bottom_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color(0.20, 0.095, 0.055, 0.96)
	panel.border_color = Color(0.78, 0.48, 0.19)
	panel.set_border_width_all(2)
	panel.set_corner_radius_all(14)
	panel.content_margin_left = 6.0
	panel.content_margin_right = 6.0
	panel.content_margin_top = 4.0
	panel.content_margin_bottom = 4.0
	_bottom_hud.add_theme_stylebox_override("panel", panel)
	_hud_root.add_child(_bottom_hud)

	var bottom_row := HBoxContainer.new()
	bottom_row.add_theme_constant_override("separation", 8)
	bottom_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bottom_hud.add_child(bottom_row)

	# Seed cards
	var deck_box := HBoxContainer.new()
	deck_box.alignment = BoxContainer.ALIGNMENT_CENTER
	deck_box.add_theme_constant_override("separation", 4)
	deck_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	deck_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	deck_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom_row.add_child(deck_box)

	_seed_cards.clear()
	for i in range(GameData.selected_deck.size()):
		var did: String = GameData.selected_deck[i]
		var card: SeedCard = SEED_CARD_SCRIPT.new()
		card.setup(did, i)
		card.card_pressed.connect(_on_card_pressed)
		card.card_drag_started.connect(_on_card_drag_started)
		deck_box.add_child(card)
		_seed_cards.append(card)

	_build_skills_bar(bottom_row)
	_build_flame_counter()


func _build_flame_counter() -> void:
	var pill_wrap := Control.new()
	_flame_counter = pill_wrap
	pill_wrap.size = Vector2(166.0, 86.0)
	pill_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud_root.add_child(pill_wrap)

	var pill_bg := TextureRect.new()
	pill_bg.texture = load("res://assets/sprites/ui/ui_resource_pill.png") as Texture2D
	pill_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	pill_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pill_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pill_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pill_wrap.add_child(pill_bg)

	_flame_hud_icon = TextureRect.new()
	_flame_hud_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_flame_hud_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_flame_hud_icon.custom_minimum_size = Vector2(40.0, 40.0)
	_flame_hud_icon.texture = load("res://assets/sprites/ui/ui_spirit_flame.png") as Texture2D
	_flame_hud_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pill_wrap.add_child(_flame_hud_icon)
	_flame_hud_icon.position = Vector2(20.0, 32.0)
	_flame_hud_icon.size = Vector2(40.0, 40.0)

	_flame_label = Label.new()
	_flame_label.text = str(spirit_flame)
	_flame_label.position = Vector2(68.0, 29.0)
	_flame_label.size = Vector2(82.0, 43.0)
	_flame_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_flame_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_flame_label.add_theme_font_size_override("font_size", 27)
	_flame_label.add_theme_color_override("font_color", Color(0.22, 0.11, 0.04))
	_flame_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pill_wrap.add_child(_flame_label)


func _build_skills_bar(parent: HBoxContainer) -> void:
	var skill_row := HBoxContainer.new()
	skill_row.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	skill_row.add_theme_constant_override("separation", 5)
	skill_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(skill_row)

	_skill_buttons.clear()
	_skill_cooldowns.clear()
	var tex_ready := load("res://assets/sprites/ui/ui_skill_frame_ready.png") as Texture2D
	var empty_sb := StyleBoxEmpty.new()
	for sid in GameData.ACTIVE_SKILL_ORDER:
		var sdata: Dictionary = GameData.ACTIVE_SKILLS[sid]
		_skill_cooldowns[sid] = 0.0
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(88, 94)
		btn.tooltip_text = "[%s] %s (%d Hỏa) — %s" % [sdata["hotkey"], sdata["name"], int(sdata["cost"]), sdata["desc"]]
		btn.pressed.connect(trigger_active_skill.bind(sid))
		btn.add_theme_stylebox_override("normal", empty_sb)
		btn.add_theme_stylebox_override("hover", empty_sb)
		btn.add_theme_stylebox_override("pressed", empty_sb)

		var frame_tex := TextureRect.new()
		frame_tex.name = "FrameTex"
		frame_tex.texture = tex_ready
		frame_tex.set_anchors_preset(Control.PRESET_FULL_RECT)
		frame_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		frame_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		frame_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(frame_tex)

		var ic := TextureRect.new()
		ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ic.position = Vector2(17, 14)
		ic.size = Vector2(54, 53)
		ic.texture = load(sdata["icon"]) as Texture2D
		ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(ic)

		var hk := Label.new()
		hk.text = str(sdata["hotkey"])
		hk.position = Vector2(9, 4)
		hk.add_theme_font_size_override("font_size", 12)
		hk.add_theme_color_override("font_color", Color(1.0, 0.89, 0.68))
		hk.add_theme_color_override("font_outline_color", Color(0.22, 0.09, 0.04))
		hk.add_theme_constant_override("outline_size", 3)
		hk.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(hk)

		var cost_lbl := Label.new()
		cost_lbl.name = "CostLbl"
		cost_lbl.text = "FREE" if int(sdata["cost"]) == 0 else str(sdata["cost"])
		cost_lbl.position = Vector2(6, 69)
		cost_lbl.size = Vector2(76, 20)
		cost_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cost_lbl.add_theme_font_size_override("font_size", 15)
		cost_lbl.add_theme_color_override("font_outline_color", Color(1.0, 0.91, 0.68))
		cost_lbl.add_theme_constant_override("outline_size", 3)
		cost_lbl.add_theme_color_override("font_color", Color(0.16, 0.36, 0.12))
		cost_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(cost_lbl)

		var cd_mask := ColorRect.new()
		cd_mask.name = "CdMask"
		cd_mask.color = Color(0.05, 0.04, 0.08, 0.56)
		cd_mask.position = Vector2(14, 13)
		cd_mask.size = Vector2(60, 56)
		cd_mask.visible = false
		cd_mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(cd_mask)

		var cd_lbl := Label.new()
		cd_lbl.name = "CdLbl"
		cd_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
		cd_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cd_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		cd_lbl.add_theme_font_size_override("font_size", 18)
		cd_lbl.add_theme_color_override("font_color", Color.WHITE)
		cd_lbl.visible = false
		cd_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(cd_lbl)

		skill_row.add_child(btn)
		_skill_buttons[sid] = btn


func _make_hud_icon_btn(tex_path: String, sz: Vector2, tip: String) -> TextureButton:
	var b := TextureButton.new()
	b.texture_normal = load(tex_path) as Texture2D
	b.custom_minimum_size = sz
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	b.ignore_texture_size = true
	b.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	b.tooltip_text = tip
	return b


func _build_modals() -> void:
	_modal_overlay = Control.new()
	_modal_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_modal_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_modal_overlay.visible = false
	_hud_root.add_child(_modal_overlay)

	var shadow_texture := GradientTexture2D.new()
	var falloff := Gradient.new()
	falloff.colors = PackedColorArray([Color(0.06, 0.04, 0.08, 0.48), Color(0.06, 0.04, 0.08, 0.0)])
	shadow_texture.gradient = falloff
	shadow_texture.fill = GradientTexture2D.FILL_RADIAL
	shadow_texture.fill_from = Vector2(0.5, 0.5)
	shadow_texture.fill_to = Vector2(0.5, 0.0)
	var shadow := TextureRect.new()
	shadow.texture = shadow_texture
	shadow.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	shadow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shadow.set_anchors_preset(Control.PRESET_CENTER)
	shadow.offset_left = -430.0
	shadow.offset_right = 430.0
	shadow.offset_top = -305.0
	shadow.offset_bottom = 305.0
	_modal_overlay.add_child(shadow)

	_modal_scroll = TextureRect.new()
	_modal_scroll.texture = load("res://assets/sprites/ui/ui_panel_scroll.png") as Texture2D
	_modal_scroll.anchor_left = 0.5
	_modal_scroll.anchor_right = 0.5
	_modal_scroll.anchor_top = 0.5
	_modal_scroll.anchor_bottom = 0.5
	_modal_scroll.offset_left = -280.0
	_modal_scroll.offset_right = 280.0
	_modal_scroll.offset_top = -210.0
	_modal_scroll.offset_bottom = 210.0
	_modal_scroll.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_modal_scroll.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_modal_overlay.add_child(_modal_scroll)

	_modal_banner = TextureRect.new()
	_modal_banner.position = Vector2(105, -50)
	_modal_banner.size = Vector2(350, 156)
	_modal_banner.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_modal_banner.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_modal_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_modal_scroll.add_child(_modal_banner)

	_modal_portrait = TextureRect.new()
	_modal_portrait.position = Vector2(-78, 224)
	_modal_portrait.size = Vector2(168, 168)
	_modal_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_modal_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_modal_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_modal_scroll.add_child(_modal_portrait)

	var v := VBoxContainer.new()
	v.position = Vector2(82, 132)
	v.size = Vector2(396, 172)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 12)
	_modal_scroll.add_child(v)

	_modal_title = Label.new()
	_modal_title.size = Vector2(396, 44)
	_modal_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_modal_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_modal_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_modal_scroll.add_child(_modal_title)

	_modal_stars_row = HBoxContainer.new()
	_modal_stars_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_modal_stars_row.add_theme_constant_override("separation", 10)
	v.add_child(_modal_stars_row)
	for s in range(3):
		var st := TextureRect.new()
		st.custom_minimum_size = Vector2(44, 44)
		st.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		st.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_modal_stars_row.add_child(st)

	_modal_subtitle = Label.new()
	_modal_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_modal_subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_modal_subtitle.add_theme_font_size_override("font_size", 15)
	_modal_subtitle.add_theme_color_override("font_color", Color(0.28, 0.18, 0.10))
	v.add_child(_modal_subtitle)

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 14)
	v.add_child(btn_row)

	_modal_btn_primary = _make_action_btn("res://assets/sprites/ui/ui_btn_action_green.png", "TIẾP TỤC")
	_modal_btn_primary_lbl = _modal_btn_primary.get_child(0) as Label
	btn_row.add_child(_modal_btn_primary)

	_modal_btn_secondary = _make_action_btn("res://assets/sprites/ui/ui_btn_action_orange.png", "CHƠI LẠI")
	_modal_btn_secondary_lbl = _modal_btn_secondary.get_child(0) as Label
	btn_row.add_child(_modal_btn_secondary)

	_modal_btn_menu = Button.new()
	_modal_btn_menu.text = "Về Màn Hình Chọn Chương"
	_modal_btn_menu.custom_minimum_size = Vector2(220, 34)
	_modal_btn_menu.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var menu_button_style := StyleBoxFlat.new()
	menu_button_style.bg_color = Color(0.98, 0.89, 0.69, 0.95)
	menu_button_style.border_color = Color(0.57, 0.35, 0.18, 0.82)
	menu_button_style.set_border_width_all(1)
	menu_button_style.set_corner_radius_all(5)
	var menu_button_hover := menu_button_style.duplicate() as StyleBoxFlat
	menu_button_hover.bg_color = Color(1.0, 0.94, 0.78)
	_modal_btn_menu.add_theme_stylebox_override("normal", menu_button_style)
	_modal_btn_menu.add_theme_stylebox_override("hover", menu_button_hover)
	_modal_btn_menu.add_theme_stylebox_override("pressed", menu_button_hover)
	_modal_btn_menu.add_theme_color_override("font_color", Color(0.41, 0.20, 0.09))
	_modal_btn_menu.add_theme_color_override("font_hover_color", Color(0.41, 0.20, 0.09))
	_modal_btn_menu.pressed.connect(_on_back_to_menu)
	v.add_child(_modal_btn_menu)

	_portrait_overlay = ColorRect.new()
	_portrait_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_portrait_overlay.color = Color(0.08, 0.06, 0.05, 0.92)
	_portrait_overlay.visible = false
	_portrait_overlay.z_index = 200
	var pv := VBoxContainer.new()
	pv.set_anchors_preset(Control.PRESET_FULL_RECT)
	pv.alignment = BoxContainer.ALIGNMENT_CENTER
	pv.add_theme_constant_override("separation", 18)
	_portrait_overlay.add_child(pv)
	var rot_ic := TextureRect.new()
	rot_ic.texture = load("res://assets/sprites/ui/ui_rotate_landscape.png") as Texture2D
	rot_ic.custom_minimum_size = Vector2(180, 180)
	rot_ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rot_ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rot_ic.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	pv.add_child(rot_ic)
	var p_lbl := Label.new()
	p_lbl.text = "Vui lòng xoay ngang điện thoại\nđể tiếp tục bảo vệ Khu Vườn Edo!"
	p_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	p_lbl.add_theme_font_size_override("font_size", 28)
	p_lbl.add_theme_color_override("font_color", Color(0.98, 0.90, 0.72))
	pv.add_child(p_lbl)
	_hud_root.add_child(_portrait_overlay)
	get_viewport().size_changed.connect(_update_orientation)
	_update_orientation()


func _update_orientation() -> void:
	var viewport_size := get_viewport_rect().size
	var portrait := viewport_size.y > viewport_size.x * 1.05
	_portrait_overlay.visible = portrait
	_world_root.process_mode = Node.PROCESS_MODE_DISABLED if portrait else Node.PROCESS_MODE_PAUSABLE


func _make_action_btn(tex_path: String, text: String) -> TextureButton:
	var b := TextureButton.new()
	b.texture_normal = load(tex_path) as Texture2D
	b.custom_minimum_size = Vector2(174, 54)
	b.ignore_texture_size = true
	b.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	var lbl := Label.new()
	lbl.text = text
	lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 18)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.75))
	lbl.add_theme_constant_override("shadow_offset_y", 2)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(lbl)
	return b


func _process(delta: float) -> void:
	if get_tree().paused or battle_ended or _portrait_overlay.visible:
		return

	# Update seed card cooldowns & afford states
	for i in range(_seed_cards.size()):
		var card: SeedCard = _seed_cards[i]
		card.update_state(delta, spirit_flame, selected_card_idx == i and not shovel_mode)

	_process_skills(delta)
	_bg_time += delta

	if _water_material:
		_water_material.set_shader_parameter("water_time", _bg_time)
		_update_pond_koi(delta / Engine.time_scale)

	# Living flora breeze sway
	for fl in _flora_nodes:
		var sp: Sprite2D = fl["node"]
		var ph := float(fl["phase"])
		sp.rotation = sin(_bg_time * 1.9 + ph) * 0.025

	# Warm pulsing lantern halos
	for gl in _glow_nodes:
		var sp: Sprite2D = gl["node"]
		var ph := float(gl["phase"])
		var pulse := 0.27 + sin(_bg_time * 3.4 + ph) * 0.08
		sp.modulate.a = pulse

	# Drifting atmosphere (clouds, mist, fireflies, sunbeams, snow wind)
	for at in _atmo_nodes:
		var sp: Sprite2D = at["node"]
		var kind := str(at["kind"])
		if kind == "drift":
			sp.position.x += float(at["vx"]) * delta
			sp.position.y += float(at["vy"]) * delta
			if sp.position.x > 1480.0:
				sp.position.x = -200.0
			elif sp.position.x < -220.0:
				sp.position.x = 1480.0
			if sp.position.y > 700.0:
				sp.position.y = 140.0
		elif kind == "pulse":
			sp.modulate.a = clampf(float(at["base_a"]) + sin(_bg_time * 1.3 + float(at["phase"])) * 0.10, 0.12, 0.60)
		elif kind == "bob":
			var ph := _bg_time * 2.1 + float(at["phase"])
			sp.position.y = float(at["base_y"]) + sin(ph) * 14.0
			sp.modulate.a = clampf(float(at["base_a"]) + sin(ph * 1.7) * 0.18, 0.30, 0.95)

	# Ambient particles
	for p in _ambient_particles:
		var sp: Sprite2D = p["node"]
		sp.position.x += float(p["vx"]) * delta
		sp.position.y += float(p["vy"]) * delta
		sp.rotation += float(p["rot"]) * delta
		if sp.position.y > 740.0 or sp.position.x < -30.0:
			sp.position = Vector2(randf_range(80.0, 1340.0), 60.0)

	# Screen shake via Camera2D
	if _shake_timer > 0.0:
		_shake_timer = maxf(0.0, _shake_timer - delta)
		if _camera:
			_camera.offset = Vector2(randf_range(-_shake_amp, _shake_amp), randf_range(-_shake_amp, _shake_amp))
	elif _camera and _camera.offset != Vector2.ZERO:
		_camera.offset = Vector2.ZERO

	# Natural Sky Spirit Flame drop
	_natural_flame_timer += delta
	if _natural_flame_timer >= _natural_flame_interval():
		_natural_flame_timer = 0.0
		var col := randi_range(1, GameData.GRID_COLS - 2)
		var row := randi_range(1, GameData.GRID_ROWS - 2)
		var land_pos := GameData.cell_to_world(row, col) + Vector2(randf_range(-16, 16), randf_range(-12, 12))
		spawn_spirit_flame(Vector2(land_pos.x, 108.0), land_pos, GameData.get_flame_value(), true)

	# Auto-placement highlight decay (in real seconds)
	if _auto_highlight_timer > 0.0:
		_auto_highlight_timer = maxf(0.0, _auto_highlight_timer - delta / maxf(1.0, Engine.time_scale))
		if _auto_highlight_timer <= 0.0 and selected_defender_id == "" and not shovel_mode:
			_cell_highlight.visible = false
			_ghost_sprite.visible = false
			if _plant_ring:
				_plant_ring.visible = false

	# 10-Minute Real-Time Auto-Play Countdown & AI Loop
	if GameData.auto_play_active:
		var rem := GameData.get_auto_play_remaining_sec()
		if rem <= 0.0:
			GameData.stop_auto_play()
			set_game_speed(1.0)
			_refresh_auto_btn()
			_show_banner("ĐÃ HOÀN THÀNH 10 PHÚT TỰ CHƠI 5x!")
		else:
			_refresh_auto_btn()
			_auto_ai_timer += delta
			if _auto_ai_timer >= 0.45:
				_auto_ai_timer = 0.0
				_step_auto_play_decision()

	# Wave spawning
	_process_waves(delta)


func _natural_flame_interval() -> float:
	return float(level_cfg.get("natural_flame_interval", 8.5))


func _preparation_speed() -> float:
	return minf(speed_multiplier, PREPARATION_MAX_SPEED)


func _process_waves(delta: float) -> void:
	if not _spawn_queue.is_empty():
		_spawn_stagger_timer -= delta
		if _spawn_stagger_timer <= 0.0:
			var next_spawn: Dictionary = _spawn_queue.pop_front()
			spawn_enemy(next_spawn["id"], int(next_spawn["lane"]))
			_spawn_stagger_timer = OPENING_SPAWN_STAGGER if _wave_index == 1 else 0.65
		return

	var waves: Array = level_cfg.get("waves", [])
	if _wave_index < waves.size():
		var preparing := _wave_index == 0
		var time_step := delta
		if not preparing and GameData.auto_play_active and _count_active_enemies() == 0:
			time_step *= 2.5
		_wave_timer += time_step
		var next_wave: Dictionary = waves[_wave_index]
		var delay := float(next_wave["delay"]) * (1.0 if preparing else COMBAT_WAVE_DELAY_MULTIPLIER)
		if _wave_timer >= delay:
			_wave_timer = 0.0
			_wave_index += 1
			if preparing:
				Engine.time_scale = speed_multiplier
			_update_wave_hud()
			if bool(next_wave.get("huge", false)):
				_show_huge_wave_banner()
			var spawns: Array = next_wave["spawns"]
			var lane_offset := randi_range(0, GameData.GRID_ROWS - 1)
			for i in range(spawns.size()):
				_spawn_queue.append({
					"id": str(spawns[i]),
					"lane": (i + lane_offset) % GameData.GRID_ROWS,
				})
			if GameData.auto_play_active and not preparing:
				var extra_pool := ["tieu_yeu", "oni_nho", "kappa", "nekomata", "tengu", "samurai_ma", "ran_ong"]
				for r in range(spawns.size(), GameData.GRID_ROWS):
					var extra_id: String = extra_pool[(level_id + _wave_index + r) % extra_pool.size()]
					_spawn_queue.append({
						"id": extra_id,
						"lane": (r + lane_offset) % GameData.GRID_ROWS,
					})
			_spawn_stagger_timer = 0.0
		elif preparing:
			_update_preparation_label(delay)
	else:
		if _count_active_enemies() == 0:
			_trigger_victory()


func _count_active_enemies() -> int:
	var cnt := 0
	for r in range(GameData.GRID_ROWS):
		for enemy in _enemies_by_lane[r]:
			if is_instance_valid(enemy):
				cnt += 1
	return cnt


func _show_banner(msg: String) -> void:
	_banner_label.text = msg
	_banner_container.visible = true
	_banner_container.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_interval(1.9)
	tw.tween_property(_banner_container, "modulate:a", 0.0, 0.5)
	tw.tween_callback(func(): _banner_container.visible = false)


func _show_huge_wave_banner() -> void:
	AudioManager.play_sfx("temple_bell", -3.0, 0.0)
	_show_banner("ĐỢT YÊU QUÁI LỚN ĐANG TRÀN TỚI!")


func _input(event: InputEvent) -> void:
	if battle_ended or (_portrait_overlay and _portrait_overlay.visible):
		return

	if event is InputEventKey and event.pressed and not event.echo:
		var kc: int = event.keycode
		if kc >= KEY_1 and kc <= KEY_8:
			var idx := kc - KEY_1
			if idx < _seed_cards.size():
				_on_card_pressed(_seed_cards[idx].defender_id, idx)
		elif kc == KEY_X:
			_on_toggle_shovel()
		elif kc == KEY_Q:
			trigger_active_skill("skill_matcha_tea")
		elif kc == KEY_W:
			trigger_active_skill("skill_frost_chime")
		elif kc == KEY_E:
			trigger_active_skill("skill_thunder_scroll")
		elif kc == KEY_TAB:
			_on_toggle_speed()
		elif kc == KEY_A:
			_on_toggle_auto_play()
		elif kc == KEY_SPACE:
			_on_toggle_pause()
		elif kc == KEY_ESCAPE:
			_clear_selection()
		return

	if get_tree().paused:
		return

	if event is InputEventMouseMotion:
		var motion := event as InputEventMouseMotion
		var viewport_to_world := get_canvas_transform().affine_inverse()
		var world_pos := viewport_to_world * motion.position
		var previous_pos := viewport_to_world * (motion.position - motion.relative)
		_collect_flames_along(previous_pos, world_pos)
		_update_hover_preview(world_pos)
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		var world_pos := get_canvas_transform().affine_inverse() * mb.position
		if mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed:
			_clear_selection()
			return
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				if _hud_contains(_top_hud_row, mb.position) or _hud_contains(_bottom_hud, mb.position):
					return
				if _collect_flames_along(world_pos, world_pos):
					return
				if not is_dragging_card:
					_handle_grid_tap(world_pos)
			elif is_dragging_card:
				_handle_grid_tap(world_pos)
				_clear_selection()


func _hud_contains(control: Control, viewport_pos: Vector2) -> bool:
	var local_pos := control.get_global_transform_with_canvas().affine_inverse() * viewport_pos
	return Rect2(Vector2.ZERO, control.size).has_point(local_pos)


func _collect_flames_along(from: Vector2, to: Vector2) -> bool:
	var hit_any := false
	for node in _flame_layer.get_children():
		if node is not SpiritFlame or node.collected:
			continue
		var closest := Geometry2D.get_closest_point_to_segment(node.position, from, to)
		if node.is_point_inside(closest):
			node.collect()
			hit_any = true
	return hit_any


func _update_hover_preview(probe_pos: Vector2) -> void:
	_occupied_hint.hide()
	if selected_defender_id == "" and not shovel_mode:
		_cell_highlight.visible = false
		_ghost_sprite.visible = false
		if _plant_ring:
			_plant_ring.visible = false
		return
	var cell := GameData.world_to_cell(probe_pos)
	if cell.x < 0:
		_cell_highlight.visible = false
		_ghost_sprite.visible = false
		if _plant_ring:
			_plant_ring.visible = false
		return

	_cell_highlight.visible = true
	_cell_highlight.position = GameData.GRID_ORIGIN + Vector2(cell.y * GameData.CELL_SIZE.x, cell.x * GameData.CELL_SIZE.y)

	if shovel_mode:
		_cell_highlight.color = Color(0.95, 0.28, 0.25, 0.42) if _is_cell_occupied(cell.x, cell.y) else Color(0.7, 0.7, 0.7, 0.18)
		_ghost_sprite.visible = false
		if _plant_ring:
			_plant_ring.visible = false
	elif _is_cell_occupied(cell.x, cell.y):
		_cell_highlight.color = Color(1.0, 0.66, 0.16, 0.30)
		_occupied_hint.show()
		_ghost_sprite.hide()
		_plant_ring.hide()
	else:
		var can_place := can_plant_at(cell.x, cell.y, selected_defender_id)
		_cell_highlight.color = Color(0.28, 0.96, 0.42, 0.26) if can_place else Color(0.95, 0.28, 0.25, 0.30)
		_ghost_sprite.visible = true
		_ghost_sprite.position = GameData.cell_to_world(cell.x, cell.y)
		_ghost_sprite.modulate = Color(1.0, 1.0, 1.0, 0.65) if can_place else Color(1.0, 0.45, 0.45, 0.55)
		if _plant_ring:
			_plant_ring.visible = true
			_plant_ring.position = _ghost_sprite.position
			_plant_ring.modulate = Color.WHITE if can_place else Color(1.0, 0.4, 0.4, 0.85)


func _handle_grid_tap(world_pos: Vector2) -> void:
	var cell := GameData.world_to_cell(world_pos)
	if cell.x < 0:
		_clear_selection()
		return
	if shovel_mode:
		if dig_defender(cell.x, cell.y) or dig_obstacle(cell.x, cell.y):
			shovel_mode = false
			_refresh_shovel_visual()
		return
	if selected_defender_id != "":
		if try_plant_defender(selected_defender_id, cell.x, cell.y, selected_card_idx):
			_clear_selection()


func _on_card_pressed(did: String, idx: int) -> void:
	if get_tree().paused or battle_ended:
		return
	AudioManager.play_sfx("ui_click")
	shovel_mode = false
	_refresh_shovel_visual()
	if selected_card_idx == idx and selected_defender_id == did:
		_clear_selection()
		return
	var card: SeedCard = _seed_cards[idx]
	if not card.is_ready_to_plant(spirit_flame):
		return
	selected_defender_id = did
	selected_card_idx = idx
	_ghost_sprite.texture = load(GameData.DEFENDERS[did]["icon"]) as Texture2D


func _on_card_drag_started(did: String, idx: int, viewport_pos: Vector2) -> void:
	if get_tree().paused or battle_ended:
		return
	var card: SeedCard = _seed_cards[idx]
	if not card.is_ready_to_plant(spirit_flame):
		return
	shovel_mode = false
	_refresh_shovel_visual()
	selected_defender_id = did
	selected_card_idx = idx
	is_dragging_card = true
	_ghost_sprite.texture = load(GameData.DEFENDERS[did]["icon"]) as Texture2D
	_update_hover_preview(get_canvas_transform().affine_inverse() * viewport_pos)


func _clear_selection() -> void:
	selected_defender_id = ""
	selected_card_idx = -1
	shovel_mode = false
	is_dragging_card = false
	if _cell_highlight:
		_cell_highlight.visible = false
	if _plant_ring:
		_plant_ring.visible = false
	if _ghost_sprite:
		_ghost_sprite.visible = false
	_refresh_shovel_visual()


func _on_toggle_shovel() -> void:
	if get_tree().paused or battle_ended:
		return
	AudioManager.play_sfx("ui_click")
	var next := not shovel_mode
	_clear_selection()
	shovel_mode = next
	_refresh_shovel_visual()


func _refresh_shovel_visual() -> void:
	if _shovel_btn:
		_shovel_btn.modulate = Color(1.0, 0.55, 0.45, 1.0) if shovel_mode else Color.WHITE
		_shovel_btn.scale = Vector2(1.08, 1.08) if shovel_mode else Vector2.ONE


func set_game_speed(mult: float) -> void:
	speed_multiplier = mult
	GameData.game_speed_multiplier = mult
	speed_2x = is_equal_approx(mult, 2.0)
	Engine.time_scale = _preparation_speed() if _wave_index == 0 else mult
	if _speed_badge:
		_speed_badge.text = "%dx" % int(round(mult))
	_update_wave_hud()


func _on_toggle_speed() -> void:
	if battle_ended:
		return
	AudioManager.play_sfx("ui_click")
	var cur_idx := 0
	for i in range(SPEED_STEPS.size()):
		if is_equal_approx(speed_multiplier, SPEED_STEPS[i]):
			cur_idx = i
			break
	var next_idx := (cur_idx + 1) % SPEED_STEPS.size()
	set_game_speed(SPEED_STEPS[next_idx])


func _on_toggle_auto_play() -> void:
	if battle_ended:
		return
	AudioManager.play_sfx("ui_click")
	if GameData.auto_play_active:
		GameData.stop_auto_play()
		set_game_speed(1.0)
	else:
		GameData.start_auto_play(600.0, 5.0)
		set_game_speed(5.0)
	_refresh_auto_btn()


func _refresh_auto_btn() -> void:
	if _auto_btn == null:
		return
	if GameData.auto_play_active:
		var rem_i := int(ceil(GameData.get_auto_play_remaining_sec()))
		var mins := floori(float(rem_i) / 60.0)
		var secs := rem_i % 60
		_auto_btn.text = "AUTO 5x %02d:%02d" % [mins, secs]
		_auto_btn.modulate = Color(0.65, 1.0, 0.68, 1.0)
	else:
		_auto_btn.text = "AUTO 5x"
		_auto_btn.modulate = Color.WHITE


func _on_toggle_sound() -> void:
	GameData.sound_muted = not GameData.sound_muted
	AudioManager.set_muted(GameData.sound_muted)
	GameData.save_progress()
	if _sound_btn:
		var stex := "res://assets/sprites/ui/ui_btn_sound_muted.png" if GameData.sound_muted else "res://assets/sprites/ui/ui_btn_sound.png"
		_sound_btn.texture_normal = load(stex) as Texture2D
		_sound_btn.modulate = Color.WHITE


func _on_toggle_pause() -> void:
	if battle_ended:
		return
	AudioManager.play_sfx("ui_click")
	if get_tree().paused:
		_resume_game()
	else:
		_show_pause_modal()


func _resume_game() -> void:
	_modal_overlay.visible = false
	get_tree().paused = false


func _set_modal_heading(title: String, ribbon: Texture2D = null) -> void:
	_modal_banner.texture = ribbon
	_modal_banner.visible = ribbon != null
	_modal_title.text = title
	_modal_title.position = Vector2(82.0, 13.0 if ribbon else 95.0)
	_modal_title.add_theme_font_size_override("font_size", 23 if ribbon else 28)
	_modal_title.add_theme_color_override("font_color", Color(1.0, 0.95, 0.81) if ribbon else Color(0.45, 0.14, 0.06))
	_modal_title.add_theme_color_override("font_outline_color", Color(0.30, 0.13, 0.12))
	_modal_title.add_theme_constant_override("outline_size", 4 if ribbon else 0)


func _show_pause_modal() -> void:
	get_tree().paused = true
	_modal_overlay.visible = true
	_set_modal_heading("TẠM DỪNG")
	if _modal_portrait:
		_modal_portrait.visible = true
		_modal_portrait.texture = load("res://assets/sprites/ui/gardener_tutorial.png") as Texture2D
	_modal_stars_row.visible = false
	_modal_subtitle.text = "%s — Đợt %d / %d" % [level_cfg["name"], _wave_index, level_cfg["waves"].size()]
	_rebind_btn(_modal_btn_primary, _resume_game)
	_modal_btn_primary_lbl.text = "TIẾP TỤC"
	_modal_btn_secondary.visible = true
	_rebind_btn(_modal_btn_secondary, _restart_level)
	_modal_btn_secondary_lbl.text = "CHƠI LẠI"


func _trigger_victory() -> void:
	if battle_ended:
		return
	battle_ended = true
	var keep_auto := GameData.auto_play_active and GameData.get_auto_play_remaining_sec() > 0.0
	if keep_auto:
		Engine.time_scale = speed_multiplier
	else:
		set_game_speed(1.0)
	AudioManager.play_sfx("victory", -2.0)

	var intact_komainu := 0
	for k in _komainu_by_lane:
		if is_instance_valid(k) and not k.spent:
			intact_komainu += 1
	var stars := 3 if intact_komainu >= 4 else (2 if intact_komainu >= 2 else 1)
	var reward_jade := GameData.record_level_win(level_id, stars)

	_modal_overlay.visible = true
	_set_modal_heading("CHIẾN THẮNG!", preload("res://assets/sprites/ui/ui_banner_victory.png"))
	if _modal_portrait:
		_modal_portrait.visible = true
		_modal_portrait.texture = load("res://assets/sprites/ui/gardener_victory.png") as Texture2D
	_modal_stars_row.visible = true
	var tex_on := load("res://assets/sprites/ui/ui_star_earned.png") as Texture2D
	var tex_off := load("res://assets/sprites/ui/ui_star_empty.png") as Texture2D
	for s in range(3):
		(_modal_stars_row.get_child(s) as TextureRect).texture = tex_on if s < stars else tex_off
	_modal_subtitle.text = "Bảo vệ thành công Linh Hỏa! (%d/5 Komainu nguyên vẹn • +%d Ngọc Magatama)" % [intact_komainu, reward_jade]

	if level_id < GameData.LEVELS.size():
		_rebind_btn(_modal_btn_primary, _next_level)
		_modal_btn_primary_lbl.text = "MÀN TIẾP"
		_modal_btn_secondary.show()
	else:
		_rebind_btn(_modal_btn_primary, _restart_level)
		_modal_btn_primary_lbl.text = "CHƠI LẠI"
		_modal_btn_secondary.hide()
	_rebind_btn(_modal_btn_secondary, _restart_level)
	_modal_btn_secondary_lbl.text = "ĐẤU LẠI"

	if keep_auto:
		get_tree().create_timer(1.5, true, false, true).timeout.connect(_auto_advance_level)


func _trigger_defeat() -> void:
	if battle_ended:
		return
	battle_ended = true
	var keep_auto := GameData.auto_play_active and GameData.get_auto_play_remaining_sec() > 0.0
	if keep_auto:
		Engine.time_scale = speed_multiplier
	else:
		set_game_speed(1.0)
	AudioManager.play_sfx("defeat", -2.0)

	_modal_overlay.visible = true
	_set_modal_heading("THẤT BẠI!", preload("res://assets/sprites/ui/ui_banner_defeat.png"))
	if _modal_portrait:
		_modal_portrait.visible = true
		_modal_portrait.texture = load("res://assets/sprites/ui/gardener_worried.png") as Texture2D
	_modal_stars_row.visible = false
	_modal_subtitle.text = "Yokai đã tiến vào ngôi nhà cổ Edo! Hãy điều chỉnh đội hình và thử lại."
	_rebind_btn(_modal_btn_primary, _restart_level)
	_modal_btn_primary_lbl.text = "THỬ LẠI"
	_modal_btn_secondary.visible = false

	if keep_auto:
		get_tree().create_timer(1.5, true, false, true).timeout.connect(_auto_advance_level)


func _auto_advance_level() -> void:
	if not is_inside_tree():
		return
	if not GameData.auto_play_active or GameData.get_auto_play_remaining_sec() <= 0.0:
		return
	get_tree().paused = false
	GameData.selected_level = (level_id % GameData.LEVELS.size()) + 1
	GameData.prepare_auto_play_loadout(GameData.selected_level)
	get_tree().reload_current_scene()


func _rebind_btn(btn: TextureButton, fn: Callable) -> void:
	for conn in btn.pressed.get_connections():
		btn.pressed.disconnect(conn["callable"])
	btn.pressed.connect(fn)


func _restart_level() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	get_tree().reload_current_scene()


func _next_level() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	GameData.selected_level = mini(GameData.LEVELS.size(), level_id + 1)
	get_tree().reload_current_scene()


func _on_back_to_menu() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_PATH)


## --- Public Battle API used by entities & automated gameplay verification ---

func _process_skills(delta: float) -> void:
	var tex_ready := load("res://assets/sprites/ui/ui_skill_frame_ready.png") as Texture2D
	var tex_cd := load("res://assets/sprites/ui/ui_skill_frame_cooldown.png") as Texture2D
	for sid in _skill_buttons.keys():
		var cd := float(_skill_cooldowns.get(sid, 0.0))
		if cd > 0.0:
			cd = maxf(0.0, cd - delta)
			_skill_cooldowns[sid] = cd
		var btn: Button = _skill_buttons[sid]
		var cost := int(GameData.ACTIVE_SKILLS[sid]["cost"])
		var ready := cd <= 0.0 and spirit_flame >= cost
		var frame_tex := btn.find_child("FrameTex", true, false) as TextureRect
		var cd_mask := btn.find_child("CdMask", true, false) as ColorRect
		var cd_lbl := btn.find_child("CdLbl", true, false) as Label
		var cost_lbl := btn.find_child("CostLbl", true, false) as Label
		if frame_tex:
			frame_tex.texture = tex_ready if ready else tex_cd
		if cd > 0.0:
			cd_mask.visible = true
			cd_lbl.visible = true
			cd_lbl.text = "%ds" % int(ceil(cd))
		else:
			cd_mask.visible = false
			cd_lbl.visible = false
		btn.modulate = Color.WHITE if ready else Color(0.84, 0.84, 0.88, 0.94)
		cost_lbl.add_theme_color_override(
			"font_color",
			Color(0.14, 0.42, 0.14) if spirit_flame >= cost else Color(0.75, 0.14, 0.14)
		)


func trigger_active_skill(sid: String) -> bool:
	if get_tree().paused or battle_ended or not GameData.ACTIVE_SKILLS.has(sid):
		return false
	if float(_skill_cooldowns.get(sid, 0.0)) > 0.0:
		return false
	var sdata: Dictionary = GameData.ACTIVE_SKILLS[sid]
	var cost := int(sdata["cost"])
	if spirit_flame < cost:
		return false
	spirit_flame -= cost
	_update_flame_hud()
	_skill_cooldowns[sid] = float(sdata["cooldown"])

	match sid:
		"skill_matcha_tea":
			AudioManager.play_sfx("heal_chime", -3.0)
			add_flame(100)
			for ally in get_all_defenders():
				if is_instance_valid(ally) and not ally.is_consuming:
					ally.heal(60.0)
					spawn_vfx("res://assets/sprites/fx/fx_heal_aura.png", Vector2i(4, 3), ally.position + Vector2(0, -8), 16.0, 0.75)
		"skill_frost_chime":
			AudioManager.play_sfx("stun_chime", -3.0)
			for enemy in get_all_enemies():
				if is_instance_valid(enemy) and not enemy.is_dying():
					enemy.apply_slow(0.50, 6.0)
					spawn_vfx("res://assets/sprites/fx/fx_frost_chime_wave.png", Vector2i(4, 3), enemy.position + Vector2(0, -8), 18.0, 0.90)
		"skill_thunder_scroll":
			AudioManager.play_sfx("explosion", -2.0)
			trigger_screen_shake(8.0, 0.30)
			for enemy in get_all_enemies():
				if is_instance_valid(enemy) and not enemy.is_dying():
					enemy.take_damage(260.0, true)
					enemy.apply_stun(1.5)
					spawn_vfx("res://assets/sprites/fx/fx_thunder_strike.png", Vector2i(4, 3), enemy.position + Vector2(0, 14), 20.0, 1.05)
	return true


func add_flame(amount: int) -> void:
	spirit_flame += amount
	_update_flame_hud()


func drain_flame(amount: int) -> void:
	spirit_flame = maxi(0, spirit_flame - amount)
	_update_flame_hud()


func _update_flame_hud() -> void:
	if _flame_label:
		_flame_label.text = str(spirit_flame)


func _update_wave_hud() -> void:
	var waves_arr: Array = level_cfg.get("waves", [])
	var total: int = waves_arr.size()
	if _wave_label:
		if _wave_index == 0 and total > 0:
			_update_preparation_label(float(waves_arr[0]["delay"]))
		else:
			_wave_label.text = "Đợt %d / %d" % [_wave_index, total]
	if total > 0 and _wave_fill_clip and _wave_oni_head:
		var ratio := clampf(float(_wave_index) / float(total), 0.05, 1.0)
		_wave_fill_clip.size.x = 136.0 * ratio
		_wave_oni_head.position = Vector2(18.0 + 116.0 * ratio, 3.0)
		_wave_oni_head.size = Vector2(28.0, 28.0)


func _update_preparation_label(delay: float) -> void:
	var seconds_left := ceili((delay - _wave_timer) / _preparation_speed())
	_wave_label.text = "Chuẩn bị · %ds" % seconds_left


func _is_cell_occupied(row: int, col: int) -> bool:
	return is_instance_valid(_grid_defenders[row][col]) or is_instance_valid(_grid_obstacles[row][col])


func can_plant_at(row: int, col: int, did: String) -> bool:
	if row < 0 or row >= GameData.GRID_ROWS or col < 0 or col >= GameData.GRID_COLS:
		return false
	if _is_cell_occupied(row, col):
		return false
	var cost := int(GameData.DEFENDERS[did]["cost"])
	return spirit_flame >= cost


func try_plant_defender(did: String, row: int, col: int, card_idx: int = -1, ignore_cost_and_cd: bool = false) -> Defender:
	if row < 0 or row >= GameData.GRID_ROWS or col < 0 or col >= GameData.GRID_COLS:
		return null
	if _is_cell_occupied(row, col):
		return null
	var cost := int(GameData.DEFENDERS[did]["cost"])
	if not ignore_cost_and_cd:
		if spirit_flame < cost:
			return null
		if card_idx >= 0 and card_idx < _seed_cards.size():
			var c: SeedCard = _seed_cards[card_idx]
			if not c.is_ready_to_plant(spirit_flame):
				return null
			c.start_cooldown()
		spirit_flame -= cost
		_update_flame_hud()

	var def: Defender = DEFENDER_SCRIPT.new()
	var pos := GameData.cell_to_world(row, col)
	def.setup(self, did, row, col, pos)
	_defender_layer.add_child(def)
	_grid_defenders[row][col] = def
	if _water_lily_overlays[row][col] != null:
		_water_lily_overlays[row][col].visible = true
		var splash := Sprite2D.new()
		splash.texture = load("res://assets/sprites/tiles/water_splash_ring.png") as Texture2D
		splash.position = pos + Vector2(0, 8)
		splash.scale = Vector2(0.45, 0.45)
		splash.z_index = 68
		_vfx_layer.add_child(splash)
		var stw := create_tween()
		stw.set_parallel(true)
		stw.tween_property(splash, "scale", Vector2(0.95, 0.95), 0.35)
		stw.tween_property(splash, "modulate:a", 0.0, 0.35)
		stw.chain().tween_callback(splash.queue_free)
	spawn_vfx("res://assets/sprites/fx/fx_smoke_puff.png", Vector2i(4, 3), pos + Vector2(0, -8), 26.0, 0.46)
	AudioManager.play_sfx("plant", -5.0)
	return def


func dig_defender(row: int, col: int) -> bool:
	if row < 0 or row >= GameData.GRID_ROWS or col < 0 or col >= GameData.GRID_COLS:
		return false
	var def = _grid_defenders[row][col]
	if def == null or not is_instance_valid(def):
		return false
	var refund := int(round(float(def.cost) * GameData.get_shovel_refund_ratio()))
	add_flame(refund)
	_grid_defenders[row][col] = null
	if _water_lily_overlays[row][col] != null:
		_water_lily_overlays[row][col].visible = false
	spawn_vfx("res://assets/sprites/fx/fx_smoke_puff.png", Vector2i(4, 3), def.position + Vector2(0, -8), 18.0, 0.56)
	AudioManager.play_sfx("shovel", -5.0)
	def.queue_free()
	return true


func remove_defender(def: Defender) -> void:
	if def.row >= 0 and def.row < GameData.GRID_ROWS and def.col >= 0 and def.col < GameData.GRID_COLS:
		if _grid_defenders[def.row][def.col] == def:
			_grid_defenders[def.row][def.col] = null
			if _water_lily_overlays[def.row][def.col] != null:
				_water_lily_overlays[def.row][def.col].visible = false


func spawn_obstacle(oid: String, row: int, col: int) -> Obstacle:
	if row < 0 or row >= GameData.GRID_ROWS or col < 0 or col >= GameData.GRID_COLS:
		return null
	if _grid_obstacles[row][col] != null and is_instance_valid(_grid_obstacles[row][col]):
		return null
	if _grid_defenders[row][col] != null and is_instance_valid(_grid_defenders[row][col]):
		return null
	var obs: Obstacle = OBSTACLE_SCRIPT.new()
	var pos := GameData.cell_to_world(row, col)
	obs.setup(self, oid, row, col, pos)
	_defender_layer.add_child(obs)
	_grid_obstacles[row][col] = obs
	return obs


func dig_obstacle(row: int, col: int) -> bool:
	if row < 0 or row >= GameData.GRID_ROWS or col < 0 or col >= GameData.GRID_COLS:
		return false
	var obs = _grid_obstacles[row][col]
	if obs == null or not is_instance_valid(obs):
		return false
	AudioManager.play_sfx("shovel", -5.0)
	obs.destroy(true)
	return true


func remove_obstacle(obs: Obstacle) -> void:
	if obs.row >= 0 and obs.row < GameData.GRID_ROWS and obs.col >= 0 and obs.col < GameData.GRID_COLS:
		if _grid_obstacles[obs.row][obs.col] == obs:
			_grid_obstacles[obs.row][obs.col] = null


func spawn_enemy(eid: String, lane: int, x_pos: float = -1.0) -> Enemy:
	var clane := clampi(lane, 0, GameData.GRID_ROWS - 1)
	var grid_right := GameData.GRID_ORIGIN.x + GameData.GRID_COLS * GameData.CELL_SIZE.x
	var sx := x_pos if x_pos > 0.0 else grid_right + randf_range(31.0, 41.0)
	var sy := GameData.cell_to_world(clane, 0).y
	var enemy: Enemy = ENEMY_SCRIPT.new()
	enemy.setup(self, eid, clane, Vector2(sx, sy))
	_enemy_layer.add_child(enemy)
	_enemies_by_lane[clane].append(enemy)
	return enemy


func notify_enemy_lane_change(enemy: Enemy, old_lane: int, new_lane: int) -> void:
	if old_lane >= 0 and old_lane < GameData.GRID_ROWS:
		_enemies_by_lane[old_lane].erase(enemy)
	if new_lane >= 0 and new_lane < GameData.GRID_ROWS and not _enemies_by_lane[new_lane].has(enemy):
		_enemies_by_lane[new_lane].append(enemy)


func on_enemy_killed(enemy: Enemy) -> void:
	if enemy.lane >= 0 and enemy.lane < GameData.GRID_ROWS:
		_enemies_by_lane[enemy.lane].erase(enemy)


func on_enemy_reached_left(enemy: Enemy) -> void:
	if battle_ended or enemy.is_dying():
		return
	var k = _komainu_by_lane[enemy.lane]
	if is_instance_valid(k) and not k.spent:
		k.trigger()
		return
	if enemy.position.x <= GameData.GRID_ORIGIN.x - 52.0:
		_trigger_defeat()


func spawn_projectile(start_pos: Vector2, lane: int, kind: String, dmg: float) -> Projectile:
	var p: Projectile = PROJECTILE_SCRIPT.new()
	p.setup(self, start_pos, lane, kind, dmg)
	_projectile_layer.add_child(p)
	return p


func spawn_vfx(
	tex_path: String,
	grid: Vector2i,
	pos: Vector2,
	fps: float = 18.0,
	target_scale: float = 0.85,
	loop_duration: float = 0.0,
	velocity: Vector2 = Vector2.ZERO
) -> VfxEffect:
	var effect_name := tex_path.get_file().get_basename()
	var ground_effect := GROUND_VFX_OFFSETS.has(effect_name)
	pos.y += float(GROUND_VFX_OFFSETS.get(effect_name, 0.0))
	# Closely overlapping one-shots can share a visual cue.
	var opacity := 1.0
	if COMBAT_VFX.has(effect_name):
		if loop_duration <= 0.0 and velocity == Vector2.ZERO:
			for active in _vfx_layer.get_children():
				if active is VfxEffect and active.is_processing() and active.get_meta("effect_name", "") == effect_name:
					if active.position.distance_squared_to(pos) < 36.0 * 36.0:
						return active as VfxEffect
		var tuning: Vector3 = COMBAT_VFX[effect_name]
		target_scale *= tuning.x
		opacity = tuning.y
		fps *= tuning.z
	if not _vfx_textures.has(tex_path):
		_vfx_textures[tex_path] = load(tex_path) as Texture2D
	var vfx: VfxEffect
	if _idle_vfx.is_empty():
		vfx = VFX_SCRIPT.new()
		vfx.finished.connect(_recycle_vfx)
		_vfx_layer.add_child(vfx)
	else:
		vfx = _idle_vfx.pop_back()
		_vfx_layer.move_child(vfx, -1)
	vfx.position = pos
	vfx.z_index = 18 if ground_effect else 70
	vfx.set_meta("effect_name", effect_name)
	vfx.setup(_vfx_textures[tex_path], grid, fps, target_scale, loop_duration, velocity, Color(1, 1, 1, opacity))
	return vfx


func _recycle_vfx(effect: VfxEffect) -> void:
	if _idle_vfx.size() < VFX_POOL_LIMIT:
		_idle_vfx.append(effect)
	else:
		effect.queue_free()


func get_flame_hud_target() -> Vector2:
	var icon_center := _flame_hud_icon.get_global_transform_with_canvas() * (_flame_hud_icon.size * 0.5)
	return _flame_layer.get_global_transform_with_canvas().affine_inverse() * icon_center


func spawn_spirit_flame(start_pos: Vector2, ground_pos: Vector2, amount: int = 25, sky_drop: bool = false) -> SpiritFlame:
	var fl: SpiritFlame = FLAME_SCRIPT.new()
	fl.setup(self, start_pos, ground_pos, amount, sky_drop)
	_flame_layer.add_child(fl)
	return fl


func trigger_screen_shake(amp: float, duration: float) -> void:
	_shake_amp = maxf(_shake_amp, amp)
	_shake_timer = maxf(_shake_timer, duration)


func is_water_lane(lane: int) -> bool:
	return lane == int(level_cfg.get("water_lane", -1))


func get_enemies_in_lane(lane: int) -> Array:
	if lane < 0 or lane >= GameData.GRID_ROWS:
		return []
	var alive: Array = []
	for e in _enemies_by_lane[lane]:
		if is_instance_valid(e):
			alive.append(e)
	return alive


func get_all_enemies() -> Array:
	var all_e: Array = []
	for r in range(GameData.GRID_ROWS):
		for e in _enemies_by_lane[r]:
			if is_instance_valid(e):
				all_e.append(e)
	return all_e


func get_defenders_in_lane(lane: int) -> Array:
	if lane < 0 or lane >= GameData.GRID_ROWS:
		return []
	var out: Array = []
	for c in range(GameData.GRID_COLS):
		var d = _grid_defenders[lane][c]
		if is_instance_valid(d):
			out.append(d)
	return out


func get_all_defenders() -> Array:
	var out: Array = []
	for r in range(GameData.GRID_ROWS):
		for c in range(GameData.GRID_COLS):
			var d = _grid_defenders[r][c]
			if is_instance_valid(d):
				out.append(d)
	return out


func get_obstacles_in_lane(lane: int) -> Array:
	if lane < 0 or lane >= GameData.GRID_ROWS:
		return []
	var out: Array = []
	for c in range(GameData.GRID_COLS):
		var o = _grid_obstacles[lane][c]
		if is_instance_valid(o):
			out.append(o)
	return out


func get_all_obstacles() -> Array:
	var out: Array = []
	for r in range(GameData.GRID_ROWS):
		for c in range(GameData.GRID_COLS):
			var o = _grid_obstacles[r][c]
			if is_instance_valid(o):
				out.append(o)
	return out


func _flash_auto_placement(did: String, row: int, col: int) -> void:
	if _cell_highlight == null or _ghost_sprite == null:
		return
	if selected_defender_id != "" or shovel_mode:
		return
	_occupied_hint.hide()
	_cell_highlight.position = GameData.GRID_ORIGIN + Vector2(col * GameData.CELL_SIZE.x, row * GameData.CELL_SIZE.y)
	_cell_highlight.color = Color(0.28, 0.96, 0.42, 0.28)
	_cell_highlight.visible = true
	_ghost_sprite.texture = load(GameData.DEFENDERS[did]["icon"]) as Texture2D
	_ghost_sprite.position = GameData.cell_to_world(row, col)
	_ghost_sprite.modulate = Color(1.0, 1.0, 1.0, 0.72)
	_ghost_sprite.visible = true
	if _plant_ring:
		_plant_ring.position = _ghost_sprite.position
		_plant_ring.modulate = Color.WHITE
		_plant_ring.visible = true
	_auto_highlight_timer = 0.25


func _ai_try_plant(did: String, row: int, col: int, ready_cards: Dictionary) -> bool:
	if not ready_cards.has(did) or not can_plant_at(row, col, did):
		return false
	var def := try_plant_defender(did, row, col, int(ready_cards[did]), false)
	if def != null:
		_flash_auto_placement(did, row, col)
		return true
	return false


func _ai_try_plant_in_cols(did: String, row: int, cols: Array, ready_cards: Dictionary) -> bool:
	if not ready_cards.has(did):
		return false
	for col in cols:
		if _ai_try_plant(did, row, col, ready_cards):
			return true
	return false


func _setup_auto_play_showcase_formation() -> void:
	# Col 0: Economy line (Thần Đèn)
	for r in range(GameData.GRID_ROWS):
		try_plant_defender("than_den", r, 0, -1, true)
	# Col 1: Primary DPS & Slow (Tre Nỏ + Hồ Lô Băng)
	var col1_units := ["tre_no", "ho_lo_bang", "tre_no", "ho_lo_bang", "tre_no"]
	for r in range(GameData.GRID_ROWS):
		try_plant_defender(col1_units[r], r, 1, -1, true)
	# Col 2: Petals, Anti-Air Wind & Healing Aura
	var col2_units := ["dao_tien", "gio_loc", "chua_lanh", "gio_loc", "dao_tien"]
	for r in range(GameData.GRID_ROWS):
		try_plant_defender(col2_units[r], r, 2, -1, true)
	# Col 3: Armor-Piercing Short-Range Poison (Nấm Độc)
	for r in range(GameData.GRID_ROWS):
		try_plant_defender("nam_doc", r, 3, -1, true)
	# Col 4: Heavy Frontline Wall (Bí Ngô)
	for r in range(GameData.GRID_ROWS):
		try_plant_defender("bi_ngo", r, 4, -1, true)
	# Col 5: Forward Stun Traps (Phù Chú) where free of obstacles
	for r in [1, 3]:
		try_plant_defender("phu_chu", r, 5, -1, true)


func _step_auto_play_decision() -> void:
	if get_tree().paused or battle_ended:
		return

	# 1. Collect all uncollected Spirit Flames
	for node in _flame_layer.get_children():
		if node is SpiritFlame and not node.collected:
			node.collect()

	# 2. Gather living enemies & per-lane threats
	var alive_enemies: Array = []
	var lane_threats: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0]
	var lane_min_x: Array[float] = [2000.0, 2000.0, 2000.0, 2000.0, 2000.0]
	var lane_has_tengu: Array[bool] = [false, false, false, false, false]
	var min_enemy_x := 2000.0

	for e in get_all_enemies():
		if e.is_dying():
			continue
		alive_enemies.append(e)
		var r := clampi(e.lane, 0, GameData.GRID_ROWS - 1)
		var ex := float(e.position.x)
		min_enemy_x = minf(min_enemy_x, ex)
		lane_min_x[r] = minf(lane_min_x[r], ex)
		var weight := 100.0
		if e.is_boss:
			weight = 350.0
		elif e.enemy_id == "tengu":
			if e.is_flying:
				lane_has_tengu[r] = true
			weight = 160.0
		elif e.enemy_id == "samurai_ma" or e.enemy_id == "yuki_onna":
			weight = 160.0
		lane_threats[r] += weight + clampf(1200.0 - ex, 0.0, 1000.0) * 0.2

	# 3. Trigger Active Skills without wiping off-screen waves prematurely
	trigger_active_skill("skill_matcha_tea")
	if min_enemy_x < 400.0 and spirit_flame >= 150:
		trigger_active_skill("skill_thunder_scroll")
	if (alive_enemies.size() >= 5 or min_enemy_x < 520.0) and spirit_flame >= 125:
		trigger_active_skill("skill_frost_chime")

	# 4. Detonate Sake Barrels on enemies or clear back-column blockers
	for obs in get_all_obstacles():
		if obs.is_consuming:
			continue
		if obs.explodes_on_destroy:
			for e in alive_enemies:
				if absi(e.lane - obs.row) <= 1 and absf(e.position.x - obs.position.x) <= 135.0:
					dig_obstacle(obs.row, obs.col)
					break
		elif obs.col <= 4:
			dig_obstacle(obs.row, obs.col)

	# 5. Map ready cards from deck
	var ready_cards: Dictionary = {}
	for i in range(_seed_cards.size()):
		var card: SeedCard = _seed_cards[i]
		if card.is_ready_to_plant(spirit_flame) and not ready_cards.has(card.defender_id):
			ready_cards[card.defender_id] = i
	if ready_cards.is_empty():
		return

	# 6. Inspect current board defenders
	var producers := 0
	var healers := 0
	var total_defenders := 0
	var any_frozen_or_hurt := false
	var lane_attackers: Array[int] = [0, 0, 0, 0, 0]
	var lane_tanks: Array[int] = [0, 0, 0, 0, 0]
	var lane_has_wind: Array[bool] = [false, false, false, false, false]
	var lane_has_ice: Array[bool] = [false, false, false, false, false]

	for d in get_all_defenders():
		if d.is_consuming:
			continue
		total_defenders += 1
		if d.frozen_timer > 0.0 or d.hp < d.max_hp * 0.78:
			any_frozen_or_hurt = true
		var r := clampi(d.row, 0, GameData.GRID_ROWS - 1)
		match d.defender_id:
			"than_den":
				producers += 1
			"bi_ngo":
				lane_tanks[r] += 1
			"chua_lanh":
				healers += 1
			"gio_loc":
				lane_attackers[r] += 1
				lane_has_wind[r] = true
			"ho_lo_bang":
				lane_attackers[r] += 1
				lane_has_ice[r] = true
			"dao_tien", "tre_no", "nam_doc", "hoa_phuong", "meo_kiem", "cung_sam":
				lane_attackers[r] += 1
			"daruma_buff":
				healers += 1

	# 7. Sort lanes by threat vs existing firepower
	var sorted_lanes: Array[int] = [0, 1, 2, 3, 4]
	sorted_lanes.sort_custom(func(a: int, b: int) -> bool:
		var score_a := lane_threats[a] - float(lane_attackers[a]) * 110.0
		var score_b := lane_threats[b] - float(lane_attackers[b]) * 110.0
		return score_a > score_b
	)

	# Priority A: Pháo Hoa 3x3 bomb on boss or 3+ enemy cluster that pushed inside x < 680
	if ready_cards.has("phao_hoa") and not alive_enemies.is_empty():
		var best_cell := Vector2i(-1, -1)
		var best_score := 0
		for r in range(GameData.GRID_ROWS):
			for c in range(2, 7):
				if not can_plant_at(r, c, "phao_hoa"):
					continue
				var cx := GameData.cell_to_world(r, c).x
				var sc := 0
				for e in alive_enemies:
					if e.position.x < 680.0 and absi(e.lane - r) <= 1 and absf(e.position.x - cx) <= 145.0:
						if e.is_boss:
							sc += 3
						elif e.position.x < 520.0:
							sc += 2
						else:
							sc += 1
				if sc > best_score:
					best_score = sc
					best_cell = Vector2i(r, c)
		if best_score >= 3 and _ai_try_plant("phao_hoa", best_cell.x, best_cell.y, ready_cards):
			return

	# Priority B: Urgent defense on any threatened unguarded lane
	for r in sorted_lanes:
		if lane_threats[r] > 0.0 and lane_attackers[r] == 0 and (lane_min_x[r] < 820.0 or producers >= 2):
			if _ai_try_plant_in_cols("tre_no", r, [1, 2], ready_cards):
				return
			if _ai_try_plant_in_cols("cung_sam", r, [1, 2], ready_cards):
				return
			if _ai_try_plant_in_cols("hoa_phuong", r, [1, 2], ready_cards):
				return
			if _ai_try_plant_in_cols("ho_lo_bang", r, [1, 2], ready_cards):
				return
			if _ai_try_plant_in_cols("meo_kiem", r, [3, 2], ready_cards):
				return
			if _ai_try_plant_in_cols("dao_tien", r, [2, 1], ready_cards):
				return
			if _ai_try_plant_in_cols("nam_doc", r, [3, 2], ready_cards):
				return
			if _ai_try_plant_in_cols("gio_loc", r, [2, 1], ready_cards):
				return

	# Priority C: Economy up to 2 Thần Đèn first, or up to 5 in Col 0
	var prod_cap := 2 if producers < 2 else 5
	if producers < prod_cap and ready_cards.has("than_den"):
		for r in sorted_lanes:
			if _ai_try_plant("than_den", r, 0, ready_cards):
				return

	# Priority D: Anti-air Wind counter vs Tengu
	for r in sorted_lanes:
		if lane_has_tengu[r] and not lane_has_wind[r]:
			if _ai_try_plant_in_cols("gio_loc", r, [2, 1], ready_cards):
				return

	# Priority E: Frontline Bí Ngô tank strictly in Col 4
	for r in sorted_lanes:
		if lane_tanks[r] == 0 and (lane_threats[r] > 0.0 or total_defenders >= 5):
			if _ai_try_plant("bi_ngo", r, 4, ready_cards):
				return

	# Priority F: Healing Shrine in Cols [2, 1]
	if (any_frozen_or_hurt or total_defenders >= 4) and healers < 2:
		for r in [2, 1, 3, 0, 4]:
			if _ai_try_plant_in_cols("chua_lanh", r, [2, 1], ready_cards):
				return

	# Priority G: Ofuda stun trap strictly in front of tank line (Cols [5, 6])
	for r in sorted_lanes:
		if lane_min_x[r] > 420.0 and lane_min_x[r] < 980.0:
			if _ai_try_plant_in_cols("phu_chu", r, [5, 6], ready_cards):
				return

	# Priority H: Expand firepower cleanly in role-specific columns
	for r in sorted_lanes:
		if not lane_has_ice[r] and _ai_try_plant_in_cols("ho_lo_bang", r, [1, 2], ready_cards):
			return
		if _ai_try_plant_in_cols("hoa_phuong", r, [1, 2], ready_cards):
			return
		if _ai_try_plant_in_cols("cung_sam", r, [1, 2], ready_cards):
			return
		if _ai_try_plant_in_cols("tre_no", r, [1, 2], ready_cards):
			return
		if _ai_try_plant_in_cols("meo_kiem", r, [3, 2], ready_cards):
			return
		if _ai_try_plant_in_cols("daruma_buff", r, [2, 1], ready_cards):
			return
		if _ai_try_plant_in_cols("nam_doc", r, [3, 2], ready_cards):
			return
		if _ai_try_plant_in_cols("dao_tien", r, [2, 1], ready_cards):
			return
		if not lane_has_wind[r] and _ai_try_plant_in_cols("gio_loc", r, [2, 1], ready_cards):
			return
