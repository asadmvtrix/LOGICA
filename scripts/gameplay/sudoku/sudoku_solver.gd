class_name SudokuSolver
extends RefCounted
## Backtracking with candidate masks and fewest-candidates-first ordering.
## Used to prove uniqueness in tests and to build random complete grids.


static func count_solutions(cells: PackedInt32Array, limit: int = 2) -> int:
	var grid := cells.duplicate()
	return _search(grid, limit, null, [])


static func random_grid(rng: RandomNumberGenerator) -> PackedInt32Array:
	var grid := PackedInt32Array()
	grid.resize(81)
	var found: Array = []
	_search(grid, 1, rng, found)
	return found[0] if not found.is_empty() else PackedInt32Array()


static func _candidates(grid: PackedInt32Array, cell: int) -> int:
	var mask := SudokuRules.ALL_CANDIDATES
	for peer in SudokuRules.peers(cell):
		mask &= ~(1 << grid[peer])
	return mask


static func _search(grid: PackedInt32Array, limit: int, rng: RandomNumberGenerator, found: Array) -> int:
	var best := -1
	var best_mask := 0
	var best_count := 10
	for cell in 81:
		if grid[cell] != 0:
			continue
		var mask := _candidates(grid, cell)
		var count := SudokuRules.bit_count(mask)
		if count == 0:
			return 0
		if count < best_count:
			best = cell
			best_mask = mask
			best_count = count
			if count == 1:
				break
	if best < 0:
		if rng != null:
			found.append(grid.duplicate())
		return 1
	var digits := Array(SudokuRules.digits_of(best_mask))
	if rng != null:
		SeededRandom.shuffle(digits, rng)
	var total := 0
	for d: int in digits:
		grid[best] = d
		total += _search(grid, limit - total, rng, found)
		if total >= limit:
			break
	grid[best] = 0
	return total
