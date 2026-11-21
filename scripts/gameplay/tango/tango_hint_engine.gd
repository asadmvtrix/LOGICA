class_name TangoHintEngine
extends HintEngine
## Tango hints: corrections against the unique solution, then TangoLogic.


func _correction(game: PuzzleGame, kind: HintResult.Kind) -> HintResult:
	var tango := game as TangoGame
	var cells := tango.channels[0]
	for cell in cells.size():
		if cells[cell] != TangoPuzzle.EMPTY and cells[cell] != tango.puzzle.solution[cell]:
			return HintResult.correction(kind, "This %s does not fit the solution. It will be cleared." % TangoPuzzle.symbol_name(cells[cell]),
				PackedInt32Array([cell]), [[0, cell, TangoPuzzle.EMPTY]])
	return null


func _placement_chain(game: PuzzleGame) -> Array[Deduction]:
	var tango := game as TangoGame
	var logic := TangoLogic.new(tango.puzzle.size, tango.channels[0], tango.puzzle.edges)
	var deduction := logic.next_deduction()
	var chain: Array[Deduction] = []
	if deduction != null:
		chain.append(deduction)
	return chain
