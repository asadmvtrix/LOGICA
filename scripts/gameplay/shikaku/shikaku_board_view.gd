class_name ShikakuBoardView
extends BoardView
## Shikaku board: numbers on a plain grid, the player's rectangles as tinted
## cards. Drag from one corner to the other to draw; tap a rectangle to remove.

var _preview := Rect2i()
var _has_preview := false


func _shikaku() -> ShikakuGame:
	return game as ShikakuGame


func _frame_padding() -> float:
	return 8.0


## Every correctly drawn rectangle, so each new one flashes once.
func _completed_units() -> Array[PackedInt32Array]:
	var result: Array[PackedInt32Array] = []
	var shikaku := game as ShikakuGame
	if shikaku == null:
		return result
	var bounds := ShikakuRules.rects_by_id(shikaku.puzzle, shikaku.channels[0])
	for id: int in bounds:
		var rect: Rect2i = bounds[id]
		if ShikakuRules.rect_ok(shikaku.puzzle, rect):
			result.append(shikaku.puzzle.rect_cells(rect))
	return result


func _draw_overlay() -> void:
	var puzzle := _shikaku().puzzle
	var ids := game.channels[0]
	var bounds := ShikakuRules.rects_by_id(puzzle, ids)
	var radius := cell_size() * 0.18
	for id: int in bounds:
		var rect: Rect2i = bounds[id]
		var ok := ShikakuRules.rect_ok(puzzle, rect)
		var area := _grid_rect(rect).grow(-maxf(3.0, cell_size() * 0.05))
		if ok:
			var fill: Color = DesignTokens.REGION_COLORS[id % DesignTokens.REGION_COLORS.size()]
			draw_tile(area.grow(2.0), fill.darkened(0.18), radius + 2.0)
			draw_tile(area, fill, radius)
		else:
			draw_tile(area, Color("#F2CFC9"), radius)
			draw_rect(area, Color(DesignTokens.COLOR_ERROR, 0.7), false, 3.0)
	if _has_preview:
		var area := _grid_rect(_preview).grow(-maxf(3.0, cell_size() * 0.05))
		draw_tile(area, Color(accent, 0.18), radius)
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
