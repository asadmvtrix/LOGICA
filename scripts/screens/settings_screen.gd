extends Screen
## Player preferences and app information.

var _toggles: Array[ToggleRow] = []


func _build() -> void:
	var content := _make_scrolling_layout("Settings", false)
	var settings := context.settings

	content.add_child(UiFactory.caption("Play"))
	var play := RowGroup.new()
	content.add_child(play)
	play.add_row(_toggle("Show timer", "Time each puzzle in the header", settings.show_timer, settings.set_show_timer))
	play.add_row(_toggle("Haptics", "A light tap when you place a piece", settings.haptics, settings.set_haptics))
	play.add_row(_toggle("Auto-cross", "Placing a queen crosses out every cell it rules out", settings.auto_cross, settings.set_auto_cross))

	content.add_child(UiFactory.spacer(DesignTokens.SPACE_L))
	content.add_child(UiFactory.caption("Display"))
	var display := RowGroup.new()
	content.add_child(display)
	display.add_row(_toggle("Reduce motion", "Shorter, simpler animations", settings.reduced_motion, _on_reduced_motion_changed))

	content.add_child(UiFactory.spacer(DesignTokens.SPACE_L))
	content.add_child(UiFactory.caption("Hints"))
	content.add_child(UiFactory.paragraph("Hint reveals the next move with its reason. Explain walks through every step that leads to it. Both are unlimited and never guess: when no logical step exists, they say so.", ThemeFactory.LABEL_SECONDARY))

	content.add_child(UiFactory.spacer(DesignTokens.SPACE_L))
	content.add_child(UiFactory.caption("About"))
	var about := RowGroup.new()
	content.add_child(about)
	about.add_row(InfoRow.new("Version", AppContext.app_version()))
	about.add_row(InfoRow.new("Fonts", "Fraunces, Inter (OFL)"))


func _toggle(title: String, subtitle: String, value: bool, callback: Callable) -> ToggleRow:
	var row := ToggleRow.new(title, subtitle, value)
	row.reduce_motion = context.settings.reduced_motion
	row.value_changed.connect(callback)
	_toggles.append(row)
	return row


func _on_reduced_motion_changed(value: bool) -> void:
	context.settings.set_reduced_motion(value)
	for row in _toggles:
		row.reduce_motion = value
