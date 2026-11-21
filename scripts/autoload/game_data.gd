extends Node

## Central game data registry, level configurations, deck definitions, and
## cross-platform save persistence (works on Desktop, Android/iOS, and Web IndexedDB).

const GRID_ROWS := 5
const GRID_COLS := 9
const CELL_SIZE := Vector2(96.0, 92.0)
const GRID_ORIGIN := Vector2(228.0, 174.0)
const SAVE_PATH := "user://edo_save.json"
const MAX_DECK_SIZE := 8

var selected_level: int = 1
var selected_deck: Array[String] = [
	"than_den", "dao_tien", "tre_no", "bi_ngo",
	"nam_doc", "ho_lo_bang", "phao_hoa", "gio_loc"
]
var unlocked_level: int = 1
var level_stars: Dictionary = {}
var jade_gems: int = 15
var unlocked_upgrades: Array[String] = []
var auto_collect_flame: bool = true
var sound_muted: bool = false

# Runtime 5x speed & 10-minute auto-play state
var game_speed_multiplier: float = 1.0
var auto_play_active: bool = false
var auto_play_end_ticks_msec: int = 0

const UPGRADE_ORDER: Array[String] = [
	"upg_watering_can", "upg_golden_trowel", "upg_festival_lantern",
	"upg_maneki_neko", "upg_blessing_mallet", "upg_bento_box"
]

const GARDEN_UPGRADES: Dictionary = {
	"upg_watering_can": {
		"id": "upg_watering_can",
		"name": "Bình Tưới Tre",
		"desc": "Giảm 15% thời gian hồi chiêu thẻ quân.",
		"cost": 5,
		"icon": "res://assets/sprites/items/upg_watering_can.png",
	},
	"upg_golden_trowel": {
		"id": "upg_golden_trowel",
		"name": "Xẻng Vàng",
		"desc": "Thu hồi cây hoàn lại 50% Linh Hỏa (thay vì 25%).",
		"cost": 5,
		"icon": "res://assets/sprites/items/upg_golden_trowel.png",
	},
	"upg_festival_lantern": {
		"id": "upg_festival_lantern",
		"name": "Đèn Lồng Lễ Hội",
		"desc": "Khởi đầu mỗi trận với +50 Linh Hỏa.",
		"cost": 5,
		"icon": "res://assets/sprites/items/upg_festival_lantern.png",
	},
	"upg_maneki_neko": {
		"id": "upg_maneki_neko",
		"name": "Mèo Thần Tài",
		"desc": "Tăng +50% Ngọc Magatama nhận được khi thắng.",
		"cost": 5,
		"icon": "res://assets/sprites/items/upg_maneki_neko.png",
	},
	"upg_blessing_mallet": {
		"id": "upg_blessing_mallet",
		"name": "Búa Thần Tài",
		"desc": "Mỗi ngọn Linh Hỏa thu thập cho +35 (thay vì +25).",
		"cost": 5,
		"icon": "res://assets/sprites/items/upg_blessing_mallet.png",
	},
	"upg_bento_box": {
		"id": "upg_bento_box",
		"name": "Hộp Cơm Bento",
		"desc": "Tăng +20% máu tối đa cho toàn bộ quân phòng thủ.",
		"cost": 5,
		"icon": "res://assets/sprites/items/upg_bento_box.png",
	},
}

const ACTIVE_SKILL_ORDER: Array[String] = [
	"skill_matcha_tea", "skill_frost_chime", "skill_thunder_scroll"
]

const ACTIVE_SKILLS: Dictionary = {
	"skill_matcha_tea": {
		"id": "skill_matcha_tea",
		"name": "Trà Matcha",
		"desc": "Nhận ngay +100 Linh Hỏa & hồi +60 HP cho toàn quân.",
		"cost": 0,
		"cooldown": 25.0,
		"hotkey": "Q",
		"icon": "res://assets/sprites/items/skill_matcha_tea.png",
	},
	"skill_frost_chime": {
		"id": "skill_frost_chime",
		"name": "Chuông Băng",
		"desc": "Làm chậm toàn bộ Yokai 50% trong 6 giây.",
		"cost": 75,
		"cooldown": 30.0,
		"hotkey": "W",
		"icon": "res://assets/sprites/items/skill_frost_chime.png",
	},
	"skill_thunder_scroll": {
		"id": "skill_thunder_scroll",
		"name": "Cuộn Sấm Sét",
		"desc": "Giáng 260 sát thương xuyên giáp & choáng 1.5s toàn bản đồ.",
		"cost": 125,
		"cooldown": 35.0,
		"hotkey": "E",
		"icon": "res://assets/sprites/items/skill_thunder_scroll.png",
	},
}

const ITEM_ICONS: Array[String] = [
	"res://assets/sprites/items/item_magatama_jade.png",
	"res://assets/sprites/items/item_magatama_ruby.png",
	"res://assets/sprites/items/item_koban_coins.png",
	"res://assets/sprites/items/item_omamori_charm.png",
	"res://assets/sprites/items/item_golden_seed.png",
	"res://assets/sprites/items/item_treasure_chest.png",
	"res://assets/sprites/items/skill_fire_fan.png",
	"res://assets/sprites/items/skill_taiko_drum.png",
	"res://assets/sprites/items/skill_edo_shield.png",
]

const DEFENDER_ORDER: Array[String] = [
	"than_den", "dao_tien", "tre_no", "bi_ngo", "nam_doc",
	"ho_lo_bang", "phao_hoa", "phu_chu", "gio_loc", "chua_lanh"
]

const DEFENDERS: Dictionary = {
	"dao_tien": {
		"id": "dao_tien",
		"name": "Đào Tiên",
		"role": "Bắn đơn cánh hoa",
		"desc": "Bắn cánh hoa anh đào thẳng 1 hàng (24 sát thương).",
		"cost": 100,
		"cooldown": 6.5,
		"hp": 320.0,
		"attack_interval": 1.35,
		"damage": 24.0,
		"idle_sheet": "res://assets/sprites/defenders/dao_tien_idle.png",
		"idle_grid": Vector2i(3, 2),
		"action_sheet": "res://assets/sprites/defenders/dao_tien_attack.png",
		"action_grid": Vector2i(4, 3),
		"icon": "res://assets/sprites/defenders/dao_tien_icon.png",
	},
	"tre_no": {
		"id": "tre_no",
		"name": "Tre Nỏ",
		"role": "Bắn nhanh 2 mũi",
		"desc": "Bắn liên tiếp 2 mũi tên tre mỗi loạt (2×22 sát thương).",
		"cost": 200,
		"cooldown": 7.0,
		"hp": 320.0,
		"attack_interval": 1.35,
		"damage": 22.0,
		"idle_sheet": "res://assets/sprites/defenders/tre_no_idle.png",
		"idle_grid": Vector2i(3, 2),
		"action_sheet": "res://assets/sprites/defenders/tre_no_attack.png",
		"action_grid": Vector2i(4, 3),
		"icon": "res://assets/sprites/defenders/tre_no_icon.png",
	},
	"than_den": {
		"id": "than_den",
		"name": "Thần Đèn",
		"role": "Tạo Linh Hỏa",
		"desc": "Phát sáng tạo +25 Linh Hỏa mỗi 10.5 giây.",
		"cost": 50,
		"cooldown": 6.5,
		"hp": 260.0,
		"attack_interval": 10.5,
		"damage": 0.0,
		"idle_sheet": "res://assets/sprites/defenders/than_den_idle.png",
		"idle_grid": Vector2i(3, 2),
		"action_sheet": "res://assets/sprites/defenders/than_den_produce.png",
		"action_grid": Vector2i(4, 3),
		"icon": "res://assets/sprites/defenders/than_den_icon.png",
	},
	"bi_ngo": {
		"id": "bi_ngo",
		"name": "Bí Ngô",
		"role": "Tường chắn Tank",
		"desc": "Máu cực cao (2400 HP), giữ chân Yokai cho tuyến sau.",
		"cost": 50,
		"cooldown": 18.0,
		"hp": 2400.0,
		"attack_interval": 0.0,
		"damage": 0.0,
		"idle_sheet": "res://assets/sprites/defenders/bi_ngo_states.png",
		"idle_grid": Vector2i(3, 2),
		"action_sheet": "res://assets/sprites/defenders/bi_ngo_states.png",
		"action_grid": Vector2i(3, 2),
		"icon": "res://assets/sprites/defenders/bi_ngo_icon.png",
	},
	"nam_doc": {
		"id": "nam_doc",
		"name": "Nấm Độc",
		"role": "Độc lan xuyên giáp",
		"desc": "Phun khói độc tầm 3.8 ô, xuyên giáp Kappa & Samurai.",
		"cost": 150,
		"cooldown": 9.0,
		"hp": 320.0,
		"attack_interval": 1.65,
		"damage": 30.0,
		"range_cells": 3.8,
		"idle_sheet": "res://assets/sprites/defenders/nam_doc_idle.png",
		"idle_grid": Vector2i(3, 2),
		"action_sheet": "res://assets/sprites/defenders/nam_doc_attack.png",
		"action_grid": Vector2i(4, 3),
		"icon": "res://assets/sprites/defenders/nam_doc_icon.png",
	},
	"ho_lo_bang": {
		"id": "ho_lo_bang",
		"name": "Hồ Lô Băng",
		"role": "Bắn làm chậm 45%",
		"desc": "Bắn cầu băng gây 22 sát thương & làm chậm 45% trong 4.5s.",
		"cost": 175,
		"cooldown": 7.0,
		"hp": 320.0,
		"attack_interval": 1.45,
		"damage": 22.0,
		"idle_sheet": "res://assets/sprites/defenders/ho_lo_bang_idle.png",
		"idle_grid": Vector2i(3, 2),
		"action_sheet": "res://assets/sprites/defenders/ho_lo_bang_attack.png",
		"action_grid": Vector2i(4, 3),
		"icon": "res://assets/sprites/defenders/ho_lo_bang_icon.png",
	},
	"phao_hoa": {
		"id": "phao_hoa",
		"name": "Pháo Hoa",
		"role": "Nổ 3×3 (1200 dmg)",
		"desc": "Kích nổ sau 0.85s gây 1200 sát thương vùng 3×3.",
		"cost": 150,
		"cooldown": 25.0,
		"hp": 9999.0,
		"attack_interval": 0.85,
		"damage": 1200.0,
		"idle_sheet": "res://assets/sprites/defenders/phao_hoa_arm.png",
		"idle_grid": Vector2i(4, 3),
		"action_sheet": "res://assets/sprites/defenders/phao_hoa_explode.png",
		"action_grid": Vector2i(4, 4),
		"icon": "res://assets/sprites/defenders/phao_hoa_icon.png",
	},
	"phu_chu": {
		"id": "phu_chu",
		"name": "Phù Chú",
		"role": "Bẫy choáng 4s",
		"desc": "Kích nổ khi Yokai chạm vào, gây choáng vùng 1×3 trong 4s.",
		"cost": 75,
		"cooldown": 15.0,
		"hp": 9999.0,
		"attack_interval": 0.25,
		"damage": 65.0,
		"idle_sheet": "res://assets/sprites/defenders/phu_chu_idle_trigger.png",
		"idle_grid": Vector2i(4, 3),
		"action_sheet": "res://assets/sprites/defenders/phu_chu_idle_trigger.png",
		"action_grid": Vector2i(4, 3),
		"icon": "res://assets/sprites/defenders/phu_chu_icon.png",
	},
	"gio_loc": {
		"id": "gio_loc",
		"name": "Gió Lốc",
		"role": "Đẩy lùi / Hạ Tengu",
		"desc": "Thổi bay Yokai lùi lại 1.8 ô; khắc chế Tengu bay.",
		"cost": 125,
		"cooldown": 12.0,
		"hp": 320.0,
		"attack_interval": 4.5,
		"damage": 20.0,
		"idle_sheet": "res://assets/sprites/defenders/gio_loc_idle.png",
		"idle_grid": Vector2i(3, 2),
		"action_sheet": "res://assets/sprites/defenders/gio_loc_blow.png",
		"action_grid": Vector2i(4, 3),
		"icon": "res://assets/sprites/defenders/gio_loc_icon.png",
	},
	"chua_lanh": {
		"id": "chua_lanh",
		"name": "Chữa Lành",
		"role": "Hồi máu & Giải băng",
		"desc": "Hồi +90 HP cho quân vùng 3×3 & giải đóng băng Yuki-onna.",
		"cost": 100,
		"cooldown": 12.0,
		"hp": 400.0,
		"attack_interval": 5.0,
		"damage": 0.0,
		"idle_sheet": "res://assets/sprites/defenders/chua_lanh_idle.png",
		"idle_grid": Vector2i(3, 2),
		"action_sheet": "res://assets/sprites/defenders/chua_lanh_heal.png",
		"action_grid": Vector2i(4, 3),
		"icon": "res://assets/sprites/defenders/chua_lanh_icon.png",
	},
}

const ENEMIES: Dictionary = {
	"tieu_yeu": {
		"id": "tieu_yeu",
		"name": "Tiểu Yêu",
		"hp": 180.0,
		"armor_hp": 0.0,
		"speed": 30.0,
		"damage": 48.0,
		"attack_interval": 1.0,
		"damage_reduction": 0.0,
		"is_flying": false,
		"is_boss": false,
		"move_sheet": "res://assets/sprites/enemies/tieu_yeu_walk.png",
		"attack_sheet": "res://assets/sprites/enemies/tieu_yeu_attack.png",
		"die_sheet": "res://assets/sprites/enemies/tieu_yeu_die.png",
		"grid": Vector2i(4, 3),
		"icon": "res://assets/sprites/enemies/tieu_yeu_icon.png",
	},
	"oni_nho": {
		"id": "oni_nho",
		"name": "Oni Nhỏ",
		"hp": 460.0,
		"armor_hp": 0.0,
		"speed": 23.0,
		"damage": 75.0,
		"attack_interval": 1.1,
		"damage_reduction": 0.0,
		"is_flying": false,
		"is_boss": false,
		"move_sheet": "res://assets/sprites/enemies/oni_nho_walk.png",
		"attack_sheet": "res://assets/sprites/enemies/oni_nho_attack.png",
		"die_sheet": "res://assets/sprites/enemies/oni_nho_die.png",
		"grid": Vector2i(4, 3),
		"icon": "res://assets/sprites/enemies/oni_nho_icon.png",
	},
	"nekomata": {
		"id": "nekomata",
		"name": "Nekomata",
		"hp": 160.0,
		"armor_hp": 0.0,
		"speed": 58.0,
		"damage": 52.0,
		"attack_interval": 0.75,
		"damage_reduction": 0.0,
		"is_flying": false,
		"is_boss": false,
		"move_sheet": "res://assets/sprites/enemies/nekomata_walk.png",
		"attack_sheet": "res://assets/sprites/enemies/nekomata_attack.png",
		"die_sheet": "res://assets/sprites/enemies/nekomata_die.png",
		"grid": Vector2i(4, 3),
		"icon": "res://assets/sprites/enemies/nekomata_icon.png",
	},
	"kappa": {
		"id": "kappa",
		"name": "Kappa",
		"hp": 360.0,
		"armor_hp": 0.0,
		"speed": 30.0,
		"damage": 60.0,
		"attack_interval": 1.0,
		"damage_reduction": 0.40,
		"is_flying": false,
		"is_boss": false,
		"move_sheet": "res://assets/sprites/enemies/kappa_walk.png",
		"attack_sheet": "res://assets/sprites/enemies/kappa_attack.png",
		"die_sheet": "res://assets/sprites/enemies/kappa_die.png",
		"grid": Vector2i(4, 3),
		"icon": "res://assets/sprites/enemies/kappa_icon.png",
	},
	"tengu": {
		"id": "tengu",
		"name": "Tengu",
		"hp": 250.0,
		"armor_hp": 0.0,
		"speed": 46.0,
		"damage": 65.0,
		"attack_interval": 0.95,
		"damage_reduction": 0.0,
		"is_flying": true,
		"is_boss": false,
		"move_sheet": "res://assets/sprites/enemies/tengu_fly.png",
		"attack_sheet": "res://assets/sprites/enemies/tengu_attack.png",
		"die_sheet": "res://assets/sprites/enemies/tengu_die.png",
		"grid": Vector2i(4, 3),
		"icon": "res://assets/sprites/enemies/tengu_icon.png",
	},
	"oni_lon": {
		"id": "oni_lon",
		"name": "Đại Oni",
		"hp": 1900.0,
		"armor_hp": 0.0,
		"speed": 17.0,
		"damage": 150.0,
		"attack_interval": 1.35,
		"damage_reduction": 0.0,
		"is_flying": false,
		"is_boss": true,
		"move_sheet": "res://assets/sprites/enemies/oni_lon_walk.png",
		"attack_sheet": "res://assets/sprites/enemies/oni_lon_attack.png",
		"die_sheet": "res://assets/sprites/enemies/oni_lon_die.png",
		"grid": Vector2i(4, 4),
		"icon": "res://assets/sprites/enemies/oni_lon_icon.png",
	},
	"miko_ma": {
		"id": "miko_ma",
		"name": "Miko Ma",
		"hp": 320.0,
		"armor_hp": 0.0,
		"speed": 22.0,
		"damage": 50.0,
		"attack_interval": 1.1,
		"damage_reduction": 0.0,
		"is_flying": false,
		"is_boss": false,
		"move_sheet": "res://assets/sprites/enemies/miko_ma_walk.png",
		"attack_sheet": "res://assets/sprites/enemies/miko_ma_summon.png",
		"die_sheet": "res://assets/sprites/enemies/miko_ma_die.png",
		"grid": Vector2i(4, 3),
		"icon": "res://assets/sprites/enemies/miko_ma_icon.png",
	},
	"samurai_ma": {
		"id": "samurai_ma",
		"name": "Samurai Ma",
		"hp": 400.0,
		"armor_hp": 480.0,
		"speed": 24.0,
		"damage": 85.0,
		"attack_interval": 1.0,
		"damage_reduction": 0.0,
		"is_flying": false,
		"is_boss": false,
		"move_sheet": "res://assets/sprites/enemies/samurai_ma_walk.png",
		"attack_sheet": "res://assets/sprites/enemies/samurai_ma_attack.png",
		"die_sheet": "res://assets/sprites/enemies/samurai_ma_die.png",
		"grid": Vector2i(4, 3),
		"icon": "res://assets/sprites/enemies/samurai_ma_icon.png",
	},
	"yuki_onna": {
		"id": "yuki_onna",
		"name": "Yuki-onna",
		"hp": 350.0,
		"armor_hp": 0.0,
		"speed": 27.0,
		"damage": 62.0,
		"attack_interval": 1.05,
		"damage_reduction": 0.0,
		"is_flying": false,
		"is_boss": false,
		"move_sheet": "res://assets/sprites/enemies/yuki_onna_walk.png",
		"attack_sheet": "res://assets/sprites/enemies/yuki_onna_cast.png",
		"die_sheet": "res://assets/sprites/enemies/yuki_onna_die.png",
		"grid": Vector2i(4, 3),
		"icon": "res://assets/sprites/enemies/yuki_onna_icon.png",
	},
	"ran_ong": {
		"id": "ran_ong",
		"name": "Rắn Ống",
		"hp": 390.0,
		"armor_hp": 0.0,
		"speed": 42.0,
		"damage": 58.0,
		"attack_interval": 0.85,
		"damage_reduction": 0.0,
		"is_flying": false,
		"is_boss": false,
		"move_sheet": "res://assets/sprites/enemies/ran_ong_walk.png",
		"attack_sheet": "res://assets/sprites/enemies/ran_ong_attack.png",
		"die_sheet": "res://assets/sprites/enemies/ran_ong_die.png",
		"grid": Vector2i(4, 3),
		"icon": "res://assets/sprites/enemies/ran_ong_icon.png",
	},
}

const OBSTACLES: Dictionary = {
	"obs_rock": {
		"id": "obs_rock",
		"name": "Tảng Đá",
		"hp": 600.0,
		"thorns": 0.0,
		"explodes": false,
		"sheet": "res://assets/sprites/obstacles/obs_rock.png",
	},
	"obs_spike_barricade": {
		"id": "obs_spike_barricade",
		"name": "Rào Gai",
		"hp": 380.0,
		"thorns": 22.0,
		"explodes": false,
		"sheet": "res://assets/sprites/obstacles/obs_spike_barricade.png",
	},
	"obs_wood_fence": {
		"id": "obs_wood_fence",
		"name": "Hàng Rào Gỗ",
		"hp": 340.0,
		"thorns": 0.0,
		"explodes": false,
		"sheet": "res://assets/sprites/obstacles/obs_wood_fence.png",
	},
	"obs_crate": {
		"id": "obs_crate",
		"name": "Thùng Gỗ",
		"hp": 300.0,
		"thorns": 0.0,
		"explodes": false,
		"sheet": "res://assets/sprites/obstacles/obs_crate.png",
	},
	"obs_haystack": {
		"id": "obs_haystack",
		"name": "Đống Rơm",
		"hp": 260.0,
		"thorns": 0.0,
		"explodes": false,
		"sheet": "res://assets/sprites/obstacles/obs_haystack.png",
	},
	"obs_sake_barrel": {
		"id": "obs_sake_barrel",
		"name": "Thùng Sake",
		"hp": 220.0,
		"thorns": 0.0,
		"explodes": true,
		"sheet": "res://assets/sprites/obstacles/obs_sake_barrel.png",
	},
}

const LEVELS: Array[Dictionary] = [
	{
		"id": 1,
		"name": "Chương 1: Sân Vườn Làng Hoa",
		"subtitle": "Ban ngày — Bảo vệ nhà cổ khỏi Tiểu Yêu & Oni Nhỏ",
		"bg_stem": "bg_ch1_sakura_village",
		"tile_primary": "tile_grass",
		"tile_alt": "tile_dirt",
		"water_lane": -1,
		"sky_top": Color(0.55, 0.78, 0.94, 1),
		"sky_bottom": Color(0.84, 0.93, 0.88, 1),
		"ground_tint": Color(0.45, 0.63, 0.34, 1),
		"ambient_particle": "res://assets/sprites/fx/part_sakura_1.png",
		"natural_flame_interval": 8.0,
		"starting_flame": 150,
		"obstacles": [],
		"props": [
			"res://assets/sprites/props/prop_sakura_tree.png",
			"res://assets/sprites/props/prop_market_stall.png",
			"res://assets/sprites/props/prop_flower_bush.png",
		],
		"waves": [
			{"delay": 3.5, "huge": false, "spawns": ["tieu_yeu", "tieu_yeu"]},
			{"delay": 10.0, "huge": false, "spawns": ["tieu_yeu", "tieu_yeu", "nekomata"]},
			{"delay": 11.0, "huge": false, "spawns": ["tieu_yeu", "oni_nho", "tieu_yeu"]},
			{"delay": 12.0, "huge": false, "spawns": ["nekomata", "oni_nho", "tieu_yeu", "tieu_yeu"]},
			{"delay": 13.0, "huge": false, "spawns": ["oni_nho", "kappa", "nekomata", "tieu_yeu"]},
			{"delay": 14.0, "huge": true, "spawns": ["oni_nho", "oni_nho", "kappa", "nekomata", "tieu_yeu", "tieu_yeu", "oni_lon"]},
		],
	},
	{
		"id": 2,
		"name": "Chương 2: Rừng Tre Hoàng Hôn",
		"subtitle": "Hoàng hôn — Vật cản rào gỗ, Tengu bay & Nekomata",
		"bg_stem": "bg_ch2_bamboo_sunset",
		"tile_primary": "tile_moss_stone",
		"tile_alt": "tile_cobble",
		"water_lane": -1,
		"sky_top": Color(0.72, 0.36, 0.28, 1),
		"sky_bottom": Color(0.95, 0.69, 0.36, 1),
		"ground_tint": Color(0.36, 0.44, 0.32, 1),
		"ambient_particle": "res://assets/sprites/fx/part_bamboo_leaf.png",
		"natural_flame_interval": 9.0,
		"starting_flame": 150,
		"obstacles": [
			{"id": "obs_wood_fence", "row": 1, "col": 5},
			{"id": "obs_rock", "row": 2, "col": 6},
			{"id": "obs_wood_fence", "row": 3, "col": 5},
			{"id": "obs_crate", "row": 4, "col": 6},
		],
		"props": [
			"res://assets/sprites/props/prop_bamboo_grove.png",
			"res://assets/sprites/props/prop_lantern.png",
			"res://assets/sprites/props/prop_signpost.png",
		],
		"waves": [
			{"delay": 3.5, "huge": false, "spawns": ["tieu_yeu", "nekomata"]},
			{"delay": 9.5, "huge": false, "spawns": ["tieu_yeu", "tengu", "tieu_yeu"]},
			{"delay": 10.5, "huge": false, "spawns": ["oni_nho", "tengu", "nekomata"]},
			{"delay": 11.5, "huge": false, "spawns": ["kappa", "tengu", "oni_nho", "tieu_yeu"]},
			{"delay": 12.0, "huge": false, "spawns": ["ran_ong", "tengu", "nekomata", "oni_nho"]},
			{"delay": 12.5, "huge": false, "spawns": ["kappa", "ran_ong", "oni_nho", "tengu", "nekomata"]},
			{"delay": 14.0, "huge": true, "spawns": ["oni_lon", "tengu", "tengu", "ran_ong", "kappa", "oni_nho", "nekomata"]},
		],
	},
	{
		"id": 3,
		"name": "Chương 3: Hồ Cá Koi Đền Thần",
		"subtitle": "Ban đêm — Làn nước Hồ Koi, Rào gai & Miko Ma",
		"bg_stem": "bg_ch3_koi_shrine_night",
		"tile_primary": "tile_sakura",
		"tile_alt": "tile_moss_stone",
		"water_lane": 2,
		"sky_top": Color(0.11, 0.14, 0.30, 1),
		"sky_bottom": Color(0.22, 0.31, 0.48, 1),
		"ground_tint": Color(0.24, 0.28, 0.38, 1),
		"ambient_particle": "res://assets/sprites/fx/part_spirit_wisp.png",
		"natural_flame_interval": 10.0,
		"starting_flame": 175,
		"obstacles": [
			{"id": "obs_spike_barricade", "row": 0, "col": 5},
			{"id": "obs_rock", "row": 1, "col": 6},
			{"id": "obs_spike_barricade", "row": 3, "col": 5},
			{"id": "obs_sake_barrel", "row": 4, "col": 6},
		],
		"props": [
			"res://assets/sprites/props/prop_red_bridge.png",
			"res://assets/sprites/props/prop_pagoda.png",
			"res://assets/sprites/props/prop_hanging_lantern.png",
		],
		"waves": [
			{"delay": 3.5, "huge": false, "spawns": ["tieu_yeu", "kappa"]},
			{"delay": 9.5, "huge": false, "spawns": ["kappa", "kappa", "tieu_yeu"]},
			{"delay": 10.5, "huge": false, "spawns": ["miko_ma", "tieu_yeu", "kappa"]},
			{"delay": 11.0, "huge": false, "spawns": ["tengu", "kappa", "nekomata", "miko_ma"]},
			{"delay": 11.5, "huge": false, "spawns": ["oni_nho", "kappa", "ran_ong", "tengu"]},
			{"delay": 12.0, "huge": false, "spawns": ["miko_ma", "samurai_ma", "kappa", "tieu_yeu"]},
			{"delay": 13.0, "huge": false, "spawns": ["kappa", "tengu", "miko_ma", "oni_nho", "ran_ong"]},
			{"delay": 14.0, "huge": true, "spawns": ["oni_lon", "miko_ma", "kappa", "kappa", "samurai_ma", "tengu", "nekomata"]},
		],
	},
	{
		"id": 4,
		"name": "Chương 4: Thành Cổ Sương Mù",
		"subtitle": "Đêm sương — Thùng Sake nổ, Samurai Ma & Rắn Ống",
		"bg_stem": "bg_ch4_misty_castle",
		"tile_primary": "tile_gravel_night",
		"tile_alt": "tile_cobble",
		"water_lane": -1,
		"sky_top": Color(0.16, 0.14, 0.25, 1),
		"sky_bottom": Color(0.32, 0.31, 0.42, 1),
		"ground_tint": Color(0.24, 0.24, 0.30, 1),
		"ambient_particle": "res://assets/sprites/fx/part_sakura_2.png",
		"natural_flame_interval": 10.0,
		"starting_flame": 175,
		"obstacles": [
			{"id": "obs_crate", "row": 0, "col": 5},
			{"id": "obs_sake_barrel", "row": 1, "col": 6},
			{"id": "obs_spike_barricade", "row": 2, "col": 5},
			{"id": "obs_sake_barrel", "row": 3, "col": 6},
			{"id": "obs_rock", "row": 4, "col": 5},
		],
		"props": [
			"res://assets/sprites/props/prop_pagoda.png",
			"res://assets/sprites/props/prop_lantern.png",
			"res://assets/sprites/props/prop_banner.png",
		],
		"waves": [
			{"delay": 3.5, "huge": false, "spawns": ["tieu_yeu", "ran_ong"]},
			{"delay": 9.5, "spawns": ["samurai_ma", "tieu_yeu", "nekomata"], "huge": false},
			{"delay": 10.5, "spawns": ["ran_ong", "kappa", "miko_ma"], "huge": false},
			{"delay": 11.0, "spawns": ["samurai_ma", "tengu", "oni_nho", "ran_ong"], "huge": false},
			{"delay": 11.5, "spawns": ["miko_ma", "samurai_ma", "kappa", "nekomata"], "huge": false},
			{"delay": 12.0, "spawns": ["ran_ong", "ran_ong", "samurai_ma", "tengu"], "huge": false},
			{"delay": 12.5, "spawns": ["oni_nho", "samurai_ma", "miko_ma", "yuki_onna"], "huge": false},
			{"delay": 13.0, "spawns": ["samurai_ma", "samurai_ma", "ran_ong", "tengu", "kappa"], "huge": false},
			{"delay": 14.0, "spawns": ["oni_lon", "samurai_ma", "samurai_ma", "miko_ma", "ran_ong", "tengu", "oni_nho"], "huge": true},
		],
	},
	{
		"id": 5,
		"name": "Chương 5: Đỉnh Núi Tuyết Trắng",
		"subtitle": "Bão tuyết — Đống rơm, Yuki-onna & Trùm Đại Oni",
		"bg_stem": "bg_ch5_snowy_mountain",
		"tile_primary": "tile_snow",
		"tile_alt": "tile_gravel_night",
		"water_lane": -1,
		"sky_top": Color(0.16, 0.25, 0.40, 1),
		"sky_bottom": Color(0.65, 0.80, 0.92, 1),
		"ground_tint": Color(0.55, 0.65, 0.78, 1),
		"ambient_particle": "res://assets/sprites/fx/part_snowflake.png",
		"natural_flame_interval": 9.5,
		"starting_flame": 200,
		"obstacles": [
			{"id": "obs_haystack", "row": 0, "col": 5},
			{"id": "obs_rock", "row": 1, "col": 6},
			{"id": "obs_sake_barrel", "row": 2, "col": 6},
			{"id": "obs_haystack", "row": 3, "col": 5},
			{"id": "obs_spike_barricade", "row": 4, "col": 5},
		],
		"props": [
			"res://assets/sprites/props/prop_snow_bonsai.png",
			"res://assets/sprites/props/prop_pagoda.png",
			"res://assets/sprites/props/prop_hanging_lantern.png",
		],
		"waves": [
			{"delay": 3.5, "huge": false, "spawns": ["tieu_yeu", "yuki_onna"]},
			{"delay": 9.5, "huge": false, "spawns": ["yuki_onna", "nekomata", "tieu_yeu"]},
			{"delay": 10.0, "huge": false, "spawns": ["samurai_ma", "yuki_onna", "tengu"]},
			{"delay": 10.5, "huge": false, "spawns": ["ran_ong", "yuki_onna", "kappa", "oni_nho"]},
			{"delay": 11.0, "huge": false, "spawns": ["miko_ma", "samurai_ma", "yuki_onna", "tengu"]},
			{"delay": 11.5, "huge": false, "spawns": ["yuki_onna", "yuki_onna", "samurai_ma", "ran_ong"]},
			{"delay": 12.0, "huge": false, "spawns": ["oni_lon", "yuki_onna", "tengu", "nekomata"]},
			{"delay": 12.5, "huge": false, "spawns": ["samurai_ma", "miko_ma", "yuki_onna", "ran_ong", "kappa"]},
			{"delay": 13.0, "huge": false, "spawns": ["oni_lon", "samurai_ma", "yuki_onna", "tengu", "miko_ma"]},
			{"delay": 14.5, "huge": true, "spawns": ["oni_lon", "oni_lon", "yuki_onna", "samurai_ma", "miko_ma", "ran_ong", "tengu", "kappa"]},
		],
	},
]


func _ready() -> void:
	load_progress()
	var args := OS.get_cmdline_args()
	var user_args := OS.get_cmdline_user_args()
	if args.has("--autoplay-5x-10m") or user_args.has("--autoplay-5x-10m") or DisplayServer.get_name() != "headless":
		start_auto_play(600.0, 5.0)


func start_auto_play(duration_sec: float = 600.0, speed: float = 5.0) -> void:
	auto_play_active = true
	auto_play_end_ticks_msec = Time.get_ticks_msec() + int(round(duration_sec * 1000.0))
	game_speed_multiplier = speed
	auto_collect_flame = true
	unlocked_level = LEVELS.size()
	prepare_auto_play_loadout(selected_level)


func stop_auto_play() -> void:
	auto_play_active = false
	auto_play_end_ticks_msec = 0
	game_speed_multiplier = 1.0
	Engine.time_scale = 1.0


func get_auto_play_remaining_sec() -> float:
	if not auto_play_active:
		return 0.0
	var rem := float(auto_play_end_ticks_msec - Time.get_ticks_msec()) / 1000.0
	return maxf(0.0, rem)


func prepare_auto_play_loadout(lvl_id: int) -> void:
	for uid in UPGRADE_ORDER:
		if not has_upgrade(uid) and jade_gems >= int(GARDEN_UPGRADES[uid]["cost"]):
			unlock_upgrade(uid)
	match lvl_id:
		2:
			selected_deck.assign(["than_den", "dao_tien", "tre_no", "bi_ngo", "ho_lo_bang", "phao_hoa", "gio_loc", "phu_chu"])
		4, 5:
			selected_deck.assign(["than_den", "tre_no", "bi_ngo", "nam_doc", "ho_lo_bang", "phao_hoa", "gio_loc", "chua_lanh"])
		_:
			selected_deck.assign(["than_den", "dao_tien", "tre_no", "bi_ngo", "nam_doc", "ho_lo_bang", "phao_hoa", "phu_chu"])
	save_progress()


func get_level_config(level_id: int) -> Dictionary:
	var idx := clampi(level_id - 1, 0, LEVELS.size() - 1)
	return LEVELS[idx]


func cell_to_world(row: int, col: int) -> Vector2:
	return GRID_ORIGIN + Vector2((col + 0.5) * CELL_SIZE.x, (row + 0.5) * CELL_SIZE.y)


func world_to_cell(pos: Vector2) -> Vector2i:
	var rel := pos - GRID_ORIGIN
	if rel.x < 0.0 or rel.y < 0.0:
		return Vector2i(-1, -1)
	var col := int(floor(rel.x / CELL_SIZE.x))
	var row := int(floor(rel.y / CELL_SIZE.y))
	if row < 0 or row >= GRID_ROWS or col < 0 or col >= GRID_COLS:
		return Vector2i(-1, -1)
	return Vector2i(row, col)


func is_deck_member(defender_id: String) -> bool:
	return selected_deck.has(defender_id)


func toggle_deck_member(defender_id: String) -> bool:
	if selected_deck.has(defender_id):
		if selected_deck.size() <= 1:
			return false
		selected_deck.erase(defender_id)
		save_progress()
		return true
	if selected_deck.size() >= MAX_DECK_SIZE:
		return false
	selected_deck.append(defender_id)
	save_progress()
	return true


func has_upgrade(uid: String) -> bool:
	return unlocked_upgrades.has(uid)


func unlock_upgrade(uid: String) -> bool:
	if unlocked_upgrades.has(uid) or not GARDEN_UPGRADES.has(uid):
		return false
	var cost := int(GARDEN_UPGRADES[uid]["cost"])
	if jade_gems < cost:
		return false
	jade_gems -= cost
	unlocked_upgrades.append(uid)
	save_progress()
	return true


func get_cooldown_mult() -> float:
	return 0.85 if has_upgrade("upg_watering_can") else 1.0


func get_shovel_refund_ratio() -> float:
	return 0.50 if has_upgrade("upg_golden_trowel") else 0.25


func get_starting_flame_bonus() -> int:
	return 50 if has_upgrade("upg_festival_lantern") else 0


func get_flame_value() -> int:
	return 35 if has_upgrade("upg_blessing_mallet") else 25


func get_defender_hp_mult() -> float:
	return 1.20 if has_upgrade("upg_bento_box") else 1.0


func get_victory_jade_reward(stars: int) -> int:
	var base := 5 + stars * 3
	if has_upgrade("upg_maneki_neko"):
		base = int(ceil(float(base) * 1.5))
	return base


func record_level_win(level_id: int, stars: int) -> int:
	var key := str(level_id)
	var prev := int(level_stars.get(key, 0))
	if stars > prev:
		level_stars[key] = stars
	if level_id >= unlocked_level and level_id < LEVELS.size():
		unlocked_level = level_id + 1
	var reward := get_victory_jade_reward(stars)
	jade_gems += reward
	save_progress()
	return reward


func unlock_all_levels() -> void:
	unlocked_level = LEVELS.size()
	save_progress()


func save_progress() -> void:
	var data := {
		"unlocked_level": unlocked_level,
		"level_stars": level_stars,
		"selected_deck": selected_deck,
		"jade_gems": jade_gems,
		"unlocked_upgrades": unlocked_upgrades,
		"auto_collect_flame": auto_collect_flame,
		"sound_muted": sound_muted,
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))


func load_progress() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	unlocked_level = clampi(int(parsed.get("unlocked_level", 1)), 1, LEVELS.size())
	jade_gems = maxi(0, int(parsed.get("jade_gems", 15)))
	var upg_raw = parsed.get("unlocked_upgrades", [])
	if typeof(upg_raw) == TYPE_ARRAY:
		unlocked_upgrades.clear()
		for u in upg_raw:
			var su := str(u)
			if GARDEN_UPGRADES.has(su) and not unlocked_upgrades.has(su):
				unlocked_upgrades.append(su)
	var stars_raw = parsed.get("level_stars", {})
	if typeof(stars_raw) == TYPE_DICTIONARY:
		level_stars = stars_raw
	var deck_raw = parsed.get("selected_deck", [])
	if typeof(deck_raw) == TYPE_ARRAY and deck_raw.size() > 0:
		var clean_deck: Array[String] = []
		for d in deck_raw:
			var sid := str(d)
			if DEFENDERS.has(sid) and not clean_deck.has(sid) and clean_deck.size() < MAX_DECK_SIZE:
				clean_deck.append(sid)
		if clean_deck.size() > 0:
			selected_deck = clean_deck
	auto_collect_flame = bool(parsed.get("auto_collect_flame", true))
	sound_muted = bool(parsed.get("sound_muted", false))
