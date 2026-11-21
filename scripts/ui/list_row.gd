class_name ListRow
extends Button
## Full-width navigational row: title, optional subtitle and a trailing chevron.


func _init(title: String, subtitle: String = "") -> void:
	theme_type_variation = ThemeFactory.BUTTON_ROW
	mouse_filter = Control.MOUSE_FILTER_PASS
	custom_minimum_size.y = DesignTokens.ROW_HEIGHT if subtitle.is_empty() else DesignTokens.ROW_HEIGHT_TALL
	add_child(UiFactory.row_text(title, subtitle, DesignTokens.CHEVRON_SIZE + DesignTokens.SPACE_M))


func _draw() -> void:
	var center := Vector2(size.x - DesignTokens.CHEVRON_SIZE * 0.5, size.y * 0.5)
	VectorIcons.draw_chevron(self, center, VectorIcons.Direction.RIGHT, DesignTokens.COLOR_INK_MUTED)
