extends RefCounted

## Contact point (source pixels) and visible width for the seasonal artwork.
const GROUND_CONTACTS := {
	"prop_edo_house": Vector3(131, 239, 230),
	"house_ch2_teahouse": Vector3(139, 239, 230),
	"house_ch3_koi_shrine": Vector3(128, 239, 230),
	"house_ch4_castle_guard": Vector3(134, 239, 230),
	"house_ch5_snow_shrine": Vector3(130, 238, 224),
	"house_ch6_fire_shrine": Vector3(133, 245, 230),
	"gate_ch1_sakura_torii": Vector3(127, 245, 212),
	"gate_ch2_bamboo": Vector3(127, 245, 212),
	"gate_ch3_night_torii": Vector3(127, 245, 215),
	"gate_ch4_castle_gate": Vector3(127, 245, 210),
	"gate_ch5_snow_torii": Vector3(127, 245, 209),
	"gate_ch6_volcano_torii": Vector3(127, 245, 217),
	"flora_sakura_hedge": Vector3(128, 237, 230),
	"prop_sakura_tree": Vector3(128, 235, 230),
	"flora_moss_lantern_cluster": Vector3(128, 237, 230),
	"prop_bamboo_grove": Vector3(126, 237, 196),
	"prop_banner": Vector3(64, 119, 80),
	"prop_snow_bonsai": Vector3(66, 117, 115),
	"flora_sunset_bamboo": Vector3(129, 237, 230),
	"flora_night_sakura": Vector3(129, 236, 230),
	"flora_autumn_maple": Vector3(130, 235, 230),
	"flora_snow_pine_tall": Vector3(127, 236, 221),
	"flora_snow_lantern_rock": Vector3(128, 236, 224),
	"flora_ch6_ember_maple": Vector3(118, 245, 230),
	"prop_red_bridge": Vector3(128, 237, 230),
	"env_path_stepping_stones": Vector3(190, 97, 381),
	"env_path_stones_sunset": Vector3(158, 77, 317),
	"env_path_stones_night": Vector3(164, 87, 329),
	"env_path_stones_winter": Vector3(154, 77, 308),
}

var _contact_shadow: GradientTexture2D


func place(parent: Node2D, path: String, foot: Vector2, width: float, depth: int, tint: Color = Color.WHITE, angle: float = 0.0) -> Sprite2D:
	var texture := load(path) as Texture2D
	var art_name := path.get_file().get_basename()
	var contact: Vector3 = GROUND_CONTACTS[art_name]
	var art_scale := width / contact.z
	_add_shadow(parent, foot + Vector2(0, 3), width, depth - 1)

	var prop := Sprite2D.new()
	prop.texture = texture
	prop.centered = false
	prop.offset = -Vector2(contact.x, contact.y)
	prop.position = foot
	prop.scale = Vector2.ONE * art_scale
	prop.modulate = tint
	prop.rotation = angle
	prop.z_index = depth
	parent.add_child(prop)
	return prop


func _add_shadow(parent: Node2D, position: Vector2, width: float, depth: int) -> void:
	if _contact_shadow == null:
		var falloff := Gradient.new()
		falloff.colors = PackedColorArray([Color(0.12, 0.10, 0.14, 0.38), Color(0.12, 0.10, 0.14, 0.0)])
		_contact_shadow = GradientTexture2D.new()
		_contact_shadow.gradient = falloff
		_contact_shadow.fill = GradientTexture2D.FILL_RADIAL
		_contact_shadow.fill_from = Vector2(0.5, 0.5)
		_contact_shadow.fill_to = Vector2(0.5, 0.0)

	var shadow := Sprite2D.new()
	shadow.texture = _contact_shadow
	shadow.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	shadow.position = position
	shadow.scale = Vector2(width * 0.93, width * 0.22) / _contact_shadow.get_size()
	shadow.z_index = depth
	parent.add_child(shadow)
