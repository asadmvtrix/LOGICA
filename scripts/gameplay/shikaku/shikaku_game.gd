class_name ShikakuGame
extends PuzzleGame
## A Shikaku puzzle in play. Channel 0 holds the id of the rectangle covering
## each cell (0 = uncovered).

var puzzle: ShikakuPuzzle


func _init(p_puzzle: ShikakuPuzzle, p_difficulty: int, p_key: String) -> void:
	puzzle = p_puzzle
	mode_id = &"shikaku"
	difficulty = p_difficulty
	key = p_key
	width = puzzle.width
	height = puzzle.height
	channels = initial_channels()


func initial_channels() -> Array[PackedInt32Array]:
	var ids := PackedInt32Array()
	ids.resize(width * height)
	var result: Array[PackedInt32Array] = [ids]
	return result


func check_complete() -> bool:
	return ShikakuRules.is_solved(puzzle, channels[0])


func conflicts() -> PackedByteArray:
	return ShikakuRules.conflicts(puzzle, channels[0])


func hint_engine() -> HintEngine:
	return ShikakuHintEngine.new()


func next_id() -> int:
	var highest := 0
	for id in channels[0]:
		highest = maxi(highest, id)
	return highest + 1


static func rect_between(a: Vector2i, b: Vector2i) -> Rect2i:
	var top_left := Vector2i(mini(a.x, b.x), mini(a.y, b.y))
	var bottom_right := Vector2i(maxi(a.x, b.x), maxi(a.y, b.y))
	return Rect2i(top_left, bottom_right - top_left + Vector2i.ONE)


## Changes that draw rect as a new rectangle, removing any rectangles it
## overlaps.
func changes_for_rect(rect: Rect2i) -> Array:
	var ids := channels[0]
	var overlapped := {}
	for cell in puzzle.rect_cells(rect):
		if ids[cell] != 0:
			overlapped[ids[cell]] = true
	var changes: Array = []
	var inside := {}
	var id := next_id()
	for cell in puzzle.rect_cells(rect):
		inside[cell] = true
		changes.append([0, cell, id])
	for cell in ids.size():
		if overlapped.has(ids[cell]) and not inside.has(cell):
			changes.append([0, cell, 0])
	return changes


func draw_rect_between(a: int, b: int) -> void:
	apply(changes_for_rect(rect_between(puzzle.cell_point(a), puzzle.cell_point(b))))


## Tapping a rectangle removes it; tapping an uncovered 1 covers it.
func tap(cell: int) -> void:
	var id := value(cell)
	if id != 0:
		var changes: Array = []
		for other in cell_count():
			if channels[0][other] == id:
				changes.append([0, other, 0])
		apply(changes)
	elif puzzle.clues[cell] == 1:
		apply([[0, cell, next_id()]])


func _on_move_applied(move: Array) -> void:
	var new_ids := {}
	for step: PackedInt32Array in move:
		if step[3] != 0:
			new_ids[step[3]] = true
	if new_ids.is_empty():
		return
	var bounds := ShikakuRules.rects_by_id(puzzle, channels[0])
	for id: int in new_ids:
		if not bounds.has(id):
			continue
		entries += 1
		var rect: Rect2i = bounds[id]
		if not (rect in puzzle.solution):
			mistakes += 1
