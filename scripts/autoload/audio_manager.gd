extends Node

## Procedural Edo-themed audio manager generating lightweight PCM AudioStreamWAV
## assets in memory so WebGL 2 and mobile builds require zero external audio files.

const SAMPLE_RATE := 22050
const POOL_SIZE := 10

var muted: bool = false
var _sfx_streams: Dictionary = {}
var _sfx_pool: Array[AudioStreamPlayer] = []
var _pool_idx: int = 0
var _bgm_player: AudioStreamPlayer
var _is_headless: bool = false


func _ready() -> void:
	_is_headless = DisplayServer.get_name() == "headless"
	process_mode = Node.PROCESS_MODE_ALWAYS
	_init_pool()
	_build_sfx_bank()
	_build_bgm()
	if GameData:
		set_muted(GameData.sound_muted)


func _init_pool() -> void:
	for i in range(POOL_SIZE):
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_sfx_pool.append(p)
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.bus = "Master"
	_bgm_player.volume_db = -14.0
	add_child(_bgm_player)


func set_muted(value: bool) -> void:
	muted = value
	if _bgm_player:
		if muted and _bgm_player.playing:
			_bgm_player.stop()
		elif not muted and not _is_headless and _bgm_player.stream and not _bgm_player.playing:
			_bgm_player.play()


func start_bgm() -> void:
	if _is_headless or muted:
		return
	if _bgm_player and _bgm_player.stream and not _bgm_player.playing:
		_bgm_player.play()


func play_sfx(sfx_name: String, volume_db: float = -6.0, pitch_jitter: float = 0.06) -> void:
	if muted or _is_headless:
		return
	var stream: AudioStreamWAV = _sfx_streams.get(sfx_name)
	if stream == null:
		return
	var player := _sfx_pool[_pool_idx]
	_pool_idx = (_pool_idx + 1) % POOL_SIZE
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = randf_range(1.0 - pitch_jitter, 1.0 + pitch_jitter) if pitch_jitter > 0.0 else 1.0
	player.play()


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
				s = randf_range(-1.0, 1.0)
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
	_sfx_streams["ui_click"] = _make_wav(_synth_tone(660.0, 880.0, 0.07, "koto", 9.0, 0.35))
	_sfx_streams["plant"] = _make_wav(_synth_tone(240.0, 420.0, 0.14, "koto", 6.0, 0.48))
	_sfx_streams["shovel"] = _make_wav(_synth_tone(320.0, 140.0, 0.14, "triangle", 7.0, 0.42))
	_sfx_streams["collect_flame"] = _make_wav(_concat_tones([
		_synth_tone(587.3, 659.2, 0.07, "koto", 5.0, 0.42),
		_synth_tone(880.0, 987.7, 0.12, "koto", 6.0, 0.42),
	]))
	_sfx_streams["shoot_petal"] = _make_wav(_synth_tone(780.0, 520.0, 0.08, "sine", 8.0, 0.28))
	_sfx_streams["shoot_dart"] = _make_wav(_synth_tone(920.0, 340.0, 0.07, "triangle", 9.0, 0.3))
	_sfx_streams["shoot_ice"] = _make_wav(_synth_tone(1100.0, 660.0, 0.11, "koto", 7.0, 0.32))
	_sfx_streams["poison_puff"] = _make_wav(_synth_tone(240.0, 110.0, 0.18, "noise", 5.0, 0.3))
	_sfx_streams["explosion"] = _make_wav(_synth_tone(120.0, 36.0, 0.45, "noise", 4.0, 0.65))
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
	_sfx_streams["hit"] = _make_wav(_synth_tone(260.0, 120.0, 0.07, "triangle", 10.0, 0.28))
	_sfx_streams["enemy_die"] = _make_wav(_synth_tone(420.0, 160.0, 0.18, "koto", 6.0, 0.38))
	_sfx_streams["komainu_roar"] = _make_wav(_concat_tones([
		_synth_tone(220.0, 440.0, 0.18, "triangle", 3.5, 0.55),
		_synth_tone(440.0, 660.0, 0.28, "koto", 4.0, 0.5),
	]))
	_sfx_streams["wave_horn"] = _make_wav(_synth_tone(196.0, 293.66, 0.55, "triangle", 2.5, 0.48))
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


func _build_bgm() -> void:
	# Japanese Yo-scale pentatonic melody (D4, E4, G4, A4, B4, D5)
	var notes := [
		293.66, 392.00, 440.00, 392.00, 329.63, 293.66, 392.00, 493.88,
		587.33, 493.88, 440.00, 392.00, 329.63, 392.00, 293.66, 293.66,
	]
	var step_dur := 0.42
	var total := int(notes.size() * step_dur * SAMPLE_RATE)
	var buf := PackedFloat32Array()
	buf.resize(total)

	for idx in range(notes.size()):
		var note := _synth_tone(notes[idx], notes[idx], step_dur, "koto", 4.5, 0.24)
		var start := int(idx * step_dur * SAMPLE_RATE)
		for i in range(note.size()):
			if start + i < total:
				buf[start + i] += note[i]
		# Gentle taiko beat on even steps
		if idx % 2 == 0:
			var drum := _synth_tone(92.0, 48.0, 0.18, "sine", 7.0, 0.22)
			for i in range(drum.size()):
				if start + i < total:
					buf[start + i] += drum[i]

	_bgm_player.stream = _make_wav(buf, true)
