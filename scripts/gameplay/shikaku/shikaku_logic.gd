class_name ShikakuLogic
extends RefCounted
## Sound Shikaku deductions over each number's candidate rectangles.
## Levels: 1 only one rectangle left for a number; 2 a cell only one number
## can reach, or cells every option of a number covers; 3 an option that
## would leave some cell unreachable.
## Placements carry payload {"clue": index, "rect": Rect2i}; eliminations
## carry payload {"clue": index, "keep": Array[Rect2i]} per affected number,
## as an Array.

const MAX_LEVEL := 3

var puzzle: ShikakuPuzzle
var options: Array = []
var placed := PackedByteArray()
var cell_owner := PackedInt32Array()


func _init(p_puzzle: ShikakuPuzzle) -> void:
	puzzle = p_puzzle
	cell_owner.resize(puzzle.width * puzzle.height)
	cell_owner.fill(-1)
	placed.resize(puzzle.clue_cells.size())
	for i in puzzle.clue_cells.size():
		options.append(puzzle.candidate_rects(i))


## Starts from the player's board, treating each rectangle that holds exactly
## one number of the right area as placed.
static func from_ids(p_puzzle: ShikakuPuzzle, ids: PackedInt32Array) -> ShikakuLogic:
	var logic := ShikakuLogic.new(p_puzzle)
	var bounds := ShikakuRules.rects_by_id(p_puzzle, ids)
	for id: int in bounds:
		var rect: Rect2i = bounds[id]
		if ShikakuRules.rect_ok(p_puzzle, rect):
			var inside := ShikakuRules.clues_in(p_puzzle, rect)
			logic._place(p_puzzle.clue_index_at(inside[0]), rect)
	return logic


func is_complete() -> bool:
	return placed.count(0) == 0


func apply(deduction: Deduction) -> void:
	if deduction.places:
		_place(deduction.payload["clue"], deduction.payload["rect"])
		return
	for item: Dictionary in deduction.payload:
		options[item["clue"]] = item["keep"]


func _place(index: int, rect: Rect2i) -> void:
	placed[index] = 1
	var keep: Array[Rect2i] = [rect]
	options[index] = keep
	for cell in puzzle.rect_cells(rect):
		cell_owner[cell] = index
	for other in options.size():
		if other == index or placed[other] == 1:
			continue
		var filtered: Array[Rect2i] = []
		for candidate: Rect2i in options[other]:
			if not candidate.intersects(rect):
				filtered.append(candidate)
		options[other] = filtered


## Hardest level used, or -1 when stuck.
func solve(max_level: int = MAX_LEVEL) -> int:
	var hardest := 0
	for i in 400:
		if is_complete():
			return hardest
		var deduction := next_deduction(max_level)
		if deduction == null:
			return -1
		hardest = maxi(hardest, deduction.level)
		apply(deduction)
	return -1


func next_deduction(max_level: int = MAX_LEVEL) -> Deduction:
	var found := _single_option()
	if found == null and max_level >= 2:
		found = _only_reach()
	if found == null and max_level >= 2:
		found = _forced_overlap()
	if found == null and max_level >= 3:
		found = _starves_cell()
	return found


func _single_option() -> Deduction:
	for i in options.size():
		if placed[i] == 1 or options[i].size() != 1:
			continue
		var rect: Rect2i = options[i][0]
		var d := Deduction.new("Only one fit", 1, true)
		d.payload = {"clue": i, "rect": rect}
		d.add_step("%s has only one rectangle left that fits: it must not cover another number or a finished rectangle." % CellNames.sentence_case(puzzle.clue_name(i)),
			puzzle.rect_cells(rect), PackedInt32Array([puzzle.clue_cells[i]]))
		return d
	return null


func _reachers(cell: int) -> Array[int]:
	var point := puzzle.cell_point(cell)
	var result: Array[int] = []
	for i in options.size():
		if placed[i] == 1:
			continue
		for rect: Rect2i in options[i]:
			if rect.has_point(point):
				result.append(i)
				break
	return result


func _only_reach() -> Deduction:
	for cell in cell_owner.size():
		if cell_owner[cell] != -1:
			continue
		var reachers := _reachers(cell)
		if reachers.size() != 1:
			continue
		var i := reachers[0]
		var point := puzzle.cell_point(cell)
		var keep: Array[Rect2i] = []
		for rect: Rect2i in options[i]:
			if rect.has_point(point):
				keep.append(rect)
		if keep.size() == options[i].size():
			continue
		var d := Deduction.new("Only one number reaches", 2, false)
		d.payload = [{"clue": i, "keep": keep}]
		d.add_step("%s can only be covered by %s." % [CellNames.sentence_case(CellNames.cell(cell, puzzle.width)), puzzle.clue_name(i)],
			PackedInt32Array([cell]), PackedInt32Array([puzzle.clue_cells[i]]))
		d.add_step("So that number's rectangle must include this cell, which leaves %d possible rectangle%s for it." % [keep.size(), "" if keep.size() == 1 else "s"],
			PackedInt32Array([cell]), _union_cells(keep))
		return d
	return null


func _forced_overlap() -> Deduction:
	for i in options.size():
		if placed[i] == 1 or options[i].is_empty():
			continue
		var common: Rect2i = options[i][0]
		for rect: Rect2i in options[i]:
			common = common.intersection(rect)
		if common.get_area() == 0:
			continue
		var changes: Array = []
		for other in options.size():
			if other == i or placed[other] == 1:
				continue
			var keep: Array[Rect2i] = []
			for rect: Rect2i in options[other]:
				if not rect.intersects(common):
					keep.append(rect)
			if keep.size() != options[other].size():
				changes.append({"clue": other, "keep": keep})
		if changes.is_empty():
			continue
		var affected := PackedInt32Array()
		for item: Dictionary in changes:
			affected.append(puzzle.clue_cells[item["clue"]])
		var d := Deduction.new("Shared cells", 2, false)
		d.payload = changes
		d.add_step("Every rectangle still possible for %s covers these cells." % puzzle.clue_name(i), puzzle.rect_cells(common), PackedInt32Array([puzzle.clue_cells[i]]))
		d.add_step("No other number can use them, which rules out some rectangles for the numbers nearby.", puzzle.rect_cells(common), affected)
		return d
	return null


func _starves_cell() -> Deduction:
	for i in options.size():
		if placed[i] == 1 or options[i].size() < 2:
			continue
		for rect: Rect2i in options[i]:
			var starved := _starved_by(i, rect)
			if starved < 0:
				continue
			var keep: Array[Rect2i] = []
			for other: Rect2i in options[i]:
				if other != rect:
					keep.append(other)
			var d := Deduction.new("Leaves a cell uncovered", 3, false)
			d.payload = [{"clue": i, "keep": keep}]
			d.add_step("Suppose %s used this rectangle." % puzzle.clue_name(i), puzzle.rect_cells(rect), PackedInt32Array([puzzle.clue_cells[i]]))
			d.add_step("Then no number could reach %s any more, so that rectangle is ruled out." % CellNames.cell(starved, puzzle.width),
				PackedInt32Array([starved]), puzzle.rect_cells(rect))
			return d
	return null


## A cell outside rect that only clue i could cover, and none of whose
## other covering options survive rect, or -1.
func _starved_by(i: int, rect: Rect2i) -> int:
	for cell in cell_owner.size():
		if cell_owner[cell] != -1:
			continue
		var point := puzzle.cell_point(cell)
		if rect.has_point(point):
			continue
		var reachable := false
		for other in options.size():
			if other == i or placed[other] == 1:
				continue
			for candidate: Rect2i in options[other]:
				if candidate.has_point(point) and not candidate.intersects(rect):
					reachable = true
					break
			if reachable:
				break
		if not reachable:
			return cell
	return -1


func _union_cells(rects: Array[Rect2i]) -> PackedInt32Array:
	var seen := {}
	for rect in rects:
		for cell in puzzle.rect_cells(rect):
			seen[cell] = true
	var cells := PackedInt32Array()
	for cell: int in seen:
		cells.append(cell)
	return cells
