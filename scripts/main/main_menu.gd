extends Control

## Main Menu & Chapter / Deck Selection screen for Edo Garden Defense.

const SAFE_AREA := preload("res://scripts/ui/safe_area.gd")
const BATTLE_SCENE_PATH := "res://scenes/battle/BattleScene.tscn"

var _stage_picker: OptionButton
var _category_sections: Array[VBoxContainer] = []
var _previous_button: Button
var _stage_view: SubViewport
var _stage_thumbnail: TextureRect
var _enemy_grid: GridContainer
var _enemy_detail: Label
var _preview_level := 0
var _deck_buttons: Dictionary = {}
var _upgrade_buttons: Dictionary = {}
var _deck_count_label: Label
var _jade_label: Label
var _stage_description: Label
var _stage_conditions: Label
var _info_desc_label: Label
var _auto_collect_btn: Button
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
	if not GameData.progress_changed.is_connected(_refresh_ui):
		GameData.progress_changed.connect(_refresh_ui)
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
	sub_lbl.text = "Bảo vệ khu vườn qua 24 màn"
	sub_lbl.add_theme_font_size_override("font_size", 14)
	sub_lbl.add_theme_color_override("font_color", Color(0.32, 0.22, 0.12))
	title_text_v.add_child(sub_lbl)

	# Jade Magatama currency pill
	var jade_pill := _make_washi_panel(Color(0.98, 0.94, 0.82, 0.96), Color(0.24, 0.56, 0.30, 1.0))
	jade_pill.custom_minimum_size = Vector2(82, 45)
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
	_auto_collect_btn.custom_minimum_size = Vector2(153, 45)
	_auto_collect_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_auto_collect_btn.add_theme_font_size_override("font_size", 13)
	_auto_collect_btn.icon = load("res://assets/sprites/ui/ui_btn_auto_collect.png") as Texture2D
	_auto_collect_btn.expand_icon = true
	_auto_collect_btn.pressed.connect(_on_toggle_auto_collect)
	header.add_child(_auto_collect_btn)

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

	var content := HBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 14)
	vbox.add_child(content)
	_build_roster(content)
	_build_stage_brief(content)

	var footer := Label.new()
	footer.text = "Trong trận: 1–8 chọn thẻ  ·  X xẻng  ·  Tab đổi tốc độ  ·  Space tạm dừng"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 12)
	footer.add_theme_color_override("font_color", Color("#ffedcf"))
	footer.add_theme_color_override("font_shadow_color", Color("#261822"))
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


func _build_roster(content: HBoxContainer) -> void:
	var panel := _make_washi_panel(Color("#f8eedced"), Color("#866347"))
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_stretch_ratio = 1.58
	content.add_child(panel)
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 7)
	panel.add_child(body)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	body.add_child(header)
	var title := _menu_label("Chọn đội hình", 22, Color("#39272a"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	_deck_count_label = _menu_label("", 14, Color("#34544e"))
	header.add_child(_deck_count_label)
	var filter := OptionButton.new()
	_style_paper_button(filter)
	filter.tooltip_text = "Lọc theo vai trò"
	filter.add_item("Tất cả nhóm")
	for category in GameData.DEFENDER_CATEGORIES:
		filter.add_item(category["name"])
	filter.item_selected.connect(_filter_categories)
	header.add_child(filter)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.follow_focus = true
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	var roster := VBoxContainer.new()
	roster.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	roster.add_theme_constant_override("separation", 4)
	scroll.add_child(roster)
	for category in GameData.DEFENDER_CATEGORIES:
		var section := VBoxContainer.new()
		section.add_theme_constant_override("separation", 2)
		roster.add_child(section)
		_category_sections.append(section)
		var color: Color = category["color"]
		section.add_child(_menu_label(category["name"], 14, color.darkened(0.35)))
		var row := GridContainer.new()
		row.columns = 5
		row.add_theme_constant_override("h_separation", 7)
		row.add_theme_constant_override("v_separation", 4)
		section.add_child(row)
		for did: String in category["members"]:
			var card := _create_defender_picker_btn(did, color)
			row.add_child(card)
			_deck_buttons[did] = card

	_info_desc_label = _menu_label("Chọn tối đa 8 thẻ để mang vào trận.", 13, Color("#483831"))
	_info_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_info_desc_label.custom_minimum_size.y = 36
	body.add_child(_info_desc_label)

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 9)
	body.add_child(footer)
	_previous_button = Button.new()
	_style_paper_button(_previous_button)
	_previous_button.text = "Dùng đội hình trước"
	_previous_button.tooltip_text = "Khôi phục các thẻ từ trận chơi gần nhất"
	_previous_button.pressed.connect(_reuse_deck)
	footer.add_child(_previous_button)
	var upg_row := HBoxContainer.new()
	upg_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upg_row.alignment = BoxContainer.ALIGNMENT_END
	upg_row.add_theme_constant_override("separation", 5)
	footer.add_child(upg_row)
	for uid in GameData.UPGRADE_ORDER:
		var button := _create_upgrade_btn(uid)
		upg_row.add_child(button)
		_upgrade_buttons[uid] = button


func _filter_categories(index: int) -> void:
	for i in _category_sections.size():
		_category_sections[i].visible = index == 0 or index == i + 1


func _reuse_deck() -> void:
	if GameData.reuse_previous_deck():
		_info_desc_label.text = "Đã khôi phục đội hình của trận trước."
		_refresh_ui()


func _build_stage_brief(content: HBoxContainer) -> void:
	var panel := _make_washi_panel(Color("#f5e9d6f2"), Color("#866347"))
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size.x = 318.0
	content.add_child(panel)
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 7)
	panel.add_child(body)

	var header := HBoxContainer.new()
	body.add_child(header)
	var title := _menu_label("Chiến địa", 22, Color("#39272a"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var unlock := Button.new()
	_style_paper_button(unlock)
	unlock.text = "Mở khóa hết"
	unlock.tooltip_text = "Mở khóa 24 màn để chơi thử"
	unlock.pressed.connect(_on_unlock_all)
	header.add_child(unlock)

	_stage_picker = OptionButton.new()
	_style_paper_button(_stage_picker)
	_stage_picker.fit_to_longest_item = false
	_stage_picker.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	for stage in GameData.LEVELS:
		_stage_picker.add_item(stage["name"], stage["id"])
	_stage_picker.item_selected.connect(func(index: int): _on_select_level(_stage_picker.get_item_id(index)))
	body.add_child(_stage_picker)

	_stage_view = SubViewport.new()
	_stage_view.size = Vector2i(640, 360)
	_stage_view.world_2d = World2D.new()
	_stage_view.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(_stage_view)
	_stage_thumbnail = TextureRect.new()
	_stage_thumbnail.custom_minimum_size.y = 200
	_stage_thumbnail.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_stage_thumbnail.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_stage_thumbnail.texture = _stage_view.get_texture()
	body.add_child(_stage_thumbnail)
	_bg_preview_rect.texture = _stage_view.get_texture()
	_bg_preview_rect.modulate = Color(0.62, 0.56, 0.63, 1.0)

	_stage_description = _menu_label("", 13, Color("#372828"))
	_stage_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(_stage_description)
	_stage_conditions = _menu_label("", 12, Color("#663e31"))
	_stage_conditions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(_stage_conditions)
	body.add_child(_menu_label("Yokai xuất hiện", 14, Color("#39272a")))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.follow_focus = true
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	_enemy_grid = GridContainer.new()
	_enemy_grid.columns = 6
	_enemy_grid.add_theme_constant_override("h_separation", 4)
	_enemy_grid.add_theme_constant_override("v_separation", 4)
	scroll.add_child(_enemy_grid)
	_enemy_detail = _menu_label("", 13, Color("#60382d"))
	_enemy_detail.custom_minimum_size.y = 20
	body.add_child(_enemy_detail)
	var play := Button.new()
	play.text = "Vào trận"
	play.custom_minimum_size.y = 43
	play.add_theme_font_size_override("font_size", 19)
	play.add_theme_stylebox_override("normal", _card_style(Color("#304c45"), Color("#5f8e76"), 1))
	play.add_theme_stylebox_override("hover", _card_style(Color("#426452"), Color("#8db498"), 1))
	play.add_theme_stylebox_override("pressed", _card_style(Color("#213d36"), Color("#8db498"), 1))
	play.pressed.connect(_on_start_battle)
	body.add_child(play)


func _refresh_stage_brief(config: Dictionary) -> void:
	if _preview_level == int(config["id"]):
		return
	_preview_level = int(config["id"])
	for old in _stage_view.get_children():
		_stage_view.remove_child(old)
		old.queue_free()
	var preview := (load(BATTLE_SCENE_PATH) as PackedScene).instantiate()
	preview.stage_preview_id = _preview_level
	_stage_view.add_child(preview)
	_stage_view.render_target_update_mode = SubViewport.UPDATE_ONCE
	_stage_description.text = config["subtitle"]
	var details := PackedStringArray(["%d đợt" % config["waves"].size()])
	if config.has("fog"):
		details.append("Sương mù · nên mang đèn")
	match config.get("layout", ""):
		"twin_pond":
			details.append("Hai làn nước · tự đặt bè sen")
		"stone_island":
			details.append("Đảo đá · ô nước sâu không đặt được")
		_:
			if not GameData.stage_water_rows(config).is_empty():
				details.append("Làn nước · tự đặt bè sen")
	_stage_conditions.text = "  ·  ".join(details)

	for old in _enemy_grid.get_children():
		_enemy_grid.remove_child(old)
		old.queue_free()
	_enemy_detail.text = ""
	var enemies := {}
	for wave in config["waves"]:
		for id in wave["spawns"]:
			enemies[id] = GameData.ENEMIES[id]
	var ordered := enemies.keys()
	ordered.sort_custom(func(a, b): return int(enemies[a]["is_boss"]) > int(enemies[b]["is_boss"]))
	for key in ordered:
		var info: Dictionary = enemies[key]
		var boss := bool(info["is_boss"])
		var name_text := str(info["name"])
		var description := ("Boss · " if boss else "") + name_text
		var icon := Button.new()
		icon.icon = load(info["icon"]) as Texture2D
		icon.expand_icon = true
		icon.custom_minimum_size = Vector2(44.0, 42.0)
		icon.tooltip_text = description
		icon.add_theme_stylebox_override("normal", _card_style(Color("#fdf4e2"), Color("#ac643d") if boss else Color("#c7b498"), 2 if boss else 1))
		icon.mouse_entered.connect(_show_enemy_detail.bind(description))
		icon.focus_entered.connect(_show_enemy_detail.bind(description))
		icon.pressed.connect(_show_enemy_detail.bind(description))
		_enemy_grid.add_child(icon)


func _show_enemy_detail(description: String) -> void:
	_enemy_detail.text = description


func _menu_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _card_style(color: Color, border: Color, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_corner_radius_all(7)
	style.set_border_width_all(width)
	return style


func _style_paper_button(button: Button) -> void:
	for state in ["normal", "hover", "pressed", "disabled"]:
		var ink := Color("#513e36") if state != "disabled" else Color("#817365")
		var paper := Color("#f8edd9") if state == "normal" else Color("#eedcc3")
		var style := _card_style(paper, Color("#ad9175"), 1)
		style.content_margin_left = 10.0
		style.content_margin_right = 10.0
		style.content_margin_top = 6.0
		style.content_margin_bottom = 6.0
		button.add_theme_stylebox_override(state, style)
		button.add_theme_color_override("font_color" if state == "normal" else "font_%s_color" % state, ink)
	button.add_theme_color_override("font_focus_color", Color("#513e36"))
	button.add_theme_stylebox_override("focus", _card_style(Color.TRANSPARENT, Color("#614b40"), 2))


func _create_defender_picker_btn(did: String, color: Color) -> Button:
	var data: Dictionary = GameData.DEFENDERS[did]
	var btn := Button.new()
	var has_hint := data.has("card_hint")
	btn.custom_minimum_size = Vector2(78, 74)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.tooltip_text = "%s · %d Linh Hỏa
%s" % [data["name"], data["cost"], data["desc"]]
	btn.pressed.connect(_on_toggle_defender.bind(did))
	btn.mouse_entered.connect(_show_defender_detail.bind(did))
	btn.focus_entered.connect(_show_defender_detail.bind(did))
	btn.add_theme_stylebox_override("focus", _card_style(Color.TRANSPARENT, Color("#332231"), 2))

	var column := VBoxContainer.new()
	column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	column.offset_top = 4.0
	column.offset_bottom = -7.0
	column.add_theme_constant_override("separation", 0)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(column)
	var icon := TextureRect.new()
	icon.texture = load(data["icon"]) as Texture2D
	icon.custom_minimum_size.y = 28.0
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(icon)
	var name_label := _menu_label(data["name"], 11, Color("#33242a"))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	column.add_child(name_label)
	var cost_text := str(data["cost"])
	if has_hint:
		cost_text += " · " + str(data["card_hint"])
	var cost := _menu_label(cost_text, 13, color.darkened(0.43))
	cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(cost)
	var selected := Control.new()
	selected.name = "SelectedMark"
	selected.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(selected)
	selected.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	selected.position += Vector2(-21, 9)
	var check := Line2D.new()
	check.points = PackedVector2Array([Vector2(0, 4), Vector2(3, 7), Vector2(9, 0)])
	check.width = 1.8
	check.default_color = color.darkened(0.38)
	check.antialiased = true
	selected.add_child(check)
	return btn


func _show_defender_detail(did: String) -> void:
	var data: Dictionary = GameData.DEFENDERS[did]
	_info_desc_label.text = "%s · %d Linh Hỏa — %s" % [data["name"], data["cost"], data["desc"]]


func _create_upgrade_btn(uid: String) -> Button:
	var data: Dictionary = GameData.GARDEN_UPGRADES[uid]
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(56, 52)
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
	ic.custom_minimum_size = Vector2(26, 26)
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
	for index in _stage_picker.item_count:
		_stage_picker.set_item_disabled(index, _stage_picker.get_item_id(index) > GameData.unlocked_level)
	_stage_picker.select(_stage_picker.get_item_index(GameData.selected_level))

	for did in _deck_buttons:
		var button: Button = _deck_buttons[did]
		var active := GameData.is_deck_member(did)
		button.get_node("SelectedMark").visible = active
		var color: Color = GameData.defender_category(did)["color"]
		var off := Color("#fff7e7").lerp(color, 0.10)
		var on := Color("#fff1d9").lerp(color, 0.30)
		button.add_theme_stylebox_override("normal", _card_style(on if active else off, color, 3 if active else 1))
		button.add_theme_stylebox_override("hover", _card_style(on, color.darkened(0.22), 3))
		button.add_theme_stylebox_override("pressed", _card_style(on, color.darkened(0.32), 3))
	_previous_button.disabled = GameData.previous_deck.is_empty()

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
	_refresh_stage_brief(GameData.get_level_config(GameData.selected_level))
	_auto_collect_btn.text = "Hút Linh Hỏa: BẬT" if GameData.auto_collect_flame else "Hút Linh Hỏa: TẮT"
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
	GameData.remember_battle_deck()
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
	if GameData.auto_play_active and GameData.get_auto_play_remaining_sec() <= 0.0:
		GameData.stop_auto_play()
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
