class_name VectorIcons
extends RefCounted
## Resolution-independent icons drawn with canvas primitives, so the UI needs no
## bitmap icon assets.

enum Direction { LEFT, RIGHT }
enum Icon { UNDO, REDO, RESET, HINT, EXPLAIN, PAUSE, PLAY, NOTES, ERASE, CHECK, LOCK, CLOSE }


static func draw_chevron(canvas: CanvasItem, center: Vector2, direction: Direction, color: Color) -> void:
	var half := DesignTokens.CHEVRON_SIZE * 0.5
	var tip_x := half * 0.5 if direction == Direction.RIGHT else -half * 0.5
	var points := PackedVector2Array([
		center + Vector2(-tip_x, -half),
		center + Vector2(tip_x, 0.0),
		center + Vector2(-tip_x, half),
	])
	canvas.draw_polyline(points, color, DesignTokens.ICON_STROKE, true)


## Draws an icon fitting a square of side size around center.
static func draw_icon(canvas: CanvasItem, icon: Icon, center: Vector2, size: float, color: Color) -> void:
	var stroke := DesignTokens.ICON_STROKE
	var r := size * 0.32
	match icon:
		Icon.UNDO, Icon.REDO:
			var flip := 1.0 if icon == Icon.REDO else -1.0
			var arc_center := center + Vector2(0, r * 0.25)
			var points := PackedVector2Array()
			for i in 17:
				var a := lerpf(-PI * 0.05, -PI, i / 16.0)
				points.append(arc_center + Vector2(cos(a) * flip * -1.0, sin(a)) * r)
			canvas.draw_polyline(points, color, stroke, true)
			var tip := points[points.size() - 1]
			_arrow_head(canvas, tip, Vector2(0, 1), r * 0.5, color)
		Icon.RESET:
			var points := PackedVector2Array()
			for i in 25:
				var a := lerpf(-PI * 0.35, PI * 1.25, i / 24.0)
				points.append(center + Vector2.from_angle(a) * r)
			canvas.draw_polyline(points, color, stroke, true)
			var a_end := PI * 1.25
			var tangent := Vector2(-sin(a_end), cos(a_end))
			_arrow_head(canvas, points[points.size() - 1], tangent, r * 0.5, color)
		Icon.HINT:
			var bulb := center + Vector2(0, -r * 0.25)
			canvas.draw_arc(bulb, r * 0.75, PI * 0.8, PI * 2.2, 24, color, stroke, true)
			var base_top := bulb.y + r * 0.6
			canvas.draw_line(Vector2(center.x - r * 0.35, base_top), Vector2(center.x + r * 0.35, base_top), color, stroke, true)
			canvas.draw_line(Vector2(center.x - r * 0.25, base_top + r * 0.35), Vector2(center.x + r * 0.25, base_top + r * 0.35), color, stroke, true)
		Icon.EXPLAIN:
			for k in 3:
				var y := center.y + (k - 1) * r * 0.75
				canvas.draw_circle(Vector2(center.x - r * 0.8, y), stroke * 0.8, color)
				canvas.draw_line(Vector2(center.x - r * 0.4, y), Vector2(center.x + r * 0.9, y), color, stroke, true)
		Icon.PAUSE:
			canvas.draw_line(center + Vector2(-r * 0.35, -r * 0.7), center + Vector2(-r * 0.35, r * 0.7), color, stroke * 1.4)
			canvas.draw_line(center + Vector2(r * 0.35, -r * 0.7), center + Vector2(r * 0.35, r * 0.7), color, stroke * 1.4)
		Icon.PLAY:
			canvas.draw_colored_polygon(PackedVector2Array([
				center + Vector2(-r * 0.5, -r * 0.75), center + Vector2(r * 0.8, 0), center + Vector2(-r * 0.5, r * 0.75)]), color)
		Icon.NOTES:
			var a := center + Vector2(-r * 0.75, r * 0.75)
			var b := center + Vector2(r * 0.6, -r * 0.6)
			canvas.draw_line(a, b, color, stroke * 1.6, true)
			canvas.draw_line(b, b + Vector2(r * 0.25, -r * 0.25), color, stroke * 1.6, true)
			canvas.draw_line(center + Vector2(-r * 0.9, r * 0.95), center + Vector2(r * 0.2, r * 0.95), color, stroke * 0.7, true)
		Icon.ERASE:
			var box := Rect2(center - Vector2(r, r * 0.7), Vector2(r * 2, r * 1.4))
			canvas.draw_rect(box, color, false, stroke)
			canvas.draw_line(center + Vector2(-r * 0.35, -r * 0.35), center + Vector2(r * 0.35, r * 0.35), color, stroke, true)
			canvas.draw_line(center + Vector2(-r * 0.35, r * 0.35), center + Vector2(r * 0.35, -r * 0.35), color, stroke, true)
		Icon.CHECK:
			canvas.draw_polyline(PackedVector2Array([
				center + Vector2(-r * 0.7, 0), center + Vector2(-r * 0.15, r * 0.55), center + Vector2(r * 0.8, -r * 0.55)]), color, stroke * 1.2, true)
		Icon.LOCK:
			var body := Rect2(center + Vector2(-r * 0.6, -r * 0.1), Vector2(r * 1.2, r * 0.9))
			canvas.draw_rect(body, color)
			canvas.draw_arc(center + Vector2(0, -r * 0.1), r * 0.38, PI, TAU, 16, color, stroke, true)
		Icon.CLOSE:
			canvas.draw_line(center + Vector2(-r * 0.6, -r * 0.6), center + Vector2(r * 0.6, r * 0.6), color, stroke, true)
			canvas.draw_line(center + Vector2(-r * 0.6, r * 0.6), center + Vector2(r * 0.6, -r * 0.6), color, stroke, true)


static func _arrow_head(canvas: CanvasItem, tip: Vector2, direction: Vector2, length: float, color: Color) -> void:
	var d := direction.normalized()
	var side := Vector2(-d.y, d.x)
	var points := PackedVector2Array([
		tip + d * length * 0.55,
		tip - d * length * 0.45 + side * length * 0.6,
		tip - d * length * 0.45 - side * length * 0.6,
	])
	canvas.draw_colored_polygon(points, color)
