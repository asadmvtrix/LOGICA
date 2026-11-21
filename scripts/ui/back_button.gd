class_name BackButton
extends Button
## Square touch target with a left chevron.


func _init() -> void:
	theme_type_variation = ThemeFactory.BUTTON_ICON
	custom_minimum_size = Vector2(DesignTokens.TOUCH_TARGET_MIN, DesignTokens.TOUCH_TARGET_MIN)
	tooltip_text = "Back"


func _draw() -> void:
	VectorIcons.draw_chevron(self, size * 0.5, VectorIcons.Direction.LEFT, DesignTokens.COLOR_INK)
