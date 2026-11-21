class_name TangoBoardView
extends BoardView
## Tango board: suns and moons, givens on a darker fill, edge clues drawn on
## the shared border. Tap cycles empty, sun, moon.


var _conflicts := PackedByteArray()


func _tango() -> TangoGame:
	return game as TangoGame


func _cell_fill(index: int) -> Color:
	if _conflicts[index] == 1:
		return DesignTokens.COLOR_CONFLICT_FILL
	if _tango().is_locked(index):
		return DesignTokens.COLOR_BOARD_GIVEN
	return Color(0, 0, 0, 0)


func _draw_cell(index: int, rect: Rect2) -> void:
	var value := game.value(index)
	if value == TangoPuzzle.SUN:
		draw_sun(self, rect.get_center(), rect.size.x * 0.26)
	elif value == TangoPuzzle.MOON:
		draw_moon(self, rect.get_center(), rect.size.x * 0.27)


func _draw() -> void:
	_conflicts = game.conflicts()
	super._draw()
	var badge := cell_size() * 0.17
	for e in _tango().puzzle.edges:
		var a := cell_rect(e[0])
		var b := cell_rect(e[1])
		var center := (a.get_center() + b.get_center()) * 0.5
		draw_circle(center, badge, DesignTokens.COLOR_SURFACE)
		var color := DesignTokens.COLOR_INK_SECONDARY
		var s := badge * 0.5
		if e[2] == TangoPuzzle.EQUAL:
			draw_line(center + Vector2(-s, -s * 0.45), center + Vector2(s, -s * 0.45), color, DesignTokens.ICON_STROKE * 0.8, true)
			draw_line(center + Vector2(-s, s * 0.45), center + Vector2(s, s * 0.45), color, DesignTokens.ICON_STROKE * 0.8, true)
		else:
			draw_line(center + Vector2(-s, -s), center + Vector2(s, s), color, DesignTokens.ICON_STROKE * 0.8, true)
			draw_line(center + Vector2(-s, s), center + Vector2(s, -s), color, DesignTokens.ICON_STROKE * 0.8, true)


static func draw_sun(canvas: CanvasItem, center: Vector2, radius: float) -> void:
	canvas.draw_circle(center, radius, DesignTokens.COLOR_SUN)


static func draw_moon(canvas: CanvasItem, center: Vector2, radius: float) -> void:
	var outer := _circle_points(center, radius)
	var inner := _circle_points(center + Vector2(radius * 0.48, -radius * 0.34), radius * 0.82)
	var pieces := Geometry2D.clip_polygons(outer, inner)
	for piece: PackedVector2Array in pieces:
		canvas.draw_colored_polygon(piece, DesignTokens.COLOR_MOON)


static func _circle_points(center: Vector2, radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 40:
		points.append(center + Vector2.from_angle(TAU * i / 40.0) * radius)
	return points
