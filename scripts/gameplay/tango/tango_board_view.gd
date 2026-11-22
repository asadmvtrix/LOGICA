class_name TangoBoardView
extends BoardView
## Tango board: one rounded tile per cell, givens on a deeper tile, edge clues
## sitting in the gap between tiles. Tap cycles empty, sun, moon. A row or
## column flashes when it is filled without breaking a rule.

var _conflicts := PackedByteArray()


func _tango() -> TangoGame:
	return game as TangoGame


func _completed_units() -> Array[PackedInt32Array]:
	var result: Array[PackedInt32Array] = []
	var tango := game as TangoGame
	if tango == null:
		return result
	var n := tango.width
	var conflicts := tango.conflicts()
	for is_row: bool in [true, false]:
		for number in n:
			var line := TangoRules.line_cells(n, is_row, number)
			var done := true
			for cell in line:
				if tango.value(cell) == TangoPuzzle.EMPTY or conflicts[cell] == 1:
					done = false
					break
			if done:
				result.append(line)
	return result


func _frame_padding() -> float:
	return roundf(_cell * 0.08)


func _draw_frame_border(_board: Rect2) -> void:
	pass


func _draw_grid() -> void:
	pass


func _tile_rect(index: int) -> Rect2:
	return cell_rect(index).grow(-maxf(3.0, roundf(_cell * 0.05)))


func _draw_cell_background(index: int, _rect: Rect2) -> void:
	var color := Color("#EEE9E0")
	if _tango().is_locked(index):
		color = Color("#DDD5C8")
	if _conflicts[index] == 1:
		color = Color("#F2CFC9")
	draw_tile(_tile_rect(index), color, _cell * 0.2)


func _draw_highlight(index: int, color: Color) -> void:
	draw_tile(_tile_rect(index), color, _cell * 0.2)


func _draw_cell(index: int, rect: Rect2) -> void:
	var value := game.value(index)
	if value == TangoPuzzle.SUN:
		draw_sun(self, rect.get_center(), rect.size.x * 0.25)
	elif value == TangoPuzzle.MOON:
		draw_moon(self, rect.get_center(), rect.size.x * 0.27)


func _draw() -> void:
	_conflicts = game.conflicts()
	super._draw()
	var badge := cell_size() * 0.15
	for e in _tango().puzzle.edges:
		var a := cell_rect(e[0])
		var b := cell_rect(e[1])
		var center := (a.get_center() + b.get_center()) * 0.5
		draw_circle(center, badge, DesignTokens.COLOR_SURFACE, true, -1.0, true)
		var color := DesignTokens.COLOR_INK
		var s := badge * 0.48
		var stroke := maxf(3.0, badge * 0.2)
		if e[2] == TangoPuzzle.EQUAL:
			draw_line(center + Vector2(-s, -s * 0.42), center + Vector2(s, -s * 0.42), color, stroke, true)
			draw_line(center + Vector2(-s, s * 0.42), center + Vector2(s, s * 0.42), color, stroke, true)
		else:
			draw_line(center + Vector2(-s, -s), center + Vector2(s, s), color, stroke, true)
			draw_line(center + Vector2(-s, s), center + Vector2(s, -s), color, stroke, true)


static func draw_sun(canvas: CanvasItem, center: Vector2, radius: float) -> void:
	canvas.draw_circle(center, radius * 1.18, Color(DesignTokens.COLOR_SUN, 0.22), true, -1.0, true)
	canvas.draw_circle(center, radius, DesignTokens.COLOR_SUN, true, -1.0, true)
	canvas.draw_circle(center - Vector2(radius, radius) * 0.28, radius * 0.34, Color(1, 1, 1, 0.28), true, -1.0, true)


static func draw_moon(canvas: CanvasItem, center: Vector2, radius: float) -> void:
	var outer := _circle_points(center, radius)
	var inner := _circle_points(center + Vector2(radius * 0.48, -radius * 0.34), radius * 0.82)
	var pieces := Geometry2D.clip_polygons(outer, inner)
	for piece: PackedVector2Array in pieces:
		canvas.draw_colored_polygon(piece, DesignTokens.COLOR_MOON)


static func _circle_points(center: Vector2, radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 48:
		points.append(center + Vector2.from_angle(TAU * i / 48.0) * radius)
	return points
