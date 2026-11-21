class_name SudokuGame
extends PuzzleGame
## A Sudoku in play. Channel 0 holds digits (givens included), channel 1 a
## notes bitmask per cell (bit d = pencil mark d).

var puzzle: SudokuPuzzle


func _init(p_puzzle: SudokuPuzzle, p_difficulty: int, p_key: String) -> void:
	puzzle = p_puzzle
	mode_id = &"sudoku"
	difficulty = p_difficulty
	key = p_key
	width = 9
	height = 9
	channels = initial_channels()


func initial_channels() -> Array[PackedInt32Array]:
	var notes := PackedInt32Array()
	notes.resize(81)
	var result: Array[PackedInt32Array] = [puzzle.givens.duplicate(), notes]
	return result


func is_locked(index: int) -> bool:
	return puzzle.givens[index] != 0


func check_complete() -> bool:
	return SudokuRules.is_solved(channels[0])


func conflicts() -> PackedByteArray:
	return SudokuRules.conflicts(channels[0])


func hint_engine() -> HintEngine:
	return SudokuHintEngine.new()


## Enters a digit (or clears it if already there). Also removes that digit
## from the notes of every peer, in the same undo step.
func set_digit(cell: int, digit: int) -> void:
	if cell < 0 or is_locked(cell):
		return
	if value(cell) == digit:
		apply([[0, cell, 0]])
		return
	var changes: Array = [[0, cell, digit], [1, cell, 0]]
	for peer in SudokuRules.peers(cell):
		var notes := value(peer, 1)
		if notes & (1 << digit):
			changes.append([1, peer, notes & ~(1 << digit)])
	apply(changes)


func toggle_note(cell: int, digit: int) -> void:
	if cell < 0 or is_locked(cell) or value(cell) != 0:
		return
	apply([[1, cell, value(cell, 1) ^ (1 << digit)]])


func erase(cell: int) -> void:
	if cell < 0 or is_locked(cell):
		return
	apply([[0, cell, 0], [1, cell, 0]])


func _on_move_applied(move: Array) -> void:
	for step: PackedInt32Array in move:
		if step[0] == 0 and step[3] != 0:
			entries += 1
			if puzzle.solution[step[1]] != step[3]:
				mistakes += 1
