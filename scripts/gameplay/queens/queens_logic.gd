class_name QueensLogic
extends RefCounted
## Sound deductions for Queens, used by the hint engine and to grade generated
## puzzles. Works on candidate cells: a cell stays a candidate until a rule
## rules it out.
## Levels: 1 queen eliminations and last-cell placements, 2 confinement,
## 3 groups of two or three lines, 4 a queen that would empty a unit.

const MAX_LEVEL := 4

var size: int
var regions: PackedInt32Array
var candidate := PackedByteArray()
var queen := PackedByteArray()

var _names: QueensPuzzle
var _region_cells: Array[PackedInt32Array] = []


func _init(puzzle: QueensPuzzle) -> void:
	_names = puzzle
	size = puzzle.size
	regions = puzzle.regions
	candidate.resize(size * size)
	candidate.fill(1)
	queen.resize(size * size)
	for r in size:
		_region_cells.append(PackedInt32Array())
	for cell in size * size:
		_region_cells[regions[cell]].append(cell)


## Starts from the player's board: marked cells are ruled out, queens placed.
## Cells attacked by queens are not removed yet; the first deduction does that.
static func from_cells(puzzle: QueensPuzzle, cells: PackedInt32Array) -> QueensLogic:
	var logic := QueensLogic.new(puzzle)
	for cell in cells.size():
		if cells[cell] == QueensRules.MARK:
			logic.candidate[cell] = 0
		elif cells[cell] == QueensRules.QUEEN:
			logic.candidate[cell] = 0
			logic.queen[cell] = 1
	return logic


func queen_count() -> int:
	var count := 0
	for q in queen:
		count += q
	return count


func apply(deduction: Deduction) -> void:
	for change in deduction.changes:
		var cell: int = change[1]
		candidate[cell] = 0
		if change[2] == QueensRules.QUEEN:
			queen[cell] = 1


## Runs deductions up to max_level until solved. Returns the hardest level used,
## or -1 when stuck or contradictory.
func solve(max_level: int = MAX_LEVEL) -> int:
	var hardest := 0
	for i in size * size * 3:
		if queen_count() == size:
			return hardest
		var deduction := next_deduction(max_level)
		if deduction == null:
			return -1
		hardest = maxi(hardest, deduction.level)
		apply(deduction)
	return -1


func next_deduction(max_level: int = MAX_LEVEL) -> Deduction:
	var found := _queen_eliminations()
	if found == null:
		found = _last_cell()
	if found == null and max_level >= 2:
		found = _confinement()
	if found == null and max_level >= 3:
		found = _groups(2)
	if found == null and max_level >= 3:
		found = _groups(3)
	if found == null and max_level >= 4:
		found = _exhaustion()
	return found


# --- Units -------------------------------------------------------------------

func _row_cells(r: int) -> PackedInt32Array:
	var cells := PackedInt32Array()
	for c in size:
		cells.append(r * size + c)
	return cells


func _column_cells(c: int) -> PackedInt32Array:
	var cells := PackedInt32Array()
	for r in size:
		cells.append(r * size + c)
	return cells


func _unit_has_queen(cells: PackedInt32Array) -> bool:
	for cell in cells:
		if queen[cell] == 1:
			return true
	return false


func _open(cells: PackedInt32Array) -> PackedInt32Array:
	var result := PackedInt32Array()
	for cell in cells:
		if candidate[cell] == 1:
			result.append(cell)
	return result


## Units still needing a queen, as [kind, number, cells].
func _open_units() -> Array:
	var units: Array = []
	for r in size:
		units.append(["region", r, _region_cells[r]])
	for r in size:
		units.append(["row", r, _row_cells(r)])
	for c in size:
		units.append(["column", c, _column_cells(c)])
	return units.filter(func(unit: Array) -> bool: return not _unit_has_queen(unit[2]))


func _unit_name(kind: String, number: int) -> String:
	match kind:
		"region":
			return "the %s region" % _names.region_name(number)
		"row":
			return CellNames.row(number)
	return CellNames.column(number)


# --- Techniques -------------------------------------------------------------

func _queen_eliminations() -> Deduction:
	var queens := PackedInt32Array()
	for cell in queen.size():
		if queen[cell] == 1:
			queens.append(cell)
	var ruled_out := PackedInt32Array()
	for cell in candidate.size():
		if candidate[cell] == 0:
			continue
		for q in queens:
			if QueensRules.attacks(size, regions, q, cell):
				ruled_out.append(cell)
				break
	if ruled_out.is_empty():
		return null
	var d := Deduction.new("Cells ruled out by queens", 1, false)
	d.add_step("A queen claims its row, its column and its region, and no other queen may touch it. These cells can be marked empty.", ruled_out, queens)
	for cell in ruled_out:
		d.changes.append([0, cell, QueensRules.MARK])
	return d


func _last_cell() -> Deduction:
	for unit in _open_units():
		var open := _open(unit[2])
		if open.size() == 1:
			var unit_name := _unit_name(unit[0], unit[1])
			var d := Deduction.new("Only one place left", 1, true)
			d.add_step("%s has only one cell left that can hold a queen, so its queen goes here." % CellNames.sentence_case(unit_name), open, unit[2])
			d.changes.append([0, open[0], QueensRules.QUEEN])
			return d
	return null


func _confinement() -> Deduction:
	# A region whose open cells all lie in one row or column claims that line.
	for r in size:
		var cells := _region_cells[r]
		if _unit_has_queen(cells):
			continue
		var open := _open(cells)
		if open.is_empty():
			continue
		for is_row in [true, false]:
			var line := _line_of(open[0], is_row)
			var confined := true
			for cell in open:
				if _line_of(cell, is_row) != line:
					confined = false
					break
			if not confined:
				continue
			var ruled_out := PackedInt32Array()
			for cell in (_row_cells(line) if is_row else _column_cells(line)):
				if candidate[cell] == 1 and regions[cell] != r:
					ruled_out.append(cell)
			if not ruled_out.is_empty():
				var region_name := _unit_name("region", r)
				var line_name := CellNames.line(is_row, line)
				var d := Deduction.new("Region confined to one line", 2, false)
				d.add_step("Every open cell of %s is in %s, so that region's queen will be in %s." % [region_name, line_name, line_name], open)
				d.add_step("No other queen can use %s, so its remaining cells outside %s are ruled out." % [line_name, region_name], ruled_out, open)
				_mark_all(d, ruled_out)
				return d
	# A line whose open cells all belong to one region claims that region.
	for is_row in [true, false]:
		for line in size:
			var cells := _row_cells(line) if is_row else _column_cells(line)
			if _unit_has_queen(cells):
				continue
			var open := _open(cells)
			if open.is_empty():
				continue
			var region := regions[open[0]]
			var single := true
			for cell in open:
				if regions[cell] != region:
					single = false
					break
			if not single:
				continue
			var ruled_out := PackedInt32Array()
			for cell in _region_cells[region]:
				if candidate[cell] == 1 and _line_of(cell, is_row) != line:
					ruled_out.append(cell)
			if not ruled_out.is_empty():
				var line_name := CellNames.line(is_row, line)
				var region_name := _unit_name("region", region)
				var d := Deduction.new("Line confined to one region", 2, false)
				d.add_step("All open cells in %s belong to %s, so %s's queen is also that region's queen." % [line_name, region_name, line_name], open)
				d.add_step("The rest of %s is therefore ruled out." % region_name, ruled_out, open)
				_mark_all(d, ruled_out)
				return d
	return null


func _groups(count: int) -> Deduction:
	var open_regions: Array[int] = []
	for r in size:
		if not _unit_has_queen(_region_cells[r]) and not _open(_region_cells[r]).is_empty():
			open_regions.append(r)
	for combo in _combinations(open_regions, count):
		for is_row in [true, false]:
			var lines := {}
			var group_cells := PackedInt32Array()
			for r: int in combo:
				for cell in _open(_region_cells[r]):
					lines[_line_of(cell, is_row)] = true
					group_cells.append(cell)
			if lines.size() != count:
				continue
			var ruled_out := PackedInt32Array()
			for line: int in lines:
				for cell in (_row_cells(line) if is_row else _column_cells(line)):
					if candidate[cell] == 1 and not (regions[cell] in combo):
						ruled_out.append(cell)
			if ruled_out.is_empty():
				continue
			var region_names := PackedStringArray()
			for r: int in combo:
				region_names.append(_names.region_name(r))
			var line_names := PackedStringArray()
			var sorted_lines := lines.keys()
			sorted_lines.sort()
			for line: int in sorted_lines:
				line_names.append(str(line + 1))
			var kind := "rows" if is_row else "columns"
			var d := Deduction.new("%d regions share %d lines" % [count, count], 3, false)
			d.add_step("The %s regions only have open cells in %s %s. Those %d lines must hold exactly these %d queens." % [
				" and ".join(region_names), kind, " and ".join(line_names), count, count], group_cells)
			d.add_step("Every other cell in those %s is ruled out." % kind, ruled_out, group_cells)
			_mark_all(d, ruled_out)
			return d
	return null


func _exhaustion() -> Deduction:
	var units := _open_units()
	for cell in candidate.size():
		if candidate[cell] == 0:
			continue
		for unit in units:
			var cells: PackedInt32Array = unit[2]
			if cell in cells:
				continue
			var open := _open(cells)
			if open.is_empty():
				continue
			var all_blocked := true
			for other in open:
				if not QueensRules.attacks(size, regions, cell, other):
					all_blocked = false
					break
			if all_blocked:
				var unit_name := _unit_name(unit[0], unit[1])
				var d := Deduction.new("A queen here would block a whole unit", 4, false)
				d.add_step("Suppose a queen were placed in %s." % CellNames.cell(cell, size), PackedInt32Array([cell]))
				d.add_step("It would rule out every remaining cell of %s, leaving it no queen. So this cell must be empty." % unit_name, PackedInt32Array([cell]), open)
				d.changes.append([0, cell, QueensRules.MARK])
				return d
	return null


func _mark_all(deduction: Deduction, cells: PackedInt32Array) -> void:
	for cell in cells:
		deduction.changes.append([0, cell, QueensRules.MARK])


func _line_of(cell: int, is_row: bool) -> int:
	return cell / size if is_row else cell % size


static func _combinations(items: Array[int], count: int) -> Array:
	var result: Array = []
	_combine(items, count, 0, [], result)
	return result


static func _combine(items: Array[int], count: int, start: int, current: Array, result: Array) -> void:
	if current.size() == count:
		result.append(current.duplicate())
		return
	for i in range(start, items.size()):
		current.append(items[i])
		_combine(items, count, i + 1, current, result)
		current.pop_back()
