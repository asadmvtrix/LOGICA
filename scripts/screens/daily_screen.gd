extends Screen
## Today's four puzzles, the same on every device for a given date. Difficulty
## follows the weekday: gentle early in the week, Expert on Sunday.


func _build() -> void:
	var content := _make_scrolling_layout("Daily", false)
	var progress := context.progress
	var today := context.today()
	var day := ProgressionCatalog.date_key(today)

	content.add_child(UiFactory.label(DateFormat.long_date(today), ThemeFactory.LABEL_SECONDARY))
	var stats := HBoxContainer.new()
	stats.add_theme_constant_override(&"separation", DesignTokens.SPACE_M)
	content.add_child(UiFactory.spacer(DesignTokens.SPACE_XS))
	content.add_child(stats)
	stats.add_child(StatTile.new("%d/4" % progress.daily_count(day), "Solved today"))
	stats.add_child(StatTile.new(str(progress.daily_streak(today)), "Day streak"))
	stats.add_child(StatTile.new(str(progress.daily_days()), "Days played"))
	content.add_child(UiFactory.spacer(DesignTokens.SPACE_S))

	for mode in PuzzleModes.ALL:
		content.add_child(_puzzle_card(ProgressionCatalog.daily_launch(mode, today)))


func _puzzle_card(launch: PuzzleLaunch) -> CardButton:
	var card := CardButton.new(DesignTokens.SPACE_M)
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", DesignTokens.SPACE_M)
	card.content.add_child(row)
	row.add_child(ModePreview.new(launch.mode, 130.0))
	var text := VBoxContainer.new()
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(text)
	text.add_child(UiFactory.label(PuzzleModes.title(launch.mode), ThemeFactory.LABEL_TITLE))
	text.add_child(UiFactory.label(Difficulty.name_of(launch.difficulty), ThemeFactory.LABEL_SECONDARY))
	var record := context.progress.record_for(launch.key)
	var status := UiFactory.caption("Solved · %s" % TimeFormat.clock(record["time"]) if not record.is_empty() else "Play")
	status.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	status.add_theme_color_override(&"font_color", DesignTokens.COLOR_SUCCESS if not record.is_empty() else DesignTokens.mode_color(launch.mode))
	row.add_child(status)
	card.pressed.connect(context.router.push.bind(Routes.PLAY, launch))
	return card
