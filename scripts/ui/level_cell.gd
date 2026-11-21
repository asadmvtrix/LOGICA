class_name LevelCell
extends Button
## One journey level in the grid: solved (filled), next (outlined) or locked.

enum State { SOLVED, NEXT, OPEN, LOCKED }

var level: int
var state: State
var accent: Color


func _init(p_level: int, p_state: State, p_accent: Color) -> void:
	level = p_level
	state = p_state
	accent = p_accent
	theme_type_variation = ThemeFactory.BUTTON_ICON
	mouse_filter = Control.MOUSE_FILTER_PASS
	custom_minimum_size = Vector2(DesignTokens.TOUCH_TARGET_MIN, DesignTokens.TOUCH_TARGET_MIN)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	disabled = state == State.LOCKED


func _draw() -> void:
	var side := minf(size.x, size.y) - DesignTokens.SPACE_XS
	var rect := Rect2((size - Vector2(side, side)) * 0.5, Vector2(side, side))
	var font := BoardView.font(DesignTokens.FONT_WEIGHT_SEMIBOLD)
	var font_size := DesignTokens.FONT_SIZE_BODY_SMALL
	var text_color := DesignTokens.COLOR_INK
	match state:
		State.SOLVED:
			draw_rect(rect, accent)
			text_color = DesignTokens.COLOR_SURFACE
		State.NEXT:
			draw_rect(rect, DesignTokens.COLOR_SURFACE)
			draw_rect(rect.grow(-2), accent, false, 5.0)
			text_color = accent
		State.OPEN:
			draw_rect(rect, DesignTokens.COLOR_SURFACE)
			draw_rect(rect, DesignTokens.COLOR_SEPARATOR, false, DesignTokens.HAIRLINE)
		State.LOCKED:
			draw_rect(rect, DesignTokens.COLOR_SURFACE_SUNKEN)
			VectorIcons.draw_icon(self, VectorIcons.Icon.LOCK, rect.get_center(), side * 0.42, DesignTokens.COLOR_INK_MUTED)
			return
	var baseline := rect.position.y + (rect.size.y + font.get_ascent(font_size) - font.get_descent(font_size)) * 0.5
	draw_string(font, Vector2(rect.position.x, baseline), str(level), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, font_size, text_color)
