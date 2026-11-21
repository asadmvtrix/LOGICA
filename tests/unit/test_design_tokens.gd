extends "res://tests/test_case.gd"

const WCAG_AA_BODY := 4.5
const WCAG_AAA_BODY := 7.0


func test_primary_text_contrast_meets_aaa() -> void:
	assert_gte(_contrast(DesignTokens.COLOR_INK, DesignTokens.COLOR_BACKGROUND), WCAG_AAA_BODY)
	assert_gte(_contrast(DesignTokens.COLOR_INK, DesignTokens.COLOR_SURFACE_SUNKEN), WCAG_AAA_BODY)


func test_secondary_text_contrast_meets_aa() -> void:
	assert_gte(_contrast(DesignTokens.COLOR_INK_SECONDARY, DesignTokens.COLOR_BACKGROUND), WCAG_AA_BODY)
	assert_gte(_contrast(DesignTokens.COLOR_INK_SECONDARY, DesignTokens.COLOR_SURFACE_SUNKEN), WCAG_AA_BODY)


func test_spacing_scale_increases() -> void:
	var scale := [
		DesignTokens.SPACE_XXS, DesignTokens.SPACE_XS, DesignTokens.SPACE_S, DesignTokens.SPACE_M,
		DesignTokens.SPACE_L, DesignTokens.SPACE_XL, DesignTokens.SPACE_XXL,
	]
	for i in range(1, scale.size()):
		assert_true(scale[i] > scale[i - 1], "spacing step %d" % i)


func test_interactive_elements_meet_minimum_touch_target() -> void:
	# 48 dp at the reference density is about 126 px.
	assert_gte(DesignTokens.TOUCH_TARGET_MIN, 126)
	assert_gte(DesignTokens.ROW_HEIGHT, DesignTokens.TOUCH_TARGET_MIN)
	assert_gte(DesignTokens.NAV_HEIGHT, DesignTokens.TOUCH_TARGET_MIN)


func test_mode_colours_are_distinct_and_legible() -> void:
	var seen := {}
	for mode in PuzzleModes.ALL:
		var color := DesignTokens.mode_color(mode)
		assert_false(seen.has(color.to_html()), "unique colour for %s" % mode)
		seen[color.to_html()] = true
		# Used for captions and large numerals: WCAG AA for large text / UI parts.
		assert_gte(_contrast(color, DesignTokens.COLOR_SURFACE), 3.0, String(mode))


func test_bundled_fonts_load() -> void:
	assert_true(load(DesignTokens.FONT_UI_PATH) is Font, "Inter")
	assert_true(load(DesignTokens.FONT_DISPLAY_PATH) is Font, "Fraunces")


func test_theme_defines_every_variation_used_by_components() -> void:
	var theme := ThemeFactory.build()
	for variation in [
		ThemeFactory.LABEL_WORDMARK, ThemeFactory.LABEL_HEADLINE, ThemeFactory.LABEL_TITLE, ThemeFactory.LABEL_NUMERAL,
		ThemeFactory.LABEL_STRONG, ThemeFactory.LABEL_SECONDARY, ThemeFactory.LABEL_CAPTION,
	]:
		assert_eq(theme.get_type_variation_base(variation), &"Label", str(variation))
	for variation in [
		ThemeFactory.BUTTON_PRIMARY, ThemeFactory.BUTTON_SECONDARY, ThemeFactory.BUTTON_TOOL, ThemeFactory.BUTTON_ROW,
		ThemeFactory.BUTTON_TILE, ThemeFactory.BUTTON_ICON, ThemeFactory.BUTTON_NAV, ThemeFactory.BUTTON_NAV_ACTIVE,
	]:
		assert_eq(theme.get_type_variation_base(variation), &"Button", str(variation))
	for variation in [ThemeFactory.PANEL_NAV_BAR, ThemeFactory.PANEL_SHEET, ThemeFactory.PANEL_CARD]:
		assert_eq(theme.get_type_variation_base(variation), &"PanelContainer", str(variation))


static func _contrast(a: Color, b: Color) -> float:
	var la := _luminance(a)
	var lb := _luminance(b)
	return (maxf(la, lb) + 0.05) / (minf(la, lb) + 0.05)


static func _luminance(color: Color) -> float:
	var channels := [color.r, color.g, color.b]
	var linear: Array[float] = []
	for c: float in channels:
		linear.append(c / 12.92 if c <= 0.03928 else pow((c + 0.055) / 1.055, 2.4))
	return 0.2126 * linear[0] + 0.7152 * linear[1] + 0.0722 * linear[2]
