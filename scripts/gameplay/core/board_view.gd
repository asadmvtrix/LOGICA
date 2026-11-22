class_name BoardView
extends Control
## Base for drawn puzzle boards. Fits a square-celled grid into its rect, maps
## touches to cells, shows hint highlights and animates the board: pieces pop
## in when placed, newly conflicting cells shake, finished rows / columns /
## regions flash, and solving plays a ripple across every cell.
## Subclasses draw cell backgrounds and contents and react to taps and drags.

signal cell_selected(index: int)

const POP_TIME := 0.34
const SHAKE_TIME := 0.42
const FLASH_TIME := 0.6
const RIPPLE_STAGGER_MS := 28

var game: PuzzleGame
var accent := DesignTokens.COLOR_ACCENT
var selected := -1
var input_enabled := true
var reduce_motion := false

var hint_focus := PackedInt32Array()
var hint_related := PackedInt32Array()

var _origin := Vector2.ZERO
var _cell := 1.0
var _press_cell := -1
var _last_cell := -1
var _dragging := false

var _pops := {}
var _shakes := {}
var _flashes: Array = []
var _snapshot := PackedInt32Array()
var _conflict_snapshot := PackedByteArray()
var _units_done := {}
var _frame_box := StyleBoxFlat.new()
var _tile_box := StyleBoxFlat.new()

static var _fonts := {}


func _init(p_game: PuzzleGame) -> void:
	game = p_game
	accent = DesignTokens.mode_color(game.mode_id)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	custom_minimum_size = Vector2(300, 300)
	_snapshot = game.channels[0].duplicate()
	_conflict_snapshot = game.conflicts()
	for unit in _completed_units():
		_units_done[str(unit)] = true
	game.changed.connect(_on_game_changed)
	resized.connect(_layout)
	set_process(false)

	_frame_box.bg_color = DesignTokens.COLOR_SURFACE
	_frame_box.set_corner_radius_all(DesignTokens.RADIUS_L)
	_frame_box.shadow_color = DesignTokens.COLOR_SHADOW
	_frame_box.shadow_size = 18
	_frame_box.shadow_offset = Vector2(0, 6)
	_frame_box.anti_aliasing = true
	_tile_box.anti_aliasing = true


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


## Ripple: every cell pops in diagonal order, with a colour wash.
func play_completion(p_reduce_motion: bool) -> void:
	selected = -1
	clear_hint()
	if p_reduce_motion:
		return
	var now := Time.get_ticks_msec()
	for i in game.cell_count():
		var order := i % game.width + i / game.width
		_pops[i] = now + order * RIPPLE_STAGGER_MS
		_flashes.append([PackedInt32Array([i]), now + order * RIPPLE_STAGGER_MS])
	_animate()


## Pops a cell's content in after delay_ms (hidden until then).
func pop(cell: int, delay_ms: int = 0) -> void:
	if reduce_motion:
		return
	_pops[cell] = Time.get_ticks_msec() + delay_ms
	_animate()


func flash(cells: PackedInt32Array, delay_ms: int = 0) -> void:
	if reduce_motion:
		return
	_flashes.append([cells, Time.get_ticks_msec() + delay_ms])
	_animate()


func _layout() -> void:
	_cell = floorf(minf(size.x / game.width, size.y / game.height))
	_cell = maxf(_cell, 1.0)
	_origin = ((size - Vector2(game.width, game.height) * _cell) * 0.5).floor()
	queue_redraw()


# --- Change tracking -----------------------------------------------------------

func _on_game_changed() -> void:
	var now := Time.get_ticks_msec()
	var current := game.channels[0]
	var changed := PackedInt32Array()
	for i in current.size():
		if current[i] != _snapshot[i]:
			changed.append(i)
			if current[i] != 0 and not reduce_motion:
				_pops[i] = now
	_snapshot = current.duplicate()

	var conflicts := game.conflicts()
	if not reduce_motion:
		for i in conflicts.size():
			if conflicts[i] == 1 and _conflict_snapshot[i] == 0:
				_shakes[i] = now
	_conflict_snapshot = conflicts

	_on_cells_changed(changed)

	var done := {}
	for unit in _completed_units():
		var unit_key := str(unit)
		done[unit_key] = true
		if not _units_done.has(unit_key) and not game.is_solved:
			flash(unit)
	_units_done = done
	_animate()


## Subclass hook after player changes (cells whose channel-0 value changed).
func _on_cells_changed(_changed: PackedInt32Array) -> void:
	pass


## Subclasses: rows, columns, regions or boxes currently complete and valid.
func _completed_units() -> Array[PackedInt32Array]:
	return []


func _animate() -> void:
	set_process(true)
	queue_redraw()


func _process(_delta: float) -> void:
	var now := Time.get_ticks_msec()
	for cell: int in _pops.keys():
		if now - int(_pops[cell]) > POP_TIME * 1000.0:
			_pops.erase(cell)
	for cell: int in _shakes.keys():
		if now - int(_shakes[cell]) > SHAKE_TIME * 1000.0:
			_shakes.erase(cell)
	_flashes = _flashes.filter(func(item: Array) -> bool: return now - int(item[1]) <= FLASH_TIME * 1000.0)
	queue_redraw()
	if _pops.is_empty() and _shakes.is_empty() and _flashes.is_empty():
		set_process(false)


func _pop_scale(cell: int, now: int) -> float:
	if not _pops.has(cell):
		return 1.0
	var t := (now - int(_pops[cell])) / (POP_TIME * 1000.0)
	if t < 0.0:
		return 0.0
	if t >= 1.0:
		return 1.0
	var c1 := 1.70158
	var c3 := c1 + 1.0
	return 1.0 + c3 * pow(t - 1.0, 3) + c1 * pow(t - 1.0, 2)


func _shake_offset(cell: int, now: int) -> float:
	if not _shakes.has(cell):
		return 0.0
	var t := clampf((now - int(_shakes[cell])) / (SHAKE_TIME * 1000.0), 0.0, 1.0)
	return sin(t * PI * 7.0) * _cell * 0.07 * (1.0 - t)


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
	var now := Time.get_ticks_msec()
	var board := board_rect()
	var pad := _frame_padding()
	draw_style_box(_frame_box, board.grow(pad))
	for i in game.cell_count():
		_draw_cell_background(i, cell_rect(i))
	for i in hint_related:
		_draw_highlight(i, DesignTokens.COLOR_HINT_RELATED)
	if selected >= 0 and selected < game.cell_count():
		_draw_highlight(selected, DesignTokens.COLOR_BOARD_SELECTED)
	_draw_grid()
	_draw_overlay()
	for i in game.cell_count():
		_draw_cell_animated(i, cell_rect(i), now)
	if hint_focus.size() > 4:
		for i in hint_focus:
			_draw_highlight(i, Color(DesignTokens.COLOR_HINT_FOCUS, 0.24))
	else:
		for i in hint_focus:
			draw_rect(cell_rect(i).grow(-_cell * 0.06), DesignTokens.COLOR_HINT_FOCUS, false, DesignTokens.BOARD_LINE_STRONG)
	for item: Array in _flashes:
		var t := (now - int(item[1])) / (FLASH_TIME * 1000.0)
		if t < 0.0 or t > 1.0:
			continue
		var alpha := sin(t * PI) * 0.34
		for i: int in item[0]:
			_draw_highlight(i, Color(accent, alpha))
	_draw_frame_border(board)


func _draw_cell_animated(index: int, rect: Rect2, now: int) -> void:
	var s := _pop_scale(index, now)
	if s <= 0.001:
		return
	var dx := _shake_offset(index, now)
	if is_equal_approx(s, 1.0) and is_zero_approx(dx):
		_draw_cell(index, rect)
		return
	var c := rect.get_center()
	draw_set_transform_matrix(Transform2D(0.0, Vector2(s, s), 0.0, c + Vector2(dx, 0.0)) * Transform2D(0.0, -c))
	_draw_cell(index, rect)
	draw_set_transform_matrix(Transform2D.IDENTITY)


## Space between the board frame and the cells.
func _frame_padding() -> float:
	return 0.0


func _draw_frame_border(board: Rect2) -> void:
	var border := StyleBoxFlat.new()
	border.draw_center = false
	border.anti_aliasing = true
	border.set_corner_radius_all(DesignTokens.RADIUS_S)
	border.set_border_width_all(int(DesignTokens.BOARD_LINE_STRONG * 0.8))
	border.border_color = Color(DesignTokens.COLOR_BOARD_LINE_STRONG, 0.85)
	draw_style_box(border, board.grow(2.0))


func _draw_cell_background(index: int, rect: Rect2) -> void:
	var fill := _cell_fill(index)
	if fill.a > 0.0:
		draw_rect(rect, fill)


func _draw_highlight(index: int, color: Color) -> void:
	draw_rect(cell_rect(index), color)


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


## Rounded tile; corners is [top_left, top_right, bottom_right, bottom_left].
func draw_tile(rect: Rect2, color: Color, radius: float, corners: Array = [true, true, true, true]) -> void:
	_tile_box.bg_color = color
	_tile_box.corner_radius_top_left = int(radius) if corners[0] else 0
	_tile_box.corner_radius_top_right = int(radius) if corners[1] else 0
	_tile_box.corner_radius_bottom_right = int(radius) if corners[2] else 0
	_tile_box.corner_radius_bottom_left = int(radius) if corners[3] else 0
	draw_style_box(_tile_box, rect)


func draw_centered_text(rect: Rect2, text: String, font_size: int, color: Color, weight: int = DesignTokens.FONT_WEIGHT_MEDIUM) -> void:
	var f := font(weight)
	var ascent := f.get_ascent(font_size)
	var descent := f.get_descent(font_size)
	var baseline := rect.position.y + (rect.size.y + ascent - descent) * 0.5
	draw_string(f, Vector2(rect.position.x, baseline), text, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, font_size, color)
