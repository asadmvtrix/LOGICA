class_name ShikakuBoardView
extends BoardView
## Shikaku board: numbers on a plain grid, the player's rectangles as tinted
## cards. Drag from one corner to the other to draw; tap a rectangle to remove.

var _preview := Rect2i()
var _has_preview := false


func _shikaku() -> ShikakuGame:
	return game as ShikakuGame


func _draw_overlay() -> void:
	var puzzle := _shikaku().puzzle
	var ids := game.channels[0]
	var bounds := ShikakuRules.rects_by_id(puzzle, ids)
	for id: int in bounds:
		var rect: Rect2i = bounds[id]
		var ok := ShikakuRules.rect_ok(puzzle, rect)
		var color := accent if ok else DesignTokens.COLOR_ERROR
		var area := _grid_rect(rect).grow(-DesignTokens.BOARD_LINE * 3)
		draw_rect(area, Color(color, 0.16))
		draw_rect(area, Color(color, 0.85), false, DesignTokens.BOARD_LINE_STRONG * 0.6)
	if _has_preview:
		var area := _grid_rect(_preview).grow(-DesignTokens.BOARD_LINE * 3)
		draw_rect(area, Color(accent, 0.1))
		draw_rect(area, accent, false, DesignTokens.BOARD_LINE_STRONG * 0.6)
		var label := "%d × %d = %d" % [_preview.size.x, _preview.size.y, _preview.get_area()]
		var label_rect := Rect2(area.position.x, area.position.y - cell_size() * 0.5, area.size.x, cell_size() * 0.45)
		if label_rect.position.y < 0:
			label_rect.position.y = area.end.y + cell_size() * 0.05
		draw_centered_text(label_rect, label, int(cell_size() * 0.3), accent, DesignTokens.FONT_WEIGHT_SEMIBOLD)


func _grid_rect(rect: Rect2i) -> Rect2:
	var top_left := cell_rect(rect.position.y * game.width + rect.position.x)
	return Rect2(top_left.position, Vector2(rect.size) * cell_size())


func _draw_cell(index: int, rect: Rect2) -> void:
	var clue := _shikaku().puzzle.clues[index]
	if clue > 0:
		draw_centered_text(rect, str(clue), int(rect.size.y * 0.5), DesignTokens.COLOR_INK, DesignTokens.FONT_WEIGHT_SEMIBOLD)


func _on_tap(index: int) -> void:
	_shikaku().tap(index)


func _on_drag_start(index: int) -> void:
	_update_preview(index, index)


func _on_drag(index: int) -> void:
	_update_preview(_press_cell, index)


func _on_drag_end(index: int) -> void:
	_has_preview = false
	if index >= 0:
		_shikaku().draw_rect_between(_press_cell, index)
	queue_redraw()


func _update_preview(a: int, b: int) -> void:
	var puzzle := _shikaku().puzzle
	_preview = ShikakuGame.rect_between(puzzle.cell_point(a), puzzle.cell_point(b))
	_has_preview = true
	queue_redraw()
