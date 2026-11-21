class_name HintResult
extends RefCounted
## Outcome of a hint request. The title and steps form the explanation shown to
## the player; changes are applied when the player accepts a reveal.

enum Kind { REVEAL, TACTICAL }

var kind := Kind.REVEAL
var available := false
var title := ""
var steps: Array[HintStep] = []
var changes: Array = []
var is_correction := false


static func none(p_kind: Kind, reason: String) -> HintResult:
	var result := HintResult.new()
	result.kind = p_kind
	result.title = "No hint available"
	result.steps = [HintStep.new(reason)]
	return result


static func correction(p_kind: Kind, text: String, cells: PackedInt32Array, p_changes: Array) -> HintResult:
	var result := HintResult.new()
	result.kind = p_kind
	result.available = true
	result.is_correction = true
	result.title = "Check this"
	result.steps = [HintStep.new(text, cells)]
	result.changes = p_changes
	return result


## Builds a hint from a chain of deductions ending in a placement.
## Reveal hints show only the deciding step; tactical hints show every step.
static func from_chain(p_kind: Kind, chain: Array[Deduction]) -> HintResult:
	var result := HintResult.new()
	result.kind = p_kind
	result.available = true
	var last: Deduction = chain.back()
	result.title = last.technique
	result.changes = last.changes
	if p_kind == Kind.REVEAL:
		result.steps = last.steps.duplicate()
		if chain.size() > 1:
			result.steps.push_front(HintStep.new("This follows after %d earlier deduction%s. Use Explain to see them." % [chain.size() - 1, "" if chain.size() == 2 else "s"]))
		return result
	for deduction in chain:
		result.steps.append_array(deduction.steps)
	if chain.size() > 1:
		result.title = "%s, %d steps" % [last.technique, chain.size()]
	return result
