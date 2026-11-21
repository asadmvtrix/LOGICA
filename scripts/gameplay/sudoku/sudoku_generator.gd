class_name SudokuGenerator
extends RefCounted
## Generates Sudoku puzzles: a random complete grid, then clues removed in
## symmetric pairs while SudokuLogic can still solve it within max_level.
## Solvable by sound logic implies a unique solution. When min_level is set,
## grids whose hardest step is easier than that are retried a few times.

const GRID_ATTEMPTS := 6


static func generate(max_level: int, min_level: int, rng: RandomNumberGenerator) -> SudokuPuzzle:
	var best: SudokuPuzzle = null
	for attempt in GRID_ATTEMPTS:
		var solution := SudokuSolver.random_grid(rng)
		var givens := solution.duplicate()
		var order: Array = SeededRandom.range_shuffled(41, rng)
		for cell: int in order:
			var mirror := 80 - cell
			var saved_a := givens[cell]
			var saved_b := givens[mirror]
			givens[cell] = 0
			givens[mirror] = 0
			if SudokuLogic.new(givens).solve(max_level) < 0:
				givens[cell] = saved_a
				givens[mirror] = saved_b
		best = SudokuPuzzle.new(givens, solution)
		if SudokuLogic.new(givens).solve(max_level) >= min_level:
			return best
	return best
