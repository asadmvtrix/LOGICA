extends "res://tests/test_case.gd"
## Integration test: boots the real app scene and walks every route.

const SETTINGS_PATH := "user://test_shell_settings.json"
const PROGRESS_PATH := "user://test_shell_progress.json"

## Untyped on purpose: the app root script has no class_name.
var app


func before_each() -> void:
	var store := JsonFileStore.new(SETTINGS_PATH)
	store.delete_all()
	store.write({"version": 1, "data": {"reduced_motion": true}})
	JsonFileStore.new(PROGRESS_PATH).delete_all()
	app = load("res://scenes/app/app.tscn").instantiate()
	app.settings_path = SETTINGS_PATH
	app.progress_path = PROGRESS_PATH
	tree.root.add_child(app)


func after_each() -> void:
	app.free()
	JsonFileStore.new(SETTINGS_PATH).delete_all()
	JsonFileStore.new(PROGRESS_PATH).delete_all()


func test_starts_on_home() -> void:
	assert_eq(app.current_screen().route, Routes.HOME)
	assert_eq(app.active_nav_tab(), Routes.HOME)
	assert_true(app.context.settings.reduced_motion, "settings loaded from the injected file")


func test_every_tab_shows_its_screen() -> void:
	var router: Router = app.context.router
	for tab in Routes.TABS:
		router.select_tab(tab)
		assert_eq(app.current_screen().route, tab)
		assert_eq(app.active_nav_tab(), tab)


func test_pushed_sections_open_and_return() -> void:
	var router: Router = app.context.router
	for section in [Routes.TRAINING, Routes.CHALLENGES]:
		router.push(section)
		assert_eq(app.current_screen().route, section)
		assert_eq(app.active_nav_tab(), Routes.HOME, "tab stays on Home under pushed screens")
		assert_true(router.back())
		assert_eq(app.current_screen().route, Routes.HOME)


func test_lessons_open_for_every_mode() -> void:
	var router: Router = app.context.router
	for mode in PuzzleModes.ALL:
		router.push(Routes.LESSON, mode)
		assert_eq(app.current_screen().route, Routes.LESSON)
		assert_true(router.back())


func test_nav_tap_selects_tab() -> void:
	app._nav.item_selected.emit(Routes.SETTINGS)
	assert_eq(app.current_screen().route, Routes.SETTINGS)


func test_play_screen_generates_plays_and_saves() -> void:
	var router: Router = app.context.router
	var launch := ProgressionCatalog.journey_launch(PuzzleModes.TANGO, 1)
	router.push(Routes.PLAY, launch)
	var screen: GameplayScreen = app.current_screen()
	assert_false(app._nav.visible, "tab bar hidden while playing")
	screen.finish_generation_now()
	assert_true(screen.is_ready(), "puzzle generated")

	screen.request_hint(HintResult.Kind.REVEAL)
	assert_true(screen.hints.is_open())
	assert_true(screen.hints.current_result().available)
	screen.hints._on_apply()
	assert_eq(screen.game.reveal_hints_used, 1)
	assert_true(screen.game.history.can_undo())

	screen.pause()
	assert_true(screen.paused)
	screen.resume()
	assert_true(router.back())
	assert_true(app._nav.visible)
	assert_eq(app.context.progress.session_key(), launch.key, "session saved on leaving")


func test_each_mode_board_builds() -> void:
	var router: Router = app.context.router
	for mode in PuzzleModes.ALL:
		router.push(Routes.PLAY, ProgressionCatalog.training_launch(mode))
		var screen: GameplayScreen = app.current_screen()
		screen.finish_generation_now()
		assert_true(screen.board != null, String(mode))
		assert_true(router.back())
