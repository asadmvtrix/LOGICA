class_name HintPresentationController
extends Control
## Bottom sheet that presents a HintResult one step at a time, highlighting
## each step's cells on the board. Reveal hints offer Apply; tactical hints
## walk through every step and offer Apply at the end. No-hint results only
## explain why and close.

signal apply_requested(result: HintResult)
signal closed

var board: BoardView
var reduce_motion := false

var _result: HintResult
var _index := 0
var _sheet: PanelContainer
var _kind_label: Label
var _title: Label
var _body: Label
var _counter: Label
var _previous: Button
var _next: Button
var _apply: Button
var _slide: Tween
var _rest_top := 0.0
var _rest_bottom := 0.0

const SLIDE_DISTANCE := 480.0


func _init() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false

	_sheet = PanelContainer.new()
	_sheet.theme_type_variation = ThemeFactory.PANEL_SHEET
	_sheet.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_sheet.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_sheet.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_sheet)
	_rest_top = _sheet.offset_top
	_rest_bottom = _sheet.offset_bottom

	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", DesignTokens.SPACE_S)
	_sheet.add_child(column)

	var top := HBoxContainer.new()
	column.add_child(top)
	_kind_label = UiFactory.caption("Hint")
	_kind_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_kind_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top.add_child(_kind_label)
	_counter = UiFactory.label("", ThemeFactory.LABEL_SECONDARY)
	_counter.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top.add_child(_counter)
	var close := IconButton.new(VectorIcons.Icon.CLOSE)
	close.pressed.connect(hide_hint)
	top.add_child(close)

	_title = UiFactory.paragraph("", ThemeFactory.LABEL_TITLE)
	column.add_child(_title)
	_body = UiFactory.paragraph("")
	_body.custom_minimum_size.y = DesignTokens.FONT_SIZE_BODY * 3.6
	column.add_child(_body)

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override(&"separation", DesignTokens.SPACE_S)
	column.add_child(buttons)
	_previous = _button("Back", ThemeFactory.BUTTON_SECONDARY)
	_previous.pressed.connect(_step.bind(-1))
	buttons.add_child(_previous)
	_next = _button("Next", ThemeFactory.BUTTON_SECONDARY)
	_next.pressed.connect(_step.bind(1))
	buttons.add_child(_next)
	_apply = _button("Apply", ThemeFactory.BUTTON_PRIMARY)
	_apply.pressed.connect(_on_apply)
	buttons.add_child(_apply)


func _button(text: String, variation: StringName) -> Button:
	var button := Button.new()
	button.text = text
	button.theme_type_variation = variation
	button.custom_minimum_size.y = DesignTokens.TOUCH_TARGET_MIN
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return button


func is_open() -> bool:
	return visible


func current_result() -> HintResult:
	return _result


func current_index() -> int:
	return _index


func show_hint(result: HintResult) -> void:
	_result = result
	_index = 0
	if result.kind == HintResult.Kind.TACTICAL:
		_kind_label.text = "EXPLANATION"
	else:
		_kind_label.text = "HINT"
	_title.text = result.title
	var was_open := visible
	visible = true
	_refresh()
	if not reduce_motion and not was_open:
		if _slide != null:
			_slide.kill()
		_sheet.offset_top = _rest_top + SLIDE_DISTANCE
		_sheet.offset_bottom = _rest_bottom + SLIDE_DISTANCE
		_sheet.modulate.a = 0.0
		_slide = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		_slide.tween_property(_sheet, "offset_top", _rest_top, DesignTokens.MOTION_SLOW)
		_slide.tween_property(_sheet, "offset_bottom", _rest_bottom, DesignTokens.MOTION_SLOW)
		_slide.tween_property(_sheet, "modulate:a", 1.0, DesignTokens.MOTION_STANDARD)


func hide_hint() -> void:
	if not visible:
		return
	visible = false
	_result = null
	if board != null:
		board.clear_hint()
	closed.emit()


func _step(delta: int) -> void:
	_index = clampi(_index + delta, 0, _result.steps.size() - 1)
	_refresh()


func _refresh() -> void:
	var steps := _result.steps
	var step: HintStep = steps[_index] if not steps.is_empty() else HintStep.new("")
	_body.text = step.text
	var multi := steps.size() > 1
	_counter.text = "%d of %d" % [_index + 1, steps.size()] if multi else ""
	_previous.visible = multi
	_next.visible = multi
	_previous.disabled = _index == 0
	_next.disabled = _index >= steps.size() - 1
	var last := _index >= steps.size() - 1
	_apply.visible = true
	if not _result.available:
		_apply.text = "Close"
	elif _result.kind == HintResult.Kind.TACTICAL and not last:
		_apply.visible = false
	else:
		_apply.text = "Apply"
	if board != null:
		board.set_hint(step.focus, step.related)


func _on_apply() -> void:
	var result := _result
	if result == null or not result.available:
		hide_hint()
		return
	hide_hint()
	apply_requested.emit(result)
