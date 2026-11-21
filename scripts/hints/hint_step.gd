class_name HintStep
extends RefCounted
## One step of a hint explanation, with the cells it refers to.
## focus: the cells the step is about (strong highlight).
## related: supporting cells such as the rest of a row or region (soft highlight).

var text: String
var focus: PackedInt32Array
var related: PackedInt32Array


func _init(p_text: String, p_focus: PackedInt32Array = PackedInt32Array(), p_related: PackedInt32Array = PackedInt32Array()) -> void:
	text = p_text
	focus = p_focus
	related = p_related
