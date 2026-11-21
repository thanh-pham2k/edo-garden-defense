extends Node

## Keeps continuous scene audio and limits one-shot playback in real time.

const SAMPLE_RATE := 22050
const POOL_SIZE := 10
const QUIT_AUDIO_DRAIN_SECONDS := 0.1
const MIX := {
	"ui": Vector3(-15, 2, 65),
	"attack": Vector3(-23, 3, 85),
	"hit": Vector3(-25, 1, 100),
	"magic": Vector3(-19, 2, 110),
	"important": Vector3(-12, 2, 220),
}
const FAST_COMBAT_INTERVAL_MS := {
	"attack": 125,
	"hit": 140,
	"magic": 150,
}

var muted: bool = false
var _sfx_streams: Dictionary = {}
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_rng := RandomNumberGenerator.new()
var _last_stream_play_ms: Dictionary[AudioStream, int] = {}
var _last_group_play_ms: Dictionary[String, int] = {}
var _bgm_player: AudioStreamPlayer
var _ambience_player: AudioStreamPlayer
var _ambience_db := -19.0
var _ambience_fade: Tween
var _is_headless: bool = false
var _closing := false


func _ready() -> void:
	_is_headless = DisplayServer.get_name() == "headless"
	process_mode = Node.PROCESS_MODE_ALWAYS
	_init_pool()
	_build_sfx_bank()
	_bgm_player.stream = _load_loop("res://assets/audio/koto_garden.ogg")
	_ambience_player.stream = _load_loop("res://assets/audio/bamboo_stream.ogg")
	set_muted(GameData.sound_muted)
	if OS.has_feature("pc") and not _is_headless:
		get_tree().auto_accept_quit = false
		get_tree().root.close_requested.connect(_on_close_requested)


func _on_close_requested() -> void:
	if _closing:
		return
	set_muted(true)
	_closing = true
	var tree := get_tree()
	tree.paused = true
	# The mixer releases stopped playback on its audio thread.
	await tree.create_timer(QUIT_AUDIO_DRAIN_SECONDS, true, false, true).timeout
	tree.quit()


func _exit_tree() -> void:
	_stop_audio()
	_bgm_player.stream = null
	_ambience_player.stream = null
	for player in _sfx_pool:
		player.stream = null
	_sfx_streams.clear()


func _init_pool() -> void:
	for i in range(POOL_SIZE):
		var player := AudioStreamPlayer.new()
		add_child(player)
		_sfx_pool.append(player)
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.volume_db = -12.0
	add_child(_bgm_player)
	_ambience_player = AudioStreamPlayer.new()
	_ambience_player.volume_db = _ambience_db
	add_child(_ambience_player)


func _load_loop(path: String) -> AudioStreamOggVorbis:
	var loop := load(path) as AudioStreamOggVorbis
	loop.loop = true
	return loop


func _stop_audio() -> void:
	_bgm_player.stop()
	_ambience_player.stop()
	_stop_sfx()


func _stop_sfx() -> void:
	for player in _sfx_pool:
		player.stop()
	_last_stream_play_ms.clear()
	_last_group_play_ms.clear()


func set_muted(value: bool) -> void:
	if _closing:
		return
	muted = value
	if muted:
		_stop_audio()
	else:
		_refresh_layers()


func set_layer_enabled(layer: String, enabled: bool) -> void:
	GameData.audio_layers[layer] = enabled
	if layer == "sfx" and not enabled:
		_stop_sfx()
	_refresh_layers()
	GameData.save_progress()


func _refresh_layers() -> void:
	if muted or _is_headless:
		return
	_refresh_loop(_bgm_player, GameData.audio_layers["music"])
	_refresh_loop(_ambience_player, GameData.audio_layers["ambience"])


func _refresh_loop(player: AudioStreamPlayer, enabled: bool) -> void:
	if enabled and not player.playing:
		player.play()
	elif not enabled and player.playing:
		player.stop()


func start_bgm(chapter: int = 0) -> void:
	_refresh_layers()
	var target_db := float([-19, -19, -17, -16, -23, -25][clampi(chapter, 0, 5)])
	if is_equal_approx(target_db, _ambience_db):
		return
	_ambience_db = target_db
	if _ambience_fade:
		_ambience_fade.kill()
	_ambience_fade = create_tween().set_ignore_time_scale(true)
	_ambience_fade.tween_property(_ambience_player, "volume_db", target_db, 1.4)


func _sfx_group(sfx_name: String) -> String:
	match sfx_name:
		"ui_click", "shovel", "plant":
			return "ui"
		"shoot_petal", "shoot_dart", "shoot_ice", "poison_puff", "wind_gust":
			return "attack"
		"hit", "enemy_die":
			return "hit"
		"victory", "defeat", "wave_horn", "temple_bell", "komainu_roar":
			return "important"
		_:
			return "magic"


func play_sfx(sfx_name: String, volume_db: float = -6.0, pitch_jitter: float = 0.04) -> void:
	if muted or _is_headless or not GameData.audio_layers["sfx"]:
		return
	var stream: AudioStream = _sfx_streams.get(sfx_name)
	if stream == null:
		return
	var group := _sfx_group(sfx_name)
	var mix: Vector3 = MIX[group]
	var now := Time.get_ticks_msec()
	if now - _last_stream_play_ms.get(stream, -10000) < int(mix.z):
		return
	if Engine.time_scale >= 5.0:
		var interval: int = FAST_COMBAT_INTERVAL_MS.get(group, 0)
		if now - _last_group_play_ms.get(group, -10000) < interval:
			return

	var free_player: AudioStreamPlayer = null
	var low_priority_player: AudioStreamPlayer = null
	var announcement_player: AudioStreamPlayer = null
	var active_count := 0
	for player in _sfx_pool:
		if not player.playing:
			free_player = player
			continue
		var active_group: String = player.get_meta("category", "")
		if active_group == group:
			active_count += 1
		if active_group == "important":
			announcement_player = player
		if active_group == "hit" or active_group == "attack":
			low_priority_player = player
	if active_count >= int(mix.y):
		if sfx_name not in ["victory", "defeat"]:
			return
		free_player = announcement_player
	if free_player == null and group == "important":
		free_player = low_priority_player
	if free_player == null:
		return

	_last_stream_play_ms[stream] = now
	_last_group_play_ms[group] = now
	free_player.stop()
	free_player.set_meta("category", group)
	free_player.stream = stream
	free_player.volume_db = mix.x + clampf((volume_db + 6.0) * 0.35, -4.0, 3.0) + _sfx_rng.randf_range(-1.0, 1.0)
	free_player.pitch_scale = 1.0 + _sfx_rng.randf_range(-pitch_jitter, pitch_jitter)
	free_player.play()


func _make_wav(samples: PackedFloat32Array, loop: bool = false) -> AudioStreamWAV:
	var pcm := PackedByteArray()
	pcm.resize(samples.size() * 2)
	for i in range(samples.size()):
		var v := int(clampf(samples[i], -1.0, 1.0) * 32767.0)
		pcm.encode_s16(i * 2, v)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.data = pcm
	if loop:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = samples.size()
	return wav


func _synth_tone(freq_start: float, freq_end: float, duration: float, wave: String = "sine", decay: float = 6.0, amp: float = 0.45) -> PackedFloat32Array:
	var count := maxi(1, int(duration * SAMPLE_RATE))
	var buf := PackedFloat32Array()
	buf.resize(count)
	var phase := 0.0
	for i in range(count):
		var t := float(i) / float(SAMPLE_RATE)
		var u := float(i) / float(count)
		var f := lerpf(freq_start, freq_end, u)
		phase += TAU * f / float(SAMPLE_RATE)
		var env := exp(-decay * u) * minf(1.0, t * 120.0)
		var s := 0.0
		match wave:
			"koto":
				s = sin(phase) * 0.65 + sin(phase * 2.0) * 0.25 + sin(phase * 3.0) * 0.1
			"triangle":
				s = 2.0 * absf(2.0 * (phase / TAU - floorf(phase / TAU + 0.5))) - 1.0
			"noise":
				s = _sfx_rng.randf_range(-1.0, 1.0)
			_:
				s = sin(phase)
		buf[i] = s * env * amp
	return buf


func _concat_tones(parts: Array[PackedFloat32Array]) -> PackedFloat32Array:
	var total := 0
	for p in parts:
		total += p.size()
	var out := PackedFloat32Array()
	out.resize(total)
	var offset := 0
	for p in parts:
		for i in range(p.size()):
			out[offset + i] = p[i]
		offset += p.size()
	return out


func _build_sfx_bank() -> void:
	_sfx_streams["plant"] = _make_wav(_synth_tone(240.0, 420.0, 0.14, "koto", 6.0, 0.48))
	_sfx_streams["shovel"] = _make_wav(_synth_tone(320.0, 140.0, 0.14, "triangle", 7.0, 0.42))
	_sfx_streams["collect_flame"] = _make_wav(_concat_tones([
		_synth_tone(587.3, 659.2, 0.07, "koto", 5.0, 0.42),
		_synth_tone(880.0, 987.7, 0.12, "koto", 6.0, 0.42),
	]))
	_sfx_streams["shoot_dart"] = preload("res://assets/audio/stick_whoosh.ogg")
	_sfx_streams["stun_chime"] = _make_wav(_concat_tones([
		_synth_tone(1046.5, 1046.5, 0.08, "koto", 6.0, 0.4),
		_synth_tone(1318.5, 1318.5, 0.16, "koto", 5.0, 0.4),
	]))
	_sfx_streams["wind_gust"] = _make_wav(_synth_tone(380.0, 620.0, 0.32, "noise", 3.5, 0.38))
	_sfx_streams["heal_chime"] = _make_wav(_concat_tones([
		_synth_tone(523.25, 523.25, 0.09, "sine", 4.0, 0.35),
		_synth_tone(659.25, 659.25, 0.09, "sine", 4.0, 0.35),
		_synth_tone(783.99, 783.99, 0.16, "sine", 5.0, 0.35),
	]))
	_sfx_streams["komainu_roar"] = _make_wav(_concat_tones([
		_synth_tone(220.0, 440.0, 0.18, "triangle", 3.5, 0.55),
		_synth_tone(440.0, 660.0, 0.28, "koto", 4.0, 0.5),
	]))
	_sfx_streams["wave_horn"] = _make_wav(_synth_tone(196.0, 293.66, 0.55, "triangle", 2.5, 0.48))
	_sfx_streams["temple_bell"] = preload("res://assets/audio/temple_bell.ogg")
	_sfx_streams["victory"] = _make_wav(_concat_tones([
		_synth_tone(523.25, 523.25, 0.12, "koto", 4.0, 0.45),
		_synth_tone(659.25, 659.25, 0.12, "koto", 4.0, 0.45),
		_synth_tone(783.99, 783.99, 0.14, "koto", 4.0, 0.45),
		_synth_tone(1046.5, 1046.5, 0.34, "koto", 3.0, 0.5),
	]))
	_sfx_streams["defeat"] = _make_wav(_concat_tones([
		_synth_tone(392.0, 392.0, 0.18, "koto", 3.5, 0.45),
		_synth_tone(349.23, 349.23, 0.18, "koto", 3.5, 0.45),
		_synth_tone(293.66, 220.0, 0.42, "koto", 3.0, 0.45),
	]))

	var wood := preload("res://assets/audio/wood_click.ogg")
	var whoosh := preload("res://assets/audio/magic_whoosh.ogg")
	var hit := preload("res://assets/audio/soft_hit.ogg")
	var puff := preload("res://assets/audio/soft_puff.ogg")
	_sfx_streams["ui_click"] = wood
	_sfx_streams["shoot_petal"] = whoosh
	_sfx_streams["shoot_ice"] = whoosh
	_sfx_streams["poison_puff"] = whoosh
	_sfx_streams["hit"] = hit
	_sfx_streams["enemy_die"] = puff
	_sfx_streams["explosion"] = puff
