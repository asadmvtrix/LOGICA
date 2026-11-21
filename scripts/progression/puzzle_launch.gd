class_name PuzzleLaunch
extends RefCounted
## Describes which puzzle to play and why (journey level, daily, challenge,
## training practice). Passed as the PLAY route's parameter and stored with
## the saved session.

const JOURNEY := &"journey"
const DAILY := &"daily"
const CHALLENGE := &"challenge"
const TRAINING := &"training"

var mode: StringName
var difficulty: int
var key: String
var source: StringName
var level := 0
var challenge_id := ""
var date := ""


static func create(p_mode: StringName, p_difficulty: int, p_key: String, p_source: StringName) -> PuzzleLaunch:
	var launch := PuzzleLaunch.new()
	launch.mode = p_mode
	launch.difficulty = p_difficulty
	launch.key = p_key
	launch.source = p_source
	return launch


func subtitle() -> String:
	match source:
		JOURNEY:
			return "Level %d · %s" % [level, Difficulty.name_of(difficulty)]
		DAILY:
			return "Daily · %s" % Difficulty.name_of(difficulty)
		CHALLENGE:
			return "Challenge · %s" % Difficulty.name_of(difficulty)
		TRAINING:
			return "Practice"
	return Difficulty.name_of(difficulty)


func to_dict() -> Dictionary:
	return {
		"mode": String(mode), "difficulty": difficulty, "key": key, "source": String(source),
		"level": level, "challenge_id": challenge_id, "date": date,
	}


static func from_dict(data: Dictionary) -> PuzzleLaunch:
	if not (data.get("mode") is String and data.get("key") is String):
		return null
	var mode := StringName(data["mode"])
	if not (mode in PuzzleModes.ALL):
		return null
	var launch := create(mode, int(data.get("difficulty", 0)), data["key"], StringName(str(data.get("source", ""))))
	launch.level = int(data.get("level", 0))
	launch.challenge_id = str(data.get("challenge_id", ""))
	launch.date = str(data.get("date", ""))
	return launch
