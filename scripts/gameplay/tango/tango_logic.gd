class_name TangoLogic
extends RefCounted
## Sound deductions for Tango. Every deduction places at least one symbol.
## Levels: 1 edge clues, pairs and gaps; 2 a line's count is full;
## 3 every valid completion of a line agrees; 4 an assumption leads to a
## broken rule.

const MAX_LEVEL := 4

var size: int
var cells: PackedInt32Array
var edges: Array[PackedInt32Array]


func _init(p_size: int, p_cells: PackedInt32Array, p_edges: Array[PackedInt32Array]) -> void:
	size = p_size
	cells = p_cells.duplicate()
	edges = p_edges


func copy() -> TangoLogic:
	return TangoLogic.new(size, cells, edges)


func empty_count() -> int:
	var count := 0
	for v in cells:
		if v == TangoPuzzle.EMPTY:
			count += 1
	return count


func apply(deduction: Deduction) -> void:
	for change in deduction.changes:
		cells[change[1]] = change[2]


## Hardest level used to fill the grid, or -1 when stuck.
func solve(max_level: int = MAX_LEVEL) -> int:
	var hardest := 0
	while empty_count() > 0:
		var deduction := next_deduction(max_level)
		if deduction == null:
			return -1
		hardest = maxi(hardest, deduction.level)
		apply(deduction)
	if has_conflict():
		return -1
	return hardest


func has_conflict() -> bool:
	for flag in TangoRules.conflicts(size, edges, cells):
		if flag == 1:
			return true
	return false


func next_deduction(max_level: int = MAX_LEVEL) -> Deduction:
	var found := _edge_clue()
	if found == null:
		found = _pair()
	if found == null:
		found = _gap()
	if found == null and max_level >= 2:
		found = _count()
	if found == null and max_level >= 3:
		found = _line_analysis()
	if found == null and max_level >= 4:
		found = _contradiction()
	return found


func _name(cell: int) -> String:
	return CellNames.cell(cell, size)


func _place(technique: String, level: int, cell: int, symbol: int) -> Deduction:
	var d := Deduction.new(technique, level, true)
	d.changes.append([0, cell, symbol])
	return d


# --- Level 1 ---------------------------------------------------------------

func _edge_clue() -> Deduction:
	for e in edges:
		var a := cells[e[0]]
		var b := cells[e[1]]
		if (a == TangoPuzzle.EMPTY) == (b == TangoPuzzle.EMPTY):
			continue
		var known := e[0] if a != TangoPuzzle.EMPTY else e[1]
		var target := e[1] if known == e[0] else e[0]
		var symbol := cells[known]
		var result := symbol if e[2] == TangoPuzzle.EQUAL else TangoPuzzle.opposite(symbol)
		var sign := "=" if e[2] == TangoPuzzle.EQUAL else "×"
		var meaning := "match" if e[2] == TangoPuzzle.EQUAL else "differ"
		var d := _place("Edge clue", 1, target, result)
		d.add_step("The %s sign between these cells means they %s. One is a %s, so the other is a %s." % [
			sign, meaning, TangoPuzzle.symbol_name(symbol), TangoPuzzle.symbol_name(result)], PackedInt32Array([target]), PackedInt32Array([known]))
		return d
	return null


func _pair() -> Deduction:
	for is_row in [true, false]:
		for n in size:
			var line := TangoRules.line_cells(size, is_row, n)
			for k in size - 1:
				var v := cells[line[k]]
				if v == TangoPuzzle.EMPTY or cells[line[k + 1]] != v:
					continue
				for end in [k - 1, k + 2]:
					if end >= 0 and end < size and cells[line[end]] == TangoPuzzle.EMPTY:
						var result := TangoPuzzle.opposite(v)
						var d := _place("Pair", 1, line[end], result)
						d.add_step("Two %ss sit side by side in %s. A third in a row is not allowed, so this cell is a %s." % [
							TangoPuzzle.symbol_name(v), CellNames.line(is_row, n), TangoPuzzle.symbol_name(result)],
							PackedInt32Array([line[end]]), PackedInt32Array([line[k], line[k + 1]]))
						return d
	return null


func _gap() -> Deduction:
	for is_row in [true, false]:
		for n in size:
			var line := TangoRules.line_cells(size, is_row, n)
			for k in range(1, size - 1):
				var v := cells[line[k - 1]]
				if v == TangoPuzzle.EMPTY or cells[line[k + 1]] != v or cells[line[k]] != TangoPuzzle.EMPTY:
					continue
				var result := TangoPuzzle.opposite(v)
				var d := _place("Gap", 1, line[k], result)
				d.add_step("This cell sits between two %ss in %s. Another %s here would make three in a row, so it is a %s." % [
					TangoPuzzle.symbol_name(v), CellNames.line(is_row, n), TangoPuzzle.symbol_name(v), TangoPuzzle.symbol_name(result)],
					PackedInt32Array([line[k]]), PackedInt32Array([line[k - 1], line[k + 1]]))
				return d
	return null


# --- Level 2 ---------------------------------------------------------------

func _count() -> Deduction:
	var half := size / 2
	for is_row in [true, false]:
		for n in size:
			var line := TangoRules.line_cells(size, is_row, n)
			for symbol in [TangoPuzzle.SUN, TangoPuzzle.MOON]:
				var have := PackedInt32Array()
				var empty := PackedInt32Array()
				for cell in line:
					if cells[cell] == symbol:
						have.append(cell)
					elif cells[cell] == TangoPuzzle.EMPTY:
						empty.append(cell)
				if have.size() != half or empty.is_empty():
					continue
				var result := TangoPuzzle.opposite(symbol)
				var d := Deduction.new("Line count", 2, true)
				d.add_step("%s already has %d %ss, which is its full share. Every empty cell left in it is a %s." % [
					CellNames.sentence_case(CellNames.line(is_row, n)), half, TangoPuzzle.symbol_name(symbol), TangoPuzzle.symbol_name(result)], empty, have)
				for cell in empty:
					d.changes.append([0, cell, result])
				return d
	return null


# --- Level 3 ---------------------------------------------------------------

func _line_edges(line: PackedInt32Array) -> Array:
	var local: Array = []
	for e in edges:
		var ka := line.find(e[0])
		var kb := line.find(e[1])
		if ka >= 0 and kb >= 0:
			local.append(PackedInt32Array([ka, kb, e[2]]))
	return local


## Valid completions of a line, or an empty array when it cannot be completed.
func _completions(line: PackedInt32Array) -> Array[PackedInt32Array]:
	var base := PackedInt32Array()
	var empties := PackedInt32Array()
	for k in line.size():
		base.append(cells[line[k]])
		if cells[line[k]] == TangoPuzzle.EMPTY:
			empties.append(k)
	var local_edges := _line_edges(line)
	var result: Array[PackedInt32Array] = []
	for mask in 1 << empties.size():
		var values := base.duplicate()
		for j in empties.size():
			values[empties[j]] = TangoPuzzle.MOON if (mask >> j) & 1 else TangoPuzzle.SUN
		if TangoRules.line_ok(size, values, local_edges):
			result.append(values)
	return result


func _line_analysis() -> Deduction:
	for is_row in [true, false]:
		for n in size:
			var line := TangoRules.line_cells(size, is_row, n)
			var completions := _completions(line)
			if completions.is_empty():
				continue
			var forced := PackedInt32Array()
			var forced_values := PackedInt32Array()
			for k in size:
				if cells[line[k]] != TangoPuzzle.EMPTY:
					continue
				var first := completions[0][k]
				var agree := true
				for values in completions:
					if values[k] != first:
						agree = false
						break
				if agree:
					forced.append(line[k])
					forced_values.append(first)
			if forced.is_empty():
				continue
			var line_name := CellNames.line(is_row, n)
			var d := Deduction.new("Line analysis", 3, true)
			d.add_step("Try every way to finish %s: it needs three of each symbol, no three in a row, and must respect its signs." % line_name, PackedInt32Array(), line)
			var what := TangoPuzzle.symbol_name(forced_values[0]) if forced.size() == 1 else "the same symbol"
			d.add_step("Only %d way%s work%s, and %s always get%s %s." % [
				completions.size(), "" if completions.size() == 1 else "s", "s" if completions.size() == 1 else "",
				"this cell" if forced.size() == 1 else "these cells", "s" if forced.size() == 1 else "", what], forced, line)
			for j in forced.size():
				d.changes.append([0, forced[j], forced_values[j]])
			return d
	return null


# --- Level 4 ---------------------------------------------------------------

func _contradiction() -> Deduction:
	for cell in cells.size():
		if cells[cell] != TangoPuzzle.EMPTY:
			continue
		for symbol in [TangoPuzzle.SUN, TangoPuzzle.MOON]:
			var trial := copy()
			trial.cells[cell] = symbol
			var broken := trial._propagate_until_broken()
			if broken.is_empty():
				continue
			var result := TangoPuzzle.opposite(symbol)
			var d := _place("Contradiction", 4, cell, result)
			d.add_step("Suppose %s were a %s." % [_name(cell), TangoPuzzle.symbol_name(symbol)], PackedInt32Array([cell]))
			d.add_step("Following the simpler rules from there, %s." % broken, PackedInt32Array([cell]))
			d.add_step("That is impossible, so this cell must be a %s." % TangoPuzzle.symbol_name(result), PackedInt32Array([cell]))
			return d
	return null


## Applies level 1 to 3 deductions until stuck. Returns a description of the
## first broken rule, or "" when none was found.
func _propagate_until_broken() -> String:
	for i in cells.size() + 1:
		var broken := _describe_break()
		if not broken.is_empty():
			return broken
		var deduction := next_deduction(3)
		if deduction == null:
			return _describe_dead_line()
		apply(deduction)
	return ""


func _describe_dead_line() -> String:
	for is_row in [true, false]:
		for n in size:
			if _completions(TangoRules.line_cells(size, is_row, n)).is_empty():
				return "%s could no longer be completed" % CellNames.line(is_row, n)
	return ""


func _describe_break() -> String:
	var half := size / 2
	for is_row in [true, false]:
		for n in size:
			var line := TangoRules.line_cells(size, is_row, n)
			var values := PackedInt32Array()
			for cell in line:
				values.append(cells[cell])
			var line_name := CellNames.line(is_row, n)
			var suns := values.count(TangoPuzzle.SUN)
			var moons := values.count(TangoPuzzle.MOON)
			if suns > half or moons > half:
				return "%s would hold more than %d of one symbol" % [line_name, half]
			for k in range(2, size):
				if values[k] != TangoPuzzle.EMPTY and values[k] == values[k - 1] and values[k] == values[k - 2]:
					return "%s would get three in a row" % line_name
	for e in edges:
		var a := cells[e[0]]
		var b := cells[e[1]]
		if a != TangoPuzzle.EMPTY and b != TangoPuzzle.EMPTY and (e[2] == TangoPuzzle.EQUAL) != (a == b):
			return "the sign between %s and %s would be broken" % [_name(e[0]), _name(e[1])]
	return ""
