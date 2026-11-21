class_name ShikakuRules
extends RefCounted
## Rule checks on the player's board, where each cell holds the id of the
## rectangle covering it (0 = uncovered).


## Bounding rectangle for every id: { id: Rect2i }.
static func rects_by_id(puzzle: ShikakuPuzzle, ids: PackedInt32Array) -> Dictionary:
	var bounds := {}
	for cell in ids.size():
		var id := ids[cell]
		if id == 0:
			continue
		var point := puzzle.cell_point(cell)
		if bounds.has(id):
			var rect: Rect2i = bounds[id]
			bounds[id] = rect.merge(Rect2i(point, Vector2i.ONE))
		else:
			bounds[id] = Rect2i(point, Vector2i.ONE)
	return bounds


## Clue cells inside a rectangle.
static func clues_in(puzzle: ShikakuPuzzle, rect: Rect2i) -> PackedInt32Array:
	var found := PackedInt32Array()
	for cell in puzzle.clue_cells:
		if rect.has_point(puzzle.cell_point(cell)):
			found.append(cell)
	return found


## A rectangle breaks the rules when it holds no number, several numbers, or a
## number different from its area.
static func rect_ok(puzzle: ShikakuPuzzle, rect: Rect2i) -> bool:
	var inside := clues_in(puzzle, rect)
	return inside.size() == 1 and puzzle.clues[inside[0]] == rect.get_area()


static func conflicts(puzzle: ShikakuPuzzle, ids: PackedInt32Array) -> PackedByteArray:
	var result := PackedByteArray()
	result.resize(ids.size())
	var bounds := rects_by_id(puzzle, ids)
	for id: int in bounds:
		var rect: Rect2i = bounds[id]
		if not rect_ok(puzzle, rect):
			for cell in puzzle.rect_cells(rect):
				if ids[cell] == id:
					result[cell] = 1
	return result


static func is_solved(puzzle: ShikakuPuzzle, ids: PackedInt32Array) -> bool:
	for id in ids:
		if id == 0:
			return false
	var bounds := rects_by_id(puzzle, ids)
	for id: int in bounds:
		var rect: Rect2i = bounds[id]
		if not rect_ok(puzzle, rect):
			return false
		for cell in puzzle.rect_cells(rect):
			if ids[cell] != id:
				return false
	return true
