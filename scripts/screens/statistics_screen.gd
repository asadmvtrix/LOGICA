extends Screen
## Totals and per-mode statistics, all from local progress.


func _build() -> void:
	var content := _make_scrolling_layout("Statistics", false)
	var progress := context.progress

	var totals := HBoxContainer.new()
	totals.add_theme_constant_override(&"separation", DesignTokens.SPACE_M)
	content.add_child(totals)
	totals.add_child(StatTile.new(str(progress.total_solved()), "Solved"))
	totals.add_child(StatTile.new(TimeFormat.clock(progress.total_time()), "Time played"))
	totals.add_child(StatTile.new(str(progress.daily_streak(context.today())), "Day streak"))

	for mode in PuzzleModes.ALL:
		var stats := progress.mode_stats(mode)
		content.add_child(UiFactory.spacer(DesignTokens.SPACE_M))
		var heading := UiFactory.caption(PuzzleModes.title(mode))
		heading.add_theme_color_override(&"font_color", DesignTokens.mode_color(mode))
		content.add_child(heading)
		var rows := RowGroup.new()
		content.add_child(rows)
		rows.add_row(InfoRow.new("Solved", str(stats["solved"])))
		rows.add_row(InfoRow.new("Journey", "%d of %d" % [progress.journey_completed(mode), ProgressionCatalog.JOURNEY_LEVELS]))
		var best: Dictionary = stats["best"]
		for level in Difficulty.NAMES.size():
			var key := str(level)
			if best.has(key):
				rows.add_row(InfoRow.new("Best · %s" % Difficulty.NAMES[level], TimeFormat.clock(best[key])))
		rows.add_row(InfoRow.new("Hints used", str(stats["hints"])))
