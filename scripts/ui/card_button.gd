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
	# Button computes its own minimum size natively (a script override is
	# ignored), so the content height is copied into custom_minimum_size.
	_margin.minimum_size_changed.connect(_sync_minimum_size)
	resized.connect(_sync_minimum_size)


func _ready() -> void:
	_ignore_mouse(content)
	_sync_minimum_size()


func _sync_minimum_size() -> void:
	var needed := _margin.get_combined_minimum_size().y
	if not is_equal_approx(custom_minimum_size.y, needed):
		custom_minimum_size.y = needed


static func _ignore_mouse(node: Node) -> void:
	for child in node.get_children():
		if child is Control:
			(child as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
		_ignore_mouse(child)
