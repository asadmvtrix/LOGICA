class_name ModeTabs
extends HBoxContainer
## Row of mode names with an underline in the selected mode's colour.

signal mode_selected(mode: StringName)

var selected: StringName
var _buttons := {}


func _init(initial: StringName) -> void:
	selected = initial
	add_theme_constant_override(&"separation", 0)
	for mode in PuzzleModes.ALL:
		var button := TabButton.new(mode)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(select.bind(mode))
		add_child(button)
		_buttons[mode] = button
	_refresh()


func select(mode: StringName) -> void:
	if mode == selected:
		return
	selected = mode
	_refresh()
	mode_selected.emit(mode)


func _refresh() -> void:
	for mode: StringName in _buttons:
		(_buttons[mode] as TabButton).active = mode == selected


class TabButton:
	extends Button

	var mode: StringName
	var active := false:
		set(value):
			active = value
			theme_type_variation = ThemeFactory.BUTTON_NAV_ACTIVE if active else ThemeFactory.BUTTON_NAV
			queue_redraw()

	func _init(p_mode: StringName) -> void:
		mode = p_mode
		text = PuzzleModes.title(mode)
		theme_type_variation = ThemeFactory.BUTTON_NAV
		mouse_filter = Control.MOUSE_FILTER_PASS
		custom_minimum_size.y = DesignTokens.TOUCH_TARGET_MIN

	func _draw() -> void:
		var line := DesignTokens.COLOR_SEPARATOR
		draw_line(Vector2(0, size.y - 1), Vector2(size.x, size.y - 1), line, DesignTokens.HAIRLINE)
		if active:
			draw_rect(Rect2(0, size.y - 6, size.x, 6), DesignTokens.mode_color(mode))
