extends Control

## Main Menu & Chapter / Deck Selection screen for Edo Garden Defense.

const SAFE_AREA := preload("res://scripts/ui/safe_area.gd")
const BATTLE_SCENE_PATH := "res://scenes/battle/BattleScene.tscn"

var _level_buttons: Array[Button] = []
var _deck_buttons: Dictionary = {}
var _upgrade_buttons: Dictionary = {}
var _deck_count_label: Label
var _jade_label: Label
var _selected_level_label: Label
var _info_desc_label: Label
var _auto_collect_btn: Button
var _auto_play_btn: Button
var _sound_btn: TextureButton
var _audio_menu: PopupMenu
var _bg_preview_rect: TextureRect
var _portrait_overlay: Control
var _particle_layer: Node2D
var _petals: Array[Dictionary] = []


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	AudioManager.start_bgm()
	_build_ui()
	_refresh_ui()
	if GameData.auto_play_active:
		GameData.prepare_auto_play_loadout(GameData.selected_level)
		_refresh_ui()
		get_tree().create_timer(0.5, true, false, true).timeout.connect(_auto_enter_battle)


func _update_menu_safe_area(menu: MarginContainer) -> void:
	if not menu.is_inside_tree():
		return
	var insets := SAFE_AREA.viewport_insets(get_window())
	var viewport_size := get_viewport_rect().size
	var safe_origin := Vector2(insets.x, insets.y)
	var safe_size := viewport_size - safe_origin - Vector2(insets.z, insets.w)
	var menu_size := safe_size.min(Vector2(1280.0, 720.0))
	var origin := safe_origin + (safe_size - menu_size) * 0.5
	menu.offset_left = origin.x
	menu.offset_top = origin.y
	menu.offset_right = origin.x + menu_size.x - viewport_size.x
	menu.offset_bottom = origin.y + menu_size.y - viewport_size.y


func _build_ui() -> void:
	# 1. Atmospheric Edo Sky & Garden Backdrop
	var sky := ColorRect.new()
	sky.set_anchors_preset(Control.PRESET_FULL_RECT)
	sky.color = Color(0.95, 0.87, 0.78, 1.0)
	add_child(sky)

	var top_tint := ColorRect.new()
	top_tint.anchor_right = 1.0
	top_tint.anchor_bottom = 0.58
	top_tint.color = Color(0.67, 0.83, 0.94, 0.55)
	add_child(top_tint)

	var ground := ColorRect.new()
	ground.anchor_top = 0.56
	ground.anchor_right = 1.0
	ground.anchor_bottom = 1.0
	ground.color = Color(0.45, 0.62, 0.34, 0.88)
	add_child(ground)

	# Chapter scenic backdrop preview (from 08_backgrounds adapted panels)
	_bg_preview_rect = TextureRect.new()
	_bg_preview_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_bg_preview_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_bg_preview_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg_preview_rect.modulate = Color(1.0, 1.0, 1.0, 0.72)
	_bg_preview_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bg_preview_rect)

	# Falling Sakura Particles
	_particle_layer = Node2D.new()
	add_child(_particle_layer)
	var petal_tex := load("res://assets/sprites/fx/part_sakura_1.png") as Texture2D
	for i in range(18):
		var sp := Sprite2D.new()
		sp.texture = petal_tex
		var sc := randf_range(0.28, 0.48)
		sp.scale = Vector2(sc, sc)
		sp.position = Vector2(randf_range(0.0, 1280.0), randf_range(0.0, 720.0))
		sp.modulate.a = 0.72
		_particle_layer.add_child(sp)
		_petals.append({"node": sp, "vx": randf_range(-28.0, -10.0), "vy": randf_range(26.0, 52.0), "rot": randf_range(-1.8, 1.8)})

	# 2. Safe Margin Wrapper
	var root := MarginContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("margin_left", 24)
	root.add_theme_constant_override("margin_right", 24)
	root.add_theme_constant_override("margin_top", 14)
	root.add_theme_constant_override("margin_bottom", 14)
	add_child(root)
	var update_safe_area := _update_menu_safe_area.bind(root)
	get_viewport().size_changed.connect(update_safe_area)
	get_window().focus_entered.connect(update_safe_area)
	update_safe_area.call()

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	root.add_child(vbox)

	# 3. Header Bar
	var header := HBoxContainer.new()
	header.custom_minimum_size = Vector2(0, 82)
	header.add_theme_constant_override("separation", 12)
	vbox.add_child(header)

	var title_box := _make_washi_panel(Color(0.98, 0.92, 0.79, 0.95), Color(0.55, 0.30, 0.12, 1.0))
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title_box)

	var title_hbox := HBoxContainer.new()
	title_hbox.add_theme_constant_override("separation", 14)
	title_box.add_child(title_hbox)

	var logo := TextureRect.new()
	logo.texture = load("res://assets/sprites/ui/gardener_happy.png") as Texture2D
	logo.custom_minimum_size = Vector2(72, 72)
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	title_hbox.add_child(logo)

	var title_text_v := VBoxContainer.new()
	title_text_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_text_v.alignment = BoxContainer.ALIGNMENT_CENTER
	title_hbox.add_child(title_text_v)

	var title_lbl := Label.new()
	title_lbl.text = "EDO GARDEN DEFENSE"
	title_lbl.add_theme_font_size_override("font_size", 28)
	title_lbl.add_theme_color_override("font_color", Color(0.45, 0.14, 0.08))
	title_text_v.add_child(title_lbl)

	var sub_lbl := Label.new()
	sub_lbl.text = "Bách Quỷ Dạ Hành — Bảo vệ Linh Hỏa & Khu Vườn Làng Hoa Anh Đào"
	sub_lbl.add_theme_font_size_override("font_size", 14)
	sub_lbl.add_theme_color_override("font_color", Color(0.32, 0.22, 0.12))
	title_text_v.add_child(sub_lbl)

	# Jade Magatama currency pill
	var jade_pill := _make_washi_panel(Color(0.98, 0.94, 0.82, 0.96), Color(0.24, 0.56, 0.30, 1.0))
	jade_pill.custom_minimum_size = Vector2(128, 54)
	jade_pill.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header.add_child(jade_pill)

	var jade_h := HBoxContainer.new()
	jade_h.alignment = BoxContainer.ALIGNMENT_CENTER
	jade_h.add_theme_constant_override("separation", 6)
	jade_pill.add_child(jade_h)

	var jade_ic := TextureRect.new()
	jade_ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	jade_ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	jade_ic.custom_minimum_size = Vector2(30, 30)
	jade_ic.texture = load("res://assets/sprites/items/item_magatama_jade.png") as Texture2D
	jade_h.add_child(jade_ic)

	_jade_label = Label.new()
	_jade_label.text = str(GameData.jade_gems)
	_jade_label.add_theme_font_size_override("font_size", 20)
	_jade_label.add_theme_color_override("font_color", Color(0.10, 0.42, 0.18))
	jade_h.add_child(_jade_label)

	# Auto-collect toggle
	_auto_collect_btn = Button.new()
	_auto_collect_btn.custom_minimum_size = Vector2(198, 54)
	_auto_collect_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_auto_collect_btn.add_theme_font_size_override("font_size", 13)
	_auto_collect_btn.icon = load("res://assets/sprites/ui/ui_btn_auto_collect.png") as Texture2D
	_auto_collect_btn.expand_icon = true
	_auto_collect_btn.pressed.connect(_on_toggle_auto_collect)
	header.add_child(_auto_collect_btn)

	# Auto-play 5x (10m) toggle
	_auto_play_btn = Button.new()
	_auto_play_btn.custom_minimum_size = Vector2(182, 54)
	_auto_play_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_auto_play_btn.add_theme_font_size_override("font_size", 13)
	_auto_play_btn.icon = load("res://assets/sprites/ui/ui_kitsune_auto.png") as Texture2D
	_auto_play_btn.expand_icon = true
	_auto_play_btn.tooltip_text = "Bật/Tắt chế độ Tự Chơi 5x trong 10 phút"
	_auto_play_btn.pressed.connect(_on_toggle_auto_play)
	header.add_child(_auto_play_btn)

	# Sound button
	_sound_btn = TextureButton.new()
	_sound_btn.texture_normal = load("res://assets/sprites/ui/ui_btn_sound.png") as Texture2D
	_sound_btn.custom_minimum_size = Vector2(60, 60)
	_sound_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_sound_btn.ignore_texture_size = true
	_sound_btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	_sound_btn.tooltip_text = "Cài đặt âm thanh"
	_sound_btn.pressed.connect(_show_audio_menu)
	header.add_child(_sound_btn)
	_audio_menu = PopupMenu.new()
	_audio_menu.add_check_item("Tắt toàn bộ âm thanh", 0)
	_audio_menu.add_separator()
	_audio_menu.add_check_item("Nhạc nền", 1)
	_audio_menu.add_check_item("Âm thanh thiên nhiên", 2)
	_audio_menu.add_check_item("Hiệu ứng âm thanh", 3)
	_audio_menu.id_pressed.connect(_on_audio_menu_selected)
	add_child(_audio_menu)

	# 4. Main Content Columns (Left: Chapters, Right: Deck Picker & Play)
	var content := HBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 18)
	vbox.add_child(content)

	# Left Column: 5 Campaign Chapters
	var left_panel := _make_washi_panel(Color(0.97, 0.91, 0.78, 0.94), Color(0.50, 0.28, 0.10, 1.0))
	left_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_panel.size_flags_stretch_ratio = 1.05
	content.add_child(left_panel)

	var left_v := VBoxContainer.new()
	left_v.add_theme_constant_override("separation", 8)
	left_panel.add_child(left_v)

	var ch_top := HBoxContainer.new()
	left_v.add_child(ch_top)

	var ch_title := Label.new()
	ch_title.text = "CHỌN MÀN CHIẾN DỊCH (%d MÀN)" % GameData.LEVELS.size()
	ch_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ch_title.add_theme_font_size_override("font_size", 18)
	ch_title.add_theme_color_override("font_color", Color(0.36, 0.14, 0.08))
	ch_top.add_child(ch_title)

	var unlock_btn := Button.new()
	unlock_btn.text = "Mở khóa hết"
	unlock_btn.add_theme_font_size_override("font_size", 12)
	unlock_btn.tooltip_text = "Mở khóa toàn bộ %d màn để chơi thử ngay" % GameData.LEVELS.size()
	unlock_btn.pressed.connect(_on_unlock_all)
	ch_top.add_child(unlock_btn)

	var ch_scroll := ScrollContainer.new()
	ch_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	ch_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	left_v.add_child(ch_scroll)

	var ch_list := VBoxContainer.new()
	ch_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ch_list.add_theme_constant_override("separation", 6)
	ch_scroll.add_child(ch_list)

	for lvl in GameData.LEVELS:
		var lid := int(lvl["id"])
		var btn := _create_level_row(lvl)
		btn.pressed.connect(_on_select_level.bind(lid))
		ch_list.add_child(btn)
		_level_buttons.append(btn)

	# Right Column: Defender Deck Picker (14 Defenders -> pick up to 8)
	var right_panel := _make_washi_panel(Color(0.97, 0.91, 0.78, 0.94), Color(0.50, 0.28, 0.10, 1.0))
	right_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_panel.size_flags_stretch_ratio = 1.15
	content.add_child(right_panel)

	var right_v := VBoxContainer.new()
	right_v.add_theme_constant_override("separation", 8)
	right_panel.add_child(right_v)

	var deck_hdr := HBoxContainer.new()
	right_v.add_child(deck_hdr)

	var deck_title := Label.new()
	deck_title.text = "ĐỘI HÌNH QUÂN PHÒNG THỦ"
	deck_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	deck_title.add_theme_font_size_override("font_size", 18)
	deck_title.add_theme_color_override("font_color", Color(0.36, 0.14, 0.08))
	deck_hdr.add_child(deck_title)

	_deck_count_label = Label.new()
	_deck_count_label.add_theme_font_size_override("font_size", 15)
	_deck_count_label.add_theme_color_override("font_color", Color(0.14, 0.45, 0.20))
	deck_hdr.add_child(_deck_count_label)

	var grid := GridContainer.new()
	grid.columns = 7
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_v.add_child(grid)

	for did in GameData.DEFENDER_ORDER:
		var d_btn := _create_defender_picker_btn(did)
		grid.add_child(d_btn)
		_deck_buttons[did] = d_btn

	# Garden Upgrade Relics strip (6 items from 09_items_upgrades)
	var upg_hdr := Label.new()
	upg_hdr.text = "BÁU VẬT NÂNG CẤP VƯỜN (5 Ngọc / Báu Vật)"
	upg_hdr.add_theme_font_size_override("font_size", 13)
	upg_hdr.add_theme_color_override("font_color", Color(0.36, 0.14, 0.08))
	right_v.add_child(upg_hdr)

	var upg_row := HBoxContainer.new()
	upg_row.add_theme_constant_override("separation", 6)
	right_v.add_child(upg_row)

	for uid in GameData.UPGRADE_ORDER:
		var u_btn := _create_upgrade_btn(uid)
		upg_row.add_child(u_btn)
		_upgrade_buttons[uid] = u_btn

	# Unit detail tooltip & Selected Chapter + Play button
	_info_desc_label = Label.new()
	_info_desc_label.text = "Chạm vào quân bất kỳ để thêm/bớt khỏi đội hình (tối đa 8 thẻ)."
	_info_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_info_desc_label.custom_minimum_size = Vector2(0, 38)
	_info_desc_label.add_theme_font_size_override("font_size", 13)
	_info_desc_label.add_theme_color_override("font_color", Color(0.28, 0.16, 0.08))
	right_v.add_child(_info_desc_label)

	var bottom_action := HBoxContainer.new()
	bottom_action.add_theme_constant_override("separation", 12)
	right_v.add_child(bottom_action)

	_selected_level_label = Label.new()
	_selected_level_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_selected_level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_selected_level_label.add_theme_font_size_override("font_size", 15)
	_selected_level_label.add_theme_color_override("font_color", Color(0.45, 0.14, 0.08))
	bottom_action.add_child(_selected_level_label)

	var play_wrap := TextureButton.new()
	play_wrap.texture_normal = load("res://assets/sprites/ui/ui_btn_action_green.png") as Texture2D
	play_wrap.custom_minimum_size = Vector2(220, 68)
	play_wrap.ignore_texture_size = true
	play_wrap.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	play_wrap.pressed.connect(_on_start_battle)
	bottom_action.add_child(play_wrap)

	var play_lbl := Label.new()
	play_lbl.text = "VÀO TRẬN!"
	play_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	play_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	play_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	play_lbl.add_theme_font_size_override("font_size", 22)
	play_lbl.add_theme_color_override("font_color", Color.WHITE)
	play_lbl.add_theme_color_override("font_shadow_color", Color(0.08, 0.24, 0.05, 0.9))
	play_lbl.add_theme_constant_override("shadow_offset_y", 2)
	play_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	play_wrap.add_child(play_lbl)

	# 5. Footer controls tip
	var footer := Label.new()
	footer.text = "Điều khiển: Web (Click hoặc phím 1–8 đặt quân • X: Xẻng • Tab: 1x/2x/5x • A: Tự chơi 5x • Space: Tạm dừng)  |  Điện thoại (Chạm/Kéo thẻ thả ô • Vuốt nhặt Linh Hỏa)"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 13)
	footer.add_theme_color_override("font_color", Color(0.98, 0.95, 0.88))
	footer.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.65))
	footer.add_theme_constant_override("shadow_offset_y", 1)
	vbox.add_child(footer)

	# 6. Portrait warning overlay for mobile portrait screens
	_portrait_overlay = _build_portrait_overlay()
	add_child(_portrait_overlay)


func _make_washi_panel(bg_col: Color, border_col: Color) -> PanelContainer:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg_col
	sb.border_color = border_col
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(12)
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	p.add_theme_stylebox_override("panel", sb)
	return p


func _create_level_row(lvl: Dictionary) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(0, 74)
	btn.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var h := HBoxContainer.new()
	h.set_anchors_preset(Control.PRESET_FULL_RECT)
	h.add_theme_constant_override("separation", 10)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(h)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(margin)

	var row_h := HBoxContainer.new()
	row_h.add_theme_constant_override("separation", 10)
	row_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(row_h)

	var node_icon := TextureRect.new()
	node_icon.name = "NodeIcon"
	node_icon.custom_minimum_size = Vector2(48, 48)
	node_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	node_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	node_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row_h.add_child(node_icon)

	var tile_prev := TextureRect.new()
	if int(lvl["water_lane"]) >= 0:
		tile_prev.texture = preload("res://assets/sprites/tiles/tile_koi_water_2.png")
	else:
		tile_prev.texture = load("res://assets/sprites/tiles/%s_%d.png" % [lvl["tile_primary"], lvl["terrain_variants"].x]) as Texture2D
	tile_prev.custom_minimum_size = Vector2(44, 44)
	tile_prev.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tile_prev.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tile_prev.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tile_prev.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row_h.add_child(tile_prev)

	var txt_v := VBoxContainer.new()
	txt_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	txt_v.alignment = BoxContainer.ALIGNMENT_CENTER
	txt_v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row_h.add_child(txt_v)

	var t1 := Label.new()
	t1.name = "Title"
	t1.text = lvl["name"]
	t1.add_theme_font_size_override("font_size", 15)
	t1.add_theme_color_override("font_color", Color(0.24, 0.12, 0.05))
	t1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	txt_v.add_child(t1)

	var t2 := Label.new()
	t2.text = lvl["subtitle"]
	t2.add_theme_font_size_override("font_size", 12)
	t2.add_theme_color_override("font_color", Color(0.42, 0.28, 0.16))
	t2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	txt_v.add_child(t2)

	var stars_h := HBoxContainer.new()
	stars_h.name = "Stars"
	stars_h.add_theme_constant_override("separation", 2)
	stars_h.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	stars_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row_h.add_child(stars_h)
	for s in range(3):
		var st := TextureRect.new()
		st.custom_minimum_size = Vector2(22, 22)
		st.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		st.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		st.mouse_filter = Control.MOUSE_FILTER_IGNORE
		stars_h.add_child(st)

	return btn


func _create_defender_picker_btn(did: String) -> Button:
	var data: Dictionary = GameData.DEFENDERS[did]
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(96, 102)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
	btn.tooltip_text = "%s (%d) — %s" % [data["name"], int(data["cost"]), data["desc"]]
	btn.pressed.connect(_on_toggle_defender.bind(did))

	var bg := TextureRect.new()
	bg.name = "CardBg"
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 2)
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(margin)

	var v := VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 2)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(v)

	var icon := TextureRect.new()
	icon.texture = load(data["icon"]) as Texture2D
	icon.custom_minimum_size = Vector2(38, 38)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(icon)

	var nm := Label.new()
	nm.text = data["name"]
	nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nm.add_theme_font_size_override("font_size", 11)
	nm.add_theme_color_override("font_color", Color(0.24, 0.12, 0.04))
	nm.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(nm)

	var cost_lbl := Label.new()
	cost_lbl.name = "CardCost"
	cost_lbl.text = "%d" % int(data["cost"])
	cost_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cost_lbl.add_theme_font_size_override("font_size", 11)
	cost_lbl.add_theme_color_override("font_color", Color(0.18, 0.08, 0.02))
	cost_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.add_child(cost_lbl)
	bg.resized.connect(_position_card_cost.bind(bg, cost_lbl))

	return btn


func _position_card_cost(bg: TextureRect, cost: Label) -> void:
	if bg.texture == null:
		return
	var texture_size := bg.texture.get_size()
	var fit := minf(bg.size.x / texture_size.x, bg.size.y / texture_size.y)
	var drawn_height := texture_size.y * fit
	var plaque_y := 0.852 if bg.texture.resource_path.ends_with("_selected.png") else 0.91
	cost.size = Vector2(bg.size.x, cost.get_combined_minimum_size().y)
	cost.position.y = (bg.size.y - drawn_height) * 0.5 + drawn_height * plaque_y - cost.size.y * 0.5


func _create_upgrade_btn(uid: String) -> Button:
	var data: Dictionary = GameData.GARDEN_UPGRADES[uid]
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(78, 62)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.tooltip_text = "%s (%d Ngọc) — %s" % [data["name"], int(data["cost"]), data["desc"]]
	btn.pressed.connect(_on_click_upgrade.bind(uid))

	var v := VBoxContainer.new()
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 1)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(v)

	var ic := TextureRect.new()
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ic.custom_minimum_size = Vector2(34, 34)
	ic.texture = load(data["icon"]) as Texture2D
	ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(ic)

	var st := Label.new()
	st.name = "StatusLbl"
	st.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	st.add_theme_font_size_override("font_size", 10)
	st.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(st)

	return btn


func _refresh_ui() -> void:
	var tex_unlocked := load("res://assets/sprites/ui/ui_node_unlocked.png") as Texture2D
	var tex_current := load("res://assets/sprites/ui/ui_node_current.png") as Texture2D
	var tex_locked := load("res://assets/sprites/ui/ui_node_locked.png") as Texture2D
	var tex_boss := load("res://assets/sprites/ui/ui_node_boss.png") as Texture2D
	var tex_ch6_emblem := load("res://assets/sprites/ui/ui_ch6_emblem.png") as Texture2D
	var tex_star_on := load("res://assets/sprites/ui/ui_star_earned.png") as Texture2D
	var tex_star_off := load("res://assets/sprites/ui/ui_star_empty.png") as Texture2D

	for i in range(_level_buttons.size()):
		var lid := i + 1
		var btn := _level_buttons[i]
		var unlocked := lid <= GameData.unlocked_level
		btn.disabled = not unlocked
		var node_icon := btn.find_child("NodeIcon", true, false) as TextureRect
		if not unlocked:
			node_icon.texture = tex_locked
		elif lid == GameData.LEVELS.size() and tex_ch6_emblem:
			node_icon.texture = tex_ch6_emblem
		elif lid == GameData.selected_level:
			node_icon.texture = tex_current
		elif lid % 3 == 0:
			node_icon.texture = tex_boss
		else:
			node_icon.texture = tex_unlocked

		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.98, 0.90, 0.62, 1.0) if lid == GameData.selected_level else Color(0.95, 0.89, 0.77, 0.9)
		if not unlocked:
			sb.bg_color = Color(0.75, 0.72, 0.68, 0.7)
		sb.border_color = Color(0.84, 0.46, 0.10) if lid == GameData.selected_level else Color(0.62, 0.42, 0.24)
		sb.set_border_width_all(3 if lid == GameData.selected_level else 2)
		sb.set_corner_radius_all(8)
		btn.add_theme_stylebox_override("normal", sb)
		btn.add_theme_stylebox_override("hover", sb)
		btn.add_theme_stylebox_override("pressed", sb)
		btn.add_theme_stylebox_override("disabled", sb)

		var stars_earned := int(GameData.level_stars.get(str(lid), 0))
		var stars_box := btn.find_child("Stars", true, false)
		for s in range(3):
			var st := stars_box.get_child(s) as TextureRect
			st.texture = tex_star_on if s < stars_earned else tex_star_off

	var tex_card_sel := load("res://assets/sprites/ui/ui_card_selected.png") as Texture2D
	var tex_card_off := load("res://assets/sprites/ui/ui_card_disabled.png") as Texture2D
	for did in _deck_buttons.keys():
		var d_btn: Button = _deck_buttons[did]
		var in_deck := GameData.is_deck_member(did)
		var bg := d_btn.find_child("CardBg", true, false) as TextureRect
		bg.texture = tex_card_sel if in_deck else tex_card_off
		_position_card_cost(bg, bg.get_node("CardCost") as Label)
		d_btn.modulate = Color.WHITE if in_deck else Color(0.78, 0.78, 0.82, 0.92)
		var empty_sb := StyleBoxEmpty.new()
		d_btn.add_theme_stylebox_override("normal", empty_sb)
		d_btn.add_theme_stylebox_override("hover", empty_sb)
		d_btn.add_theme_stylebox_override("pressed", empty_sb)

	for uid in _upgrade_buttons.keys():
		var u_btn: Button = _upgrade_buttons[uid]
		var unlocked_u := GameData.has_upgrade(uid)
		var st_lbl := u_btn.find_child("StatusLbl", true, false) as Label
		var u_sb := StyleBoxFlat.new()
		if unlocked_u:
			u_sb.bg_color = Color(0.99, 0.90, 0.56, 1.0)
			u_sb.border_color = Color(0.84, 0.46, 0.10)
			u_sb.set_border_width_all(3)
			st_lbl.text = "ĐÃ MỞ"
			st_lbl.add_theme_color_override("font_color", Color(0.14, 0.45, 0.16))
		else:
			u_sb.bg_color = Color(0.90, 0.85, 0.76, 0.88)
			u_sb.border_color = Color(0.55, 0.42, 0.30)
			u_sb.set_border_width_all(2)
			st_lbl.text = "%d Ngọc" % int(GameData.GARDEN_UPGRADES[uid]["cost"])
			st_lbl.add_theme_color_override("font_color", Color(0.32, 0.20, 0.12))
		u_sb.set_corner_radius_all(8)
		u_btn.add_theme_stylebox_override("normal", u_sb)
		u_btn.add_theme_stylebox_override("hover", u_sb)
		u_btn.add_theme_stylebox_override("pressed", u_sb)

	if _jade_label:
		_jade_label.text = str(GameData.jade_gems)
	_deck_count_label.text = "Đã chọn: %d / %d" % [GameData.selected_deck.size(), GameData.MAX_DECK_SIZE]
	var cur_lvl := GameData.get_level_config(GameData.selected_level)
	_selected_level_label.text = "Đang chọn: %s (%d đợt)" % [cur_lvl["name"], cur_lvl["waves"].size()]
	if _bg_preview_rect and cur_lvl.has("bg_stem"):
		_bg_preview_rect.texture = load("res://assets/sprites/backgrounds/%s_2.png" % cur_lvl["bg_stem"]) as Texture2D
	_auto_collect_btn.text = "Hút Linh Hỏa: BẬT" if GameData.auto_collect_flame else "Hút Linh Hỏa: TẮT"
	_update_auto_play_btn()
	var sound_tex_path := "res://assets/sprites/ui/ui_btn_sound_muted.png" if GameData.sound_muted else "res://assets/sprites/ui/ui_btn_sound.png"
	_sound_btn.texture_normal = load(sound_tex_path) as Texture2D
	_sound_btn.modulate = Color.WHITE


func _on_select_level(level_id: int) -> void:
	if level_id > GameData.unlocked_level:
		return
	AudioManager.play_sfx("ui_click")
	GameData.selected_level = level_id
	_refresh_ui()


func _on_toggle_defender(did: String) -> void:
	AudioManager.play_sfx("ui_click")
	var data: Dictionary = GameData.DEFENDERS[did]
	var changed := GameData.toggle_deck_member(did)
	if changed:
		_info_desc_label.text = "%s (%d Hỏa): %s" % [data["name"], int(data["cost"]), data["desc"]]
	else:
		_info_desc_label.text = "Đội hình tối đa %d thẻ (hoặc cần ít nhất 1 thẻ)! Bỏ chọn 1 thẻ khác trước." % GameData.MAX_DECK_SIZE
	_refresh_ui()


func _on_click_upgrade(uid: String) -> void:
	AudioManager.play_sfx("ui_click")
	var data: Dictionary = GameData.GARDEN_UPGRADES[uid]
	if GameData.has_upgrade(uid):
		_info_desc_label.text = "[ĐÃ MỞ] %s: %s" % [data["name"], data["desc"]]
	elif GameData.unlock_upgrade(uid):
		AudioManager.play_sfx("collect_flame", -4.0)
		_info_desc_label.text = "Đã mở khóa %s! (%s)" % [data["name"], data["desc"]]
	else:
		_info_desc_label.text = "Không đủ Ngọc Magatama (cần %d Ngọc)! Thắng màn chơi để nhận thêm Ngọc." % int(data["cost"])
	_refresh_ui()


func _on_unlock_all() -> void:
	AudioManager.play_sfx("ui_click")
	GameData.unlock_all_levels()
	_refresh_ui()


func _on_toggle_auto_collect() -> void:
	AudioManager.play_sfx("ui_click")
	GameData.auto_collect_flame = not GameData.auto_collect_flame
	GameData.save_progress()
	_refresh_ui()


func _update_auto_play_btn() -> void:
	if _auto_play_btn == null:
		return
	if GameData.auto_play_active:
		var rem := int(ceil(GameData.get_auto_play_remaining_sec()))
		@warning_ignore("integer_division")
		var mins := rem / 60
		var secs := rem % 60
		_auto_play_btn.text = "TỰ CHƠI 5x: %02d:%02d" % [mins, secs]
		_auto_play_btn.modulate = Color(0.65, 1.0, 0.68, 1.0)
	else:
		_auto_play_btn.text = "TỰ CHƠI 5x (10P)"
		_auto_play_btn.modulate = Color.WHITE


func _on_toggle_auto_play() -> void:
	AudioManager.play_sfx("ui_click")
	if GameData.auto_play_active:
		GameData.stop_auto_play()
		_refresh_ui()
	else:
		GameData.start_auto_play(600.0, 5.0)
		_refresh_ui()
		get_tree().create_timer(0.5, true, false, true).timeout.connect(_auto_enter_battle)


func _auto_enter_battle() -> void:
	if not is_inside_tree() or not GameData.auto_play_active:
		return
	_on_start_battle()


func _show_audio_menu() -> void:
	_audio_menu.set_item_checked(_audio_menu.get_item_index(0), GameData.sound_muted)
	for id in range(1, 4):
		var layer: String = ["music", "ambience", "sfx"][id - 1]
		_audio_menu.set_item_checked(_audio_menu.get_item_index(id), GameData.audio_layers[layer])
	var anchor := _sound_btn.get_screen_transform() * Vector2(0, _sound_btn.size.y)
	_audio_menu.position = Vector2i(anchor)
	_audio_menu.popup()


func _on_audio_menu_selected(id: int) -> void:
	if id == 0:
		GameData.sound_muted = not GameData.sound_muted
		AudioManager.set_muted(GameData.sound_muted)
		GameData.save_progress()
	else:
		var layer: String = ["music", "ambience", "sfx"][id - 1]
		AudioManager.set_layer_enabled(layer, not GameData.audio_layers[layer])
	_refresh_ui()


func _on_start_battle() -> void:
	AudioManager.play_sfx("wave_horn", -5.0)
	get_tree().change_scene_to_file(BATTLE_SCENE_PATH)


func _build_portrait_overlay() -> Control:
	var overlay := ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.08, 0.06, 0.05, 0.92)
	overlay.visible = false
	overlay.z_index = 200
	var v := VBoxContainer.new()
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 18)
	overlay.add_child(v)
	var ic := TextureRect.new()
	ic.texture = load("res://assets/sprites/ui/ui_rotate_landscape.png") as Texture2D
	ic.custom_minimum_size = Vector2(180, 180)
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ic.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(ic)
	var lbl := Label.new()
	lbl.text = "Vui lòng xoay ngang điện thoại\nđể bảo vệ Khu Vườn Edo!"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 28)
	lbl.add_theme_color_override("font_color", Color(0.98, 0.90, 0.72))
	v.add_child(lbl)
	return overlay


func _process(delta: float) -> void:
	if GameData.auto_play_active:
		if GameData.get_auto_play_remaining_sec() <= 0.0:
			GameData.stop_auto_play()
		_update_auto_play_btn()
	var vp := get_viewport_rect().size
	if _portrait_overlay:
		_portrait_overlay.visible = vp.y > vp.x * 1.05
	for p in _petals:
		var sp: Sprite2D = p["node"]
		sp.position.x += float(p["vx"]) * delta
		sp.position.y += float(p["vy"]) * delta
		sp.rotation += float(p["rot"]) * delta
		if sp.position.y > 740.0 or sp.position.x < -30.0:
			sp.position = Vector2(randf_range(80.0, 1320.0), -24.0)
