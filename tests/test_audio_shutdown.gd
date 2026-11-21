extends SceneTree

## Run with an active audio driver. Inspect the engine log for shutdown warnings.

func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var audio := root.get_node("AudioManager")
	var data := root.get_node("GameData")
	if not OS.has_feature("pc") or DisplayServer.get_name() == "headless":
		push_error("The shutdown test requires a desktop window and audio driver.")
		quit(1)
		return

	Engine.time_scale = 5.0
	data.audio_layers = {"music": true, "ambience": true, "sfx": true}
	audio.set_muted(false)
	audio.start_bgm(5)
	await create_timer(0.1, true, false, true).timeout
	for cue in ["plant", "wind_gust", "heal_chime", "wave_horn", "komainu_roar", "victory"]:
		audio.play_sfx(cue)

	var args := OS.get_cmdline_user_args()
	if not args.is_empty():
		await create_timer(args[0].to_float(), true, false, true).timeout

	var has_active_sfx: bool = audio._sfx_pool.any(func(player): return player.playing)
	if not (audio._bgm_player.playing and audio._ambience_player.playing and has_active_sfx):
		push_error("Expected both loops and an active effect when closing the game.")
		quit(1)
		return

	print("Closing at 5× with both audio loops and active effects.")
	root.close_requested.emit()
	root.close_requested.emit()
	await create_timer(0.5, true, false, true).timeout
	push_error("The close request did not exit the game.")
	quit(1)
