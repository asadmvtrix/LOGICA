extends Screen
## Lesson for one mode (the LESSON route parameter): rules, techniques and a
## practice puzzle.


func _build() -> void:
	var param: Variant = context.router.current_params()
	var mode: StringName = param if param is StringName else PuzzleModes.QUEENS
	var content := _make_scrolling_layout(PuzzleModes.title(mode), true)
	var accent := DesignTokens.mode_color(mode)

	var preview := ModePreview.new(mode, 260.0)
	preview.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	content.add_child(preview)
	content.add_child(UiFactory.spacer(DesignTokens.SPACE_XS))

	content.add_child(UiFactory.caption("Rules"))
	var number := 1
	for rule: String in PuzzleModes.RULES[mode]:
		content.add_child(_numbered(number, rule, accent))
		number += 1

	content.add_child(UiFactory.spacer(DesignTokens.SPACE_S))
	content.add_child(UiFactory.caption("Techniques"))
	for technique: Array in PuzzleModes.TECHNIQUES[mode]:
		var block := VBoxContainer.new()
		block.add_theme_constant_override(&"separation", DesignTokens.SPACE_XXS)
		block.add_child(UiFactory.label(technique[0], ThemeFactory.LABEL_STRONG))
		block.add_child(UiFactory.paragraph(technique[1], ThemeFactory.LABEL_SECONDARY))
		content.add_child(block)

	content.add_child(UiFactory.spacer(DesignTokens.SPACE_S))
	var practice := Button.new()
	practice.text = "Practice puzzle"
	practice.theme_type_variation = ThemeFactory.BUTTON_PRIMARY
	practice.custom_minimum_size.y = DesignTokens.TOUCH_TARGET_MIN
	practice.pressed.connect(context.router.push.bind(Routes.PLAY, ProgressionCatalog.training_launch(mode)))
	content.add_child(practice)


func _numbered(number: int, text: String, accent: Color) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", DesignTokens.SPACE_S)
	var index := UiFactory.label(str(number), ThemeFactory.LABEL_TITLE)
	index.add_theme_color_override(&"font_color", accent)
	index.custom_minimum_size.x = 56
	row.add_child(index)
	var body := UiFactory.paragraph(text)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(body)
	return row
