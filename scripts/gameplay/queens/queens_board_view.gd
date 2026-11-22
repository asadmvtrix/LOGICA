class_name QueensBoardView
extends BoardView
## Queens board: each region is one rounded tile, separated from its
## neighbours by a gap. Tap cycles empty, mark, queen; dragging from an empty
## cell marks every cell crossed. Placing a queen sweeps auto-crosses outward
## over every cell it rules out, and a region flashes once it holds a queen.

const CROSS_STAGGER_MS := 32

var _drag_marking := false
var _attacked := PackedByteArray()


func _init(p_game: PuzzleGame) -> void:
	super(p_game)
	_attacked = _queens().attacked_cells()


func _queens() -> QueensGame:
	return game as QueensGame


func _on_cells_changed(changed: PackedInt32Array) -> void:
	var attacked := _queens().attacked_cells()
	var origin := -1
	for cell in changed:
		if game.value(cell) == QueensRules.QUEEN:
			origin = cell
	if origin >= 0:
		var n := game.width
		for cell in attacked.size():
			if attacked[cell] == 1 and _attacked[cell] == 0 and game.value(cell) == QueensRules.EMPTY:
				var distance := maxi(absi(cell % n - origin % n), absi(cell / n - origin / n))
				pop(cell, distance * CROSS_STAGGER_MS)
	_attacked = attacked


func _completed_units() -> Array[PackedInt32Array]:
	var result: Array[PackedInt32Array] = []
	var queens := game as QueensGame
	if queens == null:
		return result
	var conflicts := queens.conflicts()
	var regions := queens.puzzle.regions
	for cell in queens.cell_count():
		if queens.value(cell) == QueensRules.QUEEN and conflicts[cell] == 0:
			var unit := PackedInt32Array()
			for other in regions.size():
				if regions[other] == regions[cell]:
					unit.append(other)
			result.append(unit)
	return result


func _frame_padding() -> float:
	return roundf(_cell * 0.09)


func _draw_frame_border(_board: Rect2) -> void:
	pass


func _region_color(index: int) -> Color:
	var region := _queens().puzzle.regions[index]
	return DesignTokens.REGION_COLORS[region % DesignTokens.REGION_COLORS.size()]


func _draw_cell_background(index: int, rect: Rect2) -> void:
	var regions := _queens().puzzle.regions
	var n := game.width
	var c := index % n
	var r := index / n
	var gap := maxf(2.0, roundf(_cell * 0.035))
	var open_left := c > 0 and regions[index - 1] == regions[index]
	var open_right := c < n - 1 and regions[index + 1] == regions[index]
	var open_up := r > 0 and regions[index - n] == regions[index]
	var open_down := r < n - 1 and regions[index + n] == regions[index]
	var tile := rect
	tile.position.x += -0.5 if open_left else gap
	tile.position.y += -0.5 if open_up else gap
	tile.end.x += 0.5 if open_right else -gap
	tile.end.y += 0.5 if open_down else -gap
	var radius := _cell * 0.2
	draw_tile(tile, _region_color(index), radius, [
		not open_up and not open_left,
		not open_up and not open_right,
		not open_down and not open_right,
		not open_down and not open_left,
	])
	var seam := Color(0, 0, 0, 0.07)
	if open_right:
		draw_line(Vector2(rect.end.x, rect.position.y + _cell * 0.18), Vector2(rect.end.x, rect.end.y - _cell * 0.18), seam, 2.0)
	if open_down:
		draw_line(Vector2(rect.position.x + _cell * 0.18, rect.end.y), Vector2(rect.end.x - _cell * 0.18, rect.end.y), seam, 2.0)


func _draw_highlight(index: int, color: Color) -> void:
	draw_tile(cell_rect(index).grow(-_cell * 0.05), color, _cell * 0.16)


func _draw_grid() -> void:
	pass


func _draw_cell(index: int, rect: Rect2) -> void:
	var value := game.value(index)
	var center := rect.get_center()
	if value == QueensRules.MARK:
		_draw_cross(center, rect.size.x * 0.1, Color(DesignTokens.COLOR_INK, 0.55))
	elif value == QueensRules.QUEEN:
		var conflict := game.conflicts()
		var color := DesignTokens.COLOR_ERROR if conflict[index] == 1 else DesignTokens.COLOR_INK
		draw_crown(self, center, rect.size.x * 0.58, color)
	elif _attacked.size() > index and _attacked[index] == 1:
		_draw_cross(center, rect.size.x * 0.085, Color(DesignTokens.COLOR_INK, 0.32))


func _draw_cross(center: Vector2, half: float, color: Color) -> void:
	var stroke := maxf(3.0, half * 0.42)
	draw_line(center - Vector2(half, half), center + Vector2(half, half), color, stroke, true)
	draw_line(center + Vector2(-half, half), center + Vector2(half, -half), color, stroke, true)


## Three-point crown with jewelled tips, also used by the mode preview.
static func draw_crown(canvas: CanvasItem, center: Vector2, width: float, color: Color) -> void:
	var w := width * 0.5
	var h := width * 0.46
	var top := center.y - h * 0.55
	var bottom := center.y + h * 0.35
	var points := PackedVector2Array([
		Vector2(center.x - w * 0.86, bottom),
		Vector2(center.x - w, top + h * 0.12),
		Vector2(center.x - w * 0.45, top + h * 0.5),
		Vector2(center.x, top - h * 0.02),
		Vector2(center.x + w * 0.45, top + h * 0.5),
		Vector2(center.x + w, top + h * 0.12),
		Vector2(center.x + w * 0.86, bottom),
	])
	canvas.draw_colored_polygon(points, color)
	var jewel := width * 0.07
	canvas.draw_circle(Vector2(center.x - w, top + h * 0.12), jewel, color, true, -1.0, true)
	canvas.draw_circle(Vector2(center.x, top - h * 0.02), jewel, color, true, -1.0, true)
	canvas.draw_circle(Vector2(center.x + w, top + h * 0.12), jewel, color, true, -1.0, true)
	var band := Rect2(center.x - w * 0.86, bottom + h * 0.1, w * 1.72, h * 0.2)
	canvas.draw_rect(band, color)


func _on_tap(index: int) -> void:
	_queens().cycle(index)


func _on_drag_start(index: int) -> void:
	_drag_marking = game.value(index) == QueensRules.EMPTY
	if _drag_marking:
		game.begin_batch()
		_queens().mark(index)


func _on_drag(index: int) -> void:
	if _drag_marking:
		_queens().mark(index)


func _on_drag_end(_index: int) -> void:
	if _drag_marking:
		game.end_batch()
		_drag_marking = false
