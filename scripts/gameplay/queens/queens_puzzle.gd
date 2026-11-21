class_name QueensPuzzle
extends RefCounted
## An N x N Queens puzzle: N coloured regions and its unique solution.
## Rules: one queen per row, per column and per region; queens may not touch,
## not even diagonally.

var size: int
## Region id (0..size-1) for every cell, row-major.
var regions: PackedInt32Array
## Solution column for every row.
var solution: PackedInt32Array


func _init(p_size: int, p_regions: PackedInt32Array, p_solution: PackedInt32Array) -> void:
	size = p_size
	regions = p_regions
	solution = p_solution


func solution_has_queen(cell: int) -> bool:
	return solution[cell / size] == cell % size


func region_name(region: int) -> String:
	return DesignTokens.REGION_NAMES[region % DesignTokens.REGION_NAMES.size()]
