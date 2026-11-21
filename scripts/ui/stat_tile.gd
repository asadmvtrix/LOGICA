class_name StatTile
extends VBoxContainer
## Large serif numeral above a small caption.


func _init(value_text: String, caption_text: String) -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_theme_constant_override(&"separation", DesignTokens.SPACE_XXS)
	add_child(UiFactory.label(value_text, ThemeFactory.LABEL_NUMERAL))
	add_child(UiFactory.caption(caption_text))
