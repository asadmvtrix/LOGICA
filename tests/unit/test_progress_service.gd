extends "res://tests/test_case.gd"

const PATH := "user://test_progress.json"

var store: JsonFileStore


func before_each() -> void:
	store = JsonFileStore.new(PATH)
	store.delete_all()


func after_each() -> void:
	store.delete_all()


func _solved_game(launch: PuzzleLaunch, seconds: float) -> PuzzleGame:
	var game := PuzzleModes.generate(launch.mode, launch.difficulty, launch.key)
	var queens := game as QueensGame
	var changes: Array = []
	for row in queens.puzzle.size:
		changes.append([0, row * queens.puzzle.size + queens.puzzle.solution[row], QueensRules.QUEEN])
	game.apply(changes)
	game.elapsed = seconds
	return game


func test_journey_advances_and_persists() -> void:
	var progress := ProgressService.new(store)
	progress.load_progress()
	assert_eq(progress.next_journey_level(PuzzleModes.QUEENS), 1)
	var launch := ProgressionCatalog.journey_launch(PuzzleModes.QUEENS, 1)
	var game := _solved_game(launch, 42.0)
	assert_true(game.is_solved)
	progress.record_solve(launch, game)
	assert_eq(progress.next_journey_level(PuzzleModes.QUEENS), 2)

	var reloaded := ProgressService.new(store)
	reloaded.load_progress()
	assert_eq(reloaded.journey_completed(PuzzleModes.QUEENS), 1)
	assert_true(reloaded.is_solved(launch.key))
	assert_eq(reloaded.mode_stats(PuzzleModes.QUEENS)["solved"], 1)
	assert_eq(int(store.read().data["version"]), ProgressService.SAVE_VERSION)


func test_better_time_is_a_new_best() -> void:
	var progress := ProgressService.new(store)
	var launch := ProgressionCatalog.journey_launch(PuzzleModes.QUEENS, 1)
	progress.record_solve(launch, _solved_game(launch, 60.0))
	var outcome := progress.record_solve(launch, _solved_game(launch, 30.0))
	assert_true(outcome["new_best"])
	assert_eq(progress.record_for(launch.key)["time"], 30.0)


func test_daily_streak_counts_consecutive_days() -> void:
	var progress := ProgressService.new(store)
	var days := [
		{"year": 2026, "month": 11, "day": 19, "weekday": 4},
		{"year": 2026, "month": 11, "day": 20, "weekday": 5},
		{"year": 2026, "month": 11, "day": 21, "weekday": 6},
	]
	for day: Dictionary in days:
		var launch := ProgressionCatalog.daily_launch(PuzzleModes.QUEENS, day)
		launch.difficulty = 0
		launch.key = "streak/%s" % launch.date
		progress.record_solve(launch, _solved_game(launch, 10.0))
	assert_eq(progress.daily_streak(days[2]), 3)
	assert_true(progress.daily_done("2026-11-21", PuzzleModes.QUEENS))
	assert_eq(progress.daily_streak({"year": 2026, "month": 11, "day": 23, "weekday": 1}), 0)


func test_session_round_trip_and_clear_on_solve() -> void:
	var progress := ProgressService.new(store)
	var launch := ProgressionCatalog.journey_launch(PuzzleModes.QUEENS, 3)
	var game := PuzzleModes.generate(launch.mode, launch.difficulty, launch.key)
	game.apply([[0, 0, QueensRules.MARK]])
	game.elapsed = 12.5
	progress.save_session(launch, game)

	var reloaded := ProgressService.new(store)
	reloaded.load_progress()
	var restored_launch := reloaded.session_launch()
	assert_eq(restored_launch.key, launch.key)
	assert_eq(restored_launch.level, 3)
	var restored := PuzzleModes.generate(restored_launch.mode, restored_launch.difficulty, restored_launch.key)
	assert_true(restored.load_save(reloaded.session_state(launch.key)))
	assert_eq(restored.value(0), QueensRules.MARK)
	assert_eq(restored.elapsed, 12.5)

	reloaded.record_solve(launch, _solved_game(launch, 20.0))
	assert_true(reloaded.session_launch() == null, "session cleared after solving")


func test_challenge_goal_must_be_met() -> void:
	var progress := ProgressService.new(store)
	var entry := ProgressionCatalog.challenge("quick-crowns")
	var launch := ProgressionCatalog.challenge_launch(entry)
	var slow := progress.record_solve(launch, _solved_game(launch, 500.0))
	assert_false(slow["challenge_met"])
	assert_false(progress.challenge_done("quick-crowns"))
	var fast := progress.record_solve(launch, _solved_game(launch, 30.0))
	assert_true(fast["challenge_met"])
	assert_true(progress.challenge_done("quick-crowns"))


func test_corrupt_file_falls_back_to_empty_progress() -> void:
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	file.store_string("{not json")
	file.close()
	var progress := ProgressService.new(store)
	progress.load_progress()
	assert_eq(progress.load_status, JsonFileStore.STATUS_CORRUPT)
	assert_eq(progress.total_solved(), 0)
