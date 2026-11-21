class_name TangoSolver
extends RefCounted
## Exhaustive backtracking for Tango: counts solutions (uniqueness proofs in
## tests) and builds random complete grids for the generator.


static func count_solutions(puzzle: TangoPuzzle, limit: int = 2) -> int:
	var cells := puzzle.givens.duplicate()
	var edge_map := _edge_map(puzzle.size, puzzle.edges)
	return _search(0, puzzle.size, cells, edge_map, limit, null, [])


## A random complete valid grid (no givens or edges).
static func random_grid(size: int, rng: RandomNumberGenerator) -> PackedInt32Array:
	var cells := PackedInt32Array()
	cells.resize(size * size)
	var found: Array = []
	_search(0, size, cells, {}, 1, rng, found)
	return found[0] if not found.is_empty() else PackedInt32Array()


static func _edge_map(size: int, edges: Array[PackedInt32Array]) -> Dictionary:
	var map := {}
	for e in edges:
		map[e[0] * size * size + e[1]] = e[2]
	return map


static func _search(index: int, size: int, cells: PackedInt32Array, edge_map: Dictionary, limit: int,
		rng: RandomNumberGenerator, found: Array) -> int:
	if index == cells.size():
		if rng != null:
			found.append(cells.duplicate())
		return 1
	if cells[index] != TangoPuzzle.EMPTY:
		return _search(index + 1, size, cells, edge_map, limit, rng, found) if _fits(index, size, cells, edge_map) else 0
	var order := [TangoPuzzle.SUN, TangoPuzzle.MOON]
	if rng != null and rng.randi() % 2 == 1:
		order = [TangoPuzzle.MOON, TangoPuzzle.SUN]
	var total := 0
	for symbol: int in order:
		cells[index] = symbol
		if _fits(index, size, cells, edge_map):
			total += _search(index + 1, size, cells, edge_map, limit - total, rng, found)
			if total >= limit:
				cells[index] = TangoPuzzle.EMPTY
				return total
	cells[index] = TangoPuzzle.EMPTY
	return total


## Checks the rules affected by the cell just filled, given that every
## earlier cell (row-major) is filled.
static func _fits(index: int, size: int, cells: PackedInt32Array, edge_map: Dictionary) -> bool:
	var r := index / size
	var c := index % size
	var v := cells[index]
	if c >= 2 and cells[index - 1] == v and cells[index - 2] == v:
		return false
	if r >= 2 and cells[index - size] == v and cells[index - 2 * size] == v:
		return false
	var half := size / 2
	var row_count := 0
	for k in c + 1:
		if cells[r * size + k] == v:
			row_count += 1
	if row_count > half:
		return false
	var column_count := 0
	for k in r + 1:
		if cells[k * size + c] == v:
			column_count += 1
	if column_count > half:
		return false
	var n2 := size * size
	if c > 0 and edge_map.has((index - 1) * n2 + index):
		if (edge_map[(index - 1) * n2 + index] == TangoPuzzle.EQUAL) != (cells[index - 1] == v):
			return false
	if r > 0 and edge_map.has((index - size) * n2 + index):
		if (edge_map[(index - size) * n2 + index] == TangoPuzzle.EQUAL) != (cells[index - size] == v):
			return false
	return true
