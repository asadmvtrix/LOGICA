class_name PuzzleGame
extends RefCounted
## Base for one puzzle being played. Player state lives in integer channels
## (one value per cell per channel) so undo/redo, reset and saving work the
## same way for every mode. Subclasses supply the rules.

signal changed
signal completed

var mode_id: StringName
var difficulty := Difficulty.Level.EASY
var key := ""
var width := 0
var height := 0
var channels: Array[PackedInt32Array] = []
var history := MoveHistory.new()

var elapsed := 0.0
var reveal_hints_used := 0
var tactical_hints_used := 0
var mistakes := 0
var entries := 0
var is_solved := false


func cell_count() -> int:
	return width * height


func value(index: int, channel: int = 0) -> int:
	return channels[channel][index]


## Applies [channel, index, new_value] triples as one undoable move.
## Returns false when nothing changed.
func apply(changes: Array) -> bool:
	if is_solved:
		return false
	var move: Array = []
	for change in changes:
		var channel: int = change[0]
		var index: int = change[1]
		var new_value: int = change[2]
		var old_value := channels[channel][index]
		if old_value == new_value:
			continue
		move.append(PackedInt32Array([channel, index, old_value, new_value]))
		channels[channel][index] = new_value
	if move.is_empty():
		return false
	_on_move_applied(move)
	history.record(move)
	_after_change()
	return true


func begin_batch() -> void:
	history.begin_group()


func end_batch() -> void:
	history.end_group()


func undo() -> bool:
	if is_solved:
		return false
	var move := history.pop_undo()
	if move.is_empty():
		return false
	for i in range(move.size() - 1, -1, -1):
		var step: PackedInt32Array = move[i]
		channels[step[0]][step[1]] = step[2]
	_after_change()
	return true


func redo() -> bool:
	if is_solved:
		return false
	var move := history.pop_redo()
	if move.is_empty():
		return false
	for step: PackedInt32Array in move:
		channels[step[0]][step[1]] = step[3]
	_after_change()
	return true


## Clears all player input (givens stay) as one undoable move.
func reset() -> bool:
	var initial := initial_channels()
	var changes: Array = []
	for channel in channels.size():
		for index in cell_count():
			if channels[channel][index] != initial[channel][index]:
				changes.append([channel, index, initial[channel][index]])
	return apply(changes)


func _after_change() -> void:
	if not is_solved and check_complete():
		is_solved = true
		changed.emit()
		completed.emit()
		return
	changed.emit()


func to_save() -> Dictionary:
	var saved_channels: Array = []
	for channel in channels:
		saved_channels.append(Array(channel))
	return {
		"channels": saved_channels,
		"elapsed": elapsed,
		"reveal": reveal_hints_used,
		"tactical": tactical_hints_used,
		"mistakes": mistakes,
		"entries": entries,
	}


## Restores saved player state. Returns false (leaving state untouched) when
## the data does not fit this puzzle.
func load_save(data: Dictionary) -> bool:
	var saved: Variant = data.get("channels")
	if not (saved is Array) or saved.size() != channels.size():
		return false
	var restored: Array[PackedInt32Array] = []
	for channel_data: Variant in saved:
		if not (channel_data is Array) or channel_data.size() != cell_count():
			return false
		restored.append(PackedInt32Array(channel_data))
	var initial := initial_channels()
	for channel in restored.size():
		for index in cell_count():
			if is_locked(index) and restored[channel][index] != initial[channel][index]:
				return false
	channels = restored
	elapsed = float(data.get("elapsed", 0.0))
	reveal_hints_used = int(data.get("reveal", 0))
	tactical_hints_used = int(data.get("tactical", 0))
	mistakes = int(data.get("mistakes", 0))
	entries = int(data.get("entries", 0))
	is_solved = check_complete()
	return true


# --- To implement in subclasses -----------------------------------------

## Player channels for a fresh puzzle (givens included).
func initial_channels() -> Array[PackedInt32Array]:
	push_error("initial_channels() not implemented")
	return []


func is_locked(_index: int) -> bool:
	return false


func check_complete() -> bool:
	push_error("check_complete() not implemented")
	return false


## 1 for every cell that currently breaks a rule.
func conflicts() -> PackedByteArray:
	return PackedByteArray()


func hint_engine() -> HintEngine:
	return HintEngine.new()


func _on_move_applied(_move: Array) -> void:
	pass
