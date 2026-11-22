extends SceneTree

## Comprehensive automated headless gameplay verification for Edo Garden Defense.

const SAFE_AREA := preload("res://scripts/ui/safe_area.gd")
const SCENERY := preload("res://scripts/battle/scenery.gd")

var _failures: Array[String] = []


func _assert(cond: bool, msg: String) -> void:
	if not cond:
		_failures.append(msg)
		push_error("ASSERT FAILED: " + msg)


func _step_frames(frames: int, dt: float = 0.05) -> void:
	for i in range(frames):
		await process_frame
		# Manually keep simulation progressing reliably in headless loop
		if i % 1 == 0:
			pass


func _initialize() -> void:
	create_timer(15.0).timeout.connect(func():
		push_error("WATCHDOG TIMEOUT")
		quit(1)
	)
	call_deferred("_run_all_tests")


func _run_all_tests() -> void:
	print("=== Starting Edo Garden Defense Automated Gameplay Verification ===")

	var game_data = root.get_node_or_null("GameData")
	var audio_mgr = root.get_node_or_null("AudioManager")
	_assert(game_data != null, "GameData autoload exists")
	_assert(audio_mgr != null, "AudioManager autoload exists")

	# Mobile safe-area rects are supplied in screen pixels, while HUD layout
	# uses logical viewport units and may be scaled by canvas_items stretch.
	var insets := SAFE_AREA.scaled_insets(Rect2i(10, 20, 2560, 1440), Rect2i(170, 84, 2260, 1320), Vector2(1280, 720))
	_assert(insets.is_equal_approx(Vector4(80, 32, 70, 28)), "Safe area preserves asymmetric cutouts under 2x viewport scaling")
	_assert(SAFE_AREA.scaled_insets(Rect2i(0, 0, 1280, 720), Rect2i(), Vector2(1280, 720)) == Vector4.ZERO, "Unavailable safe area preserves viewport margins")

	# 1. Verify all 10 Defenders, 10 Enemies, and 5 Levels textures load cleanly
	for did in game_data.DEFENDER_ORDER:
		var d: Dictionary = game_data.DEFENDERS[did]
		_assert(ResourceLoader.exists(d["idle_sheet"]), "Missing idle_sheet for " + did)
		_assert(ResourceLoader.exists(d["action_sheet"]), "Missing action_sheet for " + did)
		_assert(ResourceLoader.exists(d["icon"]), "Missing icon for " + did)

	for eid in game_data.ENEMIES.keys():
		var e: Dictionary = game_data.ENEMIES[eid]
		_assert(ResourceLoader.exists(e["move_sheet"]), "Missing move_sheet for " + eid)
		_assert(ResourceLoader.exists(e["attack_sheet"]), "Missing attack_sheet for " + eid)
		_assert(ResourceLoader.exists(e["die_sheet"]), "Missing die_sheet for " + eid)
		_assert(ResourceLoader.exists(e["icon"]), "Missing icon for " + eid)

	for oid in game_data.OBSTACLES.keys():
		var o: Dictionary = game_data.OBSTACLES[oid]
		_assert(ResourceLoader.exists(o["sheet"]), "Missing sheet for obstacle " + oid)

	for uid in game_data.UPGRADE_ORDER:
		var u: Dictionary = game_data.GARDEN_UPGRADES[uid]
		_assert(ResourceLoader.exists(u["icon"]), "Missing icon for upgrade " + uid)

	for sid in game_data.ACTIVE_SKILL_ORDER:
		var s: Dictionary = game_data.ACTIVE_SKILLS[sid]
		_assert(ResourceLoader.exists(s["icon"]), "Missing icon for skill " + sid)

	for ipath in game_data.ITEM_ICONS:
		_assert(ResourceLoader.exists(ipath), "Missing item icon " + ipath)

	# Test Garden Upgrade unlock & bonuses
	game_data.jade_gems = 20
	game_data.unlocked_upgrades.clear()
	_assert(game_data.unlock_upgrade("upg_festival_lantern"), "Unlocks Festival Lantern upgrade")
	_assert(game_data.unlock_upgrade("upg_golden_trowel"), "Unlocks Golden Trowel upgrade")
	_assert(game_data.unlock_upgrade("upg_bento_box"), "Unlocks Bento Box upgrade")
	_assert(game_data.jade_gems == 5, "3 upgrades at 5 Jade each leave 5 Jade")

	for lvl in game_data.LEVELS:
		var terrain_variants: Vector2i = lvl["terrain_variants"]
		_assert(ResourceLoader.exists("res://assets/sprites/tiles/%s_%d.png" % [lvl["tile_primary"], terrain_variants.x]), "Missing main terrain texture for level %d" % lvl["id"])
		_assert(ResourceLoader.exists("res://assets/sprites/tiles/%s_%d.png" % [lvl["tile_alt"], terrain_variants.y]), "Missing accent terrain texture for level %d" % lvl["id"])
		_assert(ResourceLoader.exists(lvl["ambient_particle"]), "Missing ambient particle for level %d" % lvl["id"])
		_assert(ResourceLoader.exists(lvl["top_border"]), "Missing top_border for level %d" % lvl["id"])
		_assert(ResourceLoader.exists(lvl["lawn_edge"]), "Missing lawn_edge for level %d" % lvl["id"])
		_assert(not lvl.has("gate_tex"), "Level %d omits its gate" % lvl["id"])
		var scenery_paths := [
			lvl["house_tex"],
			lvl.get("stone_path_tex", "res://assets/sprites/environments/env_path_stepping_stones.png"),
		]
		scenery_paths.append_array(lvl["biome_flora"])
		for scenery_path: String in scenery_paths:
			var texture := load(scenery_path) as Texture2D
			_assert(texture != null, "Missing chapter scenery %s" % scenery_path)
			var contact: Vector3 = SCENERY.GROUND_CONTACTS.get(scenery_path.get_file().get_basename(), Vector3.ZERO)
			if texture:
				var source_rect := Rect2(Vector2.ZERO, texture.get_size())
				_assert(source_rect.has_point(Vector2(contact.x, contact.y)) and contact.z > 0.0 and contact.z <= texture.get_width(),
					"Invalid scenery contact or visible width for %s" % scenery_path)
		# The battlefield uses panel 0 and the chapter menu uses panel 2.
		for p_idx in [0, 2]:
			_assert(ResourceLoader.exists("res://assets/sprites/backgrounds/%s_%d.png" % [lvl["bg_stem"], p_idx]), "Missing background panel %d for level %d" % [p_idx, lvl["id"]])

	for extra_path in [
		"res://assets/sprites/environments/env_path_stepping_stones.png",
		"res://assets/sprites/environments/env_atmo_clouds.png",
		"res://assets/sprites/environments/env_atmo_mist.png",
		"res://assets/sprites/environments/env_atmo_lantern_glow.png",
		"res://assets/sprites/environments/env_atmo_sunbeam.png",
		"res://assets/sprites/environments/env_atmo_fireflies.png",
		"res://assets/sprites/environments/env_atmo_snow_wind.png",
		"res://assets/sprites/ui/gardener_happy.png",
		"res://assets/sprites/ui/gardener_alert.png",
		"res://assets/sprites/ui/gardener_victory.png",
		"res://assets/sprites/ui/gardener_worried.png",
		"res://assets/sprites/ui/gardener_tutorial.png",
		"res://assets/sprites/ui/ui_kitsune_auto.png",
		"res://assets/sprites/ui/ui_rotate_landscape.png",
		"res://assets/sprites/ui/ui_btn_sound_muted.png",
		"res://assets/sprites/ui/ui_btn_auto_collect.png",
		"res://assets/sprites/ui/ui_skill_frame_ready.png",
		"res://assets/sprites/ui/ui_skill_frame_cooldown.png",
		"res://assets/sprites/ui/badge_armor.png",
		"res://assets/sprites/ui/badge_poison.png",
		"res://assets/sprites/ui/badge_slow.png",
		"res://assets/sprites/ui/badge_flying.png",
		"res://assets/sprites/ui/badge_boss.png",
		"res://assets/sprites/ui/badge_plant_ring.png",
		"res://assets/sprites/fx/fx_thunder_strike.png",
		"res://assets/sprites/fx/fx_frost_chime_wave.png",
		"res://assets/sprites/fx/fx_ice_hit_splash.png",
		"res://assets/sprites/fx/fx_miko_summon_circle.png",
		"res://assets/sprites/fx/fx_yuki_ice_breath.png",
		"res://assets/sprites/fx/fx_armor_break.png",
		"res://assets/sprites/fx/proj_sakura_petal_anim.png",
		"res://assets/sprites/fx/proj_ice_orb_anim.png",
		"res://assets/sprites/fx/proj_bamboo_dart_anim.png",
		"res://assets/sprites/fx/proj_poison_glob_anim.png",
		"res://assets/sprites/tiles/env_koi_water_anim.png",
		"res://assets/sprites/tiles/water_lily_pad.png",
		"res://assets/sprites/tiles/water_lily_lotus.png",
		"res://assets/sprites/tiles/water_splash_ring.png",
		"res://assets/sprites/tiles/koi_kohaku_swim.png",
		"res://assets/sprites/tiles/koi_yamabuki_swim.png",
		"res://assets/sprites/ui/ui_ch6_emblem.png",
		"res://assets/sprites/fx/proj_phoenix_fireball.png",
		"res://assets/sprites/fx/fx_chain_lightning_arc.png",
		"res://assets/sprites/fx/fx_daruma_buff_ring.png",
		"res://assets/sprites/fx/fx_katana_slash_wave.png",
		"res://assets/sprites/fx/proj_kappa_water_orb.png",
		"res://assets/sprites/fx/proj_kyubi_foxfire.png",
		"res://assets/sprites/environments/env_border_top_ch6.png",
		"res://assets/sprites/environments/house_ch6_fire_shrine.png",
		"res://assets/sprites/environments/gate_ch6_volcano_torii.png",
		"res://assets/sprites/tiles/tile_volcanic_stone_0.png",
		"res://assets/sprites/tiles/tile_ember_gravel_1.png",
		"res://assets/sprites/backgrounds/bg_ch6_blood_moon_shrine_0.png",
	]:
		_assert(ResourceLoader.exists(extra_path), "Missing adapted sprite " + extra_path)

	# 2. Test MainMenu instantiation & deck toggling
	var menu_scene := load("res://scenes/main/MainMenu.tscn") as PackedScene
	var menu := menu_scene.instantiate()
	root.add_child(menu)
	await process_frame
	_assert(menu.is_inside_tree(), "MainMenu enters tree cleanly")
	game_data.unlock_all_levels()
	_assert(game_data.unlocked_level == 24 and game_data.LEVELS.size() == 24, "All 24 levels unlock cleanly")
	_assert(game_data.get_level_config(21)["waves"].size() == 10, "Marathon stage 7-3 has 10 waves")
	_assert(game_data.get_level_config(24)["waves"].size() == 12, "Final marathon stage 8-3 has 12 waves")
	menu.queue_free()
	await process_frame

	# 3. Test BattleScene on Chapter 3-1 (Koi Pond level 7, water_lane = 2)
	game_data.selected_level = 7
	var battle_scene := load("res://scenes/battle/BattleScene.tscn") as PackedScene
	var battle := battle_scene.instantiate()
	root.add_child(battle)
	await process_frame
	_assert(battle.is_water_lane(2), "Chapter 3 lane 2 is Koi water lane")
	_assert(battle.get_all_obstacles().size() == 4, "Chapter 3 spawns its 4 configured obstacles")
	_check_pond_koi(battle)

	for obstacle_id in ["obs_wood_fence", "obs_crate"]:
		var obstacle = battle.spawn_obstacle(obstacle_id, 4, 7)
		_assert(obstacle._sprite.frame == 0, "%s starts intact" % obstacle_id)
		obstacle.take_damage(obstacle.max_hp * 0.4)
		_assert(obstacle._sprite.frame == 1, "%s shows cracks" % obstacle_id)
		obstacle.take_damage(obstacle.max_hp * 0.4)
		_assert(obstacle._sprite.frame == 2, "%s shows heavy damage" % obstacle_id)
		obstacle.take_damage(obstacle.max_hp * 0.25)
		_assert(obstacle._sprite.frame == 3 and battle.can_plant_at(4, 7, "dao_tien"),
			"%s shows debris and immediately frees its tile" % obstacle_id)

	for level in game_data.LEVELS:
		_assert(float(level["waves"][0]["delay"]) >= 26.0, "Chapter %d has at least 13 real seconds at 5x" % level["id"])
		_assert(int(level["starting_flame"]) >= 2 * int(game_data.DEFENDERS["than_den"]["cost"]) + int(game_data.DEFENDERS["bi_ngo"]["cost"]),
			"Chapter %d can afford two lamps and a blocker without upgrades or drops" % level["id"])
	battle.set_game_speed(5.0)
	_assert(is_equal_approx(Engine.time_scale, 2.0) and battle._wave_label.text.begins_with("Chuẩn bị"), "At 5x the opening runs on a shared 2x preparation clock")
	battle._wave_timer = 0.0
	battle._process_waves(27.9)
	_assert(battle._wave_index == 0 and battle._spawn_queue.is_empty(), "Ch3 keeps the board clear for 14 real seconds at 5x")
	battle._process_waves(0.2)
	_assert(battle._wave_index == 1 and battle._spawn_queue.size() == 2 and is_equal_approx(Engine.time_scale, 5.0), "Ch3 restores 5x at the start of the first wave")
	battle._spawn_queue.clear()
	battle._wave_index = 0
	battle._wave_timer = 0.0
	battle.set_game_speed(1.0)

	# Test Obstacle placement lock, thorns reflection, Sake barrel explosion & Shovel clearing
	var obs_block_fail = battle.try_plant_defender("dao_tien", 1, 6, -1, true)
	_assert(obs_block_fail == null, "Cannot plant directly on top of an obstacle")
	var spikes = battle._grid_obstacles[0][5]
	var spike_tester = battle.spawn_enemy("tieu_yeu", 0, game_data.cell_to_world(0, 5).x + 10.0)
	var pre_spike_hp: float = spike_tester.hp
	spikes.on_enemy_melee_hit(48.0, spike_tester)
	_assert(spike_tester.hp < pre_spike_hp, "Spike barricade reflects thorns damage to melee attacker")
	var barrel_target = battle.spawn_enemy("oni_nho", 4, game_data.cell_to_world(4, 6).x + 10.0)
	var dug_barrel: bool = battle.dig_obstacle(4, 6)
	_assert(dug_barrel and barrel_target.is_dying(), "Shovel triggering Sake Barrel detonates 3x3 destroying nearby Oni")
	var dug_rock: bool = battle.dig_obstacle(1, 6)
	_assert(dug_rock and battle.can_plant_at(1, 6, "dao_tien"), "Shovel clears Rock obstacle freeing tile for planting")

	# Test Planting & Shovel refund
	var start_flame: int = battle.spirit_flame
	_assert(start_flame == 250, "Festival Lantern grants +50 starting flame on Ch3 (200 + 50 = 250)")
	var planted_dao = battle.try_plant_defender("dao_tien", 0, 1, -1, false)
	_assert(planted_dao != null, "Đào Tiên plants with sufficient flame")
	_assert(is_equal_approx(planted_dao.max_hp, 384.0), "Bento Box grants +20% defender HP (320 -> 384)")
	_assert(battle.spirit_flame == start_flame - 100, "Planting deducts cost (100)")
	var dup_fail = battle.try_plant_defender("tre_no", 0, 1, -1, true)
	_assert(dup_fail == null, "Cannot plant on already occupied cell")
	var dug: bool = battle.dig_defender(0, 1)
	_assert(dug, "Shovel digs defender cleanly")
	_assert(battle.spirit_flame == start_flame - 100 + 50, "Golden Trowel Shovel refunds 50% flame (50)")
	await process_frame

	# Test all 10 Defenders + combat interactions
	battle.add_flame(5000)
	var d_than = battle.try_plant_defender("than_den", 0, 0, -1, true)
	var d_dao = battle.try_plant_defender("dao_tien", 0, 1, -1, true)
	var d_tre = battle.try_plant_defender("tre_no", 1, 1, -1, true)
	var d_ice = battle.try_plant_defender("ho_lo_bang", 2, 1, -1, true)
	var d_nam = battle.try_plant_defender("nam_doc", 3, 2, -1, true)
	var d_bi = battle.try_plant_defender("bi_ngo", 3, 4, -1, true)
	var d_heal = battle.try_plant_defender("chua_lanh", 3, 3, -1, true)
	var d_wind = battle.try_plant_defender("gio_loc", 4, 1, -1, true)
	var d_trap = battle.try_plant_defender("phu_chu", 4, 4, -1, true)

	_assert(d_than != null and d_dao != null and d_tre != null and d_ice != null, "P0 shooters/producer planted")
	_assert(d_nam != null and d_bi != null and d_heal != null and d_wind != null and d_trap != null, "Remaining defenders planted")

	# Advance Thần Đèn from placement through its first production animation.
	var pre_flame: int = battle.spirit_flame
	var flame_count: int = battle._flame_layer.get_child_count()
	for i in range(108):
		d_than._process_standard_defender(1.0 / 60.0)
	_assert(battle._flame_layer.get_child_count() == flame_count, "Thần Đèn plays its wind-up before dropping its first flame")
	for i in range(24):
		d_than._process_standard_defender(1.0 / 60.0)
	var lantern_flame = battle._flame_layer.get_child(-1)
	var produced: bool = battle._flame_layer.get_child_count() == flame_count + 1
	_assert(produced and lantern_flame.amount == 30, "Thần Đèn produces 30 flame within 2.2 simulation seconds of planting")
	if produced:
		lantern_flame.queue_free()
	var fl = battle.spawn_spirit_flame(Vector2(300, 200), Vector2(300, 240), 25, false)
	fl.collect()
	_assert(battle.spirit_flame == pre_flame + 25, "SpiritFlame collect adds +25")

	# Test Nấm Độc armor-piercing vs Samurai Ma & Yuki-onna freeze + Chữa Lành cleanse
	var samurai = battle.spawn_enemy("samurai_ma", 3, battle.cell_to_world_x(4) if battle.has_method("cell_to_world_x") else 520.0)
	samurai.stun_timer = 0.0
	var init_armor: float = samurai.armor_hp
	var init_hp: float = samurai.hp
	samurai.take_damage(50.0, false)
	_assert(samurai.armor_hp < init_armor and is_equal_approx(samurai.hp, init_hp), "Samurai armor absorbs non-piercing damage")
	samurai.take_damage(30.0, true)
	_assert(samurai.hp < init_hp, "Armor-piercing damage (Nấm Độc) bypasses Samurai armor")

	# Test Yuki-onna freeze & Chữa Lành heal+cleanse
	d_bi.take_damage(120.0)
	d_bi.apply_freeze(4.5)
	_assert(d_bi.frozen_timer > 0.0, "Yuki-onna freeze freezes defender")
	_assert(d_bi._frost_sprite.show_behind_parent and d_bi._health_bar.visible and d_bi._health_bar.z_index > d_bi.z_index,
		"Frozen defender keeps its body and damaged health bar above the ice")
	var damaged_hp: float = d_bi.hp
	d_heal._execute_action_effect()
	_assert(d_bi.hp > damaged_hp and d_bi.frozen_timer == 0.0, "Chữa Lành heals ally and cleanses freeze")
	d_bi.heal(d_bi.max_hp)
	_assert(not d_bi._health_bar.visible, "A fully healed defender hides its health bar")

	# Test Gió Lốc anti-air vs Tengu (travelling wind wave + smooth slide + Boss knockback resistance)
	var tengu = battle.spawn_enemy("tengu", 4, 520.0)
	_assert(tengu.is_flying, "Tengu starts flying")
	d_wind._execute_action_effect()
	var wind_proj = null
	for child in battle._projectile_layer.get_children():
		if child.get("kind") == "wind":
			wind_proj = child
	_assert(wind_proj != null, "Gió Lốc spawns piercing wind projectile")
	if wind_proj != null:
		for _w in range(12):
			wind_proj._process(0.05)
			if not tengu.is_flying:
				break
	_assert(not tengu.is_flying and tengu.hp < 250.0, "Gió Lốc grounds flying Tengu and deals anti-air damage")
	_assert(is_equal_approx(tengu._sprite.position.y, game_data.LANE_CONTACT_OFFSET), "Grounded Tengu shadow and sprite share the lane contact origin")
	for frame in range(12):
		tengu._set_body_frame(frame)
		var foot_y: float = tengu._sprite.offset.y + float(tengu.TENGU_FLY_CONTACT[frame]) - 64.0
		_assert(is_zero_approx(foot_y), "Grounded Tengu flight frame %d rests on the same contact row" % frame)
	tengu._set_body_frame(tengu._frame_idx)
	_assert(tengu._kb_remaining > 0.0 and is_equal_approx(tengu.position.x, 520.0), "Wind hit queues smooth slide instead of 1-frame teleport")
	for _k in range(12):
		tengu._process(0.05)
	_assert(tengu.position.x > 610.0 and tengu.position.x <= 645.0 and is_equal_approx(tengu._kb_remaining, 0.0), "Tengu finishes smooth wind slide cleanly")

	var boss_kb = battle.spawn_enemy("oni_lon", 4, 860.0)
	_assert(is_equal_approx(boss_kb._sprite.offset.y, -88.0), "192 px boss atlas uses the measured 8 px ground margin")
	boss_kb.knockback(115.0)
	_assert(boss_kb._kb_remaining > 20.0 and boss_kb._kb_remaining <= 32.0 and boss_kb._kb_cooldown >= 7.5, "Boss applies reduced knockback with immunity cooldown")
	var kb_before: float = boss_kb._kb_remaining
	boss_kb.knockback(115.0)
	_assert(is_equal_approx(boss_kb._kb_remaining, kb_before), "Boss knockback immunity blocks repeated stacking")
	for _bk in range(10):
		boss_kb._process(0.05)
	_assert(boss_kb.position.x > 875.0 and boss_kb.position.x <= 895.0 and is_equal_approx(boss_kb._kb_remaining, 0.0), "Boss completes short knockback slide and resumes march")
	boss_kb.queue_free()

	# Test Phù Chú stun trigger
	var tieu = battle.spawn_enemy("tieu_yeu", 4, game_data.cell_to_world(4, 4).x + 15.0)
	d_trap._trigger_phu_chu()
	_assert(tieu.stun_timer >= 3.5, "Phù Chú stuns nearby enemies in lane")

	# Test Pháo Hoa 3x3 detonation
	var d_bomb = battle.try_plant_defender("phao_hoa", 1, 5, -1, true)
	var oni = battle.spawn_enemy("oni_nho", 1, game_data.cell_to_world(1, 5).x + 20.0)
	var boss = battle.spawn_enemy("oni_lon", 2, game_data.cell_to_world(2, 5).x + 20.0)
	var boss_hp_before: float = boss.hp
	d_bomb._detonate_phao_hoa()
	_assert(oni.is_dying(), "Pháo Hoa 1200 dmg destroys Oni Nhỏ in 3x3")
	_assert(boss.hp <= boss_hp_before - 1190.0, "Pháo Hoa 1200 dmg heavily damages Boss Đại Oni in adjacent lane")

	# Test Kappa resistance & water speed flag
	var kappa = battle.spawn_enemy("kappa", 2, 700.0)
	kappa.take_damage(100.0, false)
	_assert(is_equal_approx(kappa.hp, 300.0), "Kappa reduces non-piercing damage by 40% (360 - 60 = 300)")

	# Test Nekomata, Miko Ma, Rắn Ống, Yuki-onna instantiation & Rắn Ống lane switch
	var neko = battle.spawn_enemy("nekomata", 0, 700.0)
	var miko = battle.spawn_enemy("miko_ma", 1, 680.0)
	var yuki = battle.spawn_enemy("yuki_onna", 2, 680.0)
	var ran = battle.spawn_enemy("ran_ong", 3, game_data.cell_to_world(3, 4).x + 10.0)
	_assert(neko != null and miko != null and yuki != null and ran != null, "All remaining Yokai types spawn cleanly")
	miko._execute_special_skill()
	_assert(battle.get_enemies_in_lane(0).size() >= 2, "Miko Ma summons Tiểu Yêu into adjacent lanes")

	# Test expansion Defenders, Yokai, Bosses & Obstacles
	var d_hoa = battle.try_plant_defender("hoa_phuong", 1, 2, -1, true)
	var d_daruma = battle.try_plant_defender("daruma_buff", 1, 3, -1, true)
	var d_meo = battle.try_plant_defender("meo_kiem", 0, 3, -1, true)
	var d_sam = battle.try_plant_defender("cung_sam", 2, 3, -1, true)
	_assert(d_hoa != null and d_daruma != null and d_meo != null and d_sam != null, "All 4 new expansion defenders plant cleanly")
	d_daruma._execute_action_effect()
	_assert(d_hoa.haste_timer >= 5.5 and d_meo.haste_timer >= 5.5, "Daruma Cổ Vũ hastes 3x3 allies cleanly")
	var slash_target = battle.spawn_enemy("tieu_yeu", 0, d_meo.position.x + 80.0)
	d_meo._execute_action_effect()
	_assert(slash_target.hp < slash_target.max_hp, "Mèo Kiếm Sĩ slashes enemies in range")
	var sam_t1 = battle.spawn_enemy("oni_nho", 2, d_sam.position.x + 45.0)
	var sam_t2 = battle.spawn_enemy("oni_nho", 2, d_sam.position.x + 80.0)
	d_sam._execute_action_effect()
	_assert(sam_t1.hp < sam_t1.max_hp and sam_t2.hp < sam_t2.max_hp and sam_t1.stun_timer > 0.0, "Cung Thủ Sấm chains lightning across targets")

	var karakasa = battle.spawn_enemy("karakasa", 0, 760.0)
	var chochin = battle.spawn_enemy("chochin_ma", 1, 760.0)
	var tanuki = battle.spawn_enemy("tanuki", 2, 760.0)
	var k_mage = battle.spawn_enemy("kappa_phap_su", 3, 760.0)
	_assert(karakasa != null and chochin.is_flying and tanuki != null and k_mage != null, "All 4 new Yokai spawn cleanly")
	tanuki.take_damage(tanuki.max_hp * 0.6, true)
	tanuki._process(0.05)
	_assert(tanuki._transformed and tanuki.armor_hp > 0.0, "Tanuki transforms at <=50% HP gaining armor and speed")
	k_mage._execute_special_skill()
	for boss_id in ["boss_tengu_king", "boss_kappa_lord", "boss_shogun", "boss_yuki_queen", "boss_kyubi"]:
		var b_unit = battle.spawn_enemy(boss_id, 4, 920.0)
		_assert(b_unit != null and b_unit.is_boss, "Boss %s spawns cleanly" % boss_id)
		b_unit._execute_special_skill()
		b_unit.queue_free()
	var obs_ice = battle.spawn_obstacle("obs_ice_block", 0, 7)
	var obs_curse = battle.spawn_obstacle("obs_cursed_lantern", 1, 7)
	var obs_incense = battle.spawn_obstacle("obs_incense_burner", 3, 7)
	_assert(obs_ice != null and obs_curse != null and obs_incense != null, "All 3 new obstacles spawn cleanly")
	obs_ice.destroy(true)
	obs_incense.destroy(true)
	obs_curse.destroy(false)

	# Test Komainu Guardian last-line sweep
	var breach_enemy = battle.spawn_enemy("tieu_yeu", 0, game_data.GRID_ORIGIN.x - 16.0)
	battle.on_enemy_reached_left(breach_enemy)
	_assert(battle._komainu_by_lane[0].spent and battle._komainu_by_lane[0].active, "Komainu Guardian activates on first lane breach")

	# Test Active Battle Skills (Matcha Tea, Frost Chime, Thunder Scroll)
	var pre_skill_flame: int = battle.spirit_flame
	d_dao.take_damage(80.0)
	var d_dao_damaged: float = d_dao.hp
	_assert(battle.trigger_active_skill("skill_matcha_tea"), "Matcha Tea skill triggers")
	_assert(battle.spirit_flame == pre_skill_flame + 100 and d_dao.hp > d_dao_damaged, "Matcha Tea grants +100 flame & heals defenders")
	var skill_target = battle.spawn_enemy("oni_nho", 1, 780.0)
	var sk_hp_before: float = skill_target.hp
	_assert(battle.trigger_active_skill("skill_frost_chime"), "Frost Chime skill triggers")
	_assert(skill_target.slow_timer >= 5.5 and is_equal_approx(skill_target.slow_ratio, 0.50), "Frost Chime slows enemies 50% for 6s")
	_assert(battle.trigger_active_skill("skill_thunder_scroll"), "Thunder Scroll skill triggers")
	_assert(skill_target.hp <= sk_hp_before - 255.0 and skill_target.stun_timer >= 1.2, "Thunder Scroll deals 260 dmg & stuns enemies")

	# Test Speed toggle (1x -> 2x -> 5x -> 1x)
	battle._on_toggle_speed()
	_assert(battle.speed_2x and is_equal_approx(Engine.time_scale, 2.0), "Speed toggles to 2x")
	battle._on_toggle_speed()
	var expected_speed := 2.0 if battle._wave_index == 0 else 5.0
	_assert(not battle.speed_2x and is_equal_approx(Engine.time_scale, expected_speed) and is_equal_approx(battle.speed_multiplier, 5.0), "Speed selects 5x with a 2x cap during preparation")
	battle._on_toggle_speed()
	_assert(not battle.speed_2x and is_equal_approx(Engine.time_scale, 1.0), "Speed toggles back to 1x")

	# Test 5x Auto-Play state & tactical decision step (collects Spirit Flames + plants defender)
	game_data.start_auto_play(600.0, 5.0)
	battle.set_game_speed(5.0)
	_assert(game_data.auto_play_active and game_data.get_auto_play_remaining_sec() > 590.0, "10-minute auto-play timer initializes cleanly")
	var auto_fl = battle.spawn_spirit_flame(Vector2(420, 220), Vector2(420, 260), 25, false)
	var def_count_before: int = battle.get_all_defenders().size()
	battle._step_auto_play_decision()
	_assert(auto_fl.collected, "Auto-Play AI collects uncollected Spirit Flames")
	_assert(battle.get_all_defenders().size() > def_count_before, "Auto-Play AI plants defender cleanly at 5x speed")
	game_data.stop_auto_play()
	battle.set_game_speed(1.0)

	# A fast pointer movement collects both orbs along the path, including
	# when the platform emits only one emulated mouse event for a touch swipe.
	var swipe_a = battle.spawn_spirit_flame(Vector2(480, 410), Vector2(480, 410))
	var swipe_b = battle.spawn_spirit_flame(Vector2(640, 410), Vector2(640, 410))
	var outside_swipe = battle.spawn_spirit_flame(Vector2(560, 510), Vector2(560, 510))
	var view: Transform2D = battle.get_canvas_transform()
	var swipe := InputEventMouseMotion.new()
	swipe.position = view * Vector2(760, 410)
	swipe.relative = swipe.position - (view * Vector2(380, 410))
	battle._input(swipe)
	_assert(swipe_a.collected and swipe_b.collected and not outside_swipe.collected, "Fast swipe collects orbs along its path only")

	# Let a few frames tick to verify zero runtime errors during active combat
	for _i in range(20):
		await process_frame

	# Test Victory flow
	battle._trigger_victory()
	_assert(battle.battle_ended and battle._modal_overlay.visible, "Victory triggers modal cleanly")
	_assert(battle._modal_banner.visible and battle._modal_btn_secondary.visible, "Chapter victory offers a result banner and manual replay")

	battle.queue_free()
	await process_frame

	# 4. Verify Showcase Auto-Play Formation & Final-Wave Spawn Queue Drain on Chapter 1
	game_data.selected_level = 1
	var showcase := battle_scene.instantiate()
	root.add_child(showcase)
	await process_frame

	# An ordinary drop near the top of a lane must still land in that lane.
	var drag_card = showcase._seed_cards[0]
	var drop_cell_center: Vector2 = game_data.cell_to_world(1, 2)
	var drop_position: Vector2 = showcase.get_canvas_transform() * (drop_cell_center - Vector2(0, 18))
	showcase._on_card_drag_started(drag_card.defender_id, 0, drop_position)
	_assert(showcase._ghost_sprite.visible and showcase._ghost_sprite.position.is_equal_approx(drop_cell_center), "The first drag motion previews the cell under the pointer")
	var drag_motion := InputEventMouseMotion.new()
	drag_motion.position = drop_position
	showcase._input(drag_motion)
	_assert(showcase._ghost_sprite.visible and showcase._ghost_sprite.position.is_equal_approx(drop_cell_center), "Dragging near a lane boundary previews the cell under the pointer")
	var drag_release := InputEventMouseButton.new()
	drag_release.button_index = MOUSE_BUTTON_LEFT
	drag_release.position = drop_position
	showcase._input(drag_release)
	_assert(showcase._grid_defenders[1][2] != null and showcase._grid_defenders[0][2] == null, "Releasing a card plants it in the intended lane")
	showcase.dig_defender(1, 2)

	showcase._setup_auto_play_showcase_formation()
	_assert(showcase.get_all_defenders().size() == 27, "Showcase formation plants all 27 role-slotted defenders cleanly without overlap")
	_assert(showcase._grid_defenders[0][0].defender_id == "than_den" and showcase._grid_defenders[0][4].defender_id == "bi_ngo", "Col 0 has Thần Đèn and Col 4 has Bí Ngô frontline")
	_assert(showcase._grid_defenders[2][2].defender_id == "chua_lanh" and showcase._grid_defenders[0][3].defender_id == "nam_doc", "Col 2 has Chữa Lành center and Col 3 has Nấm Độc")
	_assert(showcase._count_active_enemies() == 0, "Showcase formation leaves the battlefield clear during preparation")

	# Simulate a long frame at accelerated speed. Hit the nearest Yokai even
	# when it was spawned after the farther one and the projectile crosses both.
	var far_target = showcase.spawn_enemy("tieu_yeu", 0, 690.0)
	var near_target = showcase.spawn_enemy("tieu_yeu", 0, 590.0)
	var dart = showcase.spawn_projectile(Vector2(510, near_target.position.y), 0, "dart", 25.0)
	dart._process(0.45)
	_assert(near_target.hp < near_target.max_hp and is_equal_approx(far_target.hp, far_target.max_hp), "Fast projectile hits the first crossed enemy")
	var stun_target = showcase.spawn_enemy("oni_nho", 1, 620.0)
	stun_target._process_walk(0.25, 1.0, 13.5)
	_assert(stun_target._sprite.frame == 3 and is_equal_approx(stun_target.position.y, game_data.cell_to_world(1, 0).y), "Yokai walk advances every elapsed frame and remains on its lane")
	stun_target._blocking_defender = showcase._grid_defenders[1][4]
	var hp_before_strike: float = stun_target._blocking_defender.hp
	stun_target._process_melee_attack(0.52, 13.5)
	_assert(stun_target._sprite.frame == 7 and is_equal_approx(stun_target._blocking_defender.hp, hp_before_strike - stun_target.damage),
		"Yokai melee preserves one strike when a long frame crosses the impact pose")
	stun_target.apply_stun(1.0)
	stun_target._process(0.15)
	_assert(stun_target._stun_sprite.frame == 2, "Stun animation advances with simulation time")
	showcase.on_enemy_killed(far_target)
	far_target.free()
	showcase.on_enemy_killed(near_target)
	near_target.free()
	showcase.on_enemy_killed(stun_target)
	stun_target.free()

	# Finished effects can switch texture, sheet dimensions and motion on reuse.
	var flash_path := "res://assets/sprites/fx/fx_hit_spark.png"
	var flash = showcase.spawn_vfx(flash_path, Vector2i(4, 3), Vector2(880, 360))
	_assert(showcase.spawn_vfx(flash_path, Vector2i(4, 3), Vector2(890, 360)) == flash, "Nearby active hit flashes share a cue")
	var sprite: Sprite2D = flash._sprite
	flash._process(1.0)
	_assert(is_instance_valid(flash) and not flash.visible and not flash.is_processing(), "Finished effects are hidden and stop processing")
	var replacement = showcase.spawn_vfx("res://assets/sprites/defenders/phao_hoa_explode.png", Vector2i(4, 4), Vector2(975, 360), 20.0, 1.0, 0.8, Vector2(20, 0))
	_assert(replacement == flash and replacement._sprite == sprite and sprite.frame == 0 and sprite.vframes == 4, "Reuse resets the animation and keeps the sprite")
	_assert(replacement.z_index < showcase._grid_defenders[1][4].z_index,
		"Reused blast renders under unit bodies even when it replaces a foreground spark")
	replacement._process(0.25)
	_assert(is_equal_approx(replacement.position.x, 980.0) and sprite.frame == 5, "Reused effects use the new velocity and timing")
	replacement._process(0.6)
	_assert(not replacement.visible, "Reused loop expires at its new configured duration")
	var burst: Array[VfxEffect] = []
	for i in range(40):
		burst.append(showcase.spawn_vfx("res://assets/sprites/fx/fx_smoke_puff.png", Vector2i(4, 3), Vector2(200 + i * 16, 400)))
	for effect in burst:
		effect._process(1.0)
	_assert(showcase._idle_vfx.size() == showcase.VFX_POOL_LIMIT, "VFX pool retains only its configured limit after a large burst")

	# Verify final wave's _spawn_queue drains when _wave_index == waves.size()
	showcase._wave_index = showcase.level_cfg["waves"].size()
	showcase._spawn_queue.assign([{"id": "tieu_yeu", "lane": 0}, {"id": "oni_lon", "lane": 2}])
	showcase._spawn_stagger_timer = 0.0
	showcase._process_waves(0.1)
	showcase._process_waves(0.7)
	_assert(showcase._spawn_queue.is_empty() and showcase._count_active_enemies() == 2, "Final wave _spawn_queue drains completely when _wave_index == waves.size()")
	showcase.queue_free()
	await process_frame

	game_data.selected_level = game_data.LEVELS.size()
	var finale := battle_scene.instantiate()
	root.add_child(finale)
	await process_frame
	finale._trigger_victory()
	_assert(finale._modal_btn_primary_lbl.text == "CHƠI LẠI" and not finale._modal_btn_secondary.visible,
		"Final chapter victory offers a single replay action")
	finale.queue_free()
	await process_frame

	if _failures.is_empty():
		print("=== ALL GAMEPLAY VERIFICATION CHECKS PASSED (0 failures) ===")
		quit(0)
	else:
		print("=== VERIFICATION FAILED (%d failures) ===" % _failures.size())
		for f in _failures:
			print("  - " + f)
		quit(1)


func _check_pond_koi(battle: Node) -> void:
	var fish: Array[Sprite2D] = battle._pond_koi
	_assert(fish.size() >= 3, "The pond has a moving shoal")
	var headings: Array[float] = []
	var positions: Array[Vector2] = []
	var total_turn: Array[float] = []
	var continuous := true
	var visible_area := Rect2(186, 364, 1020, 80)
	var original_time: float = battle._pond_koi_time
	for koi in fish:
		headings.append(koi.rotation)
		positions.append(koi.position)
		total_turn.append(0.0)
	for sample in range(33 * 60):
		battle._update_pond_koi(1.0 / 60.0)
		for i in fish.size():
			var koi := fish[i]
			var turn := angle_difference(headings[i], koi.rotation)
			continuous = continuous and absf(turn) < 0.20
			continuous = continuous and visible_area.has_point(koi.position)
			continuous = continuous and koi.position.distance_to(positions[i]) < 2.0
			total_turn[i] += turn
			headings[i] = koi.rotation
			positions[i] = koi.position
	_assert(continuous, "Koi turn continuously at 60 Hz and stay inside the pond")
	_assert(not total_turn.is_empty() and absf(total_turn[0]) >= TAU - 0.1,
		"An oval-swimming koi turns a full 360 degrees")
	battle._pond_koi_time = original_time
	battle._update_pond_koi(0.0)
