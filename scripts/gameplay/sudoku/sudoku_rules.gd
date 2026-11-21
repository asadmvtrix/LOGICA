class_name SudokuRules
extends RefCounted
## Classic 9 x 9 Sudoku geometry and rule checks. Digits 1-9, 0 is empty.

const SIZE := 9
const ALL_CANDIDATES := 0x3FE
const BOX_NAMES: Array[String] = [
	"top-left box", "top box", "top-right box",
	"left box", "centre box", "right box",
	"bottom-left box", "bottom box", "bottom-right box",
]

static var _units: Array[PackedInt32Array] = []
static var _peers: Array[PackedInt32Array] = []


## 27 units: rows 0-8, columns 9-17, boxes 18-26.
static func units() -> Array[PackedInt32Array]:
	if _units.is_empty():
		_build()
	return _units


static func peers(cell: int) -> PackedInt32Array:
	if _peers.is_empty():
		_build()
	return _peers[cell]


static func box_of(cell: int) -> int:
	return (cell / 27) * 3 + (cell % 9) / 3


static func unit_name(unit: int) -> String:
	if unit < 9:
		return CellNames.row(unit)
	if unit < 18:
		return CellNames.column(unit - 9)
	return "the " + BOX_NAMES[unit - 18]


static func units_of(cell: int) -> PackedInt32Array:
	return PackedInt32Array([cell / 9, 9 + cell % 9, 18 + box_of(cell)])


static func _build() -> void:
	var built: Array[PackedInt32Array] = []
	for r in 9:
		var row := PackedInt32Array()
		for c in 9:
			row.append(r * 9 + c)
		built.append(row)
	for c in 9:
		var column := PackedInt32Array()
		for r in 9:
			column.append(r * 9 + c)
		built.append(column)
	for b in 9:
		var box := PackedInt32Array()
		var top := (b / 3) * 3
		var left := (b % 3) * 3
		for r in 3:
			for c in 3:
				box.append((top + r) * 9 + left + c)
		built.append(box)
	var peer_lists: Array[PackedInt32Array] = []
	for cell in 81:
		var seen := {}
		for u in units_of(cell):
			for other in built[u]:
				if other != cell:
					seen[other] = true
		var list := PackedInt32Array()
		for other: int in seen:
			list.append(other)
		list.sort()
		peer_lists.append(list)
	_units = built
	_peers = peer_lists


static func conflicts(cells: PackedInt32Array) -> PackedByteArray:
	var result := PackedByteArray()
	result.resize(81)
	for unit in units():
		var seen := {}
		for cell in unit:
			var v := cells[cell]
			if v == 0:
				continue
			if seen.has(v):
				result[cell] = 1
				result[seen[v]] = 1
			else:
				seen[v] = cell
	return result


static func is_solved(cells: PackedInt32Array) -> bool:
	for v in cells:
		if v == 0:
			return false
	for flag in conflicts(cells):
		if flag == 1:
			return false
	return true


static func bit_count(mask: int) -> int:
	var count := 0
	while mask != 0:
		mask &= mask - 1
		count += 1
	return count


static func digits_of(mask: int) -> PackedInt32Array:
	var digits := PackedInt32Array()
	for d in range(1, 10):
		if mask & (1 << d):
			digits.append(d)
	return digits
