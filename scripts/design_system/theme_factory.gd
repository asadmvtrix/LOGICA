class_name ThemeFactory
extends RefCounted
## Builds the application Theme from DesignTokens. Controls opt into styles via
## theme_type_variation names, so no screen sets colours or sizes directly.
## Typography: Fraunces (serif, display and titles) with Inter (interface).

const LABEL_WORDMARK := &"WordmarkLabel"
const LABEL_HEADLINE := &"HeadlineLabel"
const LABEL_TITLE := &"TitleLabel"
const LABEL_NUMERAL := &"NumeralLabel"
const LABEL_STRONG := &"StrongLabel"
const LABEL_SECONDARY := &"SecondaryLabel"
const LABEL_CAPTION := &"CaptionLabel"
const BUTTON_PRIMARY := &"PrimaryButton"
const BUTTON_SECONDARY := &"SecondaryButton"
const BUTTON_TOOL := &"ToolButton"
const BUTTON_ROW := &"RowButton"
const BUTTON_TILE := &"TileButton"
const BUTTON_ICON := &"IconButton"
const BUTTON_NAV := &"NavButton"
const BUTTON_NAV_ACTIVE := &"NavButtonActive"
const PANEL_NAV_BAR := &"NavBar"
const PANEL_SHEET := &"SheetPanel"
const PANEL_CARD := &"CardPanel"


static func build() -> Theme:
	var theme := Theme.new()
	var ui_regular := ui_font(DesignTokens.FONT_WEIGHT_REGULAR)
	var ui_medium := ui_font(DesignTokens.FONT_WEIGHT_MEDIUM)
	var ui_semibold := ui_font(DesignTokens.FONT_WEIGHT_SEMIBOLD)

	theme.default_font = ui_regular
	theme.default_font_size = DesignTokens.FONT_SIZE_BODY

	_add_labels(theme, ui_semibold)
	_add_buttons(theme, ui_medium, ui_semibold)
	_add_containers(theme)
	return theme


static func ui_font(weight: int) -> FontVariation:
	return _variable_font(DesignTokens.FONT_UI_PATH, {"wght": weight})


static func display_font(weight: int, optical_size: int) -> FontVariation:
	return _variable_font(DesignTokens.FONT_DISPLAY_PATH, {"wght": weight, "opsz": optical_size})


static func _variable_font(path: String, axes: Dictionary) -> FontVariation:
	var font := FontVariation.new()
	font.base_font = load(path) as Font
	var server := TextServerManager.get_primary_interface()
	var coordinates := {}
	for axis: String in axes:
		coordinates[server.name_to_tag(axis)] = axes[axis]
	font.variation_opentype = coordinates
	return font


static func _add_labels(theme: Theme, ui_semibold: Font) -> void:
	theme.set_color(&"font_color", &"Label", DesignTokens.COLOR_INK)

	_label_variation(theme, LABEL_WORDMARK, display_font(500, 144), DesignTokens.FONT_SIZE_DISPLAY, DesignTokens.COLOR_INK)
	_label_variation(theme, LABEL_HEADLINE, display_font(450, 72), DesignTokens.FONT_SIZE_HEADLINE, DesignTokens.COLOR_INK)
	_label_variation(theme, LABEL_TITLE, display_font(500, 36), DesignTokens.FONT_SIZE_TITLE, DesignTokens.COLOR_INK)
	_label_variation(theme, LABEL_NUMERAL, display_font(450, 72), DesignTokens.FONT_SIZE_NUMERAL, DesignTokens.COLOR_INK)
	_label_variation(theme, LABEL_STRONG, ui_semibold, DesignTokens.FONT_SIZE_BODY, DesignTokens.COLOR_INK)
	_label_variation(theme, LABEL_SECONDARY, null, DesignTokens.FONT_SIZE_BODY_SMALL, DesignTokens.COLOR_INK_SECONDARY)

	var caption_font := ui_font(DesignTokens.FONT_WEIGHT_SEMIBOLD)
	caption_font.spacing_glyph = DesignTokens.CAPTION_TRACKING
	_label_variation(theme, LABEL_CAPTION, caption_font, DesignTokens.FONT_SIZE_CAPTION, DesignTokens.COLOR_INK_SECONDARY)


static func _label_variation(theme: Theme, type: StringName, font: Font, font_size: int, color: Color) -> void:
	theme.set_type_variation(type, &"Label")
	if font != null:
		theme.set_font(&"font", type, font)
	theme.set_font_size(&"font_size", type, font_size)
	theme.set_color(&"font_color", type, color)


static func _add_buttons(theme: Theme, ui_medium: Font, ui_semibold: Font) -> void:
	var normal := raised(DesignTokens.COLOR_SURFACE, DesignTokens.RADIUS_M)
	normal.set_content_margin_all(DesignTokens.SPACE_S)
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = DesignTokens.COLOR_SURFACE_SUNKEN
	_button_styles(theme, &"Button", normal, pressed)
	theme.set_font(&"font", &"Button", ui_medium)
	_button_font_colors(theme, &"Button", DesignTokens.COLOR_INK, DesignTokens.COLOR_INK)

	var primary := _flat(DesignTokens.COLOR_INK, DesignTokens.RADIUS_PILL)
	primary.set_content_margin_all(DesignTokens.SPACE_S)
	primary.content_margin_left = DesignTokens.SPACE_L
	primary.content_margin_right = DesignTokens.SPACE_L
	var primary_pressed := primary.duplicate() as StyleBoxFlat
	primary_pressed.bg_color = DesignTokens.COLOR_INK.lightened(0.2)
	_button_variation(theme, BUTTON_PRIMARY, primary, primary_pressed)
	theme.set_font(&"font", BUTTON_PRIMARY, ui_semibold)
	_button_font_colors(theme, BUTTON_PRIMARY, DesignTokens.COLOR_SURFACE, DesignTokens.COLOR_SURFACE)

	_button_variation(theme, BUTTON_SECONDARY, normal, pressed)
	theme.set_font(&"font", BUTTON_SECONDARY, ui_semibold)
	_button_font_colors(theme, BUTTON_SECONDARY, DesignTokens.COLOR_INK, DesignTokens.COLOR_INK)

	var tool_pressed := _flat(DesignTokens.COLOR_SURFACE_SUNKEN, DesignTokens.RADIUS_M)
	_button_variation(theme, BUTTON_TOOL, StyleBoxEmpty.new(), tool_pressed)
	theme.set_font_size(&"font_size", BUTTON_TOOL, DesignTokens.FONT_SIZE_CAPTION)
	_button_font_colors(theme, BUTTON_TOOL, DesignTokens.COLOR_INK, DesignTokens.COLOR_INK)

	var row_pressed := _flat(DesignTokens.COLOR_SURFACE_SUNKEN, DesignTokens.RADIUS_M)
	row_pressed.expand_margin_left = DesignTokens.SPACE_S
	row_pressed.expand_margin_right = DesignTokens.SPACE_S
	_button_variation(theme, BUTTON_ROW, StyleBoxEmpty.new(), row_pressed)

	var tile := raised(DesignTokens.COLOR_SURFACE, DesignTokens.RADIUS_M)
	var tile_pressed := tile.duplicate() as StyleBoxFlat
	tile_pressed.bg_color = DesignTokens.COLOR_SURFACE_SUNKEN
	_button_variation(theme, BUTTON_TILE, tile, tile_pressed)

	_button_variation(theme, BUTTON_ICON, StyleBoxEmpty.new(), _flat(DesignTokens.COLOR_SURFACE_SUNKEN, DesignTokens.RADIUS_M))

	_button_variation(theme, BUTTON_NAV, StyleBoxEmpty.new(), StyleBoxEmpty.new())
	theme.set_font_size(&"font_size", BUTTON_NAV, DesignTokens.FONT_SIZE_NAV)
	_button_font_colors(theme, BUTTON_NAV, DesignTokens.COLOR_INK_SECONDARY, DesignTokens.COLOR_INK)

	_button_variation(theme, BUTTON_NAV_ACTIVE, StyleBoxEmpty.new(), StyleBoxEmpty.new())
	theme.set_font_size(&"font_size", BUTTON_NAV_ACTIVE, DesignTokens.FONT_SIZE_NAV)
	theme.set_font(&"font", BUTTON_NAV_ACTIVE, ui_semibold)
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

	var nav_bar := _flat(DesignTokens.COLOR_SURFACE, 0)
	nav_bar.corner_radius_top_left = DesignTokens.RADIUS_L
	nav_bar.corner_radius_top_right = DesignTokens.RADIUS_L
	nav_bar.shadow_color = DesignTokens.COLOR_SHADOW
	nav_bar.shadow_size = 24
	theme.set_type_variation(PANEL_NAV_BAR, &"PanelContainer")
	theme.set_stylebox(&"panel", PANEL_NAV_BAR, nav_bar)

	var sheet := _flat(DesignTokens.COLOR_SURFACE, 0)
	sheet.corner_radius_top_left = DesignTokens.RADIUS_L
	sheet.corner_radius_top_right = DesignTokens.RADIUS_L
	sheet.shadow_color = Color(0, 0, 0, 0.18)
	sheet.shadow_size = 30
	sheet.content_margin_left = DesignTokens.PAGE_MARGIN
	sheet.content_margin_right = DesignTokens.PAGE_MARGIN
	sheet.content_margin_top = DesignTokens.SPACE_M
	sheet.content_margin_bottom = DesignTokens.SPACE_M
	theme.set_type_variation(PANEL_SHEET, &"PanelContainer")
	theme.set_stylebox(&"panel", PANEL_SHEET, sheet)

	var card := raised(DesignTokens.COLOR_SURFACE, DesignTokens.RADIUS_M)
	card.set_content_margin_all(DesignTokens.SPACE_L)
	theme.set_type_variation(PANEL_CARD, &"PanelContainer")
	theme.set_stylebox(&"panel", PANEL_CARD, card)

	theme.set_stylebox(&"panel", &"ScrollContainer", StyleBoxEmpty.new())
	var grabber := _flat(DesignTokens.COLOR_SEPARATOR, DesignTokens.RADIUS_S)
	grabber.content_margin_left = DesignTokens.HAIRLINE * 2
	grabber.content_margin_right = DesignTokens.HAIRLINE * 2
	theme.set_stylebox(&"scroll", &"VScrollBar", StyleBoxEmpty.new())
	theme.set_stylebox(&"grabber", &"VScrollBar", grabber)
	theme.set_stylebox(&"grabber_highlight", &"VScrollBar", grabber)
	theme.set_stylebox(&"grabber_pressed", &"VScrollBar", grabber)


## Rounded surface with a soft drop shadow.
static func raised(color: Color, radius: int) -> StyleBoxFlat:
	var box := _flat(color, radius)
	box.shadow_color = DesignTokens.COLOR_SHADOW
	box.shadow_size = 14
	box.shadow_offset = Vector2(0, 5)
	return box


static func _flat(color: Color, radius: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(radius)
	box.anti_aliasing = true
	return box
