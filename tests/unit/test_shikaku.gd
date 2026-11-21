extends "res://tests/test_case.gd"


func _puzzle(key: String, size: int = 5, max_area: int = 6, level: int = 2) -> ShikakuPuzzle:
	return ShikakuGenerator.generate(size, max_area, level, SeededRandom.create(key))


func test_generated_puzzles_are_unique() -> void:
	for key in ["shikaku-a", "shikaku-b", "shikaku-c"]:
		var puzzle := _puzzle(key, 6, 8, 2)
		assert_true(puzzle != null, key)
		assert_eq(ShikakuSolver.count_solutions(puzzle, 3), 1, key)
		var area := 0
		for cell in puzzle.clue_cells:
			area += puzzle.clues[cell]
		assert_eq(area, 36, "areas cover the grid")


func test_solution_rectangles_satisfy_rules() -> void:
	var puzzle := _puzzle("rules")
	var ids := PackedInt32Array()
	ids.resize(25)
	for i in puzzle.solution.size():
		for cell in puzzle.rect_cells(puzzle.solution[i]):
			ids[cell] = i + 1
	assert_true(ShikakuRules.is_solved(puzzle, ids))


func test_drawing_over_a_rectangle_replaces_it() -> void:
	var puzzle := _puzzle("draw")
	var game := ShikakuGame.new(puzzle, 0, "draw")
	game.draw_rect_between(0, 6)
	assert_true(game.value(0) != 0)
	var first := game.value(0)
	game.draw_rect_between(1, 1)
	assert_eq(game.value(0), 0, "overlapped rectangle removed entirely")
	assert_true(game.value(1) != 0 and game.value(1) != first)
	game.tap(1)
	assert_eq(game.value(1), 0, "tap removes")
	assert_true(game.undo())
	assert_true(game.value(1) != 0)


func test_wrong_rectangle_gets_a_correction_hint() -> void:
	var puzzle := _puzzle("wrong")
	var game := ShikakuGame.new(puzzle, 0, "wrong")
	var target := Rect2i(0, 0, 5, 1)
	if target in puzzle.solution:
		target = Rect2i(0, 0, 4, 1)
	game.apply(game.changes_for_rect(target))
	var result := game.hint_engine().reveal(game)
	assert_true(result.is_correction)


func test_hints_alone_solve_the_puzzle() -> void:
	var game := ShikakuGame.new(_puzzle("hints", 7, 10, 3), 2, "hints")
	HintTestUtil.solve_with_hints(self, game)
