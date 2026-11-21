extends Node2D
class_name VfxEffect

## Plays one effect and returns it to the owning battle when finished.

signal finished(effect: VfxEffect)

var _sprite: Sprite2D
var _total_frames: int = 1
var _fps: float = 18.0
var _frame_accum: float = 0.0
var _frame_idx: int = 0
var _loop_duration: float = 0.0
var _elapsed: float = 0.0
var _velocity: Vector2 = Vector2.ZERO


func setup(
	texture: Texture2D,
	grid: Vector2i,
	fps: float = 18.0,
	target_scale: float = 0.85,
	loop_duration: float = 0.0,
	velocity: Vector2 = Vector2.ZERO,
	modulate_color: Color = Color.WHITE
) -> void:
	_fps = maxf(1.0, fps)
	_loop_duration = loop_duration
	_velocity = velocity
	_frame_accum = 0.0
	_frame_idx = 0
	_elapsed = 0.0
	if _sprite == null:
		_sprite = Sprite2D.new()
		add_child(_sprite)
	_sprite.texture = texture
	_sprite.hframes = maxi(1, grid.x)
	_sprite.vframes = maxi(1, grid.y)
	_sprite.frame = 0
	_sprite.scale = Vector2(target_scale, target_scale)
	_sprite.modulate = modulate_color
	_total_frames = _sprite.hframes * _sprite.vframes
	show()
	set_process(true)


func _process(delta: float) -> void:
	_elapsed += delta
	if _velocity != Vector2.ZERO:
		position += _velocity * delta
	if _loop_duration > 0.0 and _elapsed >= _loop_duration:
		_finish()
		return
	_frame_accum += delta * _fps
	while _frame_accum >= 1.0:
		_frame_accum -= 1.0
		_frame_idx += 1
		if _frame_idx >= _total_frames:
			if _loop_duration > 0.0:
				_frame_idx = 0
			else:
				_finish()
				return
		if _sprite:
			_sprite.frame = _frame_idx


func _finish() -> void:
	hide()
	set_process(false)
	finished.emit(self)
