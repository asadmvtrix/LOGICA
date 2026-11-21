class_name QueensGame
extends PuzzleGame
## A Queens puzzle in play. Channel 0 holds 0 empty, 1 marked empty, 2 queen.

var puzzle: QueensPuzzle


func _init(p_puzzle: QueensPuzzle, p_difficulty: int, p_key: String) -> void:
	puzzle = p_puzzle
	mode_id = &"queens"
	difficulty = p_difficulty
	key = p_key
	width = puzzle.size
	height = puzzle.size
	channels = initial_channels()


func initial_channels() -> Array[PackedInt32Array]:
	var cells := PackedInt32Array()
	cells.resize(width * height)
	var result: Array[PackedInt32Array] = [cells]
	return result


func check_complete() -> bool:
	return QueensRules.is_solved(puzzle.size, puzzle.regions, channels[0])


func conflicts() -> PackedByteArray:
	return QueensRules.conflicts(puzzle.size, puzzle.regions, channels[0])


func hint_engine() -> HintEngine:
	return QueensHintEngine.new()


## Tap cycle: empty -> marked -> queen -> empty.
func cycle(cell: int) -> void:
	apply([[0, cell, (value(cell) + 1) % 3]])


func mark(cell: int) -> void:
	if value(cell) == QueensRules.EMPTY:
		apply([[0, cell, QueensRules.MARK]])


func _on_move_applied(move: Array) -> void:
	for step: PackedInt32Array in move:
		if step[3] == QueensRules.QUEEN:
			entries += 1
			if not puzzle.solution_has_queen(step[1]):
				mistakes += 1
