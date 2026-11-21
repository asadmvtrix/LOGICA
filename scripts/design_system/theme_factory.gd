class_name ThemeFactory
extends RefCounted
## Builds the application Theme from DesignTokens. Controls opt into styles via
## theme_type_variation names, so no screen sets colours or sizes directly.

const LABEL_WORDMARK := &"WordmarkLabel"
const LABEL_HEADLINE := &"HeadlineLabel"
const LABEL_TITLE := &"TitleLabel"
const LABEL_SECONDARY := &"SecondaryLabel"
const LABEL_CAPTION := &"CaptionLabel"
const BUTTON_ROW := &"RowButton"
const BUTTON_ICON := &"IconButton"
const BUTTON_NAV := &"NavButton"
const BUTTON_NAV_ACTIVE := &"NavButtonActive"
const PANEL_NAV_BAR := &"NavBar"


static func build() -> Theme:
	var theme := Theme.new()
	var regular := _system_font(DesignTokens.FONT_WEIGHT_REGULAR)
	var medium := _system_font(DesignTokens.FONT_WEIGHT_MEDIUM)
	var semibold := _system_font(DesignTokens.FONT_WEIGHT_SEMIBOLD)

	theme.default_font = regular
	theme.default_font_size = DesignTokens.FONT_SIZE_BODY

	_add_labels(theme, medium, semibold)
	_add_buttons(theme, medium)
	_add_containers(theme)
	return theme


static func _system_font(weight: int) -> SystemFont:
	var font := SystemFont.new()
	font.font_names = PackedStringArray(DesignTokens.FONT_FAMILIES)
	font.font_weight = weight
	font.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	return font


static func _add_labels(theme: Theme, medium: Font, semibold: Font) -> void:
	theme.set_color(&"font_color", &"Label", DesignTokens.COLOR_INK)

	var wordmark := FontVariation.new()
	wordmark.base_font = semibold
	wordmark.spacing_glyph = DesignTokens.WORDMARK_TRACKING
	_label_variation(theme, LABEL_WORDMARK, wordmark, DesignTokens.FONT_SIZE_WORDMARK, DesignTokens.COLOR_INK)
	_label_variation(theme, LABEL_HEADLINE, medium, DesignTokens.FONT_SIZE_HEADLINE, DesignTokens.COLOR_INK)
	_label_variation(theme, LABEL_TITLE, medium, DesignTokens.FONT_SIZE_TITLE, DesignTokens.COLOR_INK)
	_label_variation(theme, LABEL_SECONDARY, null, DesignTokens.FONT_SIZE_BODY_SMALL, DesignTokens.COLOR_INK_SECONDARY)
	_label_variation(theme, LABEL_CAPTION, medium, DesignTokens.FONT_SIZE_CAPTION, DesignTokens.COLOR_INK_SECONDARY)


static func _label_variation(theme: Theme, type: StringName, font: Font, font_size: int, color: Color) -> void:
	theme.set_type_variation(type, &"Label")
	if font != null:
		theme.set_font(&"font", type, font)
	theme.set_font_size(&"font_size", type, font_size)
	theme.set_color(&"font_color", type, color)


static func _add_buttons(theme: Theme, medium: Font) -> void:
	var normal := _flat(DesignTokens.COLOR_SURFACE, DesignTokens.RADIUS_M)
	normal.set_border_width_all(DesignTokens.HAIRLINE)
	normal.border_color = DesignTokens.COLOR_SEPARATOR
	normal.set_content_margin_all(DesignTokens.SPACE_S)
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = DesignTokens.COLOR_SURFACE_SUNKEN
	_button_styles(theme, &"Button", normal, pressed)
	theme.set_font(&"font", &"Button", medium)
	_button_font_colors(theme, &"Button", DesignTokens.COLOR_INK, DesignTokens.COLOR_INK)

	var row_pressed := _flat(DesignTokens.COLOR_SURFACE_SUNKEN, DesignTokens.RADIUS_M)
	row_pressed.expand_margin_left = DesignTokens.SPACE_S
	row_pressed.expand_margin_right = DesignTokens.SPACE_S
	_button_variation(theme, BUTTON_ROW, StyleBoxEmpty.new(), row_pressed)

	_button_variation(theme, BUTTON_ICON, StyleBoxEmpty.new(), _flat(DesignTokens.COLOR_SURFACE_SUNKEN, DesignTokens.RADIUS_M))

	_button_variation(theme, BUTTON_NAV, StyleBoxEmpty.new(), StyleBoxEmpty.new())
	theme.set_font_size(&"font_size", BUTTON_NAV, DesignTokens.FONT_SIZE_NAV)
	_button_font_colors(theme, BUTTON_NAV, DesignTokens.COLOR_INK_SECONDARY, DesignTokens.COLOR_INK)

	_button_variation(theme, BUTTON_NAV_ACTIVE, StyleBoxEmpty.new(), StyleBoxEmpty.new())
	theme.set_font_size(&"font_size", BUTTON_NAV_ACTIVE, DesignTokens.FONT_SIZE_NAV)
	_button_font_colors(theme, BUTTON_NAV_ACTIVE, DesignTokens.COLOR_INK, DesignTokens.COLOR_INK)


static func _button_variation(theme: Theme, type: StringName, normal: StyleBox, pressed: StyleBox) -> void:
	theme.set_type_variation(type, &"Button")
	_button_styles(theme, type, normal, pressed)


static func _button_styles(theme: Theme, type: StringName, normal: StyleBox, pressed: StyleBox) -> void:
	# Hover mirrors normal: on touch screens hover state would otherwise stick.
	theme.set_stylebox(&"normal", type, normal)
	theme.set_stylebox(&"hover", type, normal)
	theme.set_stylebox(&"disabled", type, normal)
	theme.set_stylebox(&"focus", type, StyleBoxEmpty.new())
	theme.set_stylebox(&"pressed", type, pressed)
	theme.set_stylebox(&"hover_pressed", type, pressed)


static func _button_font_colors(theme: Theme, type: StringName, color: Color, pressed_color: Color) -> void:
	theme.set_color(&"font_color", type, color)
	theme.set_color(&"font_hover_color", type, color)
	theme.set_color(&"font_focus_color", type, color)
	theme.set_color(&"font_pressed_color", type, pressed_color)
	theme.set_color(&"font_hover_pressed_color", type, pressed_color)
	theme.set_color(&"font_disabled_color", type, Color(color, DesignTokens.DISABLED_ALPHA))


static func _add_containers(theme: Theme) -> void:
	var line := StyleBoxLine.new()
	line.color = DesignTokens.COLOR_SEPARATOR
	line.thickness = DesignTokens.HAIRLINE
	theme.set_stylebox(&"separator", &"HSeparator", line)
	theme.set_constant(&"separation", &"HSeparator", DesignTokens.HAIRLINE)

	var nav_bar := _flat(DesignTokens.COLOR_BACKGROUND, 0)
	nav_bar.border_width_top = DesignTokens.HAIRLINE
	nav_bar.border_color = DesignTokens.COLOR_SEPARATOR
	theme.set_type_variation(PANEL_NAV_BAR, &"PanelContainer")
	theme.set_stylebox(&"panel", PANEL_NAV_BAR, nav_bar)

	theme.set_stylebox(&"panel", &"ScrollContainer", StyleBoxEmpty.new())
	var grabber := _flat(DesignTokens.COLOR_SEPARATOR, DesignTokens.RADIUS_S)
	grabber.content_margin_left = DesignTokens.HAIRLINE * 2
	grabber.content_margin_right = DesignTokens.HAIRLINE * 2
	theme.set_stylebox(&"scroll", &"VScrollBar", StyleBoxEmpty.new())
	theme.set_stylebox(&"grabber", &"VScrollBar", grabber)
	theme.set_stylebox(&"grabber_highlight", &"VScrollBar", grabber)
	theme.set_stylebox(&"grabber_pressed", &"VScrollBar", grabber)


static func _flat(color: Color, radius: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(radius)
	box.anti_aliasing = true
	return box
