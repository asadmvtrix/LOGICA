class_name TangoPuzzle
extends RefCounted
## A Tango puzzle: an even N x N grid of suns and moons.
## Rules: each row and column holds as many suns as moons; no three equal
## symbols in a row or column; cells joined by = match, by x differ.

const EMPTY := 0
const SUN := 1
const MOON := 2
const EQUAL := 1
const OPPOSITE := 2

var size: int
## Fixed starting symbols (EMPTY where the player decides).
var givens: PackedInt32Array
## Edge clues as PackedInt32Array [cell_a, cell_b, EQUAL or OPPOSITE], a < b and adjacent.
var edges: Array[PackedInt32Array] = []
var solution: PackedInt32Array


func _init(p_size: int, p_givens: PackedInt32Array, p_edges: Array[PackedInt32Array], p_solution: PackedInt32Array) -> void:
	size = p_size
	givens = p_givens
	edges = p_edges
	solution = p_solution


static func opposite(symbol: int) -> int:
	return MOON if symbol == SUN else SUN


static func symbol_name(symbol: int) -> String:
	return "sun" if symbol == SUN else "moon"
