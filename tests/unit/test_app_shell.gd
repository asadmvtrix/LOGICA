extends "res://tests/test_case.gd"
## Integration test: boots the real app scene and walks every route.

const SETTINGS_PATH := "user://test_shell_settings.json"

## Untyped on purpose: the app root script has no class_name.
var app


func before_each() -> void:
	var store := JsonFileStore.new(SETTINGS_PATH)
	store.delete_all()
	store.write({"version": 1, "data": {"reduced_motion": true}})
	app = load("res://scenes/app/app.tscn").instantiate()
	app.settings_path = SETTINGS_PATH
	tree.root.add_child(app)


func after_each() -> void:
	app.free()
	JsonFileStore.new(SETTINGS_PATH).delete_all()


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


func test_nav_tap_selects_tab() -> void:
	app._nav.item_selected.emit(Routes.SETTINGS)
	assert_eq(app.current_screen().route, Routes.SETTINGS)
