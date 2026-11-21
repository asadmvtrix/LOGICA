class_name BoardView
extends Control
## Base for drawn puzzle boards. Fits a square-celled grid into its rect, maps
## touches to cells, shows hint highlights and plays the completion wave.
## Subclasses draw cell fills and contents and react to taps and drags.

signal cell_selected(index: int)

var game: PuzzleGame
var accent := DesignTokens.COLOR_ACCENT
var selected := -1
var input_enabled := true

var hint_focus := PackedInt32Array()
var hint_related := PackedInt32Array()

var _origin := Vector2.ZERO
var _cell := 1.0
var _press_cell := -1
var _last_cell := -1
var _dragging := false
var _wave := -1.0

static var _fonts := {}


func _init(p_game: PuzzleGame) -> void:
	game = p_game
	accent = DesignTokens.mode_color(game.mode_id)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	custom_minimum_size = Vector2(300, 300)
	game.changed.connect(queue_redraw)
	resized.connect(_layout)


static func font(weight: int) -> Font:
	if not _fonts.has(weight):
		_fonts[weight] = ThemeFactory.ui_font(weight)
	return _fonts[weight]


func cell_size() -> float:
	return _cell


func cell_rect(index: int) -> Rect2:
	var c := index % game.width
	var r := index / game.width
	return Rect2(_origin + Vector2(c, r) * _cell, Vector2(_cell, _cell))


func board_rect() -> Rect2:
	return Rect2(_origin, Vector2(game.width, game.height) * _cell)


func cell_at(point: Vector2) -> int:
	var local := (point - _origin) / _cell
	if local.x < 0 or local.y < 0 or local.x >= game.width or local.y >= game.height:
		return -1
	return int(local.y) * game.width + int(local.x)


func set_hint(focus: PackedInt32Array, related: PackedInt32Array) -> void:
	hint_focus = focus
	hint_related = related
	queue_redraw()


func clear_hint() -> void:
	set_hint(PackedInt32Array(), PackedInt32Array())


func select(index: int) -> void:
	selected = index
	cell_selected.emit(index)
	queue_redraw()


func play_completion(reduce_motion: bool) -> void:
	selected = -1
	clear_hint()
	if reduce_motion:
		return
	var tween := create_tween()
	tween.tween_method(_set_wave, 0.0, 1.0, DesignTokens.MOTION_SLOW + DesignTokens.MOTION_CELL_STAGGER * game.cell_count())
	tween.tween_callback(_set_wave.bind(-1.0))


func _set_wave(value: float) -> void:
	_wave = value
	queue_redraw()


func _layout() -> void:
	_cell = floorf(minf(size.x / game.width, size.y / game.height))
	_cell = maxf(_cell, 1.0)
	_origin = ((size - Vector2(game.width, game.height) * _cell) * 0.5).floor()
	queue_redraw()


# --- Input -----------------------------------------------------------------

func _gui_input(event: InputEvent) -> void:
	if not input_enabled or game.is_solved:
		return
	var button := event as InputEventMouseButton
	var motion := event as InputEventMouseMotion
	if button != null and button.button_index == MOUSE_BUTTON_LEFT:
		var cell := cell_at(button.position)
		if button.pressed:
			_press_cell = cell
			_last_cell = cell
			_dragging = false
			if cell >= 0:
				_on_press(cell)
		elif _press_cell >= 0:
			if _dragging:
				_on_drag_end(_last_cell)
			elif cell == _press_cell:
				_on_tap(cell)
			_press_cell = -1
		accept_event()
	elif motion != null and _press_cell >= 0 and (motion.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
		var cell := cell_at(motion.position)
		if cell >= 0 and cell != _last_cell:
			if not _dragging:
				_dragging = true
				_on_drag_start(_press_cell)
			_last_cell = cell
			_on_drag(cell)
		accept_event()


func _on_press(_cell_index: int) -> void:
	pass


func _on_tap(_cell_index: int) -> void:
	pass


func _on_drag_start(_cell_index: int) -> void:
	pass


func _on_drag(_cell_index: int) -> void:
	pass


func _on_drag_end(_cell_index: int) -> void:
	pass


# --- Drawing ---------------------------------------------------------------

func _draw() -> void:
	var board := board_rect()
	draw_rect(board, DesignTokens.COLOR_SURFACE)
	for i in game.cell_count():
		var fill := _cell_fill(i)
		if fill.a > 0.0:
			draw_rect(cell_rect(i), fill)
	for i in hint_related:
		draw_rect(cell_rect(i), DesignTokens.COLOR_HINT_RELATED)
	if selected >= 0 and selected < game.cell_count():
		draw_rect(cell_rect(selected), DesignTokens.COLOR_BOARD_SELECTED)
	_draw_grid()
	_draw_overlay()
	for i in game.cell_count():
		_draw_cell(i, cell_rect(i))
	if hint_focus.size() > 4:
		for i in hint_focus:
			draw_rect(cell_rect(i), Color(DesignTokens.COLOR_HINT_FOCUS, 0.24))
	else:
		for i in hint_focus:
			draw_rect(cell_rect(i).grow(-DesignTokens.BOARD_LINE * 2), DesignTokens.COLOR_HINT_FOCUS, false, DesignTokens.BOARD_LINE_STRONG)
	if _wave >= 0.0:
		_draw_wave()
	draw_rect(board, DesignTokens.COLOR_BOARD_LINE_STRONG, false, DesignTokens.BOARD_LINE_STRONG)


func _cell_fill(_index: int) -> Color:
	return Color(0, 0, 0, 0)


func _draw_grid() -> void:
	var board := board_rect()
	for c in range(1, game.width):
		var x := board.position.x + c * _cell
		draw_line(Vector2(x, board.position.y), Vector2(x, board.end.y), DesignTokens.COLOR_BOARD_LINE, DesignTokens.BOARD_LINE)
	for r in range(1, game.height):
		var y := board.position.y + r * _cell
		draw_line(Vector2(board.position.x, y), Vector2(board.end.x, y), DesignTokens.COLOR_BOARD_LINE, DesignTokens.BOARD_LINE)


## Drawn after the grid and before cell contents (region borders, edges).
func _draw_overlay() -> void:
	pass


func _draw_cell(_index: int, _rect: Rect2) -> void:
	pass


func _draw_wave() -> void:
	var span := float(game.width + game.height - 2)
	for i in game.cell_count():
		var order := float(i % game.width + i / game.width) / maxf(span, 1.0)
		var t := clampf((_wave - order * 0.6) / 0.4, 0.0, 1.0)
		var alpha := sin(t * PI) * 0.45
		if alpha > 0.0:
			draw_rect(cell_rect(i), Color(accent, alpha))


func draw_centered_text(rect: Rect2, text: String, font_size: int, color: Color, weight: int = DesignTokens.FONT_WEIGHT_MEDIUM) -> void:
	var f := font(weight)
	var ascent := f.get_ascent(font_size)
	var descent := f.get_descent(font_size)
	var baseline := rect.position.y + (rect.size.y + ascent - descent) * 0.5
	draw_string(f, Vector2(rect.position.x, baseline), text, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, font_size, color)
