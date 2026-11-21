class_name ScreenHost
extends Control
## Displays one screen at a time with a short, interruptible transition.
## A new transition finishes the previous one immediately.

var reduce_motion := false

var _current: Control
var _outgoing: Control
var _tween: Tween


func _init() -> void:
	clip_contents = true


func current_screen() -> Control:
	return _current


func show_screen(screen: Control, direction: int) -> void:
	_finish_transition()
	_outgoing = _current
	_current = screen
	add_child(screen)

	if _outgoing == null or reduce_motion:
		_finish_transition()
		return

	var offset := 0.0
	match direction:
		Router.Direction.FORWARD:
			offset = DesignTokens.MOTION_SCREEN_OFFSET
		Router.Direction.BACK:
			offset = -DesignTokens.MOTION_SCREEN_OFFSET

	screen.modulate.a = 0.0
	screen.position.x = offset
	_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(screen, ^"modulate:a", 1.0, DesignTokens.MOTION_STANDARD)
	_tween.tween_property(screen, ^"position:x", 0.0, DesignTokens.MOTION_STANDARD)
	_tween.tween_property(_outgoing, ^"modulate:a", 0.0, DesignTokens.MOTION_FAST)
	_tween.chain().tween_callback(_finish_transition)


func _finish_transition() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = null
	if _current != null:
		_current.modulate.a = 1.0
		_current.position = Vector2.ZERO
	if is_instance_valid(_outgoing):
		_outgoing.queue_free()
	_outgoing = null
