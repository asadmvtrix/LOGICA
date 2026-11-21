extends Screen
## Entry point listing every play section.


func _build() -> void:
	var content := _make_scrolling_layout("", false)
	content.add_child(UiFactory.spacer(DesignTokens.SPACE_XL))
	content.add_child(UiFactory.label("LOGICA", ThemeFactory.LABEL_WORDMARK))
	content.add_child(UiFactory.label(DateFormat.today(), ThemeFactory.LABEL_SECONDARY))
	content.add_child(UiFactory.spacer(DesignTokens.SPACE_XL))

	content.add_child(UiFactory.caption("Play"))
	var rows := RowGroup.new()
	content.add_child(rows)
	_add_row(rows, "Journey", "Levels in order of difficulty", Routes.JOURNEY)
	_add_row(rows, "Daily", "Today's puzzles", Routes.DAILY)
	_add_row(rows, "Training", "Learn how each puzzle works", Routes.TRAINING)
	_add_row(rows, "Challenges", "Special puzzle sets", Routes.CHALLENGES)


func _add_row(rows: RowGroup, title: String, subtitle: String, target: StringName) -> void:
	var row := ListRow.new(title, subtitle)
	row.pressed.connect(context.router.push.bind(target))
	rows.add_row(row)
