class_name ToolButton
extends Button
## Gameplay toolbar button: vector icon above a short caption. Toggle buttons
## (such as Notes) show their active state in the accent colour.

var icon_kind: VectorIcons.Icon
var accent := DesignTokens.COLOR_ACCENT
var active := false:
	set(value):
		active = value
		_caption.add_theme_color_override(&"font_color", accent if active else DesignTokens.COLOR_INK)
		queue_redraw()

var _caption: Label


func _init(caption_text: String, p_icon: VectorIcons.Icon) -> void:
	icon_kind = p_icon
	theme_type_variation = ThemeFactory.BUTTON_TOOL
	custom_minimum_size = Vector2(DesignTokens.TOUCH_TARGET_MIN, DesignTokens.TOOL_BUTTON_HEIGHT)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_caption = UiFactory.label(caption_text)
	_caption.add_theme_font_size_override(&"font_size", DesignTokens.FONT_SIZE_CAPTION)
	_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_caption.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_caption.offset_top = -DesignTokens.FONT_SIZE_CAPTION * 1.6
	_caption.offset_bottom = -DesignTokens.SPACE_XS
	add_child(_caption)


func _draw() -> void:
	var color := accent if active else DesignTokens.COLOR_INK
	if disabled:
		color = Color(color, DesignTokens.DISABLED_ALPHA)
		_caption.modulate.a = DesignTokens.DISABLED_ALPHA
	else:
		_caption.modulate.a = 1.0
	var icon_size := DesignTokens.TOOL_BUTTON_HEIGHT * 0.42
	VectorIcons.draw_icon(self, icon_kind, Vector2(size.x * 0.5, DesignTokens.SPACE_S + icon_size * 0.5), icon_size, color)
