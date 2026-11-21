class_name EmptyState
extends VBoxContainer
## Centred message shown when a section has no content yet.


func _init(title: String, message: String) -> void:
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override(&"separation", DesignTokens.SPACE_S)

	var title_label := UiFactory.paragraph(title, ThemeFactory.LABEL_TITLE)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title_label)

	var message_label := UiFactory.paragraph(message, ThemeFactory.LABEL_SECONDARY)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(message_label)
