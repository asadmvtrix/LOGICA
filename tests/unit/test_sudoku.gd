extends "res://tests/test_case.gd"


func _puzzle(key: String, max_level: int = 1, min_level: int = 0) -> SudokuPuzzle:
	return SudokuGenerator.generate(max_level, min_level, SeededRandom.create(key))


func test_units_and_peers() -> void:
	assert_eq(SudokuRules.units().size(), 27)
	assert_eq(SudokuRules.peers(0).size(), 20)
	assert_eq(SudokuRules.box_of(80), 8)


func test_conflicts_mark_duplicates() -> void:
	var cells := PackedInt32Array()
	cells.resize(81)
	cells[0] = 5
	cells[8] = 5
	var flags := SudokuRules.conflicts(cells)
	assert_eq(flags[0], 1)
	assert_eq(flags[8], 1)
	assert_eq(flags[1], 0)


func test_random_grid_is_complete_and_valid() -> void:
	assert_true(SudokuRules.is_solved(SudokuSolver.random_grid(SeededRandom.create("grid"))))


func test_generated_puzzle_is_unique_and_logic_solvable() -> void:
	for key in ["sudoku-a", "sudoku-b"]:
		var puzzle := _puzzle(key)
		assert_eq(SudokuSolver.count_solutions(puzzle.givens, 3), 1, key)
		assert_true(SudokuLogic.new(puzzle.givens).solve(1) >= 0, key)
		assert_true(puzzle.clue_count() < 50, "%s clues %d" % [key, puzzle.clue_count()])


func test_harder_puzzle_needs_harder_technique() -> void:
	var puzzle := _puzzle("sudoku-medium", 3, 3)
	assert_eq(SudokuSolver.count_solutions(puzzle.givens, 3), 1)
	assert_true(SudokuLogic.new(puzzle.givens).solve(3) >= 0)


func test_entry_clears_peer_notes_in_one_step() -> void:
	var game := SudokuGame.new(_puzzle("notes"), 0, "notes")
	var empty := game.puzzle.givens.find(0)
	var peer := -1
	for p in SudokuRules.peers(empty):
		if game.puzzle.givens[p] == 0:
			peer = p
			break
	game.toggle_note(peer, 4)
	assert_eq(game.value(peer, 1), 1 << 4)
	game.set_digit(empty, 4)
	assert_eq(game.value(peer, 1), 0, "note removed from peer")
	assert_true(game.undo())
	assert_eq(game.value(peer, 1), 1 << 4, "undo restores the note")
	assert_eq(game.value(empty), 0)


func test_wrong_digit_gets_a_correction_hint() -> void:
	var game := SudokuGame.new(_puzzle("wrong"), 0, "wrong")
	var cell := game.puzzle.givens.find(0)
	var wrong := game.puzzle.solution[cell] % 9 + 1
	game.set_digit(cell, wrong)
	assert_eq(game.mistakes, 1)
	var result := game.hint_engine().reveal(game)
	assert_true(result.is_correction)


func test_hints_alone_solve_the_puzzle() -> void:
	var game := SudokuGame.new(_puzzle("hints", 2), 1, "hints")
	HintTestUtil.solve_with_hints(self, game)
