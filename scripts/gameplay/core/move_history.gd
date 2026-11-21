class_name MoveHistory
extends RefCounted
## Undo/redo stacks. A move is an Array of PackedInt32Array
## [channel, index, old_value, new_value]. Moves recorded between begin_group()
## and end_group() are merged into one undo step.

var _undo: Array = []
var _redo: Array = []
var _group: Array = []
var _grouping := false


func record(move: Array) -> void:
	if move.is_empty():
		return
	if _grouping:
		_group.append_array(move)
		return
	_undo.append(move)
	_redo.clear()


func begin_group() -> void:
	_grouping = true
	_group = []


func end_group() -> void:
	_grouping = false
	var merged := _group
	_group = []
	record(merged)


func can_undo() -> bool:
	return not _undo.is_empty()


func can_redo() -> bool:
	return not _redo.is_empty()


func pop_undo() -> Array:
	if _undo.is_empty():
		return []
	var move: Array = _undo.pop_back()
	_redo.append(move)
	return move


func pop_redo() -> Array:
	if _redo.is_empty():
		return []
	var move: Array = _redo.pop_back()
	_undo.append(move)
	return move


func clear() -> void:
	_undo.clear()
	_redo.clear()
	_group.clear()
	_grouping = false
