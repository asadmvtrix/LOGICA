class_name TangoGenerator
extends RefCounted
## Generates Tango puzzles from a random complete grid. Starting from a full
## board, givens are removed in random order; when a removal would leave the
## puzzle unsolvable by TangoLogic at max_level, an edge clue is tried in its
## place, otherwise the given stays. Because every step is a sound deduction,
## solvability by logic also proves the solution is unique.

const SIZE := 6


static func generate(max_level: int, rng: RandomNumberGenerator, size: int = SIZE) -> TangoPuzzle:
	var solution := TangoSolver.random_grid(size, rng)
	var givens := solution.duplicate()
	var edges: Array[PackedInt32Array] = []
	for cell: int in SeededRandom.range_shuffled(size * size, rng):
		givens[cell] = TangoPuzzle.EMPTY
		if _solvable(size, givens, edges, max_level):
			continue
		var edge := _random_edge(size, cell, solution, edges, rng)
		if not edge.is_empty() and rng.randf() < 0.75:
			edges.append(edge)
			if _solvable(size, givens, edges, max_level):
				continue
			edges.pop_back()
		givens[cell] = solution[cell]
	edges.sort_custom(func(a: PackedInt32Array, b: PackedInt32Array) -> bool: return a[0] < b[0] or (a[0] == b[0] and a[1] < b[1]))
	return TangoPuzzle.new(size, givens, edges, solution)


static func _solvable(size: int, givens: PackedInt32Array, edges: Array[PackedInt32Array], max_level: int) -> bool:
	return TangoLogic.new(size, givens, edges).solve(max_level) >= 0


static func _random_edge(size: int, cell: int, solution: PackedInt32Array, edges: Array[PackedInt32Array], rng: RandomNumberGenerator) -> PackedInt32Array:
	var r := cell / size
	var c := cell % size
	var options: Array[int] = []
	if c > 0:
		options.append(cell - 1)
	if c < size - 1:
		options.append(cell + 1)
	if r > 0:
		options.append(cell - size)
	if r < size - 1:
		options.append(cell + size)
	SeededRandom.shuffle(options, rng)
	for other in options:
		var a := mini(cell, other)
		var b := maxi(cell, other)
		var taken := false
		for e in edges:
			if e[0] == a and e[1] == b:
				taken = true
				break
		if taken:
			continue
		var kind := TangoPuzzle.EQUAL if solution[a] == solution[b] else TangoPuzzle.OPPOSITE
		return PackedInt32Array([a, b, kind])
	return PackedInt32Array()
