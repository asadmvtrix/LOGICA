class_name UiFactory
extends RefCounted
## Small constructors for common styled nodes, so screens never repeat
## styling details.


static func label(text: String, variation: StringName = &"") -> Label:
	var node := Label.new()
	node.text = text
	node.theme_type_variation = variation
	return node


static func paragraph(text: String, variation: StringName = &"") -> Label:
	var node := label(text, variation)
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return node


static func caption(text: String) -> Label:
	var node := label(text, ThemeFactory.LABEL_CAPTION)
	node.uppercase = true
	return node


static func spacer(height: int) -> Control:
	var node := Control.new()
	node.custom_minimum_size = Vector2(0, height)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return node


## Title and optional subtitle laid out inside a row, leaving right_inset
## pixels free for a trailing control such as a chevron or switch.
static func row_text(title: String, subtitle: String, right_inset: float) -> MarginContainer:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override(&"margin_right", int(right_inset))

	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_theme_constant_override(&"separation", DesignTokens.SPACE_XXS)
	margin.add_child(column)

	column.add_child(label(title))
	if not subtitle.is_empty():
		column.add_child(label(subtitle, ThemeFactory.LABEL_SECONDARY))
	return margin
