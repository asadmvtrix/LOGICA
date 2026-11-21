class_name Deduction
extends RefCounted
## One sound logical inference produced by a mode's logic engine.
## changes: [channel, index, value] triples in player-state terms.
## places: true when the deduction fills in part of the solution (as opposed to
## only ruling out options).

var technique: String
var steps: Array[HintStep] = []
var changes: Array = []
var places := false
var level := 1
## Mode-specific internal effect (for example candidate eliminations) that has
## no player-state equivalent.
var payload: Variant = null


func _init(p_technique: String, p_level: int, p_places: bool) -> void:
	technique = p_technique
	level = p_level
	places = p_places


func add_step(text: String, focus: PackedInt32Array = PackedInt32Array(), related: PackedInt32Array = PackedInt32Array()) -> Deduction:
	steps.append(HintStep.new(text, focus, related))
	return self
