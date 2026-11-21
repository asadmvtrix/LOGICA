class_name SudokuLogic
extends RefCounted
## Sound Sudoku deductions on candidate masks (bit d set = digit d possible).
## Levels: 1 hidden single, 2 naked single, 3 pointing and claiming,
## 4 naked and hidden pairs. Eliminations travel in Deduction.payload as
## [cell, mask_to_remove] pairs; placements also clear the cell's notes.

const MAX_LEVEL := 4

var values: PackedInt32Array
var candidates := PackedInt32Array()


func _init(p_values: PackedInt32Array) -> void:
	values = p_values.duplicate()
	candidates.resize(81)
	for cell in 81:
		if values[cell] != 0:
			continue
		var mask := SudokuRules.ALL_CANDIDATES
		for peer in SudokuRules.peers(cell):
			mask &= ~(1 << values[peer])
		candidates[cell] = mask


func empty_count() -> int:
	return values.count(0)


func apply(deduction: Deduction) -> void:
	for change in deduction.changes:
		if change[0] == 0:
			_place(change[1], change[2])
	if deduction.payload is Array:
		for item: Array in deduction.payload:
			candidates[item[0]] &= ~int(item[1])


func _place(cell: int, digit: int) -> void:
	values[cell] = digit
	candidates[cell] = 0
	for peer in SudokuRules.peers(cell):
		candidates[peer] &= ~(1 << digit)


## Hardest level used, or -1 when stuck.
func solve(max_level: int = MAX_LEVEL) -> int:
	var hardest := 0
	while empty_count() > 0:
		var deduction := next_deduction(max_level)
		if deduction == null:
			return -1
		hardest = maxi(hardest, deduction.level)
		apply(deduction)
	return hardest


func next_deduction(max_level: int = MAX_LEVEL) -> Deduction:
	var found := _hidden_single()
	if found == null and max_level >= 2:
		found = _naked_single()
	if found == null and max_level >= 3:
		found = _pointing()
	if found == null and max_level >= 3:
		found = _claiming()
	if found == null and max_level >= 4:
		found = _naked_pair()
	if found == null and max_level >= 4:
		found = _hidden_pair()
	return found


func _name(cell: int) -> String:
	return CellNames.cell(cell, 9)


func _placement(technique: String, level: int, cell: int, digit: int) -> Deduction:
	var d := Deduction.new(technique, level, true)
	d.changes.append([0, cell, digit])
	d.changes.append([1, cell, 0])
	return d


func _unit_has(unit: PackedInt32Array, digit: int) -> bool:
	for cell in unit:
		if values[cell] == digit:
			return true
	return false


func _cells_with(unit: PackedInt32Array, digit: int) -> PackedInt32Array:
	var result := PackedInt32Array()
	for cell in unit:
		if candidates[cell] & (1 << digit):
			result.append(cell)
	return result


func _givers(cell: int, digit: int) -> PackedInt32Array:
	var result := PackedInt32Array()
	for peer in SudokuRules.peers(cell):
		if values[peer] == digit:
			result.append(peer)
	return result


# --- Singles ---------------------------------------------------------------

func _hidden_single() -> Deduction:
	var units := SudokuRules.units()
	for order in [18, 0, 9]:
		for u in range(order, order + 9):
			var unit: PackedInt32Array = units[u]
			for digit in range(1, 10):
				if _unit_has(unit, digit):
					continue
				var spots := _cells_with(unit, digit)
				if spots.size() != 1:
					continue
				var cell := spots[0]
				var blockers := PackedInt32Array()
				for other in unit:
					if other != cell and values[other] == 0:
						for giver in _givers(other, digit):
							if not (giver in blockers):
								blockers.append(giver)
				var d := _placement("Hidden single", 1, cell, digit)
				d.add_step("Look for the %d in %s. Every other open cell there is ruled out for %d by a %d it already sees, or by an earlier deduction." % [
					digit, SudokuRules.unit_name(u), digit, digit], PackedInt32Array([cell]), unit)
				d.add_step("So the %d in %s must go in %s." % [digit, SudokuRules.unit_name(u), _name(cell)], PackedInt32Array([cell]), blockers)
				return d
	return null


func _naked_single() -> Deduction:
	for cell in 81:
		if values[cell] != 0 or SudokuRules.bit_count(candidates[cell]) != 1:
			continue
		var digit := SudokuRules.digits_of(candidates[cell])[0]
		var d := _placement("Naked single", 2, cell, digit)
		d.add_step("Check which digits %s can still take. Its row, column and box already contain or rule out every digit except %d." % [_name(cell), digit],
			PackedInt32Array([cell]), SudokuRules.peers(cell))
		d.add_step("So %s is %d." % [_name(cell), digit], PackedInt32Array([cell]))
		return d
	return null


# --- Intersections ----------------------------------------------------------

func _eliminate(technique: String, level: int, targets: PackedInt32Array, mask: int) -> Deduction:
	var d := Deduction.new(technique, level, false)
	var payload: Array = []
	for cell in targets:
		payload.append([cell, mask])
	d.payload = payload
	return d


func _pointing() -> Deduction:
	var units := SudokuRules.units()
	for b in 9:
		var box := units[18 + b]
		for digit in range(1, 10):
			var spots := _cells_with(box, digit)
			if spots.size() < 2:
				continue
			for line_kind in [0, 9]:
				var line_index: int = line_kind + (spots[0] / 9 if line_kind == 0 else spots[0] % 9)
				var aligned := true
				for cell in spots:
					var this_line: int = line_kind + (cell / 9 if line_kind == 0 else cell % 9)
					if this_line != line_index:
						aligned = false
						break
				if not aligned:
					continue
				var targets := PackedInt32Array()
				for cell in units[line_index]:
					if SudokuRules.box_of(cell) != b and candidates[cell] & (1 << digit):
						targets.append(cell)
				if targets.is_empty():
					continue
				var d := _eliminate("Pointing", 3, targets, 1 << digit)
				d.add_step("In %s, the %d can only go in %s." % [SudokuRules.unit_name(18 + b), digit, SudokuRules.unit_name(line_index)], spots, box)
				d.add_step("Whichever cell it takes, %s gets its %d from this box, so %d is ruled out in the rest of that line." % [
					SudokuRules.unit_name(line_index), digit, digit], targets, spots)
				return d
	return null


func _claiming() -> Deduction:
	var units := SudokuRules.units()
	for u in 18:
		var line: PackedInt32Array = units[u]
		for digit in range(1, 10):
			var spots := _cells_with(line, digit)
			if spots.size() < 2:
				continue
			var box := SudokuRules.box_of(spots[0])
			var same_box := true
			for cell in spots:
				if SudokuRules.box_of(cell) != box:
					same_box = false
					break
			if not same_box:
				continue
			var targets := PackedInt32Array()
			for cell in units[18 + box]:
				if not (cell in line) and candidates[cell] & (1 << digit):
					targets.append(cell)
			if targets.is_empty():
				continue
			var d := _eliminate("Claiming", 3, targets, 1 << digit)
			d.add_step("In %s, the %d can only go inside %s." % [SudokuRules.unit_name(u), digit, SudokuRules.unit_name(18 + box)], spots, line)
			d.add_step("That box's %d must therefore be on this line, so %d is ruled out in its other cells." % [digit, digit], targets, spots)
			return d
	return null


# --- Pairs -----------------------------------------------------------------

func _naked_pair() -> Deduction:
	var units := SudokuRules.units()
	for u in 27:
		var unit: PackedInt32Array = units[u]
		for i in unit.size():
			var a := unit[i]
			if values[a] != 0 or SudokuRules.bit_count(candidates[a]) != 2:
				continue
			for j in range(i + 1, unit.size()):
				var b := unit[j]
				if values[b] != 0 or candidates[b] != candidates[a]:
					continue
				var mask := candidates[a]
				var targets := PackedInt32Array()
				for cell in unit:
					if cell != a and cell != b and values[cell] == 0 and candidates[cell] & mask:
						targets.append(cell)
				if targets.is_empty():
					continue
				var digits := SudokuRules.digits_of(mask)
				var d := _eliminate("Naked pair", 4, targets, mask)
				d.add_step("In %s, these two cells can only be %d or %d." % [SudokuRules.unit_name(u), digits[0], digits[1]], PackedInt32Array([a, b]), unit)
				d.add_step("Between them they take both digits, so %d and %d are ruled out everywhere else in %s." % [
					digits[0], digits[1], SudokuRules.unit_name(u)], targets, PackedInt32Array([a, b]))
				return d
	return null


func _hidden_pair() -> Deduction:
	var units := SudokuRules.units()
	for u in 27:
		var unit: PackedInt32Array = units[u]
		for d1 in range(1, 10):
			var spots1 := _cells_with(unit, d1)
			if spots1.size() != 2:
				continue
			for d2 in range(d1 + 1, 10):
				var spots2 := _cells_with(unit, d2)
				if spots2 != spots1:
					continue
				var keep := (1 << d1) | (1 << d2)
				var targets := PackedInt32Array()
				for cell in spots1:
					if candidates[cell] & ~keep:
						targets.append(cell)
				if targets.is_empty():
					continue
				var d := _eliminate("Hidden pair", 4, targets, SudokuRules.ALL_CANDIDATES & ~keep)
				d.add_step("In %s, the digits %d and %d can only go in these two cells." % [SudokuRules.unit_name(u), d1, d2], spots1, unit)
				d.add_step("Those cells must hold %d and %d, so every other digit is ruled out in them." % [d1, d2], targets)
				return d
	return null
