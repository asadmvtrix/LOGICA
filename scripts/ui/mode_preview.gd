class_name ModePreview
extends Control
## Small drawn illustration of a mode's board, used on tiles and cards.
## Fixed sample layouts; no puzzle generation involved.

const QUEENS_REGIONS := [
	0, 0, 1, 1, 1,
	0, 2, 2, 1, 3,
	0, 2, 4, 3, 3,
	4, 4, 4, 3, 3,
	4, 4, 4, 4, 3,
]
const QUEENS_CROWNS := [2, 5, 23]
const TANGO_CELLS := [1, 2, 0, 1, 0, 2, 1, 0, 2, 0, 0, 1, 0, 1, 2, 0]
const SUDOKU_DIGITS := [5, 0, 3, 0, 7, 0, 8, 0, 1]
const SHIKAKU_RECTS := [Rect2i(0, 0, 2, 2), Rect2i(2, 0, 2, 1), Rect2i(2, 1, 1, 3), Rect2i(3, 1, 1, 3), Rect2i(0, 2, 2, 2)]
const SHIKAKU_CLUES := {0: 4, 3: 2, 10: 3, 15: 3, 12: 4}

var mode: StringName


func _init(p_mode: StringName, side: float = DesignTokens.TILE_PREVIEW_SIZE) -> void:
	mode = p_mode
	custom_minimum_size = Vector2(side, side)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var side := minf(size.x, size.y)
	var origin := ((size - Vector2(side, side)) * 0.5).floor()
	match mode:
		&"queens":
			_draw_queens(origin, side)
		&"tango":
			_draw_tango(origin, side)
		&"shikaku":
			_draw_shikaku(origin, side)
		&"sudoku":
			_draw_sudoku(origin, side)


func _grid(origin: Vector2, side: float, n: int, line: Color) -> float:
	var cell := side / n
	for k in range(1, n):
		draw_line(origin + Vector2(k * cell, 0), origin + Vector2(k * cell, side), line, 1.5)
		draw_line(origin + Vector2(0, k * cell), origin + Vector2(side, k * cell), line, 1.5)
	draw_rect(Rect2(origin, Vector2(side, side)), DesignTokens.COLOR_INK, false, 3.0)
	return cell


func _draw_queens(origin: Vector2, side: float) -> void:
	var cell := side / 5.0
	for i in 25:
		var rect := Rect2(origin + Vector2(i % 5, i / 5) * cell, Vector2(cell, cell))
		draw_rect(rect, DesignTokens.REGION_COLORS[QUEENS_REGIONS[i]])
	_grid(origin, side, 5, DesignTokens.COLOR_BOARD_LINE)
	for i: int in QUEENS_CROWNS:
		var center := origin + (Vector2(i % 5, i / 5) + Vector2(0.5, 0.5)) * cell
		QueensBoardView.draw_crown(self, center, cell * 0.6, DesignTokens.COLOR_INK)


func _draw_tango(origin: Vector2, side: float) -> void:
	draw_rect(Rect2(origin, Vector2(side, side)), DesignTokens.COLOR_SURFACE)
	var cell := _grid(origin, side, 4, DesignTokens.COLOR_BOARD_LINE)
	for i in 16:
		var center := origin + (Vector2(i % 4, i / 4) + Vector2(0.5, 0.5)) * cell
		if TANGO_CELLS[i] == 1:
			TangoBoardView.draw_sun(self, center, cell * 0.26)
		elif TANGO_CELLS[i] == 2:
			TangoBoardView.draw_moon(self, center, cell * 0.28)


func _draw_shikaku(origin: Vector2, side: float) -> void:
	draw_rect(Rect2(origin, Vector2(side, side)), DesignTokens.COLOR_SURFACE)
	var cell := _grid(origin, side, 4, DesignTokens.COLOR_BOARD_LINE)
	var accent := DesignTokens.COLOR_MODE_SHIKAKU
	for rect: Rect2i in SHIKAKU_RECTS:
		var area := Rect2(origin + Vector2(rect.position) * cell, Vector2(rect.size) * cell).grow(-3.0)
		draw_rect(area, Color(accent, 0.18))
		draw_rect(area, accent, false, 2.5)
	var font := BoardView.font(DesignTokens.FONT_WEIGHT_SEMIBOLD)
	var font_size := int(cell * 0.5)
	for i: int in SHIKAKU_CLUES:
		var rect := Rect2(origin + Vector2(i % 4, i / 4) * cell, Vector2(cell, cell))
		var baseline := rect.position.y + (rect.size.y + font.get_ascent(font_size) - font.get_descent(font_size)) * 0.5
		draw_string(font, Vector2(rect.position.x, baseline), str(SHIKAKU_CLUES[i]), HORIZONTAL_ALIGNMENT_CENTER, cell, font_size, DesignTokens.COLOR_INK)


func _draw_sudoku(origin: Vector2, side: float) -> void:
	draw_rect(Rect2(origin, Vector2(side, side)), DesignTokens.COLOR_SURFACE)
	var cell := _grid(origin, side, 3, DesignTokens.COLOR_BOARD_LINE)
	var font := BoardView.font(DesignTokens.FONT_WEIGHT_MEDIUM)
	var font_size := int(cell * 0.55)
	for i in 9:
		if SUDOKU_DIGITS[i] == 0:
			continue
		var rect := Rect2(origin + Vector2(i % 3, i / 3) * cell, Vector2(cell, cell))
		var color := DesignTokens.COLOR_INK if i % 2 == 0 else DesignTokens.COLOR_MODE_SUDOKU
		var baseline := rect.position.y + (rect.size.y + font.get_ascent(font_size) - font.get_descent(font_size)) * 0.5
		draw_string(font, Vector2(rect.position.x, baseline), str(SUDOKU_DIGITS[i]), HORIZONTAL_ALIGNMENT_CENTER, cell, font_size, color)
