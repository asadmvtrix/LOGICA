class_name ScreenHeader
extends MarginContainer
## Screen title with an optional back button. The chevron aligns with the page
## margin so titles line up across screens.

signal back_pressed


func _init(title: String, show_back: bool) -> void:
	custom_minimum_size.y = DesignTokens.HEADER_HEIGHT
	var back_offset := (DesignTokens.TOUCH_TARGET_MIN - DesignTokens.CHEVRON_SIZE) * 0.5
	var left := DesignTokens.PAGE_MARGIN - int(back_offset) if show_back else DesignTokens.PAGE_MARGIN
	add_theme_constant_override(&"margin_left", left)
	add_theme_constant_override(&"margin_right", DesignTokens.PAGE_MARGIN)

	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", DesignTokens.SPACE_XS)
	add_child(row)

	if show_back:
		var back := BackButton.new()
		back.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		back.pressed.connect(back_pressed.emit)
		row.add_child(back)

	var title_label := UiFactory.label(title, ThemeFactory.LABEL_HEADLINE)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	row.add_child(title_label)
