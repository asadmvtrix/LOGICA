class_name CardButton
extends Button
## Tappable card. Fill `content`; the card sizes itself to it. Children never
## take mouse input, so the whole card is one touch target and the parent
## ScrollContainer can still be dragged.

var content: VBoxContainer
var _margin: MarginContainer


func _init(padding: int = DesignTokens.SPACE_L) -> void:
	theme_type_variation = ThemeFactory.BUTTON_TILE
	mouse_filter = Control.MOUSE_FILTER_PASS
	_margin = MarginContainer.new()
	_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in ["left", "right", "top", "bottom"]:
		_margin.add_theme_constant_override("margin_" + side, padding)
	add_child(_margin)
	content = VBoxContainer.new()
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_theme_constant_override(&"separation", DesignTokens.SPACE_XS)
	_margin.add_child(content)
	_margin.minimum_size_changed.connect(update_minimum_size)


func _get_minimum_size() -> Vector2:
	return _margin.get_combined_minimum_size()


func _ready() -> void:
	_ignore_mouse(content)


static func _ignore_mouse(node: Node) -> void:
	for child in node.get_children():
		if child is Control:
			(child as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
		_ignore_mouse(child)
