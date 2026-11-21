class_name IconButton
extends Button
## Square touch target showing a single vector icon.

var icon_kind: VectorIcons.Icon
var color := DesignTokens.COLOR_INK


func _init(p_icon: VectorIcons.Icon) -> void:
	icon_kind = p_icon
	theme_type_variation = ThemeFactory.BUTTON_ICON
	custom_minimum_size = Vector2(DesignTokens.TOUCH_TARGET_MIN, DesignTokens.TOUCH_TARGET_MIN)


func _draw() -> void:
	VectorIcons.draw_icon(self, icon_kind, size * 0.5, size.y * 0.5, color)
