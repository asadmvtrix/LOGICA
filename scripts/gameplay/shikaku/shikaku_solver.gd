class_name ShikakuSolver
extends RefCounted
## Exhaustive search over each number's candidate rectangles, used to prove
## uniqueness in tests.


static func count_solutions(puzzle: ShikakuPuzzle, limit: int = 2) -> int:
	var total_area := 0
	for cell in puzzle.clue_cells:
		total_area += puzzle.clues[cell]
	if total_area != puzzle.width * puzzle.height:
		return 0
	var options: Array = []
	for i in puzzle.clue_cells.size():
		options.append(puzzle.candidate_rects(i))
	var order := range(options.size())
	order.sort_custom(func(a: int, b: int) -> bool: return options[a].size() < options[b].size())
	var covered := PackedByteArray()
	covered.resize(puzzle.width * puzzle.height)
	return _search(0, order, options, covered, puzzle, limit)


static func _search(depth: int, order: Array, options: Array, covered: PackedByteArray, puzzle: ShikakuPuzzle, limit: int) -> int:
	if depth == order.size():
		return 1
	var total := 0
	for rect: Rect2i in options[order[depth]]:
		var cells := puzzle.rect_cells(rect)
		var free := true
		for cell in cells:
			if covered[cell] == 1:
				free = false
				break
		if not free:
			continue
		for cell in cells:
			covered[cell] = 1
		total += _search(depth + 1, order, options, covered, puzzle, limit - total)
		for cell in cells:
			covered[cell] = 0
		if total >= limit:
			return total
	return total
