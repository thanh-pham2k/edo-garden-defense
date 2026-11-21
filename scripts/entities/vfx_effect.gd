extends Node2D
class_name VfxEffect

## Plays a sprite-sheet VFX once or for a fixed loop duration, then frees itself.

var _sprite: Sprite2D
var _total_frames: int = 1
var _fps: float = 18.0
var _frame_accum: float = 0.0
var _frame_idx: int = 0
var _loop_duration: float = 0.0
var _elapsed: float = 0.0
var _velocity: Vector2 = Vector2.ZERO


func setup(
	tex_path: String,
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
	_sprite = Sprite2D.new()
	var tex := load(tex_path) as Texture2D
	_sprite.texture = tex
	_sprite.hframes = maxi(1, grid.x)
	_sprite.vframes = maxi(1, grid.y)
	_sprite.frame = 0
	_sprite.scale = Vector2(target_scale, target_scale)
	_sprite.modulate = modulate_color
	add_child(_sprite)
	_total_frames = _sprite.hframes * _sprite.vframes


func _process(delta: float) -> void:
	_elapsed += delta
	if _velocity != Vector2.ZERO:
		position += _velocity * delta
	if _loop_duration > 0.0 and _elapsed >= _loop_duration:
		queue_free()
		return
	_frame_accum += delta * _fps
	while _frame_accum >= 1.0:
		_frame_accum -= 1.0
		_frame_idx += 1
		if _frame_idx >= _total_frames:
			if _loop_duration > 0.0:
				_frame_idx = 0
			else:
				queue_free()
				return
		if _sprite:
			_sprite.frame = _frame_idx
