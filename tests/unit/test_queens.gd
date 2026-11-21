extends "res://tests/test_case.gd"

const SEEDS := ["queens-a", "queens-b", "queens-c"]


func _puzzle(key: String, size: int = 6, level: int = 2) -> QueensPuzzle:
	return QueensGenerator.generate(size, level, SeededRandom.create(key))


func test_attack_rules() -> void:
	var regions := PackedInt32Array()
	regions.resize(16)
	for i in 16:
		regions[i] = i % 4
	assert_true(QueensRules.attacks(4, regions, 0, 3), "same row")
	assert_true(QueensRules.attacks(4, regions, 0, 12), "same column")
	assert_true(QueensRules.attacks(4, regions, 0, 5), "diagonal touch")
	assert_false(QueensRules.attacks(4, regions, 1, 11), "far apart, different region")


func test_generated_puzzles_have_one_solution() -> void:
	for key in SEEDS:
		var puzzle := _puzzle(key)
		assert_true(puzzle != null, key)
		assert_eq(QueensSolver.count_solutions(puzzle.size, puzzle.regions, 3), 1, key)
		assert_eq(QueensSolver.solve(puzzle.size, puzzle.regions), puzzle.solution, key)


func test_logic_solves_within_level() -> void:
	for key in SEEDS:
		var puzzle := _puzzle(key, 7, 3)
		var level := QueensLogic.new(puzzle).solve(3)
		assert_true(level >= 1 and level <= 3, "%s level %d" % [key, level])


func test_generation_is_deterministic() -> void:
	var a := _puzzle("same-key")
	var b := _puzzle("same-key")
	assert_eq(a.regions, b.regions)
	assert_eq(a.solution, b.solution)


func test_every_region_is_connected_and_holds_a_queen() -> void:
	var puzzle := _puzzle("regions")
	for r in puzzle.size:
		var queens := 0
		for row in puzzle.size:
			if puzzle.regions[row * puzzle.size + puzzle.solution[row]] == r:
				queens += 1
		assert_eq(queens, 1, "region %d" % r)


func test_game_undo_redo_reset_and_save() -> void:
	var game := QueensGame.new(_puzzle("game"), 0, "game")
	game.cycle(0)
	game.cycle(0)
	assert_eq(game.value(0), QueensRules.QUEEN)
	assert_true(game.undo())
	assert_eq(game.value(0), QueensRules.MARK)
	assert_true(game.redo())
	assert_eq(game.value(0), QueensRules.QUEEN)
	var saved := game.to_save()
	assert_true(game.reset())
	assert_eq(game.value(0), QueensRules.EMPTY)
	assert_true(game.undo(), "reset is undoable")
	assert_eq(game.value(0), QueensRules.QUEEN)
	var restored := QueensGame.new(game.puzzle, 0, "game")
	assert_true(restored.load_save(saved))
	assert_eq(restored.value(0), QueensRules.QUEEN)


func test_drag_batch_is_one_undo_step() -> void:
	var game := QueensGame.new(_puzzle("batch"), 0, "batch")
	game.begin_batch()
	game.mark(0)
	game.mark(1)
	game.mark(2)
	game.end_batch()
	assert_true(game.undo())
	assert_eq(game.value(1), QueensRules.EMPTY)
	assert_false(game.history.can_undo())


func test_wrong_queen_gets_a_correction_hint() -> void:
	var puzzle := _puzzle("correction")
	var game := QueensGame.new(puzzle, 0, "correction")
	var wrong := -1
	for cell in puzzle.size * puzzle.size:
		if not puzzle.solution_has_queen(cell):
			wrong = cell
			break
	game.apply([[0, wrong, QueensRules.QUEEN]])
	var result := game.hint_engine().reveal(game)
	assert_true(result.available and result.is_correction)
	assert_eq(result.steps[0].focus, PackedInt32Array([wrong]))


func test_hints_alone_solve_the_puzzle() -> void:
	var game := QueensGame.new(_puzzle("hints", 7, 3), 1, "hints")
	HintTestUtil.solve_with_hints(self, game)
