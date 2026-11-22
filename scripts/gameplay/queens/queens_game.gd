class_name QueensGame
extends PuzzleGame
## A Queens puzzle in play. Channel 0 holds 0 empty, 1 marked empty, 2 queen.

var puzzle: QueensPuzzle
var auto_cross := true


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


## Cells ruled out by a placed queen (same row, column, region or touching).
## With auto_cross on these show as crosses without being stored as marks.
func attacked_cells() -> PackedByteArray:
	var result := PackedByteArray()
	result.resize(width * height)
	if not auto_cross:
		return result
	var cells := channels[0]
	for q in cells.size():
		if cells[q] != QueensRules.QUEEN:
			continue
		for cell in cells.size():
			if cell != q and QueensRules.attacks(puzzle.size, puzzle.regions, q, cell):
				result[cell] = 1
	return result


func is_auto_crossed(cell: int) -> bool:
	return value(cell) == QueensRules.EMPTY and attacked_cells()[cell] == 1


## Tap cycle: empty -> marked -> queen -> empty. An auto-crossed cell already
## shows a cross, so a tap goes straight to queen.
func cycle(cell: int) -> void:
	if is_auto_crossed(cell):
		apply([[0, cell, QueensRules.QUEEN]])
		return
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
