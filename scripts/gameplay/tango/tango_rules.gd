class_name TangoRules
extends RefCounted
## Rule checks for Tango boards.


static func line_cells(size: int, is_row: bool, number: int) -> PackedInt32Array:
	var cells := PackedInt32Array()
	for k in size:
		cells.append(number * size + k if is_row else k * size + number)
	return cells


## 1 for every cell involved in a broken rule.
static func conflicts(size: int, edges: Array[PackedInt32Array], cells: PackedInt32Array) -> PackedByteArray:
	var result := PackedByteArray()
	result.resize(cells.size())
	var half := size / 2
	for is_row in [true, false]:
		for n in size:
			var line := line_cells(size, is_row, n)
			for k in range(2, size):
				var v := cells[line[k]]
				if v != TangoPuzzle.EMPTY and cells[line[k - 1]] == v and cells[line[k - 2]] == v:
					result[line[k]] = 1
					result[line[k - 1]] = 1
					result[line[k - 2]] = 1
			for symbol in [TangoPuzzle.SUN, TangoPuzzle.MOON]:
				var count := 0
				for cell in line:
					if cells[cell] == symbol:
						count += 1
				if count > half:
					for cell in line:
						if cells[cell] == symbol:
							result[cell] = 1
	for edge in edges:
		var a := cells[edge[0]]
		var b := cells[edge[1]]
		if a == TangoPuzzle.EMPTY or b == TangoPuzzle.EMPTY:
			continue
		if (edge[2] == TangoPuzzle.EQUAL) != (a == b):
			result[edge[0]] = 1
			result[edge[1]] = 1
	return result


static func is_solved(size: int, edges: Array[PackedInt32Array], cells: PackedInt32Array) -> bool:
	for v in cells:
		if v == TangoPuzzle.EMPTY:
			return false
	for flag in conflicts(size, edges, cells):
		if flag == 1:
			return false
	return true


## True when the filled cells of one line break no line rule and every edge
## inside the line holds. Empty cells are ignored.
static func line_ok(size: int, values: PackedInt32Array, line_edges: Array) -> bool:
	var half := size / 2
	var suns := 0
	var moons := 0
	for k in values.size():
		var v := values[k]
		if v == TangoPuzzle.SUN:
			suns += 1
		elif v == TangoPuzzle.MOON:
			moons += 1
		if k >= 2 and v != TangoPuzzle.EMPTY and values[k - 1] == v and values[k - 2] == v:
			return false
	if suns > half or moons > half:
		return false
	for e: PackedInt32Array in line_edges:
		var a := values[e[0]]
		var b := values[e[1]]
		if a != TangoPuzzle.EMPTY and b != TangoPuzzle.EMPTY and (e[2] == TangoPuzzle.EQUAL) != (a == b):
			return false
	return true
