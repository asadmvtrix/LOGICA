extends Screen
## Training: one lesson per mode covering its rules and the techniques the
## hint engine uses, followed by a practice puzzle.


func _build() -> void:
	var content := _make_scrolling_layout("Training", true)
	content.add_child(UiFactory.paragraph("Each lesson covers the rules and every technique the hints use, in the order they are needed. Practice with Explain to watch each step.", ThemeFactory.LABEL_SECONDARY))
	content.add_child(UiFactory.spacer(DesignTokens.SPACE_XS))
	for mode in PuzzleModes.ALL:
		var card := CardButton.new(DesignTokens.SPACE_M)
		var row := HBoxContainer.new()
		row.add_theme_constant_override(&"separation", DesignTokens.SPACE_M)
		card.content.add_child(row)
		row.add_child(ModePreview.new(mode, 120.0))
		var text := VBoxContainer.new()
		text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_child(text)
		text.add_child(UiFactory.label(PuzzleModes.title(mode), ThemeFactory.LABEL_TITLE))
		text.add_child(UiFactory.label("%d techniques" % PuzzleModes.TECHNIQUES[mode].size(), ThemeFactory.LABEL_SECONDARY))
		card.pressed.connect(context.router.push.bind(Routes.LESSON, mode))
		content.add_child(card)
