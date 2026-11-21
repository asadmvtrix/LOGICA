extends "res://tests/test_case.gd"

const S := TangoPuzzle.SUN
const M := TangoPuzzle.MOON


func _no_edges() -> Array[PackedInt32Array]:
	var edges: Array[PackedInt32Array] = []
	return edges


func _puzzle(key: String, level: int = 2) -> TangoPuzzle:
	return TangoGenerator.generate(level, SeededRandom.create(key))


func test_rules_flag_three_in_a_row_and_edges() -> void:
	var cells := PackedInt32Array()
	cells.resize(36)
	cells[0] = S
	cells[1] = S
	cells[2] = S
	var edges: Array[PackedInt32Array] = [PackedInt32Array([6, 7, TangoPuzzle.EQUAL])]
	cells[6] = S
	cells[7] = M
	var flags := TangoRules.conflicts(6, edges, cells)
	assert_eq(flags[0], 1)
	assert_eq(flags[2], 1)
	assert_eq(flags[6], 1, "broken = sign")
	assert_eq(flags[12], 0)


func test_random_grid_is_valid() -> void:
	var grid := TangoSolver.random_grid(6, SeededRandom.create("grid"))
	assert_true(TangoRules.is_solved(6, _no_edges(), grid))


func test_generated_puzzles_are_unique_at_every_level() -> void:
	for level in range(1, 5):
		var puzzle := _puzzle("tango-%d" % level, level)
		assert_eq(TangoSolver.count_solutions(puzzle, 3), 1, "level %d" % level)
		assert_true(TangoLogic.new(puzzle.size, puzzle.givens, puzzle.edges).solve(level) >= 0, "logic solves level %d" % level)
		for cell in 36:
			if puzzle.givens[cell] != TangoPuzzle.EMPTY:
				assert_eq(puzzle.givens[cell], puzzle.solution[cell])


func test_generation_is_deterministic() -> void:
	var a := _puzzle("same")
	var b := _puzzle("same")
	assert_eq(a.givens, b.givens)
	assert_eq(a.edges.size(), b.edges.size())


func test_pair_deduction_explains_itself() -> void:
	var cells := PackedInt32Array()
	cells.resize(36)
	cells[1] = S
	cells[2] = S
	var logic := TangoLogic.new(6, cells, _no_edges())
	var d := logic.next_deduction(1)
	assert_true(d != null)
	assert_eq(d.changes[0][2], M)
	assert_true(d.steps[0].text.contains("sun"))


func test_givens_are_locked() -> void:
	var puzzle := _puzzle("locked")
	var game := TangoGame.new(puzzle, 1, "locked")
	var given := puzzle.givens.find(S)
	if given < 0:
		given = puzzle.givens.find(M)
	var before := game.value(given)
	game.cycle(given)
	assert_eq(game.value(given), before)


func test_hints_alone_solve_the_puzzle() -> void:
	var game := TangoGame.new(_puzzle("hints", 3), 2, "hints")
	HintTestUtil.solve_with_hints(self, game)
