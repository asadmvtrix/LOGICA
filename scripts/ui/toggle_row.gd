class_name ToggleRow
extends Button
## Settings row with a vector on/off switch. The whole row is the touch target.

signal value_changed(value: bool)

var value := false:
	set = set_value
var reduce_motion := false

var _knob := 0.0
var _tween: Tween


func _init(title: String, subtitle: String, initial_value: bool) -> void:
	theme_type_variation = ThemeFactory.BUTTON_ROW
	mouse_filter = Control.MOUSE_FILTER_PASS
	custom_minimum_size.y = DesignTokens.ROW_HEIGHT if subtitle.is_empty() else DesignTokens.ROW_HEIGHT_TALL
	add_child(UiFactory.row_text(title, subtitle, DesignTokens.TOGGLE_SIZE.x + DesignTokens.SPACE_M))
	value = initial_value
	_knob = 1.0 if initial_value else 0.0
	pressed.connect(_on_pressed)


func set_value(new_value: bool) -> void:
	if new_value == value:
		return
	value = new_value
	_animate_knob(1.0 if value else 0.0)


func _on_pressed() -> void:
	value = not value
	value_changed.emit(value)


func _animate_knob(target: float) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	if reduce_motion or not is_inside_tree():
		_set_knob(target)
		return
	_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_method(_set_knob, _knob, target, DesignTokens.MOTION_FAST)


func _set_knob(position_ratio: float) -> void:
	_knob = position_ratio
	queue_redraw()


func _draw() -> void:
	var track_size := DesignTokens.TOGGLE_SIZE
	var origin := Vector2(size.x - track_size.x, (size.y - track_size.y) * 0.5)
	var radius := track_size.y * 0.5
	var track_color := DesignTokens.COLOR_SEPARATOR.lerp(DesignTokens.COLOR_ACCENT, _knob)

	draw_circle(origin + Vector2(radius, radius), radius, track_color, true, -1.0, true)
	draw_circle(origin + Vector2(track_size.x - radius, radius), radius, track_color, true, -1.0, true)
	draw_rect(Rect2(origin + Vector2(radius, 0.0), Vector2(track_size.x - radius * 2.0, track_size.y)), track_color)

	var knob_x := lerpf(origin.x + radius, origin.x + track_size.x - radius, _knob)
	draw_circle(Vector2(knob_x, origin.y + radius), radius - DesignTokens.TOGGLE_INSET, DesignTokens.COLOR_SURFACE, true, -1.0, true)
