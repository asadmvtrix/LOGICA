extends Control
## Composition root. Creates the services, builds the shell (screen host and
## tab bar inside the safe area) and connects navigation.

const EMPTY_SECTION_SCREEN := preload("res://scripts/screens/empty_section_screen.gd")
const SCREEN_SCRIPTS := {
	Routes.HOME: preload("res://scripts/screens/home_screen.gd"),
	Routes.JOURNEY: EMPTY_SECTION_SCREEN,
	Routes.DAILY: EMPTY_SECTION_SCREEN,
	Routes.TRAINING: EMPTY_SECTION_SCREEN,
	Routes.CHALLENGES: EMPTY_SECTION_SCREEN,
	Routes.STATISTICS: EMPTY_SECTION_SCREEN,
	Routes.SETTINGS: preload("res://scripts/screens/settings_screen.gd"),
}

## Overridable so tests can use an isolated settings file.
@export var settings_path := "user://settings.json"

var context: AppContext

var _host: ScreenHost
var _nav: BottomNav


func _ready() -> void:
	var settings := SettingsService.new(JsonFileStore.new(settings_path))
	settings.load_settings()
	context = AppContext.new(Router.new(Routes.TABS, Routes.HOME), settings)

	theme = ThemeFactory.build()
	RenderingServer.set_default_clear_color(DesignTokens.COLOR_BACKGROUND)
	_build_shell()

	settings.changed.connect(_on_setting_changed)
	context.router.route_changed.connect(_on_route_changed)
	_nav.item_selected.connect(context.router.select_tab)
	context.router.select_tab(Routes.HOME)
	print("LOGICA boot ok (version %s)" % AppContext.app_version())


func current_screen() -> Screen:
	return _host.current_screen() as Screen


func active_nav_tab() -> StringName:
	return _nav.active_id()


func _build_shell() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var background := ColorRect.new()
	background.color = DesignTokens.COLOR_BACKGROUND
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var safe_area := SafeAreaContainer.new()
	safe_area.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(safe_area)

	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", 0)
	safe_area.add_child(column)

	_host = ScreenHost.new()
	_host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_host.reduce_motion = context.settings.reduced_motion
	column.add_child(_host)

	_nav = BottomNav.new(Routes.TABS, Routes.TAB_LABELS)
	column.add_child(_nav)


func _on_route_changed(route: StringName, direction: int) -> void:
	var screen: Screen = SCREEN_SCRIPTS[route].new()
	screen.setup(context, route)
	_host.show_screen(screen, direction)
	_nav.set_active(context.router.active_tab())


func _on_setting_changed(key: StringName) -> void:
	if key == SettingsService.KEY_REDUCED_MOTION:
		_host.reduce_motion = context.settings.reduced_motion


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_go_back_or_quit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		_go_back_or_quit()


func _go_back_or_quit() -> void:
	if context == null:
		return
	if not context.router.back():
		get_tree().quit()
