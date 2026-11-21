class_name ModalOverlay
extends Control
## Scrim with a centred card. Callers fill content and add buttons.

var content: VBoxContainer
var _card: PanelContainer


func _init() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var scrim := ColorRect.new()
	scrim.color = DesignTokens.COLOR_SCRIM
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(scrim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	_card = PanelContainer.new()
	_card.theme_type_variation = ThemeFactory.PANEL_CARD
	_card.custom_minimum_size.x = 880
	center.add_child(_card)

	content = VBoxContainer.new()
	content.add_theme_constant_override(&"separation", DesignTokens.SPACE_S)
	_card.add_child(content)


func add_button(text: String, variation: StringName = ThemeFactory.BUTTON_SECONDARY) -> Button:
	var button := Button.new()
	button.text = text
	button.theme_type_variation = variation
	button.custom_minimum_size.y = DesignTokens.TOUCH_TARGET_MIN
	content.add_child(button)
	return button


func play_in(reduce_motion: bool) -> void:
	if reduce_motion:
		return
	modulate.a = 0.0
	_card.pivot_offset = _card.size * 0.5
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, DesignTokens.MOTION_STANDARD)
	_card.scale = Vector2(0.96, 0.96)
	tween.tween_property(_card, "scale", Vector2.ONE, DesignTokens.MOTION_SLOW)
