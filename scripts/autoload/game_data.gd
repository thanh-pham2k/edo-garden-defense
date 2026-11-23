extends Node

## Central game data registry, level configurations, deck definitions, and
## cross-platform save persistence (works on Desktop, Android/iOS, and Web IndexedDB).

const GRID_ROWS := 5
const GRID_COLS := 9
const CELL_SIZE := Vector2(96.0, 92.0)
const LANTERN_FLAME_BONUS := 5
const GRID_ORIGIN := Vector2(228.0, 174.0)
# The contact line sits below the geometric lane center in the angled artwork.
const LANE_CONTACT_OFFSET := 24.0
const SAVE_PATH := "user://edo_save.json"
const MAX_DECK_SIZE := 8
const NORMAL_BATTLE_SPEED := 0.90
const DEFAULT_DECK: Array[String] = [
	"than_den", "dao_tien", "tre_no", "bi_ngo",
	"nam_doc", "ho_lo_bang", "phao_hoa", "gio_loc"
]

signal progress_changed

var player_id: String = ""
var is_external_player: bool = false
var save_updated_at: int = 0
var selected_level: int = 1
var selected_deck: Array[String] = [
	"than_den", "dao_tien", "tre_no", "bi_ngo",
	"nam_doc", "ho_lo_bang", "phao_hoa", "gio_loc"
]
var previous_deck: Array[String] = []
var unlocked_level: int = 1
var level_stars: Dictionary = {}
var jade_gems: int = 15
var unlocked_upgrades: Array[String] = []
var auto_collect_flame: bool = true
var sound_muted: bool = false
var audio_layers := {"music": true, "ambience": true, "sfx": true}

# Runtime 5x speed & 10-minute auto-play state
var game_speed_multiplier: float = NORMAL_BATTLE_SPEED
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
	"ho_lo_bang", "phao_hoa", "phu_chu", "gio_loc", "chua_lanh",
	"hoa_phuong", "daruma_buff", "meo_kiem", "cung_sam", "den_soi_yeu"
]

const DEFENDER_CATEGORIES := [
	{"name": "Kinh tế & Hỗ trợ", "color": Color("#519880"), "members": ["than_den", "bi_ngo", "chua_lanh", "daruma_buff", "den_soi_yeu"]},
	{"name": "Sát thương", "color": Color("#bd6351"), "members": ["dao_tien", "tre_no", "meo_kiem", "hoa_phuong", "cung_sam"]},
	{"name": "Khống chế & Phá giáp", "color": Color("#587faf"), "members": ["ho_lo_bang", "nam_doc", "gio_loc"]},
	{"name": "Bẫy & Bộc phát", "color": Color("#aa7335"), "members": ["phu_chu", "phao_hoa"]},
]

const DEFENDERS: Dictionary = {
	"dao_tien": {
		"id": "dao_tien",
		"name": "Đào Tiên",
		"role": "Tấn công tầm xa",
		"card_hint": "Bắn xa",
		"desc": "Quân tấn công tầm xa. Tự bắn từng cánh hoa vào Yokai cùng hàng, gây 24 sát thương mỗi phát.",
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
		"desc": "Tạo 30 Linh Hỏa sau khoảng 2 giây khi đặt, rồi mỗi khoảng 9 giây. Chiếu sáng khoảng 2,2 ô.",
		"cost": 50,
		"cooldown": 6.5,
		"hp": 260.0,
		"attack_interval": 8.0,
		"first_action_delay": 1.7,
		"damage": 0.0,
		"light_cells": Vector2(2.2, 2.2),
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
		"desc": "Phun khói độc tầm 3,8 ô, gây 30 sát thương xuyên giáp và 8 sát thương độc mỗi giây trong 3 giây.",
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
		"desc": "Bẫy kích hoạt khi Yokai đến gần, gây 65 sát thương xuyên giáp và choáng 4 giây trên một hàng.",
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
		"role": "Đẩy lùi / Hạ cánh Tengu",
		"desc": "Đẩy lùi Yokai 1,2 ô trong tầm 5,5 ô. Ép Yokai bay hạ cánh và gây 180 sát thương xuyên giáp. Luồng gió dọn sương trên làn của nó và hai làn bên cạnh trong 11 giây.",
		"cost": 125,
		"cooldown": 12.0,
		"hp": 320.0,
		"attack_interval": 5.5,
		"damage": 20.0,
		"range_cells": 5.5,
		"knockback_px": 115.0,
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
	"hoa_phuong": {
		"id": "hoa_phuong",
		"name": "Hỏa Phượng",
		"role": "Cầu lửa nổ & Tan băng",
		"desc": "Phóng cầu lửa Phượng Hoàng nổ lan vùng 3×3 (38 dmg) & giải băng cho đồng đội. Chiếu sáng 2,5 ô; cầu lửa mở đường sáng khi bay.",
		"cost": 225,
		"cooldown": 9.0,
		"hp": 320.0,
		"attack_interval": 1.75,
		"damage": 38.0,
		"light_cells": Vector2(2.5, 2.5),
		"idle_sheet": "res://assets/sprites/defenders/hoa_phuong_idle.png",
		"idle_grid": Vector2i(3, 2),
		"action_sheet": "res://assets/sprites/defenders/hoa_phuong_attack.png",
		"action_grid": Vector2i(4, 3),
		"icon": "res://assets/sprites/defenders/hoa_phuong_icon.png",
	},
	"daruma_buff": {
		"id": "daruma_buff",
		"name": "Daruma Cổ Vũ",
		"role": "Buff +40% tốc đánh 3×3",
		"desc": "Đánh trống cổ vũ tăng +40% tốc độ ra đòn cho đồng minh 3×3 trong 6 giây.",
		"cost": 150,
		"cooldown": 14.0,
		"hp": 420.0,
		"attack_interval": 5.0,
		"damage": 0.0,
		"idle_sheet": "res://assets/sprites/defenders/daruma_buff_idle.png",
		"idle_grid": Vector2i(3, 2),
		"action_sheet": "res://assets/sprites/defenders/daruma_buff_action.png",
		"action_grid": Vector2i(4, 3),
		"icon": "res://assets/sprites/defenders/daruma_buff_icon.png",
	},
	"meo_kiem": {
		"id": "meo_kiem",
		"name": "Mèo Kiếm Sĩ",
		"role": "Cận chiến chém xuyên 2.2 ô",
		"desc": "Vung kiếm chém sóng xuyên giáp nhiều Yokai trong tầm 2.2 ô trước mặt (42 dmg).",
		"cost": 175,
		"cooldown": 8.5,
		"hp": 480.0,
		"attack_interval": 1.15,
		"damage": 42.0,
		"range_cells": 2.2,
		"idle_sheet": "res://assets/sprites/defenders/meo_kiem_idle.png",
		"idle_grid": Vector2i(3, 2),
		"action_sheet": "res://assets/sprites/defenders/meo_kiem_attack.png",
		"action_grid": Vector2i(4, 3),
		"icon": "res://assets/sprites/defenders/meo_kiem_icon.png",
	},
	"cung_sam": {
		"id": "cung_sam",
		"name": "Cung Thủ Sấm",
		"role": "Xích sét lan 3 mục tiêu",
		"desc": "Bắn tiễn sét đánh lan tối đa 3 Yokai trên đường (36 dmg xuyên giáp & choáng 0.4s).",
		"cost": 250,
		"cooldown": 10.0,
		"hp": 300.0,
		"attack_interval": 1.85,
		"damage": 36.0,
		"idle_sheet": "res://assets/sprites/defenders/cung_sam_idle.png",
		"idle_grid": Vector2i(3, 2),
		"action_sheet": "res://assets/sprites/defenders/cung_sam_attack.png",
		"action_grid": Vector2i(4, 3),
		"icon": "res://assets/sprites/defenders/cung_sam_icon.png",
	},
	"den_soi_yeu": {
		"id": "den_soi_yeu",
		"name": "Đèn Soi Yêu",
		"role": "Chiếu sáng 3 hàng × 5 cột",
		"desc": "Xua sương trong 3 hàng × 5 cột quanh đèn. Làm lộ và làm chậm nhẹ Tanuki đã biến hình trong vùng sáng.",
		"cost": 50,
		"cooldown": 8.0,
		"hp": 180.0,
		"attack_interval": 4.0,
		"damage": 0.0,
		"light_cells": Vector2(2.5, 1.5),
		"idle_sheet": "res://assets/sprites/defenders/den_soi_yeu_idle.png",
		"idle_grid": Vector2i(3, 2),
		"action_sheet": "res://assets/sprites/defenders/den_soi_yeu_idle.png",
		"action_grid": Vector2i(3, 2),
		"icon": "res://assets/sprites/defenders/den_soi_yeu_icon.png",
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
	"karakasa": {
		"id": "karakasa",
		"name": "Ma Ô Karakasa",
		"hp": 220.0,
		"armor_hp": 0.0,
		"speed": 36.0,
		"damage": 52.0,
		"attack_interval": 0.9,
		"damage_reduction": 0.0,
		"is_flying": false,
		"is_boss": false,
		"move_sheet": "res://assets/sprites/enemies/karakasa_walk.png",
		"attack_sheet": "res://assets/sprites/enemies/karakasa_attack.png",
		"die_sheet": "res://assets/sprites/enemies/karakasa_die.png",
		"grid": Vector2i(4, 3),
		"icon": "res://assets/sprites/enemies/karakasa_icon.png",
	},
	"chochin_ma": {
		"id": "chochin_ma",
		"name": "Đèn Lồng Ma",
		"hp": 230.0,
		"armor_hp": 0.0,
		"speed": 34.0,
		"damage": 54.0,
		"attack_interval": 1.0,
		"damage_reduction": 0.0,
		"is_flying": true,
		"is_boss": false,
		"move_sheet": "res://assets/sprites/enemies/chochin_ma_walk.png",
		"attack_sheet": "res://assets/sprites/enemies/chochin_ma_attack.png",
		"die_sheet": "res://assets/sprites/enemies/chochin_ma_die.png",
		"grid": Vector2i(4, 3),
		"icon": "res://assets/sprites/enemies/chochin_ma_icon.png",
	},
	"tanuki": {
		"id": "tanuki",
		"name": "Tanuki Biến Hình",
		"hp": 420.0,
		"armor_hp": 0.0,
		"speed": 32.0,
		"damage": 64.0,
		"attack_interval": 0.95,
		"damage_reduction": 0.0,
		"is_flying": false,
		"is_boss": false,
		"move_sheet": "res://assets/sprites/enemies/tanuki_walk.png",
		"attack_sheet": "res://assets/sprites/enemies/tanuki_attack.png",
		"die_sheet": "res://assets/sprites/enemies/tanuki_die.png",
		"grid": Vector2i(4, 3),
		"icon": "res://assets/sprites/enemies/tanuki_icon.png",
	},
	"kappa_phap_su": {
		"id": "kappa_phap_su",
		"name": "Kappa Pháp Sư",
		"hp": 340.0,
		"armor_hp": 0.0,
		"speed": 24.0,
		"damage": 56.0,
		"attack_interval": 1.2,
		"damage_reduction": 0.25,
		"is_flying": false,
		"is_boss": false,
		"move_sheet": "res://assets/sprites/enemies/kappa_phap_su_walk.png",
		"attack_sheet": "res://assets/sprites/enemies/kappa_phap_su_attack.png",
		"die_sheet": "res://assets/sprites/enemies/kappa_phap_su_die.png",
		"grid": Vector2i(4, 3),
		"icon": "res://assets/sprites/enemies/kappa_phap_su_icon.png",
	},
	"boss_tengu_king": {
		"id": "boss_tengu_king",
		"name": "Tengu Đại Vương",
		"hp": 2200.0,
		"armor_hp": 0.0,
		"speed": 22.0,
		"damage": 135.0,
		"attack_interval": 1.25,
		"damage_reduction": 0.0,
		"is_flying": true,
		"is_boss": true,
		"move_sheet": "res://assets/sprites/enemies/boss_tengu_king_walk.png",
		"attack_sheet": "res://assets/sprites/enemies/boss_tengu_king_attack.png",
		"die_sheet": "res://assets/sprites/enemies/boss_tengu_king_die.png",
		"grid": Vector2i(4, 4),
		"icon": "res://assets/sprites/enemies/boss_tengu_king_icon.png",
	},
	"boss_kappa_lord": {
		"id": "boss_kappa_lord",
		"name": "Thủy Vương Kappa",
		"hp": 2600.0,
		"armor_hp": 400.0,
		"speed": 19.0,
		"damage": 145.0,
		"attack_interval": 1.3,
		"damage_reduction": 0.25,
		"is_flying": false,
		"is_boss": true,
		"move_sheet": "res://assets/sprites/enemies/boss_kappa_lord_walk.png",
		"attack_sheet": "res://assets/sprites/enemies/boss_kappa_lord_attack.png",
		"die_sheet": "res://assets/sprites/enemies/boss_kappa_lord_die.png",
		"grid": Vector2i(4, 4),
		"icon": "res://assets/sprites/enemies/boss_kappa_lord_icon.png",
	},
	"boss_shogun": {
		"id": "boss_shogun",
		"name": "Đại Tướng Samurai Ma",
		"hp": 2700.0,
		"armor_hp": 800.0,
		"speed": 18.0,
		"damage": 165.0,
		"attack_interval": 1.25,
		"damage_reduction": 0.0,
		"is_flying": false,
		"is_boss": true,
		"move_sheet": "res://assets/sprites/enemies/boss_shogun_walk.png",
		"attack_sheet": "res://assets/sprites/enemies/boss_shogun_attack.png",
		"die_sheet": "res://assets/sprites/enemies/boss_shogun_die.png",
		"grid": Vector2i(4, 4),
		"icon": "res://assets/sprites/enemies/boss_shogun_icon.png",
	},
	"boss_yuki_queen": {
		"id": "boss_yuki_queen",
		"name": "Nữ Hoàng Tuyết",
		"hp": 3000.0,
		"armor_hp": 0.0,
		"speed": 20.0,
		"damage": 150.0,
		"attack_interval": 1.2,
		"damage_reduction": 0.0,
		"is_flying": false,
		"is_boss": true,
		"move_sheet": "res://assets/sprites/enemies/boss_yuki_queen_walk.png",
		"attack_sheet": "res://assets/sprites/enemies/boss_yuki_queen_attack.png",
		"die_sheet": "res://assets/sprites/enemies/boss_yuki_queen_die.png",
		"grid": Vector2i(4, 4),
		"icon": "res://assets/sprites/enemies/boss_yuki_queen_icon.png",
	},
	"boss_kyubi": {
		"id": "boss_kyubi",
		"name": "Cửu Vĩ Hồ Ly",
		"hp": 3800.0,
		"armor_hp": 600.0,
		"speed": 21.0,
		"damage": 175.0,
		"attack_interval": 1.15,
		"damage_reduction": 0.0,
		"is_flying": false,
		"is_boss": true,
		"move_sheet": "res://assets/sprites/enemies/boss_kyubi_walk.png",
		"attack_sheet": "res://assets/sprites/enemies/boss_kyubi_attack.png",
		"die_sheet": "res://assets/sprites/enemies/boss_kyubi_die.png",
		"grid": Vector2i(4, 4),
		"icon": "res://assets/sprites/enemies/boss_kyubi_icon.png",
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
	"obs_ice_block": {
		"id": "obs_ice_block",
		"name": "Tảng Băng Cổ",
		"hp": 420.0,
		"thorns": 0.0,
		"explodes": false,
		"sheet": "res://assets/sprites/obstacles/obs_ice_block.png",
	},
	"obs_cursed_lantern": {
		"id": "obs_cursed_lantern",
		"name": "Đèn Lồng Nguyền",
		"hp": 320.0,
		"thorns": 0.0,
		"explodes": false,
		"sheet": "res://assets/sprites/obstacles/obs_cursed_lantern.png",
	},
	"obs_incense_burner": {
		"id": "obs_incense_burner",
		"name": "Lư Hương Thanh Tẩy",
		"hp": 280.0,
		"thorns": 0.0,
		"explodes": false,
		"sheet": "res://assets/sprites/obstacles/obs_incense_burner.png",
	},
}

const LEVELS: Array[Dictionary] = [
	# === CHƯƠNG 1: SÂN VƯỜN LÀNG HOA (Màn 1–3) ===
	{
		"id": 1,
		"name": "1-1: Làng Hoa Bình Minh",
		"subtitle": "Ban ngày — Bảo vệ nhà cổ khỏi Tiểu Yêu & Nekomata",
		"bg_stem": "bg_ch1_sakura_village",
		"land_tone": Vector2(0.72, 0.69),
		"terrain_variants": Vector2i(5, 4),
		"terrain_tint": Color(0.47, 0.58, 0.32),
		"top_border": "res://assets/sprites/environments/env_border_top_ch1.png",
		"lawn_edge": "res://assets/sprites/environments/env_edge_bamboo_flowers.png",
		"house_tex": "res://assets/sprites/props/prop_edo_house.png",
		"biome_flora": [
			"res://assets/sprites/environments/flora_sakura_hedge.png",
			"res://assets/sprites/props/prop_sakura_tree.png",
			"res://assets/sprites/environments/flora_moss_lantern_cluster.png",
		],
		"atmosphere_style": "day",
		"lane_emphasis": 1.35,
		"tile_primary": "tile_grass",
		"tile_alt": "tile_dirt",
		"water_lane": -1,
		"sky_top": Color(0.55, 0.78, 0.94, 1),
		"sky_bottom": Color(0.84, 0.93, 0.88, 1),
		"ground_tint": Color(0.45, 0.63, 0.34, 1),
		"ambient_particle": "res://assets/sprites/fx/part_sakura_1.png",
		"natural_flame_interval": 8.0,
		"starting_flame": 175,
		"obstacles": [],
		"props": ["res://assets/sprites/props/prop_sakura_tree.png"],
		"waves": [
			{"delay": 30.0, "huge": false, "spawns": ["tieu_yeu"]},
			{"delay": 12.0, "huge": false, "spawns": ["tieu_yeu", "nekomata"]},
			{"delay": 11.5, "huge": false, "spawns": ["tieu_yeu", "oni_nho", "tieu_yeu"]},
			{"delay": 12.5, "huge": true, "spawns": ["oni_nho", "nekomata", "tieu_yeu", "tieu_yeu", "oni_nho"]},
		],
	},
	{
		"id": 2,
		"name": "1-2: Ngõ Anh Đào",
		"subtitle": "Ban ngày — Vật cản Thùng gỗ Edo & Karakasa nhảy rào",
		"bg_stem": "bg_ch1_sakura_village",
		"land_tone": Vector2(0.72, 0.69),
		"terrain_variants": Vector2i(5, 4),
		"terrain_tint": Color(0.47, 0.58, 0.32),
		"top_border": "res://assets/sprites/environments/env_border_top_ch1.png",
		"lawn_edge": "res://assets/sprites/environments/env_edge_bamboo_flowers.png",
		"house_tex": "res://assets/sprites/props/prop_edo_house.png",
		"biome_flora": [
			"res://assets/sprites/environments/flora_sakura_hedge.png",
			"res://assets/sprites/props/prop_sakura_tree.png",
			"res://assets/sprites/environments/flora_moss_lantern_cluster.png",
		],
		"atmosphere_style": "day",
		"lane_emphasis": 1.35,
		"tile_primary": "tile_grass",
		"tile_alt": "tile_dirt",
		"water_lane": -1,
		"sky_top": Color(0.55, 0.78, 0.94, 1),
		"sky_bottom": Color(0.84, 0.93, 0.88, 1),
		"ground_tint": Color(0.45, 0.63, 0.34, 1),
		"ambient_particle": "res://assets/sprites/fx/part_sakura_1.png",
		"natural_flame_interval": 8.0,
		"starting_flame": 175,
		"obstacles": [
			{"id": "obs_crate", "row": 1, "col": 5},
			{"id": "obs_wood_fence", "row": 3, "col": 5},
		],
		"props": ["res://assets/sprites/props/prop_sakura_tree.png"],
		"waves": [
			{"delay": 28.0, "huge": false, "spawns": ["tieu_yeu", "tieu_yeu"]},
			{"delay": 11.5, "huge": false, "spawns": ["karakasa", "tieu_yeu", "nekomata"]},
			{"delay": 12.0, "huge": false, "spawns": ["oni_nho", "karakasa", "tieu_yeu"]},
			{"delay": 12.5, "huge": false, "spawns": ["kappa", "nekomata", "oni_nho"]},
			{"delay": 13.5, "huge": true, "spawns": ["oni_nho", "oni_nho", "kappa", "karakasa", "nekomata"]},
		],
	},
	{
		"id": 3,
		"name": "1-3: Cổng Làng Hoa (Boss)",
		"subtitle": "Ban ngày — Tổng tiến công & Boss Đại Oni đầu tiên",
		"bg_stem": "bg_ch1_sakura_village",
		"land_tone": Vector2(0.72, 0.69),
		"terrain_variants": Vector2i(5, 4),
		"terrain_tint": Color(0.47, 0.58, 0.32),
		"top_border": "res://assets/sprites/environments/env_border_top_ch1.png",
		"lawn_edge": "res://assets/sprites/environments/env_edge_bamboo_flowers.png",
		"house_tex": "res://assets/sprites/props/prop_edo_house.png",
		"biome_flora": [
			"res://assets/sprites/environments/flora_sakura_hedge.png",
			"res://assets/sprites/props/prop_sakura_tree.png",
			"res://assets/sprites/environments/flora_moss_lantern_cluster.png",
		],
		"atmosphere_style": "day",
		"lane_emphasis": 1.35,
		"tile_primary": "tile_grass",
		"tile_alt": "tile_dirt",
		"water_lane": -1,
		"sky_top": Color(0.55, 0.78, 0.94, 1),
		"sky_bottom": Color(0.84, 0.93, 0.88, 1),
		"ground_tint": Color(0.45, 0.63, 0.34, 1),
		"ambient_particle": "res://assets/sprites/fx/part_sakura_1.png",
		"natural_flame_interval": 8.0,
		"starting_flame": 200,
		"obstacles": [
			{"id": "obs_wood_fence", "row": 0, "col": 5},
			{"id": "obs_sake_barrel", "row": 2, "col": 6},
			{"id": "obs_crate", "row": 4, "col": 5},
		],
		"props": ["res://assets/sprites/props/prop_sakura_tree.png"],
		"waves": [
			{"delay": 28.0, "huge": false, "spawns": ["tieu_yeu", "karakasa"]},
			{"delay": 11.0, "huge": false, "spawns": ["tieu_yeu", "nekomata", "oni_nho"]},
			{"delay": 11.5, "huge": false, "spawns": ["kappa", "karakasa", "oni_nho"]},
			{"delay": 12.0, "huge": false, "spawns": ["oni_nho", "kappa", "nekomata", "tieu_yeu"]},
			{"delay": 13.0, "huge": false, "spawns": ["karakasa", "oni_nho", "kappa", "nekomata"]},
			{"delay": 14.0, "huge": true, "spawns": ["oni_lon", "oni_nho", "kappa", "nekomata", "karakasa", "tieu_yeu"]},
		],
	},
	# === CHƯƠNG 2: RỪNG TRE HOÀNG HÔN (Màn 4–6) ===
	{
		"id": 4,
		"name": "2-1: Bìa Rừng Tre",
		"subtitle": "Hoàng hôn — Rào gỗ 3/4 Edo, Tengu bay & Nekomata",
		"bg_stem": "bg_ch2_bamboo_sunset",
		"land_tone": Vector2(0.63, 0.58),
		"terrain_variants": Vector2i(3, 1),
		"terrain_tint": Color(0.46, 0.48, 0.34),
		"top_border": "res://assets/sprites/environments/env_border_top_ch2.png",
		"lawn_edge": "res://assets/sprites/environments/env_edge_moss_stones.png",
		"house_tex": "res://assets/sprites/environments/house_ch2_teahouse.png",
		"stone_path_tex": "res://assets/sprites/environments/env_path_stones_sunset.png",
		"biome_flora": [
			"res://assets/sprites/environments/flora_sunset_bamboo.png",
			"res://assets/sprites/environments/flora_moss_lantern_cluster.png",
			"res://assets/sprites/props/prop_bamboo_grove.png",
		],
		"atmosphere_style": "sunset",
		"tile_primary": "tile_moss_stone",
		"tile_alt": "tile_cobble",
		"water_lane": -1,
		"sky_top": Color(0.72, 0.36, 0.28, 1),
		"sky_bottom": Color(0.95, 0.69, 0.36, 1),
		"ground_tint": Color(0.36, 0.44, 0.32, 1),
		"ambient_particle": "res://assets/sprites/fx/part_bamboo_leaf.png",
		"natural_flame_interval": 9.0,
		"starting_flame": 200,
		"obstacles": [
			{"id": "obs_wood_fence", "row": 1, "col": 5},
			{"id": "obs_rock", "row": 2, "col": 6},
			{"id": "obs_wood_fence", "row": 3, "col": 5},
			{"id": "obs_crate", "row": 4, "col": 6},
		],
		"props": ["res://assets/sprites/props/prop_bamboo_grove.png"],
		"waves": [
			{"delay": 28.0, "huge": false, "spawns": ["tieu_yeu", "nekomata"]},
			{"delay": 10.5, "huge": false, "spawns": ["tieu_yeu", "tengu", "karakasa"]},
			{"delay": 11.0, "huge": false, "spawns": ["oni_nho", "tengu", "nekomata"]},
			{"delay": 12.0, "huge": false, "spawns": ["kappa", "tengu", "oni_nho", "tieu_yeu"]},
			{"delay": 13.0, "huge": true, "spawns": ["oni_nho", "tengu", "tengu", "kappa", "karakasa", "nekomata"]},
		],
	},
	{
		"id": 5,
		"name": "2-2: Đường Mòn Lá Vàng",
		"subtitle": "Hoàng hôn — Tanuki biến hình & Rắn Ống chuyển làn",
		"bg_stem": "bg_ch2_bamboo_sunset",
		"land_tone": Vector2(0.63, 0.58),
		"terrain_variants": Vector2i(3, 1),
		"terrain_tint": Color(0.46, 0.48, 0.34),
		"top_border": "res://assets/sprites/environments/env_border_top_ch2.png",
		"lawn_edge": "res://assets/sprites/environments/env_edge_moss_stones.png",
		"house_tex": "res://assets/sprites/environments/house_ch2_teahouse.png",
		"stone_path_tex": "res://assets/sprites/environments/env_path_stones_sunset.png",
		"biome_flora": [
			"res://assets/sprites/environments/flora_sunset_bamboo.png",
			"res://assets/sprites/environments/flora_moss_lantern_cluster.png",
			"res://assets/sprites/props/prop_bamboo_grove.png",
		],
		"atmosphere_style": "sunset",
		"tile_primary": "tile_moss_stone",
		"tile_alt": "tile_cobble",
		"water_lane": -1,
		"sky_top": Color(0.72, 0.36, 0.28, 1),
		"sky_bottom": Color(0.95, 0.69, 0.36, 1),
		"ground_tint": Color(0.36, 0.44, 0.32, 1),
		"ambient_particle": "res://assets/sprites/fx/part_bamboo_leaf.png",
		"natural_flame_interval": 9.0,
		"starting_flame": 200,
		"obstacles": [
			{"id": "obs_crate", "row": 0, "col": 5},
			{"id": "obs_wood_fence", "row": 2, "col": 5},
			{"id": "obs_sake_barrel", "row": 3, "col": 6},
		],
		"props": ["res://assets/sprites/props/prop_bamboo_grove.png"],
		"waves": [
			{"delay": 27.0, "huge": false, "spawns": ["karakasa", "tengu"]},
			{"delay": 10.5, "huge": false, "spawns": ["tanuki", "tengu", "nekomata"]},
			{"delay": 11.5, "huge": false, "spawns": ["ran_ong", "oni_nho", "karakasa"]},
			{"delay": 12.0, "huge": false, "spawns": ["tanuki", "ran_ong", "tengu", "kappa"]},
			{"delay": 13.0, "huge": false, "spawns": ["oni_nho", "tanuki", "ran_ong", "tengu"]},
			{"delay": 14.0, "huge": true, "spawns": ["oni_lon", "tanuki", "ran_ong", "tengu", "kappa"]},
		],
	},
	{
		"id": 6,
		"name": "2-3: Cổng Rừng Tre (Boss)",
		"subtitle": "Hoàng hôn — Đối đầu Trùm Tengu Đại Vương trên không",
		"bg_stem": "bg_ch2_bamboo_sunset",
		"land_tone": Vector2(0.63, 0.58),
		"terrain_variants": Vector2i(3, 1),
		"terrain_tint": Color(0.46, 0.48, 0.34),
		"top_border": "res://assets/sprites/environments/env_border_top_ch2.png",
		"lawn_edge": "res://assets/sprites/environments/env_edge_moss_stones.png",
		"house_tex": "res://assets/sprites/environments/house_ch2_teahouse.png",
		"stone_path_tex": "res://assets/sprites/environments/env_path_stones_sunset.png",
		"biome_flora": [
			"res://assets/sprites/environments/flora_sunset_bamboo.png",
			"res://assets/sprites/environments/flora_moss_lantern_cluster.png",
			"res://assets/sprites/props/prop_bamboo_grove.png",
		],
		"atmosphere_style": "sunset",
		"tile_primary": "tile_moss_stone",
		"tile_alt": "tile_cobble",
		"water_lane": -1,
		"sky_top": Color(0.72, 0.36, 0.28, 1),
		"sky_bottom": Color(0.95, 0.69, 0.36, 1),
		"ground_tint": Color(0.36, 0.44, 0.32, 1),
		"ambient_particle": "res://assets/sprites/fx/part_bamboo_leaf.png",
		"natural_flame_interval": 9.0,
		"starting_flame": 225,
		"obstacles": [
			{"id": "obs_wood_fence", "row": 1, "col": 5},
			{"id": "obs_incense_burner", "row": 2, "col": 5},
			{"id": "obs_wood_fence", "row": 3, "col": 5},
			{"id": "obs_rock", "row": 4, "col": 6},
		],
		"props": ["res://assets/sprites/props/prop_bamboo_grove.png"],
		"waves": [
			{"delay": 28.0, "huge": false, "spawns": ["tengu", "nekomata"]},
			{"delay": 10.0, "huge": false, "spawns": ["karakasa", "tengu", "tanuki"]},
			{"delay": 11.0, "huge": false, "spawns": ["ran_ong", "tengu", "oni_nho"]},
			{"delay": 11.5, "huge": false, "spawns": ["tanuki", "tengu", "tengu", "kappa"]},
			{"delay": 12.5, "huge": false, "spawns": ["ran_ong", "oni_nho", "karakasa", "tengu"]},
			{"delay": 14.0, "huge": true, "spawns": ["boss_tengu_king", "tengu", "tengu", "tanuki", "ran_ong", "kappa"]},
		],
	},
	# === CHƯƠNG 3: HỒ CÁ KOI ĐỀN THẦN (Màn 7–9) ===
	{
		"id": 7,
		"name": "3-1: Hồ Cá Koi Đền Thần",
		"subtitle": "Ban đêm — Làn nước Hồ Koi, Rào gai & Miko Ma",
		"bg_stem": "bg_ch3_koi_shrine_night",
		"land_tone": Vector2(0.63, 0.59),
		"terrain_variants": Vector2i(3, 2),
		"terrain_tint": Color(0.36, 0.37, 0.32),
		"top_border": "res://assets/sprites/environments/env_border_top_ch3.png",
		"lawn_edge": "res://assets/sprites/environments/env_edge_koi_bank.png",
		"house_tex": "res://assets/sprites/environments/house_ch3_koi_shrine.png",
		"stone_path_tex": "res://assets/sprites/environments/env_path_stones_night.png",
		"biome_flora": [
			"res://assets/sprites/environments/flora_night_sakura.png",
			"res://assets/sprites/environments/flora_moss_lantern_cluster.png",
			"res://assets/sprites/props/prop_red_bridge.png",
		],
		"atmosphere_style": "night",
		"tile_primary": "tile_moss_stone",
		"tile_alt": "tile_sakura",
		"water_lane": 2,
		"sky_top": Color(0.11, 0.14, 0.30, 1),
		"sky_bottom": Color(0.22, 0.31, 0.48, 1),
		"ground_tint": Color(0.24, 0.28, 0.38, 1),
		"ambient_particle": "res://assets/sprites/fx/part_spirit_wisp.png",
		"natural_flame_interval": 10.0,
		"starting_flame": 200,
		"obstacles": [
			{"id": "obs_spike_barricade", "row": 0, "col": 5},
			{"id": "obs_rock", "row": 1, "col": 6},
			{"id": "obs_spike_barricade", "row": 3, "col": 5},
			{"id": "obs_sake_barrel", "row": 4, "col": 6},
		],
		"props": ["res://assets/sprites/props/prop_red_bridge.png"],
		"waves": [
			{"delay": 28.0, "huge": false, "spawns": ["tieu_yeu", "kappa"]},
			{"delay": 10.0, "huge": false, "spawns": ["kappa", "kappa", "tieu_yeu"]},
			{"delay": 10.5, "huge": false, "spawns": ["miko_ma", "tieu_yeu", "kappa"]},
			{"delay": 11.5, "huge": false, "spawns": ["tengu", "kappa", "nekomata", "miko_ma"]},
			{"delay": 12.5, "huge": false, "spawns": ["oni_nho", "kappa", "ran_ong", "tengu"]},
			{"delay": 14.0, "huge": true, "spawns": ["oni_lon", "miko_ma", "kappa", "samurai_ma", "tengu", "nekomata"]},
		],
	},
	{
		"id": 8,
		"name": "3-2: Cầu Đỏ Đêm Trăng",
		"subtitle": "Ban đêm — Kappa Pháp Sư bắn xa & Đèn Lồng Ma hút Linh Hỏa",
		"bg_stem": "bg_ch3_koi_shrine_night",
		"land_tone": Vector2(0.63, 0.59),
		"terrain_variants": Vector2i(3, 2),
		"terrain_tint": Color(0.36, 0.37, 0.32),
		"top_border": "res://assets/sprites/environments/env_border_top_ch3.png",
		"lawn_edge": "res://assets/sprites/environments/env_edge_koi_bank.png",
		"house_tex": "res://assets/sprites/environments/house_ch3_koi_shrine.png",
		"stone_path_tex": "res://assets/sprites/environments/env_path_stones_night.png",
		"biome_flora": [
			"res://assets/sprites/environments/flora_night_sakura.png",
			"res://assets/sprites/environments/flora_moss_lantern_cluster.png",
			"res://assets/sprites/props/prop_red_bridge.png",
		],
		"atmosphere_style": "night",
		"tile_primary": "tile_moss_stone",
		"tile_alt": "tile_sakura",
		"water_lane": 2,
		"sky_top": Color(0.11, 0.14, 0.30, 1),
		"sky_bottom": Color(0.22, 0.31, 0.48, 1),
		"ground_tint": Color(0.24, 0.28, 0.38, 1),
		"ambient_particle": "res://assets/sprites/fx/part_spirit_wisp.png",
		"natural_flame_interval": 10.0,
		"starting_flame": 225,
		"obstacles": [
			{"id": "obs_cursed_lantern", "row": 0, "col": 6},
			{"id": "obs_spike_barricade", "row": 1, "col": 5},
			{"id": "obs_incense_burner", "row": 3, "col": 5},
			{"id": "obs_sake_barrel", "row": 4, "col": 6},
		],
		"props": ["res://assets/sprites/props/prop_red_bridge.png"],
		"waves": [
			{"delay": 27.0, "huge": false, "spawns": ["kappa", "chochin_ma"]},
			{"delay": 10.0, "huge": false, "spawns": ["kappa_phap_su", "kappa", "miko_ma"]},
			{"delay": 11.0, "huge": false, "spawns": ["chochin_ma", "kappa_phap_su", "ran_ong"]},
			{"delay": 11.5, "huge": false, "spawns": ["samurai_ma", "miko_ma", "kappa", "tengu"]},
			{"delay": 12.5, "huge": false, "spawns": ["kappa_phap_su", "chochin_ma", "oni_nho", "tanuki"]},
			{"delay": 14.0, "huge": true, "spawns": ["oni_lon", "kappa_phap_su", "chochin_ma", "miko_ma", "kappa", "samurai_ma"]},
		],
	},
	{
		"id": 9,
		"name": "3-3: Miếu Hồ Thủy Vương (Boss)",
		"subtitle": "Ban đêm — Boss Thủy Vương Kappa hồi máu dưới làn nước",
		"bg_stem": "bg_ch3_koi_shrine_night",
		"land_tone": Vector2(0.63, 0.59),
		"terrain_variants": Vector2i(3, 2),
		"terrain_tint": Color(0.36, 0.37, 0.32),
		"top_border": "res://assets/sprites/environments/env_border_top_ch3.png",
		"lawn_edge": "res://assets/sprites/environments/env_edge_koi_bank.png",
		"house_tex": "res://assets/sprites/environments/house_ch3_koi_shrine.png",
		"stone_path_tex": "res://assets/sprites/environments/env_path_stones_night.png",
		"biome_flora": [
			"res://assets/sprites/environments/flora_night_sakura.png",
			"res://assets/sprites/environments/flora_moss_lantern_cluster.png",
			"res://assets/sprites/props/prop_red_bridge.png",
		],
		"atmosphere_style": "night",
		"tile_primary": "tile_moss_stone",
		"tile_alt": "tile_sakura",
		"water_lane": 2,
		"sky_top": Color(0.11, 0.14, 0.30, 1),
		"sky_bottom": Color(0.22, 0.31, 0.48, 1),
		"ground_tint": Color(0.24, 0.28, 0.38, 1),
		"ambient_particle": "res://assets/sprites/fx/part_spirit_wisp.png",
		"natural_flame_interval": 10.0,
		"starting_flame": 250,
		"obstacles": [
			{"id": "obs_spike_barricade", "row": 0, "col": 5},
			{"id": "obs_cursed_lantern", "row": 1, "col": 6},
			{"id": "obs_spike_barricade", "row": 3, "col": 5},
			{"id": "obs_sake_barrel", "row": 4, "col": 6},
		],
		"props": ["res://assets/sprites/props/prop_red_bridge.png"],
		"waves": [
			{"delay": 27.0, "huge": false, "spawns": ["kappa", "kappa_phap_su"]},
			{"delay": 10.0, "huge": false, "spawns": ["miko_ma", "chochin_ma", "kappa"]},
			{"delay": 11.0, "huge": false, "spawns": ["kappa_phap_su", "samurai_ma", "tengu"]},
			{"delay": 11.5, "huge": false, "spawns": ["miko_ma", "kappa_phap_su", "chochin_ma", "ran_ong"]},
			{"delay": 12.5, "huge": false, "spawns": ["samurai_ma", "tanuki", "kappa", "tengu"]},
			{"delay": 14.0, "huge": true, "spawns": ["boss_kappa_lord", "kappa_phap_su", "miko_ma", "chochin_ma", "kappa", "samurai_ma"]},
		],
	},
	# === CHƯƠNG 4: THÀNH CỔ SƯƠNG MÙ (Màn 10–12) ===
	{
		"id": 10,
		"name": "4-1: Tường Thành Lá Phong",
		"subtitle": "Đêm sương — Thùng Sake nổ, Samurai Ma & Rắn Ống",
		"bg_stem": "bg_ch4_misty_castle",
		"land_tone": Vector2(0.71, 0.64),
		"terrain_variants": Vector2i(5, 1),
		"terrain_tint": Color(0.41, 0.40, 0.42),
		"top_border": "res://assets/sprites/environments/env_border_top_ch4.png",
		"lawn_edge": "res://assets/sprites/environments/env_edge_moss_stones.png",
		"house_tex": "res://assets/sprites/environments/house_ch4_castle_guard.png",
		"stone_path_tex": "res://assets/sprites/environments/env_path_stones_sunset.png",
		"biome_flora_widths": Vector3(90, 91, 47),
		"biome_flora": [
			"res://assets/sprites/environments/flora_autumn_maple.png",
			"res://assets/sprites/environments/flora_moss_lantern_cluster.png",
			"res://assets/sprites/props/prop_banner.png",
		],
		"atmosphere_style": "mist",
		"tile_primary": "tile_gravel_night",
		"tile_alt": "tile_cobble",
		"water_lane": -1,
		"fog": {"columns": 3.25, "opacity": 0.68, "transition": 0.40, "recovery": 1.5},
		"sky_top": Color(0.16, 0.14, 0.25, 1),
		"sky_bottom": Color(0.32, 0.31, 0.42, 1),
		"ground_tint": Color(0.24, 0.24, 0.30, 1),
		"ambient_particle": "res://assets/sprites/fx/part_sakura_2.png",
		"natural_flame_interval": 10.0,
		"starting_flame": 225,
		"obstacles": [
			{"id": "obs_crate", "row": 0, "col": 5},
			{"id": "obs_sake_barrel", "row": 1, "col": 6},
			{"id": "obs_spike_barricade", "row": 2, "col": 5},
			{"id": "obs_sake_barrel", "row": 3, "col": 6},
			{"id": "obs_rock", "row": 4, "col": 5},
		],
		"props": ["res://assets/sprites/props/prop_pagoda.png"],
		"waves": [
			{"delay": 27.0, "huge": false, "spawns": ["tieu_yeu", "ran_ong"]},
			{"delay": 10.0, "huge": false, "spawns": ["samurai_ma", "tieu_yeu", "nekomata"]},
			{"delay": 10.5, "huge": false, "spawns": ["ran_ong", "tanuki", "miko_ma"]},
			{"delay": 11.5, "huge": false, "spawns": ["samurai_ma", "tengu", "oni_nho", "karakasa"]},
			{"delay": 12.5, "huge": false, "spawns": ["miko_ma", "samurai_ma", "ran_ong", "chochin_ma"]},
			{"delay": 14.0, "huge": true, "spawns": ["oni_lon", "samurai_ma", "miko_ma", "ran_ong", "tanuki", "tengu"]},
		],
	},
	{
		"id": 11,
		"name": "4-2: Cổng Thành Nguyền Rủa",
		"subtitle": "Đêm sương — Đèn Lồng Nguyền tăng tốc Yokai & Lư Hương thanh tẩy",
		"bg_stem": "bg_ch4_misty_castle",
		"land_tone": Vector2(0.71, 0.64),
		"terrain_variants": Vector2i(5, 1),
		"terrain_tint": Color(0.41, 0.40, 0.42),
		"top_border": "res://assets/sprites/environments/env_border_top_ch4.png",
		"lawn_edge": "res://assets/sprites/environments/env_edge_moss_stones.png",
		"house_tex": "res://assets/sprites/environments/house_ch4_castle_guard.png",
		"stone_path_tex": "res://assets/sprites/environments/env_path_stones_sunset.png",
		"biome_flora_widths": Vector3(90, 91, 47),
		"biome_flora": [
			"res://assets/sprites/environments/flora_autumn_maple.png",
			"res://assets/sprites/environments/flora_moss_lantern_cluster.png",
			"res://assets/sprites/props/prop_banner.png",
		],
		"atmosphere_style": "mist",
		"tile_primary": "tile_gravel_night",
		"tile_alt": "tile_cobble",
		"water_lane": -1,
		"fog": {"columns": 3.50, "opacity": 0.74, "transition": 0.40, "recovery": 1.5},
		"sky_top": Color(0.16, 0.14, 0.25, 1),
		"sky_bottom": Color(0.32, 0.31, 0.42, 1),
		"ground_tint": Color(0.24, 0.24, 0.30, 1),
		"ambient_particle": "res://assets/sprites/fx/part_sakura_2.png",
		"natural_flame_interval": 10.0,
		"starting_flame": 250,
		"obstacles": [
			{"id": "obs_cursed_lantern", "row": 1, "col": 6},
			{"id": "obs_incense_burner", "row": 2, "col": 5},
			{"id": "obs_cursed_lantern", "row": 3, "col": 6},
			{"id": "obs_sake_barrel", "row": 4, "col": 5},
		],
		"props": ["res://assets/sprites/props/prop_pagoda.png"],
		"waves": [
			{"delay": 27.0, "huge": false, "spawns": ["samurai_ma", "karakasa"]},
			{"delay": 10.0, "huge": false, "spawns": ["tanuki", "chochin_ma", "ran_ong"]},
			{"delay": 11.0, "huge": false, "spawns": ["samurai_ma", "miko_ma", "kappa_phap_su"]},
			{"delay": 11.5, "huge": false, "spawns": ["yuki_onna", "samurai_ma", "tengu", "ran_ong"]},
			{"delay": 12.5, "huge": false, "spawns": ["miko_ma", "samurai_ma", "tanuki", "chochin_ma"]},
			{"delay": 14.0, "huge": true, "spawns": ["oni_lon", "samurai_ma", "samurai_ma", "yuki_onna", "tanuki", "miko_ma"]},
		],
	},
	{
		"id": 12,
		"name": "4-3: Lầu Vọng Thành Cổ (Boss)",
		"subtitle": "Đêm sương — Boss Đại Tướng Samurai Ma giáp nặng",
		"bg_stem": "bg_ch4_misty_castle",
		"land_tone": Vector2(0.71, 0.64),
		"terrain_variants": Vector2i(5, 1),
		"terrain_tint": Color(0.41, 0.40, 0.42),
		"top_border": "res://assets/sprites/environments/env_border_top_ch4.png",
		"lawn_edge": "res://assets/sprites/environments/env_edge_moss_stones.png",
		"house_tex": "res://assets/sprites/environments/house_ch4_castle_guard.png",
		"stone_path_tex": "res://assets/sprites/environments/env_path_stones_sunset.png",
		"biome_flora_widths": Vector3(90, 91, 47),
		"biome_flora": [
			"res://assets/sprites/environments/flora_autumn_maple.png",
			"res://assets/sprites/environments/flora_moss_lantern_cluster.png",
			"res://assets/sprites/props/prop_banner.png",
		],
		"atmosphere_style": "mist",
		"tile_primary": "tile_gravel_night",
		"tile_alt": "tile_cobble",
		"water_lane": -1,
		"fog": {"columns": 3.75, "opacity": 0.80, "transition": 0.40, "recovery": 1.5},
		"sky_top": Color(0.16, 0.14, 0.25, 1),
		"sky_bottom": Color(0.32, 0.31, 0.42, 1),
		"ground_tint": Color(0.24, 0.24, 0.30, 1),
		"ambient_particle": "res://assets/sprites/fx/part_sakura_2.png",
		"natural_flame_interval": 10.0,
		"starting_flame": 250,
		"obstacles": [
			{"id": "obs_crate", "row": 0, "col": 5},
			{"id": "obs_cursed_lantern", "row": 1, "col": 6},
			{"id": "obs_spike_barricade", "row": 2, "col": 5},
			{"id": "obs_sake_barrel", "row": 3, "col": 6},
			{"id": "obs_rock", "row": 4, "col": 5},
		],
		"props": ["res://assets/sprites/props/prop_pagoda.png"],
		"waves": [
			{"delay": 27.0, "huge": false, "spawns": ["samurai_ma", "ran_ong"]},
			{"delay": 10.0, "huge": false, "spawns": ["tanuki", "samurai_ma", "tengu"]},
			{"delay": 11.0, "huge": false, "spawns": ["miko_ma", "kappa_phap_su", "ran_ong"]},
			{"delay": 11.5, "huge": false, "spawns": ["samurai_ma", "yuki_onna", "chochin_ma", "karakasa"]},
			{"delay": 12.5, "huge": false, "spawns": ["samurai_ma", "miko_ma", "tanuki", "ran_ong"]},
			{"delay": 14.0, "huge": true, "spawns": ["boss_shogun", "samurai_ma", "miko_ma", "tanuki", "chochin_ma", "tengu"]},
		],
	},
	# === CHƯƠNG 5: ĐỈNH NÚI TUYẾT TRẮNG (Màn 13–15) ===
	{
		"id": 13,
		"name": "5-1: Sườn Núi Tuyết Trắng",
		"subtitle": "Bão tuyết — Đống rơm, Tảng Băng Cổ & Yuki-onna đóng băng",
		"bg_stem": "bg_ch5_snowy_mountain",
		"land_tone": Vector2(0.67, 0.61),
		"terrain_variants": Vector2i(0, 4),
		"terrain_tint": Color(0.57, 0.65, 0.72),
		"top_border": "res://assets/sprites/environments/env_border_top_ch5_wide.png",
		"lawn_edge": "res://assets/sprites/environments/env_edge_snowdrift.png",
		"house_tex": "res://assets/sprites/environments/house_ch5_snow_shrine.png",
		"stone_path_tex": "res://assets/sprites/environments/env_path_stones_winter.png",
		"biome_flora_widths": Vector3(90, 55, 80),
		"biome_flora": [
			"res://assets/sprites/environments/flora_snow_pine_tall.png",
			"res://assets/sprites/props/prop_snow_bonsai.png",
			"res://assets/sprites/environments/flora_snow_lantern_rock.png",
		],
		"atmosphere_style": "snow",
		"tile_primary": "tile_snow",
		"tile_alt": "tile_gravel_night",
		"water_lane": -1,
		"sky_top": Color(0.16, 0.25, 0.40, 1),
		"sky_bottom": Color(0.65, 0.80, 0.92, 1),
		"ground_tint": Color(0.55, 0.65, 0.78, 1),
		"ambient_particle": "res://assets/sprites/fx/part_snowflake.png",
		"natural_flame_interval": 9.5,
		"starting_flame": 250,
		"obstacles": [
			{"id": "obs_haystack", "row": 0, "col": 5},
			{"id": "obs_ice_block", "row": 1, "col": 6},
			{"id": "obs_sake_barrel", "row": 2, "col": 6},
			{"id": "obs_ice_block", "row": 3, "col": 5},
			{"id": "obs_spike_barricade", "row": 4, "col": 5},
		],
		"props": ["res://assets/sprites/props/prop_snow_bonsai.png"],
		"waves": [
			{"delay": 26.0, "huge": false, "spawns": ["tieu_yeu", "yuki_onna"]},
			{"delay": 9.5, "huge": false, "spawns": ["yuki_onna", "nekomata", "karakasa"]},
			{"delay": 10.5, "huge": false, "spawns": ["samurai_ma", "yuki_onna", "tengu"]},
			{"delay": 11.5, "huge": false, "spawns": ["ran_ong", "yuki_onna", "kappa", "oni_nho"]},
			{"delay": 12.5, "huge": false, "spawns": ["miko_ma", "samurai_ma", "yuki_onna", "tengu"]},
			{"delay": 14.0, "huge": true, "spawns": ["oni_lon", "yuki_onna", "samurai_ma", "miko_ma", "ran_ong", "tengu"]},
		],
	},
	{
		"id": 14,
		"name": "5-2: Bão Tuyết Miếu Cổ",
		"subtitle": "Bão tuyết — Phối hợp Hỏa Phượng tan băng & Lư Hương cổ",
		"bg_stem": "bg_ch5_snowy_mountain",
		"land_tone": Vector2(0.67, 0.61),
		"terrain_variants": Vector2i(0, 4),
		"terrain_tint": Color(0.57, 0.65, 0.72),
		"top_border": "res://assets/sprites/environments/env_border_top_ch5_wide.png",
		"lawn_edge": "res://assets/sprites/environments/env_edge_snowdrift.png",
		"house_tex": "res://assets/sprites/environments/house_ch5_snow_shrine.png",
		"stone_path_tex": "res://assets/sprites/environments/env_path_stones_winter.png",
		"biome_flora_widths": Vector3(90, 55, 80),
		"biome_flora": [
			"res://assets/sprites/environments/flora_snow_pine_tall.png",
			"res://assets/sprites/props/prop_snow_bonsai.png",
			"res://assets/sprites/environments/flora_snow_lantern_rock.png",
		],
		"atmosphere_style": "snow",
		"tile_primary": "tile_snow",
		"tile_alt": "tile_gravel_night",
		"water_lane": -1,
		"sky_top": Color(0.16, 0.25, 0.40, 1),
		"sky_bottom": Color(0.65, 0.80, 0.92, 1),
		"ground_tint": Color(0.55, 0.65, 0.78, 1),
		"ambient_particle": "res://assets/sprites/fx/part_snowflake.png",
		"natural_flame_interval": 9.5,
		"starting_flame": 275,
		"obstacles": [
			{"id": "obs_ice_block", "row": 0, "col": 5},
			{"id": "obs_incense_burner", "row": 2, "col": 5},
			{"id": "obs_cursed_lantern", "row": 3, "col": 6},
			{"id": "obs_ice_block", "row": 4, "col": 5},
		],
		"props": ["res://assets/sprites/props/prop_snow_bonsai.png"],
		"waves": [
			{"delay": 26.0, "huge": false, "spawns": ["yuki_onna", "chochin_ma"]},
			{"delay": 9.5, "huge": false, "spawns": ["kappa_phap_su", "yuki_onna", "tanuki"]},
			{"delay": 10.5, "huge": false, "spawns": ["samurai_ma", "yuki_onna", "chochin_ma", "tengu"]},
			{"delay": 11.5, "huge": false, "spawns": ["miko_ma", "yuki_onna", "ran_ong", "karakasa"]},
			{"delay": 12.5, "huge": false, "spawns": ["oni_lon", "yuki_onna", "samurai_ma", "kappa_phap_su"]},
			{"delay": 14.0, "huge": true, "spawns": ["oni_lon", "yuki_onna", "yuki_onna", "samurai_ma", "miko_ma", "tanuki"]},
		],
	},
	{
		"id": 15,
		"name": "5-3: Điện Nữ Hoàng Tuyết (Boss)",
		"subtitle": "Bão tuyết — Boss Nữ Hoàng Tuyết đóng băng liên hoàn",
		"bg_stem": "bg_ch5_snowy_mountain",
		"land_tone": Vector2(0.67, 0.61),
		"terrain_variants": Vector2i(0, 4),
		"terrain_tint": Color(0.57, 0.65, 0.72),
		"top_border": "res://assets/sprites/environments/env_border_top_ch5_wide.png",
		"lawn_edge": "res://assets/sprites/environments/env_edge_snowdrift.png",
		"house_tex": "res://assets/sprites/environments/house_ch5_snow_shrine.png",
		"stone_path_tex": "res://assets/sprites/environments/env_path_stones_winter.png",
		"biome_flora_widths": Vector3(90, 55, 80),
		"biome_flora": [
			"res://assets/sprites/environments/flora_snow_pine_tall.png",
			"res://assets/sprites/props/prop_snow_bonsai.png",
			"res://assets/sprites/environments/flora_snow_lantern_rock.png",
		],
		"atmosphere_style": "snow",
		"tile_primary": "tile_snow",
		"tile_alt": "tile_gravel_night",
		"water_lane": -1,
		"sky_top": Color(0.16, 0.25, 0.40, 1),
		"sky_bottom": Color(0.65, 0.80, 0.92, 1),
		"ground_tint": Color(0.55, 0.65, 0.78, 1),
		"ambient_particle": "res://assets/sprites/fx/part_snowflake.png",
		"natural_flame_interval": 9.5,
		"starting_flame": 275,
		"obstacles": [
			{"id": "obs_haystack", "row": 0, "col": 5},
			{"id": "obs_ice_block", "row": 1, "col": 6},
			{"id": "obs_sake_barrel", "row": 2, "col": 6},
			{"id": "obs_ice_block", "row": 3, "col": 5},
			{"id": "obs_incense_burner", "row": 4, "col": 5},
		],
		"props": ["res://assets/sprites/props/prop_snow_bonsai.png"],
		"waves": [
			{"delay": 26.0, "huge": false, "spawns": ["yuki_onna", "samurai_ma"]},
			{"delay": 9.5, "huge": false, "spawns": ["tanuki", "yuki_onna", "tengu"]},
			{"delay": 10.5, "huge": false, "spawns": ["miko_ma", "kappa_phap_su", "yuki_onna"]},
			{"delay": 11.5, "huge": false, "spawns": ["samurai_ma", "chochin_ma", "yuki_onna", "ran_ong"]},
			{"delay": 12.5, "huge": false, "spawns": ["oni_lon", "yuki_onna", "samurai_ma", "miko_ma"]},
			{"delay": 14.5, "huge": true, "spawns": ["boss_yuki_queen", "yuki_onna", "yuki_onna", "samurai_ma", "miko_ma", "tanuki", "tengu"]},
		],
	},
	# === CHƯƠNG 6: ĐỀN HỎA SƠN HUYẾT NGUYỆT (Màn 16–18) ===
	{
		"id": 16,
		"name": "6-1: Thung Lũng Huyết Nguyệt",
		"subtitle": "Huyết nguyệt — Đá bazan núi lửa & Đèn Lồng Nguyền",
		"bg_stem": "bg_ch6_blood_moon_shrine",
		"land_tone": Vector2(0.75, 0.65),
		"terrain_variants": Vector2i(0, 1),
		"terrain_tint": Color(0.42, 0.30, 0.30),
		"top_border": "res://assets/sprites/environments/env_border_top_ch6.png",
		"lawn_edge": "res://assets/sprites/environments/env_edge_volcanic_curb.png",
		"house_tex": "res://assets/sprites/environments/house_ch6_fire_shrine.png",
		"stone_path_tex": "res://assets/sprites/environments/env_path_stones_sunset.png",
		"biome_flora": [
			"res://assets/sprites/environments/flora_ch6_ember_maple.png",
			"res://assets/sprites/environments/flora_moss_lantern_cluster.png",
			"res://assets/sprites/environments/flora_ch6_ember_maple.png",
		],
		"atmosphere_style": "volcano",
		"tile_primary": "tile_volcanic_stone",
		"tile_alt": "tile_ember_gravel",
		"water_lane": -1,
		"sky_top": Color(0.24, 0.08, 0.14, 1),
		"sky_bottom": Color(0.56, 0.22, 0.22, 1),
		"ground_tint": Color(0.32, 0.22, 0.24, 1),
		"ambient_particle": "res://assets/sprites/fx/part_sakura_2.png",
		"natural_flame_interval": 9.0,
		"starting_flame": 275,
		"obstacles": [
			{"id": "obs_cursed_lantern", "row": 0, "col": 6},
			{"id": "obs_sake_barrel", "row": 1, "col": 5},
			{"id": "obs_spike_barricade", "row": 2, "col": 5},
			{"id": "obs_cursed_lantern", "row": 3, "col": 6},
			{"id": "obs_incense_burner", "row": 4, "col": 5},
		],
		"props": ["res://assets/sprites/environments/flora_ch6_ember_maple.png"],
		"waves": [
			{"delay": 26.0, "huge": false, "spawns": ["samurai_ma", "chochin_ma"]},
			{"delay": 9.5, "huge": false, "spawns": ["tanuki", "karakasa", "kappa_phap_su"]},
			{"delay": 10.5, "huge": false, "spawns": ["miko_ma", "samurai_ma", "yuki_onna", "ran_ong"]},
			{"delay": 11.5, "huge": false, "spawns": ["chochin_ma", "tanuki", "tengu", "samurai_ma"]},
			{"delay": 12.5, "huge": false, "spawns": ["oni_lon", "kappa_phap_su", "miko_ma", "yuki_onna"]},
			{"delay": 14.0, "huge": true, "spawns": ["oni_lon", "samurai_ma", "tanuki", "chochin_ma", "miko_ma", "ran_ong"]},
		],
	},
	{
		"id": 17,
		"name": "6-2: Bậc Thang Hỏa Sơn",
		"subtitle": "Huyết nguyệt — Đại quân Yêu Quái hội tụ trước chính điện",
		"bg_stem": "bg_ch6_blood_moon_shrine",
		"land_tone": Vector2(0.75, 0.65),
		"terrain_variants": Vector2i(0, 1),
		"terrain_tint": Color(0.42, 0.30, 0.30),
		"top_border": "res://assets/sprites/environments/env_border_top_ch6.png",
		"lawn_edge": "res://assets/sprites/environments/env_edge_volcanic_curb.png",
		"house_tex": "res://assets/sprites/environments/house_ch6_fire_shrine.png",
		"stone_path_tex": "res://assets/sprites/environments/env_path_stones_sunset.png",
		"biome_flora": [
			"res://assets/sprites/environments/flora_ch6_ember_maple.png",
			"res://assets/sprites/environments/flora_moss_lantern_cluster.png",
			"res://assets/sprites/environments/flora_ch6_ember_maple.png",
		],
		"atmosphere_style": "volcano",
		"tile_primary": "tile_volcanic_stone",
		"tile_alt": "tile_ember_gravel",
		"water_lane": -1,
		"sky_top": Color(0.24, 0.08, 0.14, 1),
		"sky_bottom": Color(0.56, 0.22, 0.22, 1),
		"ground_tint": Color(0.32, 0.22, 0.24, 1),
		"ambient_particle": "res://assets/sprites/fx/part_sakura_2.png",
		"natural_flame_interval": 9.0,
		"starting_flame": 300,
		"obstacles": [
			{"id": "obs_sake_barrel", "row": 0, "col": 5},
			{"id": "obs_cursed_lantern", "row": 1, "col": 6},
			{"id": "obs_incense_burner", "row": 2, "col": 5},
			{"id": "obs_cursed_lantern", "row": 3, "col": 6},
			{"id": "obs_sake_barrel", "row": 4, "col": 5},
		],
		"props": ["res://assets/sprites/environments/flora_ch6_ember_maple.png"],
		"waves": [
			{"delay": 26.0, "huge": false, "spawns": ["tanuki", "chochin_ma", "karakasa"]},
			{"delay": 9.5, "huge": false, "spawns": ["samurai_ma", "kappa_phap_su", "ran_ong"]},
			{"delay": 10.5, "huge": false, "spawns": ["yuki_onna", "miko_ma", "chochin_ma", "tengu"]},
			{"delay": 11.5, "huge": false, "spawns": ["oni_lon", "samurai_ma", "tanuki", "kappa_phap_su"]},
			{"delay": 12.5, "huge": false, "spawns": ["boss_shogun", "miko_ma", "yuki_onna", "chochin_ma"]},
			{"delay": 14.5, "huge": true, "spawns": ["oni_lon", "oni_lon", "samurai_ma", "miko_ma", "yuki_onna", "tanuki", "tengu"]},
		],
	},
	{
		"id": 18,
		"name": "6-3: Huyết Nguyệt Cửu Vĩ (Final)",
		"subtitle": "Trận cuối — Tiêu diệt Cửu Vĩ Hồ Ly bảo vệ Edo vĩnh viễn!",
		"bg_stem": "bg_ch6_blood_moon_shrine",
		"land_tone": Vector2(0.75, 0.65),
		"terrain_variants": Vector2i(0, 1),
		"terrain_tint": Color(0.42, 0.30, 0.30),
		"top_border": "res://assets/sprites/environments/env_border_top_ch6.png",
		"lawn_edge": "res://assets/sprites/environments/env_edge_volcanic_curb.png",
		"house_tex": "res://assets/sprites/environments/house_ch6_fire_shrine.png",
		"stone_path_tex": "res://assets/sprites/environments/env_path_stones_sunset.png",
		"biome_flora": [
			"res://assets/sprites/environments/flora_ch6_ember_maple.png",
			"res://assets/sprites/environments/flora_moss_lantern_cluster.png",
			"res://assets/sprites/environments/flora_ch6_ember_maple.png",
		],
		"atmosphere_style": "volcano",
		"tile_primary": "tile_volcanic_stone",
		"tile_alt": "tile_ember_gravel",
		"water_lane": -1,
		"sky_top": Color(0.24, 0.08, 0.14, 1),
		"sky_bottom": Color(0.56, 0.22, 0.22, 1),
		"ground_tint": Color(0.32, 0.22, 0.24, 1),
		"ambient_particle": "res://assets/sprites/fx/part_sakura_2.png",
		"natural_flame_interval": 9.0,
		"starting_flame": 325,
		"obstacles": [
			{"id": "obs_cursed_lantern", "row": 0, "col": 6},
			{"id": "obs_sake_barrel", "row": 1, "col": 5},
			{"id": "obs_incense_burner", "row": 2, "col": 5},
			{"id": "obs_cursed_lantern", "row": 3, "col": 6},
			{"id": "obs_sake_barrel", "row": 4, "col": 5},
		],
		"props": ["res://assets/sprites/environments/flora_ch6_ember_maple.png"],
		"waves": [
			{"delay": 26.0, "huge": false, "spawns": ["samurai_ma", "chochin_ma", "tanuki"]},
			{"delay": 9.5, "huge": false, "spawns": ["yuki_onna", "kappa_phap_su", "tengu", "karakasa"]},
			{"delay": 10.5, "huge": false, "spawns": ["miko_ma", "samurai_ma", "tanuki", "ran_ong"]},
			{"delay": 11.5, "huge": false, "spawns": ["oni_lon", "yuki_onna", "miko_ma", "chochin_ma"]},
			{"delay": 12.5, "huge": false, "spawns": ["boss_shogun", "samurai_ma", "kappa_phap_su", "tanuki", "tengu"]},
			{"delay": 15.0, "huge": true, "spawns": ["boss_kyubi", "samurai_ma", "yuki_onna", "miko_ma", "chochin_ma", "tanuki", "kappa_phap_su"]},
		],
	},
	# === CHƯƠNG 7: ĐẠI CHIẾN TRƯỜNG KỲ (Màn 19–21) ===
	{
		"id": 19,
		"name": "7-1: Trường Chiến Làng Hoa (8 đợt)",
		"subtitle": "Trường chiến ban ngày — 8 đợt tấn công liên hoàn tại Làng Hoa",
		"bg_stem": "bg_ch1_sakura_village",
		"land_tone": Vector2(0.72, 0.69),
		"terrain_variants": Vector2i(5, 4),
		"terrain_tint": Color(0.47, 0.58, 0.32),
		"top_border": "res://assets/sprites/environments/env_border_top_ch1.png",
		"lawn_edge": "res://assets/sprites/environments/env_edge_bamboo_flowers.png",
		"house_tex": "res://assets/sprites/props/prop_edo_house.png",
		"biome_flora": [
			"res://assets/sprites/environments/flora_sakura_hedge.png",
			"res://assets/sprites/props/prop_sakura_tree.png",
			"res://assets/sprites/environments/flora_moss_lantern_cluster.png",
		],
		"atmosphere_style": "day",
		"tile_primary": "tile_grass",
		"tile_alt": "tile_dirt",
		"layout": "twin_pond",
		"water_lanes": [1, 3],
		"sky_top": Color(0.55, 0.78, 0.94, 1),
		"sky_bottom": Color(0.84, 0.93, 0.88, 1),
		"ground_tint": Color(0.45, 0.63, 0.34, 1),
		"ambient_particle": "res://assets/sprites/fx/part_sakura_1.png",
		"natural_flame_interval": 8.0,
		"starting_flame": 250,
		"obstacles": [
			{"id": "obs_wood_fence", "row": 0, "col": 5},
			{"id": "obs_crate", "row": 1, "col": 6},
			{"id": "obs_haystack", "row": 3, "col": 5},
			{"id": "obs_rock", "row": 4, "col": 6},
		],
		"props": ["res://assets/sprites/props/prop_sakura_tree.png"],
		"waves": [
			{"delay": 26.0, "huge": false, "spawns": ["tieu_yeu", "tieu_yeu", "nekomata"]},
			{"delay": 9.5, "huge": false, "spawns": ["oni_nho", "nekomata", "karakasa"]},
			{"delay": 10.0, "huge": false, "spawns": ["tieu_yeu", "tanuki", "chochin_ma"]},
			{"delay": 10.5, "huge": false, "spawns": ["tengu", "nekomata", "karakasa", "oni_nho"]},
			{"delay": 12.5, "huge": true, "spawns": ["samurai_ma", "tanuki", "chochin_ma", "nekomata", "tieu_yeu"]},
			{"delay": 10.5, "huge": false, "spawns": ["tengu", "samurai_ma", "karakasa", "oni_nho"]},
			{"delay": 11.5, "huge": false, "spawns": ["oni_lon", "tanuki", "chochin_ma", "nekomata"]},
			{"delay": 13.5, "huge": true, "spawns": ["oni_lon", "samurai_ma", "tengu", "tanuki", "chochin_ma", "karakasa"]},
		],
	},
	{
		"id": 20,
		"name": "7-2: Rừng Tre Vây Hãm (9 đợt)",
		"subtitle": "Hoàng hôn vây hãm — 9 đợt liên tiếp cùng Đại Thiên Cẩu",
		"bg_stem": "bg_ch2_bamboo_sunset",
		"land_tone": Vector2(0.63, 0.58),
		"terrain_variants": Vector2i(3, 1),
		"terrain_tint": Color(0.46, 0.48, 0.34),
		"top_border": "res://assets/sprites/environments/env_border_top_ch2.png",
		"lawn_edge": "res://assets/sprites/environments/env_edge_moss_stones.png",
		"house_tex": "res://assets/sprites/environments/house_ch2_teahouse.png",
		"stone_path_tex": "res://assets/sprites/environments/env_path_stones_sunset.png",
		"biome_flora": [
			"res://assets/sprites/environments/flora_sunset_bamboo.png",
			"res://assets/sprites/environments/flora_moss_lantern_cluster.png",
			"res://assets/sprites/props/prop_bamboo_grove.png",
		],
		"atmosphere_style": "sunset",
		"tile_primary": "tile_moss_stone",
		"tile_alt": "tile_cobble",
		"layout": "stone_island",
		"water_lanes": [2],
		"island_columns": Vector2i(4, 6),
		"deep_water_columns": [3, 7],
		"sky_top": Color(0.72, 0.36, 0.28, 1),
		"sky_bottom": Color(0.95, 0.69, 0.36, 1),
		"ground_tint": Color(0.36, 0.44, 0.32, 1),
		"ambient_particle": "res://assets/sprites/fx/part_bamboo_leaf.png",
		"natural_flame_interval": 8.5,
		"starting_flame": 275,
		"obstacles": [
			{"id": "obs_wood_fence", "row": 0, "col": 5},
			{"id": "obs_sake_barrel", "row": 1, "col": 6},
			{"id": "obs_spike_barricade", "row": 2, "col": 5},
			{"id": "obs_crate", "row": 3, "col": 6},
			{"id": "obs_rock", "row": 4, "col": 5},
		],
		"props": ["res://assets/sprites/props/prop_bamboo_grove.png"],
		"waves": [
			{"delay": 26.0, "huge": false, "spawns": ["nekomata", "tengu", "karakasa"]},
			{"delay": 9.5, "huge": false, "spawns": ["tanuki", "ran_ong", "nekomata"]},
			{"delay": 10.0, "huge": false, "spawns": ["tengu", "kappa_phap_su", "karakasa"]},
			{"delay": 10.5, "huge": false, "spawns": ["tanuki", "ran_ong", "tengu", "nekomata"]},
			{"delay": 12.5, "huge": true, "spawns": ["oni_lon", "tengu", "tanuki", "kappa_phap_su", "karakasa"]},
			{"delay": 10.5, "huge": false, "spawns": ["ran_ong", "kappa_phap_su", "tengu", "nekomata"]},
			{"delay": 11.0, "huge": false, "spawns": ["oni_lon", "tanuki", "ran_ong", "karakasa"]},
			{"delay": 11.5, "huge": false, "spawns": ["oni_lon", "kappa_phap_su", "tengu", "tanuki"]},
			{"delay": 14.0, "huge": true, "spawns": ["boss_tengu_king", "oni_lon", "tengu", "ran_ong", "tanuki", "kappa_phap_su"]},
		],
	},
	{
		"id": 21,
		"name": "7-3: Đêm Dài Hồ Cá Koi (10 đợt · Boss)",
		"subtitle": "Ban đêm — Đại chiến 10 đợt bảo vệ Đền Thần & Hồ Cá Koi",
		"bg_stem": "bg_ch3_koi_shrine_night",
		"land_tone": Vector2(0.63, 0.59),
		"terrain_variants": Vector2i(3, 2),
		"terrain_tint": Color(0.36, 0.37, 0.32),
		"top_border": "res://assets/sprites/environments/env_border_top_ch3.png",
		"lawn_edge": "res://assets/sprites/environments/env_edge_koi_bank.png",
		"house_tex": "res://assets/sprites/environments/house_ch3_koi_shrine.png",
		"stone_path_tex": "res://assets/sprites/environments/env_path_stones_night.png",
		"biome_flora": [
			"res://assets/sprites/environments/flora_night_sakura.png",
			"res://assets/sprites/environments/flora_moss_lantern_cluster.png",
			"res://assets/sprites/props/prop_red_bridge.png",
		],
		"atmosphere_style": "night",
		"tile_primary": "tile_moss_stone",
		"tile_alt": "tile_sakura",
		"layout": "twin_pond",
		"water_lanes": [0, 2],
		"sky_top": Color(0.11, 0.14, 0.30, 1),
		"sky_bottom": Color(0.22, 0.31, 0.48, 1),
		"ground_tint": Color(0.24, 0.28, 0.38, 1),
		"ambient_particle": "res://assets/sprites/fx/part_spirit_wisp.png",
		"natural_flame_interval": 9.0,
		"starting_flame": 300,
		"obstacles": [
			{"id": "obs_cursed_lantern", "row": 0, "col": 6},
			{"id": "obs_spike_barricade", "row": 1, "col": 5},
			{"id": "obs_incense_burner", "row": 3, "col": 5},
			{"id": "obs_sake_barrel", "row": 4, "col": 6},
		],
		"props": ["res://assets/sprites/environments/flora_night_sakura.png"],
		"waves": [
			{"delay": 26.0, "huge": false, "spawns": ["kappa", "chochin_ma", "karakasa"]},
			{"delay": 9.5, "huge": false, "spawns": ["kappa_phap_su", "miko_ma", "kappa"]},
			{"delay": 10.0, "huge": false, "spawns": ["tanuki", "chochin_ma", "yuki_onna"]},
			{"delay": 10.5, "huge": false, "spawns": ["kappa", "kappa_phap_su", "karakasa", "miko_ma"]},
			{"delay": 12.5, "huge": true, "spawns": ["oni_lon", "kappa_phap_su", "miko_ma", "chochin_ma", "kappa"]},
			{"delay": 10.5, "huge": false, "spawns": ["yuki_onna", "tanuki", "kappa_phap_su", "karakasa"]},
			{"delay": 11.0, "huge": false, "spawns": ["oni_lon", "miko_ma", "chochin_ma", "kappa"]},
			{"delay": 11.5, "huge": false, "spawns": ["yuki_onna", "kappa_phap_su", "tanuki", "miko_ma"]},
			{"delay": 12.0, "huge": false, "spawns": ["oni_lon", "yuki_onna", "chochin_ma", "kappa", "karakasa"]},
			{"delay": 14.5, "huge": true, "spawns": ["boss_kappa_lord", "oni_lon", "kappa_phap_su", "miko_ma", "yuki_onna", "tanuki", "chochin_ma"]},
		],
	},
	# === CHƯƠNG 8: BÁCH QUỶ DẠ HÀNH (Màn 22–24) ===
	{
		"id": 22,
		"name": "8-1: Thành Cổ Huyết Chiến (10 đợt)",
		"subtitle": "Đêm sương — 10 đợt vây thành trước Đại Tướng Quân Yêu Khí",
		"bg_stem": "bg_ch4_misty_castle",
		"land_tone": Vector2(0.71, 0.64),
		"terrain_variants": Vector2i(5, 1),
		"terrain_tint": Color(0.41, 0.40, 0.42),
		"top_border": "res://assets/sprites/environments/env_border_top_ch4.png",
		"lawn_edge": "res://assets/sprites/environments/env_edge_moss_stones.png",
		"house_tex": "res://assets/sprites/environments/house_ch4_castle_guard.png",
		"stone_path_tex": "res://assets/sprites/environments/env_path_stones_sunset.png",
		"biome_flora_widths": Vector3(90, 91, 47),
		"biome_flora": [
			"res://assets/sprites/environments/flora_autumn_maple.png",
			"res://assets/sprites/environments/flora_moss_lantern_cluster.png",
			"res://assets/sprites/props/prop_banner.png",
		],
		"atmosphere_style": "night",
		"tile_primary": "tile_gravel_night",
		"tile_alt": "tile_cobble",
		"layout": "fog_night",
		"water_lanes": [],
		"fog": {"columns": 3.50, "opacity": 0.82, "transition": 0.40, "recovery": 1.5},
		"sky_top": Color(0.16, 0.14, 0.25, 1),
		"sky_bottom": Color(0.32, 0.31, 0.42, 1),
		"ground_tint": Color(0.24, 0.24, 0.30, 1),
		"ambient_particle": "res://assets/sprites/fx/part_sakura_2.png",
		"natural_flame_interval": 9.0,
		"starting_flame": 325,
		"obstacles": [
			{"id": "obs_sake_barrel", "row": 0, "col": 5},
			{"id": "obs_cursed_lantern", "row": 1, "col": 6},
			{"id": "obs_spike_barricade", "row": 2, "col": 5},
			{"id": "obs_incense_burner", "row": 3, "col": 6},
			{"id": "obs_wood_fence", "row": 4, "col": 5},
		],
		"props": ["res://assets/sprites/environments/flora_autumn_maple.png"],
		"waves": [
			{"delay": 26.0, "huge": false, "spawns": ["samurai_ma", "ran_ong", "tanuki"]},
			{"delay": 9.5, "huge": false, "spawns": ["miko_ma", "chochin_ma", "samurai_ma"]},
			{"delay": 10.0, "huge": false, "spawns": ["oni_lon", "kappa_phap_su", "ran_ong"]},
			{"delay": 10.5, "huge": false, "spawns": ["samurai_ma", "tanuki", "miko_ma", "chochin_ma"]},
			{"delay": 12.5, "huge": true, "spawns": ["oni_lon", "samurai_ma", "miko_ma", "ran_ong", "tanuki"]},
			{"delay": 10.5, "huge": false, "spawns": ["kappa_phap_su", "chochin_ma", "samurai_ma", "ran_ong"]},
			{"delay": 11.0, "huge": false, "spawns": ["oni_lon", "miko_ma", "tanuki", "kappa_phap_su"]},
			{"delay": 11.5, "huge": false, "spawns": ["samurai_ma", "oni_lon", "chochin_ma", "ran_ong"]},
			{"delay": 12.0, "huge": false, "spawns": ["oni_lon", "samurai_ma", "miko_ma", "kappa_phap_su", "tanuki"]},
			{"delay": 14.5, "huge": true, "spawns": ["boss_shogun", "samurai_ma", "oni_lon", "miko_ma", "chochin_ma", "tanuki", "kappa_phap_su"]},
		],
	},
	{
		"id": 23,
		"name": "8-2: Bão Tuyết Bất Tận (11 đợt)",
		"subtitle": "Bão tuyết — 11 đợt thủ thành giá rét chống Nữ Hoàng Tuyết",
		"bg_stem": "bg_ch5_snowy_mountain",
		"land_tone": Vector2(0.67, 0.61),
		"terrain_variants": Vector2i(0, 4),
		"terrain_tint": Color(0.57, 0.65, 0.72),
		"top_border": "res://assets/sprites/environments/env_border_top_ch5_wide.png",
		"lawn_edge": "res://assets/sprites/environments/env_edge_snowdrift.png",
		"house_tex": "res://assets/sprites/environments/house_ch5_snow_shrine.png",
		"stone_path_tex": "res://assets/sprites/environments/env_path_stones_winter.png",
		"biome_flora_widths": Vector3(90, 55, 80),
		"biome_flora": [
			"res://assets/sprites/environments/flora_snow_pine_tall.png",
			"res://assets/sprites/props/prop_snow_bonsai.png",
			"res://assets/sprites/environments/flora_snow_lantern_rock.png",
		],
		"atmosphere_style": "snow",
		"tile_primary": "tile_snow",
		"tile_alt": "tile_gravel_night",
		"layout": "stone_island",
		"water_lanes": [3],
		"island_columns": Vector2i(4, 6),
		"deep_water_columns": [3, 7],
		"sky_top": Color(0.16, 0.25, 0.40, 1),
		"sky_bottom": Color(0.65, 0.80, 0.92, 1),
		"ground_tint": Color(0.55, 0.65, 0.78, 1),
		"ambient_particle": "res://assets/sprites/fx/part_snowflake.png",
		"natural_flame_interval": 9.0,
		"starting_flame": 350,
		"obstacles": [
			{"id": "obs_ice_block", "row": 0, "col": 5},
			{"id": "obs_haystack", "row": 1, "col": 6},
			{"id": "obs_cursed_lantern", "row": 2, "col": 5},
			{"id": "obs_ice_block", "row": 3, "col": 6},
			{"id": "obs_sake_barrel", "row": 4, "col": 5},
		],
		"props": ["res://assets/sprites/environments/flora_snow_pine_tall.png"],
		"waves": [
			{"delay": 26.0, "huge": false, "spawns": ["yuki_onna", "tengu", "chochin_ma"]},
			{"delay": 9.5, "huge": false, "spawns": ["samurai_ma", "kappa_phap_su", "tanuki"]},
			{"delay": 10.0, "huge": false, "spawns": ["yuki_onna", "miko_ma", "tengu"]},
			{"delay": 10.5, "huge": false, "spawns": ["oni_lon", "yuki_onna", "chochin_ma", "tanuki"]},
			{"delay": 12.5, "huge": true, "spawns": ["oni_lon", "yuki_onna", "samurai_ma", "miko_ma", "kappa_phap_su"]},
			{"delay": 10.5, "huge": false, "spawns": ["tengu", "yuki_onna", "chochin_ma", "tanuki"]},
			{"delay": 11.0, "huge": false, "spawns": ["samurai_ma", "miko_ma", "kappa_phap_su", "oni_lon"]},
			{"delay": 13.0, "huge": true, "spawns": ["oni_lon", "yuki_onna", "miko_ma", "tengu", "samurai_ma", "chochin_ma"]},
			{"delay": 11.5, "huge": false, "spawns": ["yuki_onna", "kappa_phap_su", "tanuki", "samurai_ma"]},
			{"delay": 12.0, "huge": false, "spawns": ["oni_lon", "yuki_onna", "miko_ma", "tengu", "chochin_ma"]},
			{"delay": 14.5, "huge": true, "spawns": ["boss_yuki_queen", "oni_lon", "yuki_onna", "samurai_ma", "miko_ma", "tengu", "kappa_phap_su"]},
		],
	},
	{
		"id": 24,
		"name": "8-3: Bách Quỷ Dạ Hành (12 đợt · Đại Chiến)",
		"subtitle": "Tổng tiến công 12 đợt — Ngũ Đại Yêu Vương & Cửu Vĩ Hồ Ly",
		"bg_stem": "bg_ch6_blood_moon_shrine",
		"land_tone": Vector2(0.75, 0.65),
		"terrain_variants": Vector2i(0, 1),
		"terrain_tint": Color(0.42, 0.30, 0.30),
		"top_border": "res://assets/sprites/environments/env_border_top_ch6.png",
		"lawn_edge": "res://assets/sprites/environments/env_edge_volcanic_curb.png",
		"house_tex": "res://assets/sprites/environments/house_ch6_fire_shrine.png",
		"stone_path_tex": "res://assets/sprites/environments/env_path_stones_sunset.png",
		"biome_flora": [
			"res://assets/sprites/environments/flora_ch6_ember_maple.png",
			"res://assets/sprites/environments/flora_moss_lantern_cluster.png",
			"res://assets/sprites/environments/flora_ch6_ember_maple.png",
		],
		"atmosphere_style": "volcano",
		"tile_primary": "tile_volcanic_stone",
		"tile_alt": "tile_ember_gravel",
		"layout": "fog_night",
		"water_lanes": [],
		"fog": {"columns": 3.75, "opacity": 0.72, "transition": 0.40, "recovery": 1.5},
		"sky_top": Color(0.24, 0.08, 0.14, 1),
		"sky_bottom": Color(0.56, 0.22, 0.22, 1),
		"ground_tint": Color(0.32, 0.22, 0.24, 1),
		"ambient_particle": "res://assets/sprites/fx/part_sakura_2.png",
		"natural_flame_interval": 8.5,
		"starting_flame": 400,
		"obstacles": [
			{"id": "obs_cursed_lantern", "row": 0, "col": 6},
			{"id": "obs_sake_barrel", "row": 1, "col": 5},
			{"id": "obs_incense_burner", "row": 2, "col": 5},
			{"id": "obs_cursed_lantern", "row": 3, "col": 6},
			{"id": "obs_sake_barrel", "row": 4, "col": 5},
		],
		"props": ["res://assets/sprites/environments/flora_ch6_ember_maple.png"],
		"waves": [
			{"delay": 26.0, "huge": false, "spawns": ["samurai_ma", "chochin_ma", "tanuki"]},
			{"delay": 9.5, "huge": false, "spawns": ["tengu", "ran_ong", "karakasa", "kappa_phap_su"]},
			{"delay": 10.0, "huge": false, "spawns": ["yuki_onna", "miko_ma", "samurai_ma", "tanuki"]},
			{"delay": 12.5, "huge": true, "spawns": ["boss_tengu_king", "tengu", "samurai_ma", "chochin_ma", "tanuki"]},
			{"delay": 10.5, "huge": false, "spawns": ["oni_lon", "kappa_phap_su", "ran_ong", "yuki_onna"]},
			{"delay": 11.0, "huge": false, "spawns": ["miko_ma", "samurai_ma", "tanuki", "chochin_ma"]},
			{"delay": 13.0, "huge": true, "spawns": ["boss_kappa_lord", "oni_lon", "kappa_phap_su", "yuki_onna", "miko_ma"]},
			{"delay": 11.5, "huge": false, "spawns": ["oni_lon", "samurai_ma", "tengu", "ran_ong", "chochin_ma"]},
			{"delay": 12.0, "huge": false, "spawns": ["yuki_onna", "miko_ma", "kappa_phap_su", "tanuki", "oni_lon"]},
			{"delay": 13.5, "huge": true, "spawns": ["boss_shogun", "boss_yuki_queen", "samurai_ma", "yuki_onna", "miko_ma"]},
			{"delay": 12.5, "huge": false, "spawns": ["oni_lon", "samurai_ma", "yuki_onna", "miko_ma", "kappa_phap_su", "tanuki"]},
			{"delay": 15.0, "huge": true, "spawns": ["boss_kyubi", "oni_lon", "samurai_ma", "yuki_onna", "miko_ma", "chochin_ma", "tanuki", "kappa_phap_su"]},
		],
	},
]


func _ready() -> void:
	var ext_id := _resolve_external_player_id()
	if not ext_id.is_empty():
		player_id = ext_id
		is_external_player = true
	load_progress()
	if player_id.is_empty():
		player_id = _generate_player_id()
		_write_local_save()
	var cloud := get_node_or_null("/root/CloudSync")
	if cloud:
		if not cloud.remote_progress_loaded.is_connected(_on_remote_progress_loaded):
			cloud.remote_progress_loaded.connect(_on_remote_progress_loaded)
		cloud.pull_progress(player_id)
	var args := OS.get_cmdline_args()
	var user_args := OS.get_cmdline_user_args()
	if args.has("--autoplay-5x-10m") or user_args.has("--autoplay-5x-10m"):
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
	game_speed_multiplier = NORMAL_BATTLE_SPEED
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
	if lvl_id <= 3:
		selected_deck.assign(["than_den", "dao_tien", "tre_no", "bi_ngo", "ho_lo_bang", "phao_hoa", "gio_loc", "meo_kiem"])
	elif lvl_id <= 6:
		selected_deck.assign(["than_den", "tre_no", "bi_ngo", "ho_lo_bang", "gio_loc", "meo_kiem", "daruma_buff", "phao_hoa"])
	elif lvl_id <= 9:
		selected_deck.assign(["than_den", "dao_tien", "tre_no", "bi_ngo", "nam_doc", "ho_lo_bang", "cung_sam", "phu_chu"])
	elif lvl_id <= 12:
		selected_deck.assign(["than_den", "tre_no", "bi_ngo", "nam_doc", "ho_lo_bang", "meo_kiem", "cung_sam", "chua_lanh"])
	elif lvl_id <= 15:
		selected_deck.assign(["than_den", "tre_no", "bi_ngo", "hoa_phuong", "daruma_buff", "chua_lanh", "gio_loc", "phao_hoa"])
	else:
		selected_deck.assign(["than_den", "hoa_phuong", "cung_sam", "meo_kiem", "daruma_buff", "bi_ngo", "ho_lo_bang", "chua_lanh"])
	if get_level_config(lvl_id).has("fog"):
		selected_deck[selected_deck.size() - 1] = "den_soi_yeu"
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


func defender_category(defender_id: String) -> Dictionary:
	for category in DEFENDER_CATEGORIES:
		if defender_id in category["members"]:
			return category
	return {}


func stage_water_rows(config: Dictionary) -> Array:
	if config.has("water_lanes"):
		return config["water_lanes"]
	var lane := int(config.get("water_lane", -1))
	return [] if lane < 0 else [lane]


func valid_deck(entries: Variant) -> Array[String]:
	var deck: Array[String] = []
	if entries is Array:
		for item in entries:
			if item is String and DEFENDERS.has(item) and not deck.has(item):
				deck.append(item)
				if deck.size() == MAX_DECK_SIZE:
					break
	return deck


func remember_battle_deck() -> void:
	if not auto_play_active:
		previous_deck = valid_deck(selected_deck)
		save_progress()


func reuse_previous_deck() -> bool:
	var deck := valid_deck(previous_deck)
	if deck.is_empty():
		return false
	selected_deck.assign(deck)
	save_progress()
	return true


func is_deck_member(defender_id: String) -> bool:
	return selected_deck.has(defender_id)


func toggle_deck_member(defender_id: String) -> bool:
	if not DEFENDERS.has(defender_id):
		return false
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
	save_progress(false)
	var cloud := get_node_or_null("/root/CloudSync")
	if cloud:
		var lvl_name := str(get_level_config(level_id).get("name", ""))
		cloud.record_level_completion(build_save_snapshot(), level_id, lvl_name, stars, reward, selected_deck)
	return reward


func unlock_all_levels() -> void:
	unlocked_level = LEVELS.size()
	save_progress()


func build_save_snapshot() -> Dictionary:
	return {
		"player_id": player_id,
		"unlocked_level": unlocked_level,
		"level_stars": level_stars.duplicate(true),
		"selected_deck": selected_deck.duplicate(),
		"previous_deck": previous_deck.duplicate(),
		"jade_gems": jade_gems,
		"unlocked_upgrades": unlocked_upgrades.duplicate(),
		"auto_collect_flame": auto_collect_flame,
		"sound_muted": sound_muted,
		"audio_layers": audio_layers.duplicate(true),
		"updated_at": save_updated_at,
	}


func save_progress(sync_cloud: bool = true) -> void:
	if player_id.is_empty():
		player_id = _generate_player_id()
	save_updated_at = int(Time.get_unix_time_from_system())
	_write_local_save()
	if sync_cloud:
		var cloud := get_node_or_null("/root/CloudSync")
		if cloud:
			cloud.sync_progress(build_save_snapshot())


func _current_save_path() -> String:
	if is_external_player and not player_id.is_empty():
		return "user://edo_save_%s.json" % player_id
	return SAVE_PATH


func _sanitize_player_id(raw: String) -> String:
	var s := raw.strip_edges()
	var out := ""
	for i in range(mini(s.length(), 128)):
		var code := s.unicode_at(i)
		var is_alpha := (code >= 65 and code <= 90) or (code >= 97 and code <= 122)
		var is_digit := code >= 48 and code <= 57
		if is_alpha or is_digit or code == 95 or code == 45:
			out += char(code)
	return out


func extract_uuid_from_query(raw_query: String) -> String:
	var cleaned := raw_query.strip_edges().replace("#", "&")
	while cleaned.begins_with("?") or cleaned.begins_with("&"):
		cleaned = cleaned.substr(1)
	if cleaned.is_empty():
		return ""
	var kv: Dictionary = {}
	for pair in cleaned.split("&", false):
		var eq := pair.find("=")
		if eq <= 0:
			continue
		var k := pair.left(eq).uri_decode().strip_edges().to_lower()
		var v := pair.substr(eq + 1).uri_decode()
		if not kv.has(k):
			kv[k] = v
	for key in ["uuid", "user_id", "player_id", "uid"]:
		if kv.has(key):
			var candidate := _sanitize_player_id(str(kv[key]))
			if not candidate.is_empty():
				return candidate
	return ""


func extract_uuid_from_args(args: PackedStringArray) -> String:
	var n := args.size()
	for i in range(n):
		var arg := str(args[i]).strip_edges()
		for prefix in ["--uuid=", "--user-id=", "--player-id=", "--uid="]:
			if arg.begins_with(prefix):
				var candidate := _sanitize_player_id(arg.substr(prefix.length()).uri_decode())
				if not candidate.is_empty():
					return candidate
		if arg in ["--uuid", "--user-id", "--player-id", "--uid"] and i + 1 < n:
			var candidate := _sanitize_player_id(str(args[i + 1]).uri_decode())
			if not candidate.is_empty():
				return candidate
		var q_pos := arg.find("?")
		var h_pos := arg.find("#")
		var query_part := ""
		if q_pos >= 0:
			query_part = arg.substr(q_pos + 1)
		elif h_pos >= 0:
			query_part = arg.substr(h_pos + 1)
		elif arg.contains("uuid=") or arg.contains("user_id=") or arg.contains("player_id="):
			query_part = arg
		if not query_part.is_empty():
			var candidate := extract_uuid_from_query(query_part)
			if not candidate.is_empty():
				return candidate
	return ""


func _resolve_external_player_id() -> String:
	if OS.has_feature("web") and Engine.has_singleton("JavaScriptBridge"):
		var raw_web := str(JavaScriptBridge.eval("window.location.search + '&' + window.location.hash"))
		var from_web := extract_uuid_from_query(raw_web)
		if not from_web.is_empty():
			return from_web
	var from_user_args := extract_uuid_from_args(OS.get_cmdline_user_args())
	if not from_user_args.is_empty():
		return from_user_args
	var from_args := extract_uuid_from_args(OS.get_cmdline_args())
	if not from_args.is_empty():
		return from_args
	for env_key in ["PSA_USER_UUID", "PLAYER_UUID"]:
		var from_env := _sanitize_player_id(OS.get_environment(env_key))
		if not from_env.is_empty():
			return from_env
	return ""


func _reset_progress_to_defaults() -> void:
	selected_level = 1
	unlocked_level = 1
	level_stars = {}
	jade_gems = 15
	unlocked_upgrades.clear()
	selected_deck.assign(DEFAULT_DECK)
	previous_deck.clear()
	save_updated_at = 0


func set_external_player_id(raw_uuid: String) -> bool:
	var clean_id := _sanitize_player_id(raw_uuid)
	if clean_id.is_empty():
		return false
	player_id = clean_id
	is_external_player = true
	_reset_progress_to_defaults()
	load_progress()
	progress_changed.emit()
	var cloud := get_node_or_null("/root/CloudSync")
	if cloud:
		cloud.pull_progress(player_id)
	return true


func _write_local_save() -> void:
	var data := build_save_snapshot()
	var f := FileAccess.open(_current_save_path(), FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))


func _generate_player_id() -> String:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	return "edo_%08x%08x" % [rng.randi(), rng.randi()]


func _on_remote_progress_loaded(remote: Dictionary) -> void:
	if str(remote.get("player_id", "")) != player_id:
		return
	var remote_updated := int(remote.get("updated_at", 0))
	unlocked_level = maxi(unlocked_level, clampi(int(remote.get("unlocked_level", 1)), 1, LEVELS.size()))
	var r_stars = remote.get("level_stars", {})
	if typeof(r_stars) == TYPE_DICTIONARY:
		for k in r_stars.keys():
			var sk := str(k)
			level_stars[sk] = maxi(int(level_stars.get(sk, 0)), clampi(int(r_stars[k]), 0, 3))
	var r_upg = remote.get("unlocked_upgrades", [])
	if typeof(r_upg) == TYPE_ARRAY:
		for u in r_upg:
			var su := str(u)
			if GARDEN_UPGRADES.has(su) and not unlocked_upgrades.has(su):
				unlocked_upgrades.append(su)
	if remote_updated > save_updated_at:
		jade_gems = maxi(0, int(remote.get("jade_gems", jade_gems)))
		var r_sel := valid_deck(remote.get("selected_deck", []))
		if not r_sel.is_empty():
			selected_deck.assign(r_sel)
		var r_prev := valid_deck(remote.get("previous_deck", []))
		if not r_prev.is_empty():
			previous_deck = r_prev
		var r_settings = remote.get("settings", {})
		if typeof(r_settings) == TYPE_DICTIONARY:
			auto_collect_flame = bool(r_settings.get("auto_collect_flame", auto_collect_flame))
			sound_muted = bool(r_settings.get("sound_muted", sound_muted))
			var r_layers = r_settings.get("audio_layers", {})
			if typeof(r_layers) == TYPE_DICTIONARY:
				for layer in audio_layers:
					audio_layers[layer] = bool(r_layers.get(layer, audio_layers[layer]))
		save_updated_at = remote_updated
	_write_local_save()
	progress_changed.emit()


func load_progress() -> void:
	var path := _current_save_path()
	if not FileAccess.file_exists(path):
		return
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return
	var parsed = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	if not is_external_player:
		player_id = str(parsed.get("player_id", ""))
	elif player_id.is_empty():
		player_id = str(parsed.get("player_id", ""))
	save_updated_at = maxi(0, int(parsed.get("updated_at", 0)))
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
	var clean_deck := valid_deck(parsed.get("selected_deck", []))
	if not clean_deck.is_empty():
		selected_deck.assign(clean_deck)
	previous_deck = valid_deck(parsed.get("previous_deck", clean_deck))
	auto_collect_flame = bool(parsed.get("auto_collect_flame", true))
	sound_muted = bool(parsed.get("sound_muted", false))
	var saved_layers = parsed.get("audio_layers", {})
	if saved_layers is Dictionary:
		for layer in audio_layers:
			audio_layers[layer] = bool(saved_layers.get(layer, true))
