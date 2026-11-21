class_name HintTestUtil
extends RefCounted
## Shared check: repeatedly applying reveal hints must solve a puzzle, every
## hint must have an explanation, and every placement must agree with the
## unique solution (the game counts disagreements as mistakes).


## test is the calling test case (untyped: test scripts have no class_name).
static func solve_with_hints(test, game: PuzzleGame, limit: int = 400) -> void:
	var engine := game.hint_engine()
	for i in limit:
		if game.is_solved:
			break
		var tactical := engine.tactical(game)
		var result := engine.reveal(game)
		if not result.available:
			test.fail("No hint at step %d: %s" % [i, result.steps[0].text if not result.steps.is_empty() else ""])
			return
		if result.is_correction:
			test.fail("Unexpected correction at step %d" % i)
			return
		if result.steps.is_empty() or result.steps.back().text.is_empty():
			test.fail("Hint without explanation at step %d" % i)
			return
		if tactical.steps.size() < result.steps.size() - 1:
			test.fail("Tactical hint shorter than reveal at step %d" % i)
			return
		if not game.apply(result.changes):
			test.fail("Hint changed nothing at step %d (%s)" % [i, result.title])
			return
	test.assert_true(game.is_solved, "solved by hints alone")
	test.assert_eq(game.mistakes, 0, "hints never place a wrong value")
	var after := engine.reveal(game)
	test.assert_false(after.available, "no hint once solved")
