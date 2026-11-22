class_name PressFeedback
extends RefCounted
## Squash-and-spring scale on press for any BaseButton.

const PRESSED_SCALE := 0.94


static func attach(button: BaseButton) -> void:
	var centre := func() -> void: button.pivot_offset = button.size * 0.5
	button.resized.connect(centre)
	button.button_down.connect(func() -> void:
		centre.call()
		_scale_to(button, PRESSED_SCALE, 0.08, Tween.TRANS_QUAD)
	)
	var release := func() -> void:
		if not button.scale.is_equal_approx(Vector2.ONE):
			_scale_to(button, 1.0, 0.32, Tween.TRANS_BACK)
	button.button_up.connect(release)
	button.mouse_exited.connect(release)


static func _scale_to(button: BaseButton, target: float, duration: float, transition: Tween.TransitionType) -> void:
	if not button.is_inside_tree():
		return
	var tween := button.create_tween()
	tween.set_trans(transition).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2(target, target), duration)
