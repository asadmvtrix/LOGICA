class_name HintEngine
extends RefCounted
## Base hint engine. Each mode subclasses this with its own reasoning.
## reveal(): the next solution move with a short reason, ready to apply.
## tactical(): the same move with every reasoning step, for learning.
## Both return HintResult.none() when no sound deduction is found; they never
## guess.

const MAX_CHAIN := 40


func reveal(game: PuzzleGame) -> HintResult:
	return _hint(game, HintResult.Kind.REVEAL)


func tactical(game: PuzzleGame) -> HintResult:
	return _hint(game, HintResult.Kind.TACTICAL)


func _hint(game: PuzzleGame, kind: HintResult.Kind) -> HintResult:
	if game.is_solved:
		return HintResult.none(kind, "The puzzle is already solved.")
	var fix := _correction(game, kind)
	if fix != null:
		return fix
	var chain := _placement_chain(game)
	if chain.is_empty():
		return HintResult.none(kind, "No logical next step was found from the current position.")
	return HintResult.from_chain(kind, chain)


## Subclasses: return a correction hint when the player has made a mistake
## (compared with the puzzle's unique solution), else null.
func _correction(_game: PuzzleGame, _kind: HintResult.Kind) -> HintResult:
	return null


## Subclasses: deductions from the current position up to and including the
## first one that places part of the solution. Empty when stuck.
func _placement_chain(_game: PuzzleGame) -> Array[Deduction]:
	return []
