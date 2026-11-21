class_name TangoGame
extends PuzzleGame
## A Tango puzzle in play. Channel 0 holds 0 empty, 1 sun, 2 moon.

var puzzle: TangoPuzzle


func _init(p_puzzle: TangoPuzzle, p_difficulty: int, p_key: String) -> void:
	puzzle = p_puzzle
	mode_id = &"tango"
	difficulty = p_difficulty
	key = p_key
	width = puzzle.size
	height = puzzle.size
	channels = initial_channels()


func initial_channels() -> Array[PackedInt32Array]:
	var result: Array[PackedInt32Array] = [puzzle.givens.duplicate()]
	return result


func is_locked(index: int) -> bool:
	return puzzle.givens[index] != TangoPuzzle.EMPTY


func check_complete() -> bool:
	return TangoRules.is_solved(puzzle.size, puzzle.edges, channels[0])


func conflicts() -> PackedByteArray:
	return TangoRules.conflicts(puzzle.size, puzzle.edges, channels[0])


func hint_engine() -> HintEngine:
	return TangoHintEngine.new()


## Tap cycle: empty -> sun -> moon -> empty.
func cycle(cell: int) -> void:
	if not is_locked(cell):
		apply([[0, cell, (value(cell) + 1) % 3]])


func _on_move_applied(move: Array) -> void:
	for step: PackedInt32Array in move:
		if step[3] != TangoPuzzle.EMPTY:
			entries += 1
			if puzzle.solution[step[1]] != step[3]:
				mistakes += 1
