extends SceneTree
## Renders every screen of the app to PNG for visual review in CI.
## Needs a real rendering driver (for example under xvfb-run).
## Usage: godot --path . --script res://tests/capture_screenshots.gd -- <output-dir>

const SETTINGS_PATH := "user://screenshot_settings.json"
const SETTLE_FRAMES := 3

var _started := false


func _process(_delta: float) -> bool:
	if not _started:
		_started = true
		_capture.call_deferred()
	return false


func _capture() -> void:
	var args := OS.get_cmdline_user_args()
	var output_dir: String = args[0] if not args.is_empty() else OS.get_user_data_dir().path_join("screenshots")
	DirAccess.make_dir_recursive_absolute(output_dir)

	var store := JsonFileStore.new(SETTINGS_PATH)
	store.delete_all()
	store.write({"version": SettingsService.SAVE_VERSION, "data": {"reduced_motion": true}})

	var app = load("res://scenes/app/app.tscn").instantiate()
	app.settings_path = SETTINGS_PATH
	root.add_child(app)
	var router: Router = app.context.router

	var shots := [
		[Routes.HOME, Routes.HOME],
		[Routes.JOURNEY, Routes.JOURNEY],
		[Routes.DAILY, Routes.DAILY],
		[Routes.STATISTICS, Routes.STATISTICS],
		[Routes.SETTINGS, Routes.SETTINGS],
		[Routes.HOME, Routes.TRAINING],
		[Routes.HOME, Routes.CHALLENGES],
	]
	var index := 1
	for shot in shots:
		router.select_tab(shot[0])
		router.push(shot[1])
		for i in SETTLE_FRAMES:
			await process_frame
		await RenderingServer.frame_post_draw
		var file_path := output_dir.path_join("%02d_%s.png" % [index, shot[1]])
		var error := root.get_texture().get_image().save_png(file_path)
		print("%s %s" % ["saved" if error == OK else "FAILED", file_path])
		index += 1

	store.delete_all()
	quit(0)
