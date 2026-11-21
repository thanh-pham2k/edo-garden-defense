extends Node2D

## Main lane-based battle controller for Edo Garden Defense.

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
var _grid_layer: Node2D
var _defender_layer: Node2D
var _enemy_layer: Node2D
var _projectile_layer: Node2D
var _vfx_layer: Node2D
var _flame_layer: Node2D
var _ambient_layer: Node2D
var _ghost_sprite: Sprite2D
var _cell_highlight: ColorRect

var _hud_layer: CanvasLayer
var _hud_root: Control
var _flame_label: Label
var _flame_pill_pos: Vector2 = Vector2(96.0, 48.0)
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
var _modal_overlay: ColorRect
var _modal_scroll: TextureRect
var _modal_banner: TextureRect
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
var _pointer_down_on_field: bool = false
var _auto_ai_timer: float = 0.0
var _auto_highlight_timer: float = 0.0


func _ready() -> void:
	get_tree().paused = false
	level_id = GameData.selected_level
	level_cfg = GameData.get_level_config(level_id)
	spirit_flame = int(level_cfg.get("starting_flame", 150)) + GameData.get_starting_flame_bonus()

	_init_data_structures()
	_build_world()
	_build_hud()
	_build_modals()
	AudioManager.start_bgm()
	set_game_speed(5.0 if GameData.auto_play_active else GameData.game_speed_multiplier)
	_refresh_auto_btn()
	_update_wave_hud()
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


func _build_world() -> void:
	_camera = Camera2D.new()
	_camera.position = Vector2(640.0, 360.0)
	_camera.enabled = true
	add_child(_camera)

	_world_root = Node2D.new()
	_world_root.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(_world_root)

	# Sky & Chapter Terrain Backdrop (extra wide for 20:9 & 4:3 aspect expand)
	var sky_rect := ColorRect.new()
	sky_rect.position = Vector2(-420, -220)
	sky_rect.size = Vector2(2120, 400)
	sky_rect.color = level_cfg["sky_top"]
	_world_root.add_child(sky_rect)

	var horizon_rect := ColorRect.new()
	horizon_rect.position = Vector2(-420, 80)
	horizon_rect.size = Vector2(2120, 110)
	horizon_rect.color = level_cfg["sky_bottom"]
	_world_root.add_child(horizon_rect)

	var ground_rect := ColorRect.new()
	ground_rect.position = Vector2(-420, 170)
	ground_rect.size = Vector2(2120, 860)
	ground_rect.color = level_cfg["ground_tint"]
	_world_root.add_child(ground_rect)

	# Scenic Chapter Backdrop Strip (from 08_backgrounds adapted panels)
	if level_cfg.has("bg_stem"):
		var bg_tex := load("res://assets/sprites/backgrounds/%s_1.png" % level_cfg["bg_stem"]) as Texture2D
		if bg_tex:
			for idx in range(3):
				var bg_sp := Sprite2D.new()
				bg_sp.texture = bg_tex
				bg_sp.position = Vector2(160.0 + idx * 480.0, 56.0)
				bg_sp.scale = Vector2(0.75, 0.75)
				bg_sp.flip_h = (idx % 2 == 1)
				bg_sp.z_index = 2
				_world_root.add_child(bg_sp)

	# Border garden path strips left & right (tinted to match chapter ground)
	var path_tint: Color = level_cfg["ground_tint"].darkened(0.15)
	path_tint.a = 0.65
	var left_yard := ColorRect.new()
	left_yard.position = Vector2(0, 174)
	left_yard.size = Vector2(228, GameData.GRID_ROWS * GameData.CELL_SIZE.y)
	left_yard.color = path_tint
	_world_root.add_child(left_yard)

	var right_yard := ColorRect.new()
	right_yard.position = Vector2(GameData.GRID_ORIGIN.x + GameData.GRID_COLS * GameData.CELL_SIZE.x, 174)
	right_yard.size = Vector2(220, GameData.GRID_ROWS * GameData.CELL_SIZE.y)
	right_yard.color = path_tint
	_world_root.add_child(right_yard)

	# Scenic Yard Props (placed outside the 5x9 grid so defenders stay clear)
	var prop_paths: Array = level_cfg.get("props", [])
	var prop_positions := [Vector2(94, 152), Vector2(1186, 152), Vector2(94, 656), Vector2(1186, 656)]
	for i in range(mini(prop_paths.size(), prop_positions.size())):
		var pr := Sprite2D.new()
		pr.texture = load(prop_paths[i]) as Texture2D
		pr.position = prop_positions[i]
		pr.scale = Vector2(0.42, 0.42)
		pr.offset = Vector2(0, -16)
		pr.z_index = 4
		_world_root.add_child(pr)

	# 5x9 Grid Tiles
	_grid_layer = Node2D.new()
	_grid_layer.z_index = 5
	_world_root.add_child(_grid_layer)

	var p_name: String = level_cfg["tile_primary"]
	var a_name: String = level_cfg["tile_alt"]
	var water_lane: int = int(level_cfg.get("water_lane", -1))

	for r in range(GameData.GRID_ROWS):
		for c in range(GameData.GRID_COLS):
			var tile_sp := Sprite2D.new()
			var tex_path := ""
			if r == water_lane:
				var water_pattern := [0, 2, 3, 4, 5, 1, 3, 2, 0]
				tex_path = "res://assets/sprites/tiles/tile_koi_water_%d.png" % water_pattern[c]
			else:
				var use_primary := ((r + c) % 2) == 0
				var stem := p_name if use_primary else a_name
				var variant := 0 if use_primary else 1
				if ((r * 7 + c * 3) % 5) == 0:
					variant = 2 + ((r + c) % 4)
				tex_path = "res://assets/sprites/tiles/%s_%d.png" % [stem, variant]
			tile_sp.texture = load(tex_path) as Texture2D
			tile_sp.position = GameData.cell_to_world(r, c)
			tile_sp.scale = Vector2(GameData.CELL_SIZE.x / 128.0, GameData.CELL_SIZE.y / 128.0)
			_grid_layer.add_child(tile_sp)

			# Subtle grid checkerboard readability border
			if r != water_lane and ((r + c) % 2) == 1:
				var tint := ColorRect.new()
				tint.position = GameData.GRID_ORIGIN + Vector2(c * GameData.CELL_SIZE.x, r * GameData.CELL_SIZE.y)
				tint.size = GameData.CELL_SIZE
				tint.color = Color(0.0, 0.0, 0.0, 0.055)
				tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
				_grid_layer.add_child(tint)

			if r == water_lane:
				var lily := Sprite2D.new()
				lily.texture = load("res://assets/sprites/tiles/tile_koi_water_3.png") as Texture2D
				lily.position = GameData.cell_to_world(r, c)
				lily.scale = Vector2(GameData.CELL_SIZE.x / 128.0, GameData.CELL_SIZE.y / 128.0)
				lily.visible = false
				lily.z_index = 6
				_grid_layer.add_child(lily)
				_water_lily_overlays[r][c] = lily

	# Left Edo Guardian House & Right Torii Spawn Gate
	var edo_house := Sprite2D.new()
	edo_house.texture = load("res://assets/sprites/props/prop_edo_house.png") as Texture2D
	edo_house.position = Vector2(76.0, 410.0)
	edo_house.scale = Vector2(0.72, 0.72)
	edo_house.z_index = 12
	_world_root.add_child(edo_house)

	var torii := Sprite2D.new()
	torii.texture = load("res://assets/sprites/props/prop_torii.png") as Texture2D
	torii.position = Vector2(1188.0, 410.0)
	torii.scale = Vector2(0.84, 0.84)
	torii.z_index = 12
	_world_root.add_child(torii)

	# Cell highlight & Ghost preview
	_cell_highlight = ColorRect.new()
	_cell_highlight.size = GameData.CELL_SIZE
	_cell_highlight.color = Color(0.3, 1.0, 0.45, 0.28)
	_cell_highlight.visible = false
	_cell_highlight.z_index = 15
	_cell_highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_world_root.add_child(_cell_highlight)

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
	_ambient_layer.z_index = 85
	_world_root.add_child(_defender_layer)
	_world_root.add_child(_enemy_layer)
	_world_root.add_child(_projectile_layer)
	_world_root.add_child(_vfx_layer)
	_world_root.add_child(_flame_layer)
	_world_root.add_child(_ambient_layer)

	# Spawn 5 Komainu Guardians (Last Line of Defense)
	for r in range(GameData.GRID_ROWS):
		var k: KomainuGuardian = KOMAINU_SCRIPT.new()
		var pos := Vector2(188.0, GameData.GRID_ORIGIN.y + (r + 0.5) * GameData.CELL_SIZE.y)
		k.setup(self, r, pos)
		_world_root.add_child(k)
		_komainu_by_lane[r] = k

	# Spawn Chapter Obstacles
	var obs_list: Array = level_cfg.get("obstacles", [])
	for obs_cfg in obs_list:
		spawn_obstacle(str(obs_cfg["id"]), int(obs_cfg["row"]), int(obs_cfg["col"]))

	# Ambient particles matching chapter biome
	var p_tex := load(level_cfg["ambient_particle"]) as Texture2D
	for i in range(14):
		var sp := Sprite2D.new()
		sp.texture = p_tex
		var sc := randf_range(0.26, 0.44)
		sp.scale = Vector2(sc, sc)
		sp.position = Vector2(randf_range(0.0, 1280.0), randf_range(100.0, 700.0))
		sp.modulate.a = 0.65
		_ambient_layer.add_child(sp)
		_ambient_particles.append({
			"node": sp,
			"vx": randf_range(-24.0, -8.0),
			"vy": randf_range(18.0, 38.0),
			"rot": randf_range(-1.5, 1.5),
		})


func _build_hud() -> void:
	_hud_layer = CanvasLayer.new()
	_hud_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_hud_layer)

	_hud_root = Control.new()
	_hud_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud_layer.add_child(_hud_root)

	# Top wood-tinted bar backdrop
	var top_bar_bg := ColorRect.new()
	top_bar_bg.anchor_right = 1.0
	top_bar_bg.offset_bottom = 108.0
	top_bar_bg.color = Color(0.18, 0.10, 0.05, 0.72)
	top_bar_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud_root.add_child(top_bar_bg)

	var top_row := HBoxContainer.new()
	top_row.anchor_left = 0.5
	top_row.anchor_right = 0.5
	top_row.offset_left = -636.0
	top_row.offset_right = 636.0
	top_row.offset_top = 6.0
	top_row.offset_bottom = 102.0
	top_row.add_theme_constant_override("separation", 4)
	top_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud_root.add_child(top_row)

	# 1. Spirit Flame Pill Counter
	var pill_wrap := Control.new()
	pill_wrap.custom_minimum_size = Vector2(150.0, 68.0)
	pill_wrap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pill_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_row.add_child(pill_wrap)

	var pill_bg := TextureRect.new()
	pill_bg.texture = load("res://assets/sprites/ui/ui_resource_pill.png") as Texture2D
	pill_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	pill_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pill_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pill_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pill_wrap.add_child(pill_bg)

	var flame_icon := TextureRect.new()
	flame_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	flame_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	flame_icon.custom_minimum_size = Vector2(34.0, 34.0)
	flame_icon.texture = load("res://assets/sprites/ui/ui_spirit_flame.png") as Texture2D
	flame_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pill_wrap.add_child(flame_icon)
	flame_icon.position = Vector2(14.0, 16.0)
	flame_icon.size = Vector2(34.0, 34.0)

	_flame_label = Label.new()
	_flame_label.text = str(spirit_flame)
	_flame_label.position = Vector2(52.0, 16.0)
	_flame_label.size = Vector2(84.0, 38.0)
	_flame_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_flame_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_flame_label.add_theme_font_size_override("font_size", 24)
	_flame_label.add_theme_color_override("font_color", Color(0.22, 0.11, 0.04))
	_flame_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pill_wrap.add_child(_flame_label)
	# Wait one frame for layout or compute pill center cleanly
	var hud_center_x := get_viewport_rect().size.x * 0.5
	_flame_pill_pos = Vector2(hud_center_x - 636.0 + 32.0, 44.0)

	# 2. Seed Card Deck Row (up to 8 cards)
	var deck_box := HBoxContainer.new()
	deck_box.add_theme_constant_override("separation", 4)
	deck_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	deck_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	deck_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_row.add_child(deck_box)

	_seed_cards.clear()
	for i in range(GameData.selected_deck.size()):
		var did: String = GameData.selected_deck[i]
		var card: SeedCard = SEED_CARD_SCRIPT.new()
		card.setup(did, i)
		card.card_pressed.connect(_on_card_pressed)
		card.card_drag_started.connect(_on_card_drag_started)
		deck_box.add_child(card)
		_seed_cards.append(card)

	# 3. Right HUD Controls (Wave Progress + Auto + Shovel + Speed + Sound + Pause)
	var right_box := HBoxContainer.new()
	right_box.add_theme_constant_override("separation", 4)
	right_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	right_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_row.add_child(right_box)

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
	_auto_btn.custom_minimum_size = Vector2(106, 46)
	_auto_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_auto_btn.add_theme_font_size_override("font_size", 11)
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
	_sound_btn = _make_hud_icon_btn("res://assets/sprites/ui/ui_btn_sound.png", Vector2(42, 42), "Bật / Tắt Âm Thanh")
	_sound_btn.modulate = Color(0.55, 0.55, 0.55, 0.85) if GameData.sound_muted else Color.WHITE
	_sound_btn.pressed.connect(_on_toggle_sound)
	right_box.add_child(_sound_btn)

	# Pause Button
	var pause_btn := _make_hud_icon_btn("res://assets/sprites/ui/ui_btn_pause.png", Vector2(46, 46), "Tạm dừng (Phím Space)")
	pause_btn.pressed.connect(_on_toggle_pause)
	right_box.add_child(pause_btn)

	# Huge Wave Banner
	_banner_container = PanelContainer.new()
	_banner_container.anchor_left = 0.5
	_banner_container.anchor_right = 0.5
	_banner_container.anchor_top = 0.5
	_banner_container.anchor_bottom = 0.5
	_banner_container.offset_left = -250.0
	_banner_container.offset_right = 250.0
	_banner_container.offset_top = -44.0
	_banner_container.offset_bottom = 44.0
	_banner_container.visible = false
	_banner_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var b_sb := StyleBoxFlat.new()
	b_sb.bg_color = Color(0.68, 0.11, 0.09, 0.92)
	b_sb.border_color = Color(0.96, 0.78, 0.24)
	b_sb.set_border_width_all(4)
	b_sb.set_corner_radius_all(14)
	_banner_container.add_theme_stylebox_override("panel", b_sb)
	_hud_root.add_child(_banner_container)

	_banner_label = Label.new()
	_banner_label.text = "ĐỢT YÊU QUÁI LỚN ĐANG TRÀN TỚI!"
	_banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_banner_label.add_theme_font_size_override("font_size", 24)
	_banner_label.add_theme_color_override("font_color", Color(1.0, 0.94, 0.72))
	_banner_container.add_child(_banner_label)

	_build_skills_bar()


func _build_skills_bar() -> void:
	var skill_row := HBoxContainer.new()
	skill_row.anchor_top = 1.0
	skill_row.anchor_bottom = 1.0
	skill_row.offset_left = 12.0
	skill_row.offset_right = 224.0
	skill_row.offset_top = -80.0
	skill_row.offset_bottom = -8.0
	skill_row.add_theme_constant_override("separation", 6)
	skill_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud_root.add_child(skill_row)

	_skill_buttons.clear()
	_skill_cooldowns.clear()
	for sid in GameData.ACTIVE_SKILL_ORDER:
		var sdata: Dictionary = GameData.ACTIVE_SKILLS[sid]
		_skill_cooldowns[sid] = 0.0
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(66, 68)
		btn.tooltip_text = "[%s] %s (%d Hỏa) — %s" % [sdata["hotkey"], sdata["name"], int(sdata["cost"]), sdata["desc"]]
		btn.pressed.connect(trigger_active_skill.bind(sid))

		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.96, 0.89, 0.74, 0.94)
		sb.border_color = Color(0.55, 0.28, 0.10)
		sb.set_border_width_all(2)
		sb.set_corner_radius_all(10)
		btn.add_theme_stylebox_override("normal", sb)
		btn.add_theme_stylebox_override("hover", sb)
		btn.add_theme_stylebox_override("pressed", sb)

		var ic := TextureRect.new()
		ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ic.position = Vector2(11, 6)
		ic.size = Vector2(44, 42)
		ic.texture = load(sdata["icon"]) as Texture2D
		ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(ic)

		var hk := Label.new()
		hk.text = str(sdata["hotkey"])
		hk.position = Vector2(4, 2)
		hk.add_theme_font_size_override("font_size", 10)
		hk.add_theme_color_override("font_color", Color(0.38, 0.16, 0.06))
		hk.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(hk)

		var cost_lbl := Label.new()
		cost_lbl.name = "CostLbl"
		cost_lbl.text = "FREE" if int(sdata["cost"]) == 0 else str(int(sdata["cost"]))
		cost_lbl.position = Vector2(4, 49)
		cost_lbl.size = Vector2(58, 16)
		cost_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cost_lbl.add_theme_font_size_override("font_size", 11)
		cost_lbl.add_theme_color_override("font_color", Color(0.16, 0.36, 0.12))
		cost_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(cost_lbl)

		var cd_mask := ColorRect.new()
		cd_mask.name = "CdMask"
		cd_mask.color = Color(0.05, 0.04, 0.08, 0.65)
		cd_mask.set_anchors_preset(Control.PRESET_FULL_RECT)
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
	_modal_overlay = ColorRect.new()
	_modal_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_modal_overlay.color = Color(0.05, 0.04, 0.06, 0.68)
	_modal_overlay.visible = false
	_hud_root.add_child(_modal_overlay)

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
	_modal_banner.position = Vector2(105, -36)
	_modal_banner.size = Vector2(350, 124)
	_modal_banner.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_modal_banner.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_modal_scroll.add_child(_modal_banner)

	var v := VBoxContainer.new()
	v.position = Vector2(82, 76)
	v.size = Vector2(396, 276)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 12)
	_modal_scroll.add_child(v)

	_modal_title = Label.new()
	_modal_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_modal_title.add_theme_font_size_override("font_size", 28)
	_modal_title.add_theme_color_override("font_color", Color(0.45, 0.14, 0.06))
	v.add_child(_modal_title)

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
	_modal_btn_menu.pressed.connect(_on_back_to_menu)
	v.add_child(_modal_btn_menu)

	_portrait_overlay = ColorRect.new()
	_portrait_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_portrait_overlay.color = Color(0.08, 0.06, 0.05, 0.92)
	_portrait_overlay.visible = false
	_portrait_overlay.z_index = 200
	var p_lbl := Label.new()
	p_lbl.text = "Vui lòng xoay ngang điện thoại\nđể tiếp tục bảo vệ Khu Vườn Edo!"
	p_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	p_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	p_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	p_lbl.add_theme_font_size_override("font_size", 28)
	p_lbl.add_theme_color_override("font_color", Color(0.98, 0.90, 0.72))
	_portrait_overlay.add_child(p_lbl)
	_hud_root.add_child(_portrait_overlay)


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
	var vp := get_viewport_rect().size
	if _portrait_overlay:
		_portrait_overlay.visible = vp.y > vp.x * 1.05

	if get_tree().paused or battle_ended:
		return

	# Update seed card cooldowns & afford states
	for i in range(_seed_cards.size()):
		var card: SeedCard = _seed_cards[i]
		card.update_state(delta, spirit_flame, selected_card_idx == i and not shovel_mode)

	_process_skills(delta)

	# Ambient particles
	for p in _ambient_particles:
		var sp: Sprite2D = p["node"]
		sp.position.x += float(p["vx"]) * delta
		sp.position.y += float(p["vy"]) * delta
		sp.rotation += float(p["rot"]) * delta
		if sp.position.y > 740.0 or sp.position.x < -30.0:
			sp.position = Vector2(randf_range(120.0, 1320.0), 110.0)

	# Screen shake via Camera2D
	if _shake_timer > 0.0:
		_shake_timer = maxf(0.0, _shake_timer - delta)
		if _camera:
			_camera.offset = Vector2(randf_range(-_shake_amp, _shake_amp), randf_range(-_shake_amp, _shake_amp))
	elif _camera and _camera.offset != Vector2.ZERO:
		_camera.offset = Vector2.ZERO

	# Natural Sky Spirit Flame drop
	var nat_interval := float(level_cfg.get("natural_flame_interval", 8.5))
	_natural_flame_timer += delta
	if _natural_flame_timer >= nat_interval:
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


func _process_waves(delta: float) -> void:
	if not _spawn_queue.is_empty():
		_spawn_stagger_timer -= delta
		if _spawn_stagger_timer <= 0.0:
			var next_spawn: Dictionary = _spawn_queue.pop_front()
			spawn_enemy(next_spawn["id"], int(next_spawn["lane"]))
			_spawn_stagger_timer = 0.65
		return

	var waves: Array = level_cfg.get("waves", [])
	if _wave_index < waves.size():
		var time_step := delta * (2.5 if (GameData.auto_play_active and _count_active_enemies() == 0) else 1.0)
		_wave_timer += time_step
		var next_wave: Dictionary = waves[_wave_index]
		if _wave_timer >= float(next_wave["delay"]):
			_wave_timer = 0.0
			_wave_index += 1
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
			if GameData.auto_play_active:
				var extra_pool := ["tieu_yeu", "oni_nho", "kappa", "nekomata", "tengu", "samurai_ma", "ran_ong"]
				for r in range(spawns.size(), GameData.GRID_ROWS):
					var extra_id: String = extra_pool[(level_id + _wave_index + r) % extra_pool.size()]
					_spawn_queue.append({
						"id": extra_id,
						"lane": (r + lane_offset) % GameData.GRID_ROWS,
					})
			_spawn_stagger_timer = 0.0
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
	AudioManager.play_sfx("wave_horn", -3.0)
	_show_banner("ĐỢT YÊU QUÁI LỚN ĐANG TRÀN TỚI!")


func _input(event: InputEvent) -> void:
	if battle_ended:
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
		var world_pos := get_global_mouse_position()
		_collect_flames_near(world_pos)
		var probe := world_pos + (Vector2(0.0, -42.0) if is_dragging_card else Vector2.ZERO)
		_update_hover_preview(probe)
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		var world_pos := get_global_mouse_position()
		if mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed:
			_clear_selection()
			return
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				# Ignore clicks in HUD top strip & bottom-left active skill bar
				if world_pos.y <= 112.0 or (world_pos.x <= 230.0 and world_pos.y >= 630.0):
					return
				_pointer_down_on_field = true
				if _collect_flames_near(world_pos):
					return
				if not is_dragging_card:
					_handle_grid_tap(world_pos)
			else:
				if is_dragging_card:
					var probe := world_pos + Vector2(0.0, -42.0)
					_handle_grid_tap(probe)
					is_dragging_card = false
					_clear_selection()
				_pointer_down_on_field = false


func _collect_flames_near(world_pos: Vector2) -> bool:
	var hit_any := false
	for node in _flame_layer.get_children():
		if node is SpiritFlame and not node.collected and node.is_point_inside(world_pos):
			node.collect()
			hit_any = true
	return hit_any


func _update_hover_preview(probe_pos: Vector2) -> void:
	if selected_defender_id == "" and not shovel_mode:
		_cell_highlight.visible = false
		_ghost_sprite.visible = false
		return
	var cell := GameData.world_to_cell(probe_pos)
	if cell.x < 0:
		_cell_highlight.visible = false
		_ghost_sprite.visible = false
		return

	_cell_highlight.visible = true
	_cell_highlight.position = GameData.GRID_ORIGIN + Vector2(cell.y * GameData.CELL_SIZE.x, cell.x * GameData.CELL_SIZE.y)

	if shovel_mode:
		var has_def := _grid_defenders[cell.x][cell.y] != null and is_instance_valid(_grid_defenders[cell.x][cell.y])
		var has_obs := _grid_obstacles[cell.x][cell.y] != null and is_instance_valid(_grid_obstacles[cell.x][cell.y])
		_cell_highlight.color = Color(0.95, 0.28, 0.25, 0.42) if (has_def or has_obs) else Color(0.7, 0.7, 0.7, 0.18)
		_ghost_sprite.visible = false
	else:
		var can_place := can_plant_at(cell.x, cell.y, selected_defender_id)
		_cell_highlight.color = Color(0.28, 0.96, 0.42, 0.34) if can_place else Color(0.95, 0.28, 0.25, 0.34)
		_ghost_sprite.visible = true
		_ghost_sprite.position = GameData.cell_to_world(cell.x, cell.y)
		_ghost_sprite.modulate = Color(1.0, 1.0, 1.0, 0.65) if can_place else Color(1.0, 0.45, 0.45, 0.55)


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


func _on_card_drag_started(did: String, idx: int, _global_pos: Vector2) -> void:
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


func _clear_selection() -> void:
	selected_defender_id = ""
	selected_card_idx = -1
	shovel_mode = false
	is_dragging_card = false
	if _cell_highlight:
		_cell_highlight.visible = false
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
	Engine.time_scale = mult
	if _speed_badge:
		_speed_badge.text = "%dx" % int(round(mult))


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
		_sound_btn.modulate = Color(0.55, 0.55, 0.55, 0.85) if GameData.sound_muted else Color.WHITE


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


func _show_pause_modal() -> void:
	get_tree().paused = true
	_modal_overlay.visible = true
	_modal_banner.visible = false
	_modal_stars_row.visible = false
	_modal_title.text = "TẠM DỪNG"
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
	_modal_banner.visible = true
	_modal_banner.texture = load("res://assets/sprites/ui/ui_banner_victory.png") as Texture2D
	_modal_title.text = "CHIẾN THẮNG!"
	_modal_stars_row.visible = true
	var tex_on := load("res://assets/sprites/ui/ui_star_earned.png") as Texture2D
	var tex_off := load("res://assets/sprites/ui/ui_star_empty.png") as Texture2D
	for s in range(3):
		(_modal_stars_row.get_child(s) as TextureRect).texture = tex_on if s < stars else tex_off
	_modal_subtitle.text = "Bảo vệ thành công Linh Hỏa! (%d/5 Komainu nguyên vẹn • +%d Ngọc Magatama)" % [intact_komainu, reward_jade]

	if level_id < GameData.LEVELS.size():
		_rebind_btn(_modal_btn_primary, _next_level)
		_modal_btn_primary_lbl.text = "MÀN TIẾP"
	else:
		_rebind_btn(_modal_btn_primary, _restart_level)
		_modal_btn_primary_lbl.text = "CHƠI LẠI"
	_modal_btn_secondary.visible = true
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
	_modal_banner.visible = true
	_modal_banner.texture = load("res://assets/sprites/ui/ui_banner_defeat.png") as Texture2D
	_modal_title.text = "THẤT BẠI!"
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
	for sid in _skill_buttons.keys():
		var cd := float(_skill_cooldowns.get(sid, 0.0))
		if cd > 0.0:
			cd = maxf(0.0, cd - delta)
			_skill_cooldowns[sid] = cd
		var btn: Button = _skill_buttons[sid]
		var cost := int(GameData.ACTIVE_SKILLS[sid]["cost"])
		var ready := cd <= 0.0 and spirit_flame >= cost
		var cd_mask := btn.find_child("CdMask", true, false) as ColorRect
		var cd_lbl := btn.find_child("CdLbl", true, false) as Label
		var cost_lbl := btn.find_child("CostLbl", true, false) as Label
		if cd > 0.0:
			cd_mask.visible = true
			cd_lbl.visible = true
			cd_lbl.text = "%ds" % int(ceil(cd))
		else:
			cd_mask.visible = false
			cd_lbl.visible = false
		btn.modulate = Color.WHITE if ready else Color(0.74, 0.74, 0.78, 0.90)
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
					spawn_vfx("res://assets/sprites/fx/fx_freeze_overlay.png", Vector2i(4, 3), enemy.position + Vector2(0, -8), 16.0, 0.8)
		"skill_thunder_scroll":
			AudioManager.play_sfx("explosion", -2.0)
			trigger_screen_shake(8.0, 0.30)
			for enemy in get_all_enemies():
				if is_instance_valid(enemy) and not enemy.is_dying():
					enemy.take_damage(260.0, true)
					enemy.apply_stun(1.5)
					spawn_vfx("res://assets/sprites/fx/fx_hit_spark.png", Vector2i(4, 3), enemy.position + Vector2(0, -8), 20.0, 0.85)
	return true


func add_flame(amount: int) -> void:
	spirit_flame += amount
	_update_flame_hud()


func _update_flame_hud() -> void:
	if _flame_label:
		_flame_label.text = str(spirit_flame)


func _update_wave_hud() -> void:
	var waves_arr: Array = level_cfg.get("waves", [])
	var total: int = waves_arr.size()
	if _wave_label:
		_wave_label.text = "Đợt %d / %d" % [_wave_index, total]
	if total > 0 and _wave_fill_clip and _wave_oni_head:
		var ratio := clampf(float(_wave_index) / float(total), 0.05, 1.0)
		_wave_fill_clip.size.x = 136.0 * ratio
		_wave_oni_head.position = Vector2(18.0 + 116.0 * ratio, 3.0)
		_wave_oni_head.size = Vector2(28.0, 28.0)


func can_plant_at(row: int, col: int, did: String) -> bool:
	if row < 0 or row >= GameData.GRID_ROWS or col < 0 or col >= GameData.GRID_COLS:
		return false
	if _grid_defenders[row][col] != null and is_instance_valid(_grid_defenders[row][col]):
		return false
	if _grid_obstacles[row][col] != null and is_instance_valid(_grid_obstacles[row][col]):
		return false
	var cost := int(GameData.DEFENDERS[did]["cost"])
	return spirit_flame >= cost


func try_plant_defender(did: String, row: int, col: int, card_idx: int = -1, ignore_cost_and_cd: bool = false) -> Defender:
	if row < 0 or row >= GameData.GRID_ROWS or col < 0 or col >= GameData.GRID_COLS:
		return null
	if _grid_defenders[row][col] != null and is_instance_valid(_grid_defenders[row][col]):
		return null
	if _grid_obstacles[row][col] != null and is_instance_valid(_grid_obstacles[row][col]):
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
	var sx := x_pos if x_pos > 0.0 else randf_range(1155.0, 1205.0)
	var sy := GameData.GRID_ORIGIN.y + (clane + 0.5) * GameData.CELL_SIZE.y
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
	var vfx: VfxEffect = VFX_SCRIPT.new()
	vfx.position = pos
	vfx.z_index = 70
	vfx.setup(tex_path, grid, fps, target_scale, loop_duration, velocity)
	_vfx_layer.add_child(vfx)
	return vfx


func spawn_spirit_flame(start_pos: Vector2, ground_pos: Vector2, amount: int = 25, sky_drop: bool = false) -> SpiritFlame:
	var fl: SpiritFlame = FLAME_SCRIPT.new()
	fl.setup(self, start_pos, ground_pos, _flame_pill_pos, amount, sky_drop)
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
	_cell_highlight.position = GameData.GRID_ORIGIN + Vector2(col * GameData.CELL_SIZE.x, row * GameData.CELL_SIZE.y)
	_cell_highlight.color = Color(0.28, 0.96, 0.42, 0.40)
	_cell_highlight.visible = true
	_ghost_sprite.texture = load(GameData.DEFENDERS[did]["icon"]) as Texture2D
	_ghost_sprite.position = GameData.cell_to_world(row, col)
	_ghost_sprite.modulate = Color(1.0, 1.0, 1.0, 0.72)
	_ghost_sprite.visible = true
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

	# Spawn opening 5-lane Yokai vanguard so combat, shooting, hit & death animations begin immediately
	var openers := ["tieu_yeu", "oni_nho", "kappa", "tengu", "samurai_ma"]
	for r in range(GameData.GRID_ROWS):
		spawn_enemy(openers[r], r, 1045.0 + float(r) * 28.0)


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
			"dao_tien", "tre_no", "nam_doc":
				lane_attackers[r] += 1

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
			if _ai_try_plant_in_cols("ho_lo_bang", r, [1, 2], ready_cards):
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
		if _ai_try_plant_in_cols("tre_no", r, [1, 2], ready_cards):
			return
		if _ai_try_plant_in_cols("nam_doc", r, [3, 2], ready_cards):
			return
		if _ai_try_plant_in_cols("dao_tien", r, [2, 1], ready_cards):
			return
		if not lane_has_wind[r] and _ai_try_plant_in_cols("gio_loc", r, [2, 1], ready_cards):
			return
