class_name QueensHintEngine
extends HintEngine
## Queens hints: corrections against the unique solution, then QueensLogic.


func _correction(game: PuzzleGame, kind: HintResult.Kind) -> HintResult:
	var queens := game as QueensGame
	var cells := queens.channels[0]
	for cell in cells.size():
		if cells[cell] == QueensRules.QUEEN and not queens.puzzle.solution_has_queen(cell):
			return HintResult.correction(kind, "This queen is not part of the solution. It will be removed.",
				PackedInt32Array([cell]), [[0, cell, QueensRules.EMPTY]])
	for cell in cells.size():
		if cells[cell] == QueensRules.MARK and queens.puzzle.solution_has_queen(cell):
			return HintResult.correction(kind, "This cell is marked empty, but the solution needs a queen here. The mark will be cleared.",
				PackedInt32Array([cell]), [[0, cell, QueensRules.EMPTY]])
	return null


func _placement_chain(game: PuzzleGame) -> Array[Deduction]:
	var queens := game as QueensGame
	var logic := QueensLogic.from_cells(queens.puzzle, queens.channels[0])
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
