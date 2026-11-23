extends Node

## Asynchronous non-blocking Turso (libSQL HTTP v2 pipeline) cloud state sync.
## Keeps local user://edo_save.json authoritative offline and merges safely on pull.

signal remote_progress_loaded(data: Dictionary)
signal sync_completed(ok: bool, kind: String)

const CONFIG_PATH := "res://cloud_config.cfg"
const SYNC_DEBOUNCE_SEC := 0.6

var allow_in_headless: bool = false

var _base_url: String = ""
var _auth_token: String = ""
var _is_headless: bool = false
var _http: HTTPRequest
var _debounce_timer: Timer
var _pending_sync_snapshot: Dictionary = {}
var _queue: Array[Dictionary] = []
var _in_flight: bool = false
var _active_item: Dictionary = {}


func _ready() -> void:
	_is_headless = DisplayServer.get_name() == "headless"
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_credentials()

	_http = HTTPRequest.new()
	_http.timeout = 10.0
	_http.request_completed.connect(_on_request_completed)
	add_child(_http)

	_debounce_timer = Timer.new()
	_debounce_timer.one_shot = true
	_debounce_timer.wait_time = SYNC_DEBOUNCE_SEC
	_debounce_timer.timeout.connect(_on_debounce_timeout)
	add_child(_debounce_timer)


func _load_credentials() -> void:
	var cfg := ConfigFile.new()
	if ResourceLoader.exists(CONFIG_PATH) or FileAccess.file_exists(CONFIG_PATH):
		if cfg.load(CONFIG_PATH) == OK:
			_base_url = str(cfg.get_value("turso", "url", ""))
			_auth_token = str(cfg.get_value("turso", "auth_token", ""))
	if _base_url.is_empty():
		_base_url = OS.get_environment("TURSO_URL")
	if _auth_token.is_empty():
		_auth_token = OS.get_environment("TURSO_AUTH_TOKEN")
	_base_url = _normalize_url(_base_url)


func _normalize_url(raw: String) -> String:
	var cleaned := raw.strip_edges()
	if cleaned.begins_with("libsql://"):
		cleaned = "https://" + cleaned.substr(9)
	while cleaned.ends_with("/"):
		cleaned = cleaned.left(cleaned.length() - 1)
	return cleaned


func is_configured() -> bool:
	return not _base_url.is_empty() and not _auth_token.is_empty()


func _can_network() -> bool:
	if _is_headless and not allow_in_headless:
		return false
	return is_configured() and is_inside_tree()


func pull_progress(player_id: String) -> void:
	if not _can_network() or player_id.is_empty():
		return
	var reqs := [
		{
			"type": "execute",
			"stmt": {
				"sql": """
					SELECT player_id, unlocked_level, jade_gems, level_stars_json,
					       selected_deck_json, previous_deck_json, unlocked_upgrades_json,
					       settings_json, updated_at
					FROM player_progress
					WHERE player_id = ?
					LIMIT 1;
				""".strip_edges(),
				"args": [_arg_text(player_id)],
			},
		},
		{"type": "close"},
	]
	_enqueue({"kind": "pull", "requests": reqs, "player_id": player_id})


func sync_progress(snapshot: Dictionary) -> void:
	if not _can_network() or str(snapshot.get("player_id", "")).is_empty():
		return
	_pending_sync_snapshot = snapshot.duplicate(true)
	_debounce_timer.start()


func _on_debounce_timeout() -> void:
	if _pending_sync_snapshot.is_empty() or not _can_network():
		return
	var snap := _pending_sync_snapshot.duplicate(true)
	_pending_sync_snapshot.clear()
	var reqs := [
		_upsert_progress_stmt(snap),
		{"type": "close"},
	]
	_enqueue({"kind": "sync", "requests": reqs})


func record_level_completion(
	snapshot: Dictionary,
	level_id: int,
	level_name: String,
	stars: int,
	jade_reward: int,
	deck: Array
) -> void:
	if not _can_network():
		return
	var pid := str(snapshot.get("player_id", ""))
	if pid.is_empty():
		return
	# Clear any older debounced sync since this batch already persists the latest progress snapshot.
	_pending_sync_snapshot.clear()
	_debounce_timer.stop()
	var completed_at := int(snapshot.get("updated_at", Time.get_unix_time_from_system()))
	var reqs := [
		{
			"type": "execute",
			"stmt": {
				"sql": """
					INSERT INTO level_completions
						(player_id, level_id, level_name, stars, jade_reward, deck_json, completed_at)
					VALUES (?, ?, ?, ?, ?, ?, ?);
				""".strip_edges(),
				"args": [
					_arg_text(pid),
					_arg_int(level_id),
					_arg_text(level_name),
					_arg_int(stars),
					_arg_int(jade_reward),
					_arg_text(JSON.stringify(deck)),
					_arg_int(completed_at),
				],
			},
		},
		_upsert_progress_stmt(snapshot),
		{"type": "close"},
	]
	_enqueue({"kind": "completion", "requests": reqs})


func _upsert_progress_stmt(snapshot: Dictionary) -> Dictionary:
	var settings := {
		"auto_collect_flame": bool(snapshot.get("auto_collect_flame", true)),
		"sound_muted": bool(snapshot.get("sound_muted", false)),
		"audio_layers": snapshot.get("audio_layers", {"music": true, "ambience": true, "sfx": true}),
	}
	return {
		"type": "execute",
		"stmt": {
			"sql": """
				INSERT INTO player_progress (
					player_id, unlocked_level, jade_gems, level_stars_json,
					selected_deck_json, previous_deck_json, unlocked_upgrades_json,
					settings_json, updated_at
				) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
				ON CONFLICT(player_id) DO UPDATE SET
					unlocked_level = excluded.unlocked_level,
					jade_gems = excluded.jade_gems,
					level_stars_json = excluded.level_stars_json,
					selected_deck_json = excluded.selected_deck_json,
					previous_deck_json = excluded.previous_deck_json,
					unlocked_upgrades_json = excluded.unlocked_upgrades_json,
					settings_json = excluded.settings_json,
					updated_at = excluded.updated_at;
			""".strip_edges(),
			"args": [
				_arg_text(str(snapshot.get("player_id", ""))),
				_arg_int(int(snapshot.get("unlocked_level", 1))),
				_arg_int(int(snapshot.get("jade_gems", 15))),
				_arg_text(JSON.stringify(snapshot.get("level_stars", {}))),
				_arg_text(JSON.stringify(snapshot.get("selected_deck", []))),
				_arg_text(JSON.stringify(snapshot.get("previous_deck", []))),
				_arg_text(JSON.stringify(snapshot.get("unlocked_upgrades", []))),
				_arg_text(JSON.stringify(settings)),
				_arg_int(int(snapshot.get("updated_at", Time.get_unix_time_from_system()))),
			],
		},
	}


func _enqueue(item: Dictionary) -> void:
	if item.get("kind", "") == "sync":
		for i in range(_queue.size() - 1, -1, -1):
			if _queue[i].get("kind", "") == "sync":
				_queue.remove_at(i)
	_queue.append(item)
	_drain_queue()


func _drain_queue() -> void:
	if _in_flight or _queue.is_empty() or not _can_network():
		return
	_active_item = _queue.pop_front()
	_in_flight = true
	var endpoint := "%s/v2/pipeline" % _base_url
	var headers := PackedStringArray([
		"Authorization: Bearer %s" % _auth_token,
		"Content-Type: application/json",
	])
	var payload := JSON.stringify({"requests": _active_item["requests"]})
	var err := _http.request(endpoint, headers, HTTPClient.METHOD_POST, payload)
	if err != OK:
		var kind := str(_active_item.get("kind", ""))
		_in_flight = false
		_active_item.clear()
		sync_completed.emit(false, kind)
		_drain_queue()


func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var item := _active_item
	var kind := str(item.get("kind", ""))
	_in_flight = false
	_active_item = {}

	var ok := result == HTTPRequest.RESULT_SUCCESS and response_code >= 200 and response_code < 300
	var parsed: Variant = null
	if ok:
		parsed = JSON.parse_string(body.get_string_from_utf8())
		if typeof(parsed) != TYPE_DICTIONARY:
			ok = false
		else:
			for res in parsed.get("results", []):
				if typeof(res) == TYPE_DICTIONARY and res.get("type", "") == "error":
					ok = false
					push_warning("CloudSync %s error: %s" % [kind, str(res.get("error", {}))])
					break

	if ok and kind == "pull":
		var remote := _extract_progress_row(parsed)
		if not remote.is_empty():
			remote_progress_loaded.emit(remote)

	sync_completed.emit(ok, kind)
	_drain_queue()


func _extract_progress_row(pipeline_resp: Dictionary) -> Dictionary:
	var results: Array = pipeline_resp.get("results", [])
	if results.is_empty() or typeof(results[0]) != TYPE_DICTIONARY:
		return {}
	var exec_res: Dictionary = results[0].get("response", {}).get("result", {})
	var cols: Array = exec_res.get("cols", [])
	var rows: Array = exec_res.get("rows", [])
	if cols.is_empty() or rows.is_empty() or typeof(rows[0]) != TYPE_ARRAY:
		return {}
	var raw_map: Dictionary = {}
	var row: Array = rows[0]
	for i in range(mini(cols.size(), row.size())):
		var col_name := str(cols[i].get("name", ""))
		var cell: Dictionary = row[i] if typeof(row[i]) == TYPE_DICTIONARY else {}
		raw_map[col_name] = _decode_cell(cell)

	var out := {
		"player_id": str(raw_map.get("player_id", "")),
		"unlocked_level": int(raw_map.get("unlocked_level", 1)),
		"jade_gems": int(raw_map.get("jade_gems", 15)),
		"updated_at": int(raw_map.get("updated_at", 0)),
	}
	var stars_v = JSON.parse_string(str(raw_map.get("level_stars_json", "{}")))
	if typeof(stars_v) == TYPE_DICTIONARY:
		out["level_stars"] = stars_v
	var sel_v = JSON.parse_string(str(raw_map.get("selected_deck_json", "[]")))
	if typeof(sel_v) == TYPE_ARRAY:
		out["selected_deck"] = sel_v
	var prev_v = JSON.parse_string(str(raw_map.get("previous_deck_json", "[]")))
	if typeof(prev_v) == TYPE_ARRAY:
		out["previous_deck"] = prev_v
	var upg_v = JSON.parse_string(str(raw_map.get("unlocked_upgrades_json", "[]")))
	if typeof(upg_v) == TYPE_ARRAY:
		out["unlocked_upgrades"] = upg_v
	var settings_v = JSON.parse_string(str(raw_map.get("settings_json", "{}")))
	if typeof(settings_v) == TYPE_DICTIONARY:
		out["settings"] = settings_v
	return out


func _decode_cell(cell: Dictionary) -> Variant:
	var ctype := str(cell.get("type", "null"))
	if ctype == "null":
		return null
	if ctype == "integer":
		return int(cell.get("value", "0"))
	if ctype == "float":
		return float(cell.get("value", 0.0))
	return str(cell.get("value", ""))


func _arg_text(value: String) -> Dictionary:
	return {"type": "text", "value": value}


func _arg_int(value: int) -> Dictionary:
	return {"type": "integer", "value": str(value)}
