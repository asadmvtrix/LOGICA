class_name ShikakuHintEngine
extends HintEngine
## Shikaku hints: corrections against the unique solution, then ShikakuLogic.
## Placement changes are built here because rectangle ids live in player state.


func _correction(game: PuzzleGame, kind: HintResult.Kind) -> HintResult:
	var shikaku := game as ShikakuGame
	var ids := shikaku.channels[0]
	var bounds := ShikakuRules.rects_by_id(shikaku.puzzle, ids)
	for id: int in bounds:
		var rect: Rect2i = bounds[id]
		if rect in shikaku.puzzle.solution:
			var whole := true
			for cell in shikaku.puzzle.rect_cells(rect):
				if ids[cell] != id:
					whole = false
					break
			if whole:
				continue
		var cells := PackedInt32Array()
		var changes: Array = []
		for cell in ids.size():
			if ids[cell] == id:
				cells.append(cell)
				changes.append([0, cell, 0])
		return HintResult.correction(kind, "This rectangle is not part of the solution. It will be removed.", cells, changes)
	return null


func _placement_chain(game: PuzzleGame) -> Array[Deduction]:
	var shikaku := game as ShikakuGame
	var logic := ShikakuLogic.from_ids(shikaku.puzzle, shikaku.channels[0])
	var chain: Array[Deduction] = []
	for i in MAX_CHAIN:
		var deduction := logic.next_deduction()
		if deduction == null:
			return []
		chain.append(deduction)
		logic.apply(deduction)
		if deduction.places:
			var rect: Rect2i = deduction.payload["rect"]
			deduction.changes = shikaku.changes_for_rect(rect)
			return chain
	return []
