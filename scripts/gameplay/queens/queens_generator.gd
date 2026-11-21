class_name QueensGenerator
extends RefCounted
## Generates Queens puzzles: places a random valid set of queens, grows one
## region from each queen, then keeps the layout only if it has exactly one
## solution and QueensLogic can solve it within the allowed level.

const MAX_ATTEMPTS := 4000


static func generate(size: int, max_level: int, rng: RandomNumberGenerator) -> QueensPuzzle:
	for attempt in MAX_ATTEMPTS:
		var solution := _random_queens(size, rng)
		if solution.is_empty():
			continue
		var regions := _grow_regions(size, solution, rng)
		if QueensSolver.count_solutions(size, regions, 2) != 1:
			continue
		var puzzle := QueensPuzzle.new(size, regions, solution)
		if QueensLogic.new(puzzle).solve(max_level) < 0:
			continue
		return puzzle
	push_error("Queens generator gave up (size %d)" % size)
	return null


static func _random_queens(size: int, rng: RandomNumberGenerator) -> PackedInt32Array:
	var placed := PackedInt32Array()
	placed.resize(size)
	var used := PackedByteArray()
	used.resize(size)
	if _place_row(0, size, placed, used, rng):
		return placed
	return PackedInt32Array()


static func _place_row(row: int, size: int, placed: PackedInt32Array, used: PackedByteArray, rng: RandomNumberGenerator) -> bool:
	if row == size:
		return true
	for column: int in SeededRandom.range_shuffled(size, rng):
		if used[column] == 1 or (row > 0 and absi(placed[row - 1] - column) <= 1):
			continue
		used[column] = 1
		placed[row] = column
		if _place_row(row + 1, size, placed, used, rng):
			return true
		used[column] = 0
	return false


## Random flood fill: each step assigns a random unassigned neighbour of the
## grown area to the region it touches.
static func _grow_regions(size: int, solution: PackedInt32Array, rng: RandomNumberGenerator) -> PackedInt32Array:
	var regions := PackedInt32Array()
	regions.resize(size * size)
	regions.fill(-1)
	var frontier: Array = []
	for row in size:
		var cell := row * size + solution[row]
		regions[cell] = row
		_push_neighbours(cell, size, frontier)
	var remaining := size * size - size
	while remaining > 0 and not frontier.is_empty():
		var pick := rng.randi_range(0, frontier.size() - 1)
		var entry: Array = frontier[pick]
		frontier[pick] = frontier.back()
		frontier.pop_back()
		var target: int = entry[1]
		if regions[target] != -1:
			continue
		regions[target] = regions[entry[0]]
		remaining -= 1
		_push_neighbours(target, size, frontier)
	return regions


static func _push_neighbours(cell: int, size: int, frontier: Array) -> void:
	var r := cell / size
	var c := cell % size
	if r > 0:
		frontier.append([cell, cell - size])
	if r < size - 1:
		frontier.append([cell, cell + size])
	if c > 0:
		frontier.append([cell, cell - 1])
	if c < size - 1:
		frontier.append([cell, cell + 1])
