class_name SudokuHintEngine
extends HintEngine
## Sudoku hints: corrections against the unique solution, then SudokuLogic.


func _correction(game: PuzzleGame, kind: HintResult.Kind) -> HintResult:
	var sudoku := game as SudokuGame
	var cells := sudoku.channels[0]
	for cell in 81:
		if cells[cell] != 0 and cells[cell] != sudoku.puzzle.solution[cell]:
			return HintResult.correction(kind, "The %d in %s does not fit the solution. It will be cleared." % [cells[cell], CellNames.cell(cell, 9)],
				PackedInt32Array([cell]), [[0, cell, 0]])
	return null


func _placement_chain(game: PuzzleGame) -> Array[Deduction]:
	var sudoku := game as SudokuGame
	var logic := SudokuLogic.new(sudoku.channels[0])
	var chain: Array[Deduction] = []
	for i in MAX_CHAIN:
		var deduction := logic.next_deduction()
		if deduction == null:
			return []
		chain.append(deduction)
		logic.apply(deduction)
		if deduction.places:
			return chain
	return []
