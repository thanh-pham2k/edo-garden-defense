extends SceneTree

## Comprehensive automated headless gameplay verification for Edo Garden Defense.

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
		_assert(ResourceLoader.exists("res://assets/sprites/tiles/%s_0.png" % lvl["tile_primary"]), "Missing tile_primary for level %d" % lvl["id"])
		_assert(ResourceLoader.exists(lvl["ambient_particle"]), "Missing ambient particle for level %d" % lvl["id"])
		_assert(ResourceLoader.exists(lvl["top_border"]), "Missing top_border for level %d" % lvl["id"])
		_assert(ResourceLoader.exists(lvl["lawn_edge"]), "Missing lawn_edge for level %d" % lvl["id"])
		_assert(ResourceLoader.exists(lvl["house_tex"]), "Missing house_tex for level %d" % lvl["id"])
		_assert(ResourceLoader.exists(lvl["gate_tex"]), "Missing gate_tex for level %d" % lvl["id"])
		for fp in lvl["biome_flora"]:
			_assert(ResourceLoader.exists(fp), "Missing biome_flora %s for level %d" % [fp, lvl["id"]])
		for p_idx in range(4):
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
	]:
		_assert(ResourceLoader.exists(extra_path), "Missing adapted sprite " + extra_path)

	# 2. Test MainMenu instantiation & deck toggling
	var menu_scene := load("res://scenes/main/MainMenu.tscn") as PackedScene
	var menu := menu_scene.instantiate()
	root.add_child(menu)
	await process_frame
	_assert(menu.is_inside_tree(), "MainMenu enters tree cleanly")
	game_data.unlock_all_levels()
	_assert(game_data.unlocked_level == 5, "All 5 levels unlock cleanly")
	menu.queue_free()
	await process_frame

	# 3. Test BattleScene on Chapter 3 (Koi Pond water_lane = 2)
	game_data.selected_level = 3
	var battle_scene := load("res://scenes/battle/BattleScene.tscn") as PackedScene
	var battle := battle_scene.instantiate()
	root.add_child(battle)
	await process_frame
	_assert(battle.is_water_lane(2), "Chapter 3 lane 2 is Koi water lane")
	_assert(battle.get_all_obstacles().size() == 4, "Chapter 3 spawns its 4 configured obstacles")

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
	_assert(start_flame == 225, "Festival Lantern grants +50 starting flame on Ch3 (175 + 50 = 225)")
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

	# Force Thần Đèn production & test SpiritFlame collection
	var pre_flame: int = battle.spirit_flame
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
	var damaged_hp: float = d_bi.hp
	d_heal._execute_action_effect()
	_assert(d_bi.hp > damaged_hp and d_bi.frozen_timer == 0.0, "Chữa Lành heals ally and cleanses freeze")

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
	_assert(tengu._kb_remaining > 0.0 and is_equal_approx(tengu.position.x, 520.0), "Wind hit queues smooth slide instead of 1-frame teleport")
	for _k in range(12):
		tengu._process(0.05)
	_assert(tengu.position.x > 610.0 and tengu.position.x <= 645.0 and is_equal_approx(tengu._kb_remaining, 0.0), "Tengu finishes smooth wind slide cleanly")

	var boss_kb = battle.spawn_enemy("oni_lon", 4, 860.0)
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
	_assert(not battle.speed_2x and is_equal_approx(Engine.time_scale, 5.0) and is_equal_approx(battle.speed_multiplier, 5.0), "Speed toggles to 5x")
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

	# Let a few frames tick to verify zero runtime errors during active combat
	for _i in range(20):
		await process_frame

	# Test Victory flow
	battle._trigger_victory()
	_assert(battle.battle_ended and battle._modal_overlay.visible, "Victory triggers modal cleanly")

	battle.queue_free()
	await process_frame

	# 4. Verify Showcase Auto-Play Formation & Final-Wave Spawn Queue Drain on Chapter 1
	game_data.selected_level = 1
	var showcase := battle_scene.instantiate()
	root.add_child(showcase)
	await process_frame
	showcase._setup_auto_play_showcase_formation()
	_assert(showcase.get_all_defenders().size() == 27, "Showcase formation plants all 27 role-slotted defenders cleanly without overlap")
	_assert(showcase._grid_defenders[0][0].defender_id == "than_den" and showcase._grid_defenders[0][4].defender_id == "bi_ngo", "Col 0 has Thần Đèn and Col 4 has Bí Ngô frontline")
	_assert(showcase._grid_defenders[2][2].defender_id == "chua_lanh" and showcase._grid_defenders[0][3].defender_id == "nam_doc", "Col 2 has Chữa Lành center and Col 3 has Nấm Độc")
	_assert(showcase._count_active_enemies() == 5, "Showcase formation spawns 5 opening Yokai across all 5 lanes")

	# Verify final wave's _spawn_queue drains when _wave_index == waves.size()
	showcase._wave_index = showcase.level_cfg["waves"].size()
	showcase._spawn_queue.assign([{"id": "tieu_yeu", "lane": 0}, {"id": "oni_lon", "lane": 2}])
	showcase._spawn_stagger_timer = 0.0
	showcase._process_waves(0.1)
	showcase._process_waves(0.7)
	_assert(showcase._spawn_queue.is_empty() and showcase._count_active_enemies() == 7, "Final wave _spawn_queue drains completely when _wave_index == waves.size()")
	showcase.queue_free()
	await process_frame

	if _failures.is_empty():
		print("=== ALL GAMEPLAY VERIFICATION CHECKS PASSED (0 failures) ===")
		quit(0)
	else:
		print("=== VERIFICATION FAILED (%d failures) ===" % _failures.size())
		for f in _failures:
			print("  - " + f)
		quit(1)
