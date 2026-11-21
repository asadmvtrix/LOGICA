class_name VectorIcons
extends RefCounted
## Resolution-independent icons drawn with canvas primitives, so the UI needs no
## bitmap icon assets.

enum Direction { LEFT, RIGHT }


static func draw_chevron(canvas: CanvasItem, center: Vector2, direction: Direction, color: Color) -> void:
	var half := DesignTokens.CHEVRON_SIZE * 0.5
	var tip_x := half * 0.5 if direction == Direction.RIGHT else -half * 0.5
	var points := PackedVector2Array([
		center + Vector2(-tip_x, -half),
		center + Vector2(tip_x, 0.0),
		center + Vector2(-tip_x, half),
	])
	canvas.draw_polyline(points, color, DesignTokens.ICON_STROKE, true)
