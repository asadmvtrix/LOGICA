extends Screen
## Player preferences and app information.

var _reduced_motion_row: ToggleRow


func _build() -> void:
	var content := _make_scrolling_layout("Settings", false)
	var settings := context.settings

	content.add_child(UiFactory.caption("Display"))
	var display := RowGroup.new()
	content.add_child(display)
	_reduced_motion_row = ToggleRow.new("Reduce motion", "Shorter, simpler animations", settings.reduced_motion)
	_reduced_motion_row.reduce_motion = settings.reduced_motion
	_reduced_motion_row.value_changed.connect(_on_reduced_motion_changed)
	display.add_row(_reduced_motion_row)

	content.add_child(UiFactory.spacer(DesignTokens.SPACE_L))
	content.add_child(UiFactory.caption("About"))
	var about := RowGroup.new()
	content.add_child(about)
	about.add_row(InfoRow.new("Version", AppContext.app_version()))


func _on_reduced_motion_changed(value: bool) -> void:
	context.settings.set_reduced_motion(value)
	_reduced_motion_row.reduce_motion = value
