class_name SudokuPuzzle
extends RefCounted
## A 9 x 9 Sudoku: givens (0 for empty) and the unique solution.

var givens: PackedInt32Array
var solution: PackedInt32Array


func _init(p_givens: PackedInt32Array, p_solution: PackedInt32Array) -> void:
	givens = p_givens
	solution = p_solution


func clue_count() -> int:
	var count := 0
	for v in givens:
		if v != 0:
			count += 1
	return count
