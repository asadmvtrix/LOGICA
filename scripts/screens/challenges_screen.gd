extends Screen
## Fixed challenges: a set puzzle with a goal such as a time limit or no hints.


func _build() -> void:
	var content := _make_scrolling_layout("Challenges", true)
	var progress := context.progress
	content.add_child(UiFactory.paragraph("%d of %d complete. Each challenge is a fixed puzzle; replay it as often as you like." % [
		progress.challenges_done(), ProgressionCatalog.CHALLENGES.size()], ThemeFactory.LABEL_SECONDARY))
	content.add_child(UiFactory.spacer(DesignTokens.SPACE_XS))
	for entry: Dictionary in ProgressionCatalog.CHALLENGES:
		var card := CardButton.new(DesignTokens.SPACE_M)
		var row := HBoxContainer.new()
		row.add_theme_constant_override(&"separation", DesignTokens.SPACE_M)
		card.content.add_child(row)
		row.add_child(ModePreview.new(entry["mode"], 120.0))
		var text := VBoxContainer.new()
		text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_child(text)
		var done := progress.challenge_done(entry["id"])
		var caption := UiFactory.caption("Complete" if done else PuzzleModes.title(entry["mode"]))
		caption.add_theme_color_override(&"font_color", DesignTokens.COLOR_SUCCESS if done else DesignTokens.mode_color(entry["mode"]))
		text.add_child(caption)
		text.add_child(UiFactory.label(entry["title"], ThemeFactory.LABEL_TITLE))
		text.add_child(UiFactory.paragraph(ProgressionCatalog.challenge_goal(entry), ThemeFactory.LABEL_SECONDARY))
		card.pressed.connect(context.router.push.bind(Routes.PLAY, ProgressionCatalog.challenge_launch(entry)))
		content.add_child(card)
