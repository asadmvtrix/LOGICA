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
	if not disabled:
		PressFeedback.attach(self)


func _draw() -> void:
	var side := minf(size.x, size.y) - DesignTokens.SPACE_XS
	var rect := Rect2((size - Vector2(side, side)) * 0.5, Vector2(side, side))
	var font := BoardView.font(DesignTokens.FONT_WEIGHT_SEMIBOLD)
	var font_size := DesignTokens.FONT_SIZE_BODY_SMALL
	var text_color := DesignTokens.COLOR_INK
	var box := StyleBoxFlat.new()
	box.anti_aliasing = true
	box.set_corner_radius_all(int(side * 0.3))
	match state:
		State.SOLVED:
			box.bg_color = accent
			box.shadow_color = Color(accent, 0.3)
			box.shadow_size = 8
			box.shadow_offset = Vector2(0, 4)
			draw_style_box(box, rect)
			text_color = DesignTokens.COLOR_SURFACE
		State.NEXT:
			box.bg_color = DesignTokens.COLOR_SURFACE
			box.set_border_width_all(6)
			box.border_color = accent
			draw_style_box(box, rect)
			text_color = accent
		State.OPEN:
			box.bg_color = DesignTokens.COLOR_SURFACE
			draw_style_box(box, rect)
		State.LOCKED:
			box.bg_color = DesignTokens.COLOR_SURFACE_SUNKEN
			draw_style_box(box, rect)
			VectorIcons.draw_icon(self, VectorIcons.Icon.LOCK, rect.get_center(), side * 0.42, DesignTokens.COLOR_INK_MUTED)
			return
	var baseline := rect.position.y + (rect.size.y + font.get_ascent(font_size) - font.get_descent(font_size)) * 0.5
	draw_string(font, Vector2(rect.position.x, baseline), str(level), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, font_size, text_color)
