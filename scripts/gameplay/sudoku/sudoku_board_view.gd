class_name SudokuBoardView
extends BoardView
## Sudoku board: box lines, givens in ink, entries in the mode colour, notes as
## small digits. Tapping selects a cell; digits come from the number pad.

var _conflicts := PackedByteArray()


func _sudoku() -> SudokuGame:
	return game as SudokuGame


func _draw() -> void:
	_conflicts = game.conflicts()
	super._draw()


func _cell_fill(index: int) -> Color:
	if selected >= 0 and selected != index:
		var digit := game.value(selected)
		if digit != 0 and game.value(index) == digit:
			return DesignTokens.COLOR_BOARD_SELECTED.lerp(DesignTokens.COLOR_SURFACE, 0.4)
		if index in SudokuRules.peers(selected):
			return DesignTokens.COLOR_BOARD_PEER
	return Color(0, 0, 0, 0)


func _draw_overlay() -> void:
	var board := board_rect()
	for k: int in [3, 6]:
		var x := board.position.x + k * cell_size()
		var y := board.position.y + k * cell_size()
		draw_line(Vector2(x, board.position.y), Vector2(x, board.end.y), DesignTokens.COLOR_BOARD_LINE_STRONG, DesignTokens.BOARD_LINE_STRONG * 0.7)
		draw_line(Vector2(board.position.x, y), Vector2(board.end.x, y), DesignTokens.COLOR_BOARD_LINE_STRONG, DesignTokens.BOARD_LINE_STRONG * 0.7)


func _draw_cell(index: int, rect: Rect2) -> void:
	var digit := game.value(index)
	var digit_size := int(rect.size.y * 0.56)
	if digit != 0:
		var color := DesignTokens.COLOR_INK
		var weight := DesignTokens.FONT_WEIGHT_SEMIBOLD
		if not _sudoku().is_locked(index):
			color = accent
			weight = DesignTokens.FONT_WEIGHT_REGULAR
		if _conflicts[index] == 1:
			color = DesignTokens.COLOR_ERROR
		draw_centered_text(rect, str(digit), digit_size, color, weight)
		return
	var notes := game.value(index, 1)
	if notes == 0:
		return
	var third := rect.size / 3.0
	var note_size := int(rect.size.y * 0.24)
	for d in range(1, 10):
		if notes & (1 << d):
			var sub := Rect2(rect.position + Vector2((d - 1) % 3, (d - 1) / 3) * third, third)
			draw_centered_text(sub, str(d), note_size, DesignTokens.COLOR_INK_SECONDARY, DesignTokens.FONT_WEIGHT_MEDIUM)


func _on_tap(index: int) -> void:
	select(index)
