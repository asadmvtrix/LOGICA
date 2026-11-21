class_name ShikakuPuzzle
extends RefCounted
## A Shikaku puzzle: split the grid into rectangles so that each holds exactly
## one number, equal to its area.

var width: int
var height: int
## Number per cell, 0 where there is none.
var clues: PackedInt32Array
## Cells holding numbers, in row-major order.
var clue_cells := PackedInt32Array()
## Solution rectangle (in cell coordinates) for each entry of clue_cells.
var solution: Array[Rect2i] = []


func _init(p_width: int, p_height: int, p_clues: PackedInt32Array, p_solution: Array[Rect2i]) -> void:
	width = p_width
	height = p_height
	clues = p_clues
	for cell in clues.size():
		if clues[cell] > 0:
			clue_cells.append(cell)
	solution = p_solution


func cell_point(cell: int) -> Vector2i:
	return Vector2i(cell % width, cell / width)


func clue_index_at(cell: int) -> int:
	return clue_cells.find(cell)


func rect_cells(rect: Rect2i) -> PackedInt32Array:
	var cells := PackedInt32Array()
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			cells.append(y * width + x)
	return cells


func clue_name(index: int) -> String:
	var cell := clue_cells[index]
	return "the %d at %s" % [clues[cell], CellNames.cell(cell, width)]


## Every rectangle of the right area that contains the clue cell, stays on the
## board and holds no other number.
func candidate_rects(index: int) -> Array[Rect2i]:
	var cell := clue_cells[index]
	var area := clues[cell]
	var point := cell_point(cell)
	var result: Array[Rect2i] = []
	for w in range(1, area + 1):
		if area % w != 0:
			continue
		var h := area / w
		if w > width or h > height:
			continue
		for x in range(point.x - w + 1, point.x + 1):
			for y in range(point.y - h + 1, point.y + 1):
				if x < 0 or y < 0 or x + w > width or y + h > height:
					continue
				var rect := Rect2i(x, y, w, h)
				var clean := true
				for other in rect_cells(rect):
					if other != cell and clues[other] > 0:
						clean = false
						break
				if clean:
					result.append(rect)
	return result
