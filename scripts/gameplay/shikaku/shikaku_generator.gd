class_name ShikakuGenerator
extends RefCounted
## Generates Shikaku puzzles: a random partition of the grid into rectangles,
## one number placed in each, kept only if ShikakuLogic solves it within
## max_level (which also proves the solution is unique).

const MAX_ATTEMPTS := 3000


static func generate(size: int, max_area: int, max_level: int, rng: RandomNumberGenerator) -> ShikakuPuzzle:
	for attempt in MAX_ATTEMPTS:
		var rects := _partition(size, size, max_area, rng)
		var clues := PackedInt32Array()
		clues.resize(size * size)
		var by_clue := {}
		for rect in rects:
			var x := rng.randi_range(rect.position.x, rect.end.x - 1)
			var y := rng.randi_range(rect.position.y, rect.end.y - 1)
			clues[y * size + x] = rect.get_area()
			by_clue[y * size + x] = rect
		var cells := by_clue.keys()
		cells.sort()
		var solution: Array[Rect2i] = []
		for cell: int in cells:
			solution.append(by_clue[cell])
		var puzzle := ShikakuPuzzle.new(size, size, clues, solution)
		if ShikakuLogic.new(puzzle).solve(max_level) >= 0:
			return puzzle
	push_error("Shikaku generator gave up (size %d)" % size)
	return null


static func _partition(width: int, height: int, max_area: int, rng: RandomNumberGenerator) -> Array[Rect2i]:
	var covered := PackedByteArray()
	covered.resize(width * height)
	var rects: Array[Rect2i] = []
	for cell in width * height:
		if covered[cell] == 1:
			continue
		var x := cell % width
		var y := cell / width
		var shapes: Array[Vector2i] = []
		var max_w := 0
		while x + max_w < width and covered[y * width + x + max_w] == 0:
			max_w += 1
		for w in range(1, max_w + 1):
			for h in range(1, height - y + 1):
				if w * h > max_area:
					break
				if not _free(covered, width, Rect2i(x, y, w, h)):
					break
				if w * h >= 2:
					shapes.append(Vector2i(w, h))
		var shape := Vector2i.ONE
		if not shapes.is_empty():
			shape = shapes[rng.randi_range(0, shapes.size() - 1)]
		var rect := Rect2i(Vector2i(x, y), shape)
		for yy in range(rect.position.y, rect.end.y):
			for xx in range(rect.position.x, rect.end.x):
				covered[yy * width + xx] = 1
		rects.append(rect)
	return rects


static func _free(covered: PackedByteArray, width: int, rect: Rect2i) -> bool:
	for yy in range(rect.position.y, rect.end.y):
		for xx in range(rect.position.x, rect.end.x):
			if covered[yy * width + xx] == 1:
				return false
	return true
