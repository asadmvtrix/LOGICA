class_name PuzzleModes
extends RefCounted
## Registry of puzzle modes: names, rules text, per-difficulty generator
## settings, and factories for games and boards. Generation is deterministic:
## the same key always yields the same puzzle.

const QUEENS := &"queens"
const TANGO := &"tango"
const SHIKAKU := &"shikaku"
const SUDOKU := &"sudoku"
const ALL: Array[StringName] = [QUEENS, TANGO, SHIKAKU, SUDOKU]

const TITLES := {
	QUEENS: "Queens",
	TANGO: "Tango",
	SHIKAKU: "Shikaku",
	SUDOKU: "Sudoku",
}

const TAGLINES := {
	QUEENS: "One crown per row, column and colour",
	TANGO: "Balance suns and moons",
	SHIKAKU: "Divide the grid into rectangles",
	SUDOKU: "Nine digits, no repeats",
}

const RULES := {
	QUEENS: [
		"Place one queen in every row, every column and every coloured region.",
		"Queens may not touch each other, not even diagonally.",
		"Tap a cell once to mark it empty, twice for a queen. Drag across cells to mark several.",
	],
	TANGO: [
		"Fill every cell with a sun or a moon.",
		"Each row and column holds the same number of suns and moons.",
		"No more than two equal symbols may sit next to each other in a row or column.",
		"Cells joined by = are the same; cells joined by × are different.",
		"Tap a cell to cycle sun, moon and empty.",
	],
	SHIKAKU: [
		"Divide the grid into rectangles.",
		"Each rectangle contains exactly one number, and that number is its area in cells.",
		"Drag from one corner to the opposite corner to draw. Tap a rectangle to remove it.",
	],
	SUDOKU: [
		"Fill the grid so every row, column and 3 × 3 box contains the digits 1 to 9 once each.",
		"Select a cell, then tap a digit. Turn on Notes to pencil in candidates.",
	],
}

## Techniques the hint engines use, in level order, for the Training section.
const TECHNIQUES := {
	QUEENS: [
		["Cells ruled out by queens", "A queen claims its row, column and region and the eight cells around it."],
		["Only one place left", "When a row, column or region has a single open cell, its queen goes there."],
		["Region confined to one line", "If a region's open cells all lie in one row or column, no other queen can use that line."],
		["Groups of regions", "When two (or three) regions only use the same two (or three) rows or columns, those lines belong to them."],
		["Blocking a whole unit", "A cell is empty if a queen there would rule out every remaining cell of some row, column or region."],
	],
	TANGO: [
		["Edge clues", "= copies a neighbour's symbol, × flips it."],
		["Pairs", "Two equal symbols side by side must be capped by the opposite symbol."],
		["Gaps", "A cell between two equal symbols takes the opposite symbol."],
		["Line count", "Once a line has its full share of one symbol, the rest are the other."],
		["Line analysis", "Try every legal way to finish a line; cells that agree in all of them are decided."],
		["Contradiction", "If assuming a symbol leads to a broken rule, the cell holds the other symbol."],
	],
	SHIKAKU: [
		["Only one fit", "A number with a single rectangle that fits is placed straight away."],
		["Only one number reaches", "A cell that only one number can cover must be inside that number's rectangle."],
		["Shared cells", "Cells covered by every option of a number belong to it; other numbers cannot use them."],
		["Leaves a cell uncovered", "Rule out an option if it would leave some cell that no number could cover."],
	],
	SUDOKU: [
		["Hidden single", "Within a row, column or box, a digit with only one possible cell goes there."],
		["Naked single", "A cell with only one possible digit takes it."],
		["Pointing and claiming", "When a digit in a box is confined to one line (or the reverse), remove it from the rest of that line (or box)."],
		["Pairs", "Two cells in a unit sharing the same two candidates, or two digits confined to the same two cells, clear those digits elsewhere."],
	],
}

## Generator settings per difficulty (EASY, MEDIUM, HARD, EXPERT).
const QUEENS_SIZES := [6, 7, 8, 9]
const QUEENS_LEVELS := [2, 3, 4, 4]
const TANGO_LEVELS := [1, 2, 3, 4]
const SUDOKU_LEVELS := [[1, 0], [2, 2], [3, 3], [4, 4]]
const SHIKAKU_SETTINGS := [[5, 6, 2], [6, 8, 2], [7, 10, 3], [8, 12, 3]]


static func title(mode: StringName) -> String:
	return TITLES.get(mode, String(mode).capitalize())


static func tagline(mode: StringName) -> String:
	return TAGLINES.get(mode, "")


static func generate(mode: StringName, difficulty: int, key: String) -> PuzzleGame:
	var rng := SeededRandom.create(key)
	var level := clampi(difficulty, 0, 3)
	match mode:
		QUEENS:
			var queens := QueensGenerator.generate(QUEENS_SIZES[level], QUEENS_LEVELS[level], rng)
			return QueensGame.new(queens, level, key) if queens != null else null
		TANGO:
			return TangoGame.new(TangoGenerator.generate(TANGO_LEVELS[level], rng), level, key)
		SHIKAKU:
			var settings: Array = SHIKAKU_SETTINGS[level]
			var shikaku := ShikakuGenerator.generate(settings[0], settings[1], settings[2], rng)
			return ShikakuGame.new(shikaku, level, key) if shikaku != null else null
		SUDOKU:
			var levels: Array = SUDOKU_LEVELS[level]
			return SudokuGame.new(SudokuGenerator.generate(levels[0], levels[1], rng), level, key)
	push_error("Unknown mode %s" % mode)
	return null


static func create_board(game: PuzzleGame) -> BoardView:
	match game.mode_id:
		QUEENS:
			return QueensBoardView.new(game)
		TANGO:
			return TangoBoardView.new(game)
		SHIKAKU:
			return ShikakuBoardView.new(game)
		SUDOKU:
			return SudokuBoardView.new(game)
	return BoardView.new(game)
