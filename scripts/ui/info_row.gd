class_name InfoRow
extends HBoxContainer
## Read-only row showing a label and its value.


func _init(title: String, value_text: String) -> void:
	custom_minimum_size.y = DesignTokens.ROW_HEIGHT
	var title_label := UiFactory.label(title)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(title_label)

	var value_label := UiFactory.label(value_text, ThemeFactory.LABEL_SECONDARY)
	value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(value_label)
