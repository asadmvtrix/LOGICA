extends Screen
## Front page: date and wordmark, the unfinished puzzle, today's set, the four
## modes (each opens its next journey level) and the other sections.


func _build() -> void:
	var content := _make_scrolling_layout("", false)
	var progress := context.progress
	var today := context.today()

	content.add_child(UiFactory.spacer(DesignTokens.SPACE_L))
	content.add_child(UiFactory.caption(DateFormat.long_date(today)))
	content.add_child(UiFactory.label("Logica", ThemeFactory.LABEL_WORDMARK))
	content.add_child(UiFactory.paragraph("Four logic puzzles. Every hint explains itself, and hints are unlimited.", ThemeFactory.LABEL_SECONDARY))
	content.add_child(UiFactory.spacer(DesignTokens.SPACE_M))

	var session := progress.session_launch()
	if session != null:
		content.add_child(_continue_card(session))

	content.add_child(_daily_card(today))
	content.add_child(UiFactory.spacer(DesignTokens.SPACE_M))

	content.add_child(UiFactory.caption("Puzzles"))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override(&"h_separation", DesignTokens.SPACE_S)
	grid.add_theme_constant_override(&"v_separation", DesignTokens.SPACE_S)
	content.add_child(grid)
	for mode in PuzzleModes.ALL:
		grid.add_child(_mode_tile(mode))

	content.add_child(UiFactory.spacer(DesignTokens.SPACE_M))
	content.add_child(UiFactory.caption("More"))
	var rows := RowGroup.new()
	content.add_child(rows)
	var training := ListRow.new("Training", "Rules and solving techniques, with practice")
	training.pressed.connect(context.router.push.bind(Routes.TRAINING))
	rows.add_row(training)
	var challenges := ListRow.new("Challenges", "%d of %d complete" % [progress.challenges_done(), ProgressionCatalog.CHALLENGES.size()])
	challenges.pressed.connect(context.router.push.bind(Routes.CHALLENGES))
	rows.add_row(challenges)


func _continue_card(session: PuzzleLaunch) -> CardButton:
	var card := CardButton.new()
	card.set_fill(DesignTokens.mode_tint(session.mode).lerp(DesignTokens.COLOR_SURFACE, 0.5))
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", DesignTokens.SPACE_M)
	card.content.add_child(row)
	row.add_child(ModePreview.new(session.mode, 120.0))
	var text := VBoxContainer.new()
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(text)
	text.add_child(UiFactory.caption("Continue"))
	text.add_child(UiFactory.label(PuzzleModes.title(session.mode), ThemeFactory.LABEL_TITLE))
	text.add_child(UiFactory.label(session.subtitle(), ThemeFactory.LABEL_SECONDARY))
	card.pressed.connect(context.router.push.bind(Routes.PLAY, session))
	return card


func _daily_card(today: Dictionary) -> CardButton:
	var progress := context.progress
	var day := ProgressionCatalog.date_key(today)
	var card := CardButton.new()
	card.set_fill(DesignTokens.COLOR_HERO)
	card.content.add_child(_hero_label(UiFactory.caption("Today"), true))
	card.content.add_child(_hero_label(UiFactory.label("The daily set", ThemeFactory.LABEL_HEADLINE), false))
	var previews := HBoxContainer.new()
	previews.add_theme_constant_override(&"separation", DesignTokens.SPACE_S)
	card.content.add_child(UiFactory.spacer(DesignTokens.SPACE_XS))
	card.content.add_child(previews)
	for mode in PuzzleModes.ALL:
		var holder := DailyBadge.new(mode, progress.daily_done(day, mode))
		previews.add_child(holder)
	card.content.add_child(UiFactory.spacer(DesignTokens.SPACE_XS))
	var streak := progress.daily_streak(today)
	var summary := "%d of 4 solved" % progress.daily_count(day)
	if streak > 0:
		summary += " · %d day streak" % streak
	card.content.add_child(_hero_label(UiFactory.label(summary, ThemeFactory.LABEL_SECONDARY), true))
	card.pressed.connect(context.router.select_tab.bind(Routes.DAILY))
	return card


func _hero_label(label: Label, secondary: bool) -> Label:
	label.add_theme_color_override(&"font_color", DesignTokens.COLOR_HERO_INK_SECONDARY if secondary else DesignTokens.COLOR_HERO_INK)
	return label


func _mode_tile(mode: StringName) -> CardButton:
	var tile := CardButton.new(DesignTokens.SPACE_M)
	tile.set_fill(DesignTokens.mode_tint(mode))
	tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var preview := ModePreview.new(mode, 200.0)
	preview.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	tile.content.add_child(preview)
	tile.content.add_child(UiFactory.spacer(DesignTokens.SPACE_XS))
	var name_label := UiFactory.label(PuzzleModes.title(mode), ThemeFactory.LABEL_TITLE)
	name_label.add_theme_color_override(&"font_color", DesignTokens.mode_color(mode).darkened(0.35))
	tile.content.add_child(name_label)
	var tagline := UiFactory.paragraph(PuzzleModes.tagline(mode), ThemeFactory.LABEL_SECONDARY)
	tagline.custom_minimum_size.y = DesignTokens.FONT_SIZE_BODY_SMALL * 2.6
	tile.content.add_child(tagline)
	var level := context.progress.next_journey_level(mode)
	tile.content.add_child(LevelChip.new("Level %d" % level, DesignTokens.mode_color(mode)))
	tile.pressed.connect(context.router.push.bind(Routes.PLAY, ProgressionCatalog.journey_launch(mode, level)))
	return tile


## Mode preview with a check mark once that daily puzzle is solved.
class DailyBadge:
	extends Control

	func _init(mode: StringName, done: bool) -> void:
		custom_minimum_size = Vector2(150, 150)
		var preview := ModePreview.new(mode, 150.0)
		preview.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		if not done:
			preview.modulate.a = 0.55
		add_child(preview)
		if done:
			var mark := Control.new()
			mark.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
			mark.draw.connect(func() -> void:
				var center := Vector2(mark.size.x - 22, 22)
				mark.draw_circle(center, 24, DesignTokens.COLOR_SUCCESS)
				VectorIcons.draw_icon(mark, VectorIcons.Icon.CHECK, center, 44, DesignTokens.COLOR_SURFACE)
			)
			add_child(mark)


## Solid pill in the mode colour with the next level number.
class LevelChip:
	extends Control

	var text: String
	var color: Color

	func _init(p_text: String, p_color: Color) -> void:
		text = p_text
		color = p_color
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		custom_minimum_size = Vector2(220, 64)
		size_flags_horizontal = Control.SIZE_SHRINK_BEGIN

	func _draw() -> void:
		var box := StyleBoxFlat.new()
		box.bg_color = color
		box.set_corner_radius_all(DesignTokens.RADIUS_PILL)
		box.anti_aliasing = true
		draw_style_box(box, Rect2(Vector2.ZERO, size))
		var font := BoardView.font(DesignTokens.FONT_WEIGHT_SEMIBOLD)
		var font_size := DesignTokens.FONT_SIZE_CAPTION
		var baseline := (size.y + font.get_ascent(font_size) - font.get_descent(font_size)) * 0.5
		draw_string(font, Vector2(0, baseline), text + "  ›", HORIZONTAL_ALIGNMENT_CENTER, size.x, font_size, DesignTokens.COLOR_SURFACE)
