class_name ProgressService
extends RefCounted
## Offline progress: journey position, best results, statistics, daily
## completions, challenges and the one in-progress session. Persisted as a
## versioned envelope { "version", "data" } through JsonFileStore.

signal changed

const SAVE_VERSION := 1
const SECTIONS := ["journey", "records", "stats", "daily", "challenges", "session"]

var load_status: StringName = &""

var _store: JsonFileStore
var _data := {}


func _init(store: JsonFileStore) -> void:
	_store = store
	_reset_data()


func _reset_data() -> void:
	_data = {}
	for section: String in SECTIONS:
		_data[section] = {}


func load_progress() -> void:
	_reset_data()
	var result := _store.read()
	load_status = result.status
	if not result.ok:
		return
	var data: Variant = result.data.get("data")
	if not (data is Dictionary):
		load_status = JsonFileStore.STATUS_CORRUPT
		return
	for section: String in SECTIONS:
		if data.get(section) is Dictionary:
			_data[section] = data[section]


func save() -> void:
	var error := _store.write({"version": SAVE_VERSION, "data": _data})
	if error != OK:
		push_error("Saving progress failed: %s" % error_string(error))


# --- Journey -------------------------------------------------------------------

func journey_completed(mode: StringName) -> int:
	return int(_data["journey"].get(String(mode), 0))


func next_journey_level(mode: StringName) -> int:
	return mini(journey_completed(mode) + 1, ProgressionCatalog.JOURNEY_LEVELS)


func is_level_unlocked(mode: StringName, level: int) -> bool:
	return level <= journey_completed(mode) + 1


# --- Records and statistics ------------------------------------------------------

func is_solved(key: String) -> bool:
	return _data["records"].has(key)


func record_for(key: String) -> Dictionary:
	return _data["records"].get(key, {})


func mode_stats(mode: StringName) -> Dictionary:
	var stats: Dictionary = _data["stats"].get(String(mode), {})
	return {
		"solved": int(stats.get("solved", 0)),
		"time": float(stats.get("time", 0.0)),
		"hints": int(stats.get("hints", 0)),
		"best": stats.get("best", {}),
	}


func total_solved() -> int:
	var total := 0
	for mode in PuzzleModes.ALL:
		total += mode_stats(mode)["solved"]
	return total


func total_time() -> float:
	var total := 0.0
	for mode in PuzzleModes.ALL:
		total += mode_stats(mode)["time"]
	return total


## Records a solved puzzle. Returns { "new_best": bool, "challenge_met": bool }.
func record_solve(launch: PuzzleLaunch, game: PuzzleGame) -> Dictionary:
	var hints := game.reveal_hints_used + game.tactical_hints_used
	var outcome := {"new_best": false, "challenge_met": false}

	var previous: Dictionary = record_for(launch.key)
	if previous.is_empty() or game.elapsed < float(previous.get("time", INF)):
		_data["records"][launch.key] = {"time": game.elapsed, "hints": hints, "mistakes": game.mistakes}
		outcome["new_best"] = not previous.is_empty()

	var mode := String(launch.mode)
	var stats: Dictionary = _data["stats"].get(mode, {})
	stats["solved"] = int(stats.get("solved", 0)) + 1
	stats["time"] = float(stats.get("time", 0.0)) + game.elapsed
	stats["hints"] = int(stats.get("hints", 0)) + hints
	var best: Dictionary = stats.get("best", {})
	var difficulty_key := str(launch.difficulty)
	if not best.has(difficulty_key) or game.elapsed < float(best[difficulty_key]):
		best[difficulty_key] = game.elapsed
	stats["best"] = best
	_data["stats"][mode] = stats

	match launch.source:
		PuzzleLaunch.JOURNEY:
			if launch.level == journey_completed(launch.mode) + 1:
				_data["journey"][mode] = launch.level
		PuzzleLaunch.DAILY:
			var done: Array = _data["daily"].get(launch.date, [])
			if not (mode in done):
				done.append(mode)
			_data["daily"][launch.date] = done
		PuzzleLaunch.CHALLENGE:
			var entry := ProgressionCatalog.challenge(launch.challenge_id)
			if not entry.is_empty() and ProgressionCatalog.challenge_met(entry, game):
				_data["challenges"][launch.challenge_id] = true
				outcome["challenge_met"] = true

	if session_key() == launch.key:
		_data["session"] = {}
	save()
	changed.emit()
	return outcome


# --- Daily -----------------------------------------------------------------------

func daily_done(date_key: String, mode: StringName) -> bool:
	return String(mode) in _data["daily"].get(date_key, [])


func daily_count(date_key: String) -> int:
	return _data["daily"].get(date_key, []).size()


## Consecutive days, ending today (or yesterday if today has none yet), with
## at least one daily puzzle solved.
func daily_streak(today: Dictionary) -> int:
	var unix := Time.get_unix_time_from_datetime_dict(today)
	if daily_count(ProgressionCatalog.date_key(today)) == 0:
		unix -= 86400
	var streak := 0
	while daily_count(ProgressionCatalog.date_key(Time.get_date_dict_from_unix_time(unix))) > 0:
		streak += 1
		unix -= 86400
	return streak


func daily_days() -> int:
	return _data["daily"].size()


# --- Challenges --------------------------------------------------------------

func challenge_done(id: String) -> bool:
	return _data["challenges"].get(id, false) == true


func challenges_done() -> int:
	return _data["challenges"].size()


# --- Session -------------------------------------------------------------------

func save_session(launch: PuzzleLaunch, game: PuzzleGame) -> void:
	if game.is_solved:
		return
	_data["session"] = {"launch": launch.to_dict(), "state": game.to_save()}
	save()


func session_key() -> String:
	var launch: Variant = _data["session"].get("launch")
	return str(launch.get("key", "")) if launch is Dictionary else ""


func session_launch() -> PuzzleLaunch:
	var launch: Variant = _data["session"].get("launch")
	return PuzzleLaunch.from_dict(launch) if launch is Dictionary else null


func session_state(key: String) -> Dictionary:
	if session_key() != key:
		return {}
	var state: Variant = _data["session"].get("state")
	return state if state is Dictionary else {}


func clear_session() -> void:
	if _data["session"].is_empty():
		return
	_data["session"] = {}
	save()
