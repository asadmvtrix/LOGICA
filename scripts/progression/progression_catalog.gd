class_name ProgressionCatalog
extends RefCounted
## Fixed, offline content definitions: journey levels, the daily set,
## challenges and training practice. Everything is derived from keys, so the
## same content appears on every device without a server.

const JOURNEY_LEVELS := 60

## Daily difficulty by weekday (Sunday first).
const DAILY_DIFFICULTY := [3, 0, 0, 1, 1, 2, 2]

const CHALLENGES := [
	{"id": "quick-crowns", "title": "Quick crowns", "mode": &"queens", "difficulty": 0, "max_time": 90, "no_hints": false, "no_mistakes": false},
	{"id": "balanced-mind", "title": "Balanced mind", "mode": &"tango", "difficulty": 1, "max_time": 0, "no_hints": true, "no_mistakes": false},
	{"id": "clean-cut", "title": "Clean cut", "mode": &"shikaku", "difficulty": 1, "max_time": 0, "no_hints": false, "no_mistakes": true},
	{"id": "grid-runner", "title": "Grid runner", "mode": &"sudoku", "difficulty": 1, "max_time": 600, "no_hints": false, "no_mistakes": false},
	{"id": "royal-court", "title": "Royal court", "mode": &"queens", "difficulty": 3, "max_time": 0, "no_hints": true, "no_mistakes": false},
	{"id": "eclipse", "title": "Eclipse", "mode": &"tango", "difficulty": 3, "max_time": 300, "no_hints": false, "no_mistakes": false},
	{"id": "architect", "title": "Architect", "mode": &"shikaku", "difficulty": 3, "max_time": 0, "no_hints": true, "no_mistakes": false},
	{"id": "purist", "title": "Purist", "mode": &"sudoku", "difficulty": 3, "max_time": 0, "no_hints": true, "no_mistakes": true},
]


static func difficulty_for_level(level: int) -> int:
	if level <= 12:
		return Difficulty.Level.EASY
	if level <= 30:
		return Difficulty.Level.MEDIUM
	if level <= 48:
		return Difficulty.Level.HARD
	return Difficulty.Level.EXPERT


static func journey_launch(mode: StringName, level: int) -> PuzzleLaunch:
	var launch := PuzzleLaunch.create(mode, difficulty_for_level(level), "journey/%s/%d" % [mode, level], PuzzleLaunch.JOURNEY)
	launch.level = level
	return launch


static func date_key(date: Dictionary) -> String:
	return "%04d-%02d-%02d" % [int(date["year"]), int(date["month"]), int(date["day"])]


static func daily_launch(mode: StringName, date: Dictionary) -> PuzzleLaunch:
	var day := date_key(date)
	var launch := PuzzleLaunch.create(mode, DAILY_DIFFICULTY[int(date["weekday"])], "daily/%s/%s" % [day, mode], PuzzleLaunch.DAILY)
	launch.date = day
	return launch


static func training_launch(mode: StringName) -> PuzzleLaunch:
	return PuzzleLaunch.create(mode, Difficulty.Level.EASY, "training/%s" % mode, PuzzleLaunch.TRAINING)


static func challenge(id: String) -> Dictionary:
	for entry: Dictionary in CHALLENGES:
		if entry["id"] == id:
			return entry
	return {}


static func challenge_launch(entry: Dictionary) -> PuzzleLaunch:
	var launch := PuzzleLaunch.create(entry["mode"], entry["difficulty"], "challenge/%s" % entry["id"], PuzzleLaunch.CHALLENGE)
	launch.challenge_id = entry["id"]
	return launch


static func challenge_goal(entry: Dictionary) -> String:
	var parts := PackedStringArray()
	if int(entry["max_time"]) > 0:
		parts.append("under %s" % TimeFormat.clock(entry["max_time"]))
	if entry["no_hints"]:
		parts.append("no hints")
	if entry["no_mistakes"]:
		parts.append("no mistakes")
	return "Solve %s %s, %s" % [Difficulty.name_of(entry["difficulty"]).to_lower(), PuzzleModes.title(entry["mode"]), ", ".join(parts)]


static func challenge_met(entry: Dictionary, game: PuzzleGame) -> bool:
	if not game.is_solved:
		return false
	if int(entry["max_time"]) > 0 and game.elapsed > float(entry["max_time"]):
		return false
	if entry["no_hints"] and game.reveal_hints_used + game.tactical_hints_used > 0:
		return false
	if entry["no_mistakes"] and game.mistakes > 0:
		return false
	return true
