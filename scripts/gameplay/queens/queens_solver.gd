class_name QueensSolver
extends RefCounted
## Exhaustive backtracking solver, used to prove uniqueness and in tests.


## Number of solutions, counting no further than limit.
static func count_solutions(size: int, regions: PackedInt32Array, limit: int = 2) -> int:
	var columns := PackedByteArray()
	columns.resize(size)
	var used_regions := PackedByteArray()
	used_regions.resize(size)
	var placed := PackedInt32Array()
	placed.resize(size)
	return _search(0, size, regions, columns, used_regions, placed, limit)


static func _search(row: int, size: int, regions: PackedInt32Array, columns: PackedByteArray,
		used_regions: PackedByteArray, placed: PackedInt32Array, limit: int) -> int:
	if row == size:
		return 1
	var found := 0
	for column in size:
		if columns[column] == 1:
			continue
		if row > 0 and absi(placed[row - 1] - column) <= 1:
			continue
		var region := regions[row * size + column]
		if used_regions[region] == 1:
			continue
		columns[column] = 1
		used_regions[region] = 1
		placed[row] = column
		found += _search(row + 1, size, regions, columns, used_regions, placed, limit - found)
		columns[column] = 0
		used_regions[region] = 0
		if found >= limit:
			return found
	return found


## The solution as a column per row, or an empty array if there is none.
static func solve(size: int, regions: PackedInt32Array) -> PackedInt32Array:
	var columns := PackedByteArray()
	columns.resize(size)
	var used_regions := PackedByteArray()
	used_regions.resize(size)
	var placed := PackedInt32Array()
	placed.resize(size)
	if _first(0, size, regions, columns, used_regions, placed):
		return placed
	return PackedInt32Array()


static func _first(row: int, size: int, regions: PackedInt32Array, columns: PackedByteArray,
		used_regions: PackedByteArray, placed: PackedInt32Array) -> bool:
	if row == size:
		return true
	for column in size:
		var region := regions[row * size + column]
		if columns[column] == 1 or used_regions[region] == 1:
			continue
		if row > 0 and absi(placed[row - 1] - column) <= 1:
			continue
		columns[column] = 1
		used_regions[region] = 1
		placed[row] = column
		if _first(row + 1, size, regions, columns, used_regions, placed):
			return true
		columns[column] = 0
		used_regions[region] = 0
	return false
