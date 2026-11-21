class_name Difficulty
extends RefCounted
## Difficulty levels shared by every puzzle mode. Each mode maps a level to its
## own board size and allowed reasoning techniques.

enum Level { EASY, MEDIUM, HARD, EXPERT }

const NAMES: Array[String] = ["Easy", "Medium", "Hard", "Expert"]


static func name_of(level: int) -> String:
	return NAMES[clampi(level, 0, NAMES.size() - 1)]
