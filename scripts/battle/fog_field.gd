extends ColorRect

## A tiny shared opacity field drives both fog artwork and enemy visibility.
const MASK_SIZE := Vector2i(60, 36)
const UPDATE_INTERVAL := 1.0 / 20.0
const WIND_SECONDS := 11.0
const SHADER := preload("res://assets/shaders/battlefield_fog.gdshader")

var _stage: Dictionary
var _mask := PackedByteArray()
var _base := PackedByteArray()
var _light := PackedByteArray()
var _image: Image
var _texture: ImageTexture
var _shader: ShaderMaterial
var _stationary: Array[Node2D] = []
var _projectiles: Array[Node2D] = []
var _wind := PackedFloat32Array()
var _elapsed := 0.0
var _elapsed_real := 0.0
var _resting := true
var _time := 0.0


func setup(stage: Dictionary, scene_width: float) -> void:
	_stage = stage
	var right := GameData.GRID_ORIGIN.x + GameData.CELL_SIZE.x * GameData.GRID_COLS
	var start := right - GameData.CELL_SIZE.x * float(stage["columns"])
	position = Vector2(start - 36.0, GameData.GRID_ORIGIN.y - 53.0)
	size = Vector2(scene_width - position.x + 150.0, GameData.CELL_SIZE.y * GameData.GRID_ROWS + 90.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 14

	_mask.resize(MASK_SIZE.x * MASK_SIZE.y)
	_base.resize(_mask.size())
	_light.resize(_mask.size())
	_wind.resize(GameData.GRID_ROWS)
	for y in MASK_SIZE.y:
		for x in MASK_SIZE.x:
			var world_x := position.x + (x + 0.5) * size.x / MASK_SIZE.x
			var density := smoothstep(start - 30.0, start + 82.0, world_x) * float(stage["opacity"])
			_base[y * MASK_SIZE.x + x] = roundi(density * 255.0)
	_mask = _base.duplicate()
	_image = Image.create_from_data(MASK_SIZE.x, MASK_SIZE.y, false, Image.FORMAT_L8, _mask)
	_texture = ImageTexture.create_from_image(_image)
	_shader = ShaderMaterial.new()
	_shader.shader = SHADER
	_shader.set_shader_parameter("opacity_map", _texture)
	if stage.has("tint"):
		_shader.set_shader_parameter("fog_tint", stage["tint"])
	material = _shader


func track_light(unit: Node2D) -> void:
	_stationary.append(unit)
	_resting = false


func track_projectile(projectile: Node2D) -> void:
	_projectiles.append(projectile)
	_resting = false


func disperse(lane: int) -> void:
	if lane >= 0 and lane < _wind.size():
		_wind[lane] = WIND_SECONDS
		_resting = false


func advance(delta: float, real_delta: float) -> void:
	_time += real_delta
	_shader.set_shader_parameter("fog_time", _time)
	if _resting:
		return
	_elapsed += delta
	_elapsed_real += real_delta
	for row in _wind.size():
		_wind[row] = maxf(0.0, _wind[row] - delta)
	if _elapsed_real < UPDATE_INTERVAL:
		return
	_rebuild(_elapsed)
	_elapsed = 0.0
	_elapsed_real = fposmod(_elapsed_real, UPDATE_INTERVAL)


func opacity_at(world_position: Vector2) -> float:
	var uv := (world_position - position) / size
	if uv.x < 0.0 or uv.y < 0.0 or uv.y >= 1.0:
		return 0.0
	var sample := uv.clampf(0.0, 1.0) * Vector2(MASK_SIZE) - Vector2(0.5, 0.5)
	var x := clampi(floori(sample.x), 0, MASK_SIZE.x - 1)
	var y := clampi(floori(sample.y), 0, MASK_SIZE.y - 1)
	var next_x := mini(x + 1, MASK_SIZE.x - 1)
	var next_y := mini(y + 1, MASK_SIZE.y - 1)
	var fx := clampf(sample.x - x, 0.0, 1.0)
	var fy := clampf(sample.y - y, 0.0, 1.0)
	var top := lerpf(_mask[y * MASK_SIZE.x + x], _mask[y * MASK_SIZE.x + next_x], fx)
	var bottom := lerpf(_mask[next_y * MASK_SIZE.x + x], _mask[next_y * MASK_SIZE.x + next_x], fx)
	return lerpf(top, bottom, fy) / 255.0


func _rebuild(delta: float) -> void:
	_light.fill(0)
	for i in range(_stationary.size() - 1, -1, -1):
		var unit := _stationary[i]
		if not is_instance_valid(unit) or unit.is_queued_for_deletion() or unit.is_consuming:
			_stationary.remove_at(i)
			continue
		_stamp(unit.position, unit.light_cells * GameData.CELL_SIZE, unit.defender_id == "den_soi_yeu")
	for i in range(_projectiles.size() - 1, -1, -1):
		var projectile := _projectiles[i]
		if not is_instance_valid(projectile) or projectile.is_queued_for_deletion():
			_projectiles.remove_at(i)
			continue
		# A short illuminated wake trails the moving fireball.
		_stamp(projectile.position + Vector2(-26.0, 8.0), GameData.CELL_SIZE * Vector2(1.22, 0.82))
	var changed := false
	for y in MASK_SIZE.y:
		var world_y := position.y + (y + 0.5) * size.y / MASK_SIZE.y
		var wind := 0.0
		for row in _wind.size():
			if _wind[row] > 0.0:
				var distance := absf(world_y - GameData.cell_to_world(row, 0).y) / GameData.CELL_SIZE.y
				wind = maxf(wind, 1.0 - smoothstep(1.20, 1.66, distance))
		var wind_clear := roundi(wind * 255)
		for x in MASK_SIZE.x:
			var i := y * MASK_SIZE.x + x
			var target := float(_base[i]) * (1.0 - maxi(_light[i], wind_clear) / 255.0)
			var previous := _mask[i]
			var duration: float = _stage["transition"] if target < previous else _stage["recovery"]
			var step := 255.0 * delta / maxf(duration, 0.05)
			var next := roundi(move_toward(previous, target, step))
			if next != previous:
				changed = true
				_mask[i] = next
	if not changed and _stationary.is_empty() and _projectiles.is_empty() and _wind.count(0.0) == _wind.size():
		_resting = true
	if changed:
		_image.set_data(MASK_SIZE.x, MASK_SIZE.y, false, Image.FORMAT_L8, _mask)
		_texture.update(_image)


func _stamp(center: Vector2, radius: Vector2, box: bool = false) -> void:
	var pixel := size / Vector2(MASK_SIZE)
	var start := Vector2i(((center - radius - position) / pixel).floor()).clamp(Vector2i.ZERO, MASK_SIZE)
	var end := Vector2i(((center + radius - position) / pixel).ceil()).clamp(Vector2i.ZERO, MASK_SIZE)
	for y in range(start.y, end.y):
		var dy := absf((position.y + (y + 0.5) * pixel.y - center.y) / radius.y)
		for x in range(start.x, end.x):
			var dx := absf((position.x + (x + 0.5) * pixel.x - center.x) / radius.x)
			var distance := maxf(dx, dy) if box else sqrt(dx * dx + dy * dy)
			var value := roundi((1.0 - smoothstep(0.82, 1.0, distance)) * 255.0)
			var i := y * MASK_SIZE.x + x
			_light[i] = maxi(_light[i], value)
