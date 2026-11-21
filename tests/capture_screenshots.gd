extends SceneTree
## Renders the app's screens to PNG for visual review in CI.
## Needs a real rendering driver (for example under xvfb-run).
## Usage: godot --path . --script res://tests/capture_screenshots.gd -- <output-dir>

const SETTINGS_PATH := "user://screenshot_settings.json"
const PROGRESS_PATH := "user://screenshot_progress.json"
const SETTLE_FRAMES := 4

var _started := false
var _app
var _output_dir := ""
var _index := 1


func _process(_delta: float) -> bool:
	if not _started:
		_started = true
		_capture.call_deferred()
	return false


func _capture() -> void:
	var args := OS.get_cmdline_user_args()
	_output_dir = args[0] if not args.is_empty() else OS.get_user_data_dir().path_join("screenshots")
	DirAccess.make_dir_recursive_absolute(_output_dir)

	var store := JsonFileStore.new(SETTINGS_PATH)
	store.delete_all()
	store.write({"version": SettingsService.SAVE_VERSION, "data": {"reduced_motion": true}})
	JsonFileStore.new(PROGRESS_PATH).delete_all()

	_app = load("res://scenes/app/app.tscn").instantiate()
	_app.settings_path = SETTINGS_PATH
	_app.progress_path = PROGRESS_PATH
	root.add_child(_app)
	var router: Router = _app.context.router

	for tab in [Routes.HOME, Routes.JOURNEY, Routes.DAILY, Routes.STATISTICS, Routes.SETTINGS]:
		router.select_tab(tab)
		await _shot(tab)
	router.select_tab(Routes.HOME)
	router.push(Routes.TRAINING)
	await _shot(Routes.TRAINING)
	router.push(Routes.LESSON, PuzzleModes.QUEENS)
	await _shot(Routes.LESSON)
	router.select_tab(Routes.HOME)
	router.push(Routes.CHALLENGES)
	await _shot(Routes.CHALLENGES)

	for mode in PuzzleModes.ALL:
		router.select_tab(Routes.HOME)
		router.push(Routes.PLAY, ProgressionCatalog.journey_launch(mode, 14))
		var screen: GameplayScreen = _app.current_screen()
		screen.finish_generation_now()
		_play_a_few_hints(screen, 3)
		await _shot("play_%s" % mode)
		screen.request_hint(HintResult.Kind.TACTICAL)
		await _shot("explain_%s" % mode)

	router.select_tab(Routes.HOME)
	await _shot("home_after_play")

	store.delete_all()
	JsonFileStore.new(PROGRESS_PATH).delete_all()
	quit(0)


func _play_a_few_hints(screen: GameplayScreen, count: int) -> void:
	for i in count:
		var result := screen.game.hint_engine().reveal(screen.game)
		if result.available:
			screen.game.apply(result.changes)
	if screen.board is SudokuBoardView:
		screen.board.select((screen.game as SudokuGame).puzzle.givens.find(0))


func _shot(label: String) -> void:
	for i in SETTLE_FRAMES:
		await process_frame
	await RenderingServer.frame_post_draw
	var file_path := _output_dir.path_join("%02d_%s.png" % [_index, label])
	var error := root.get_texture().get_image().save_png(file_path)
	print("%s %s" % ["saved" if error == OK else "FAILED", file_path])
	_index += 1
