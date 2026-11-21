class_name QueensBoardView
extends BoardView
## Queens board: tinted regions with strong borders between them. Tap cycles
## empty, mark, queen; dragging from an empty cell marks every cell crossed.

var _drag_marking := false


func _queens() -> QueensGame:
	return game as QueensGame


func _cell_fill(index: int) -> Color:
	var region := _queens().puzzle.regions[index]
	return DesignTokens.REGION_COLORS[region % DesignTokens.REGION_COLORS.size()]


func _draw_overlay() -> void:
	var regions := _queens().puzzle.regions
	var n := game.width
	for i in game.cell_count():
		var rect := cell_rect(i)
		var c := i % n
		var r := i / n
		if c < n - 1 and regions[i] != regions[i + 1]:
			draw_line(Vector2(rect.end.x, rect.position.y), rect.end, DesignTokens.COLOR_BOARD_LINE_STRONG, DesignTokens.BOARD_LINE_STRONG * 0.7)
		if r < n - 1 and regions[i] != regions[i + n]:
			draw_line(Vector2(rect.position.x, rect.end.y), rect.end, DesignTokens.COLOR_BOARD_LINE_STRONG, DesignTokens.BOARD_LINE_STRONG * 0.7)


func _draw_cell(index: int, rect: Rect2) -> void:
	var value := game.value(index)
	if value == QueensRules.MARK:
		var half := rect.size.x * 0.09
		var center := rect.get_center()
		var color := DesignTokens.COLOR_INK_MUTED
		draw_line(center - Vector2(half, half), center + Vector2(half, half), color, DesignTokens.ICON_STROKE, true)
		draw_line(center + Vector2(-half, half), center + Vector2(half, -half), color, DesignTokens.ICON_STROKE, true)
	elif value == QueensRules.QUEEN:
		var conflict := game.conflicts()
		var color := DesignTokens.COLOR_ERROR if conflict[index] == 1 else DesignTokens.COLOR_INK
		draw_crown(self, rect.get_center(), rect.size.x * 0.56, color)


## A simple three-point crown, also used by the mode preview.
static func draw_crown(canvas: CanvasItem, center: Vector2, width: float, color: Color) -> void:
	var w := width * 0.5
	var h := width * 0.42
	var top := center.y - h * 0.5
	var bottom := center.y + h * 0.5
	var points := PackedVector2Array([
		Vector2(center.x - w, bottom),
		Vector2(center.x - w, top + h * 0.15),
		Vector2(center.x - w * 0.5, top + h * 0.55),
		Vector2(center.x, top),
		Vector2(center.x + w * 0.5, top + h * 0.55),
		Vector2(center.x + w, top + h * 0.15),
		Vector2(center.x + w, bottom),
	])
	canvas.draw_colored_polygon(points, color)
	var band := Rect2(center.x - w, bottom + h * 0.12, w * 2.0, h * 0.18)
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
