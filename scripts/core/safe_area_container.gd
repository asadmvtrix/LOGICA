class_name SafeAreaContainer
extends MarginContainer
## Keeps content clear of display cutouts and system bars.


func _ready() -> void:
	get_viewport().size_changed.connect(_apply)
	_apply()


func _apply() -> void:
	var margins := compute_margins(
		DisplayServer.get_display_safe_area(),
		DisplayServer.window_get_size(),
		get_viewport().get_visible_rect().size
	)
	add_theme_constant_override(&"margin_left", roundi(margins.x))
	add_theme_constant_override(&"margin_top", roundi(margins.y))
	add_theme_constant_override(&"margin_right", roundi(margins.z))
	add_theme_constant_override(&"margin_bottom", roundi(margins.w))


## Converts the safe area (window pixels) into viewport-space margins
## (left, top, right, bottom). Returns zero margins when the platform reports
## no safe area.
static func compute_margins(safe_area: Rect2i, window_size: Vector2i, viewport_size: Vector2) -> Vector4:
	if safe_area.size.x <= 0 or safe_area.size.y <= 0 or window_size.x <= 0 or window_size.y <= 0:
		return Vector4.ZERO
	var scale := Vector2(viewport_size.x / window_size.x, viewport_size.y / window_size.y)
	return Vector4(
		maxf(0.0, safe_area.position.x) * scale.x,
		maxf(0.0, safe_area.position.y) * scale.y,
		maxf(0.0, window_size.x - safe_area.end.x) * scale.x,
		maxf(0.0, window_size.y - safe_area.end.y) * scale.y
	)
