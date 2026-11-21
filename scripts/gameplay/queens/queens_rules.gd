class_name QueensRules
extends RefCounted
## Rule checks for Queens. Cell values: 0 empty, 1 marked empty, 2 queen.

const EMPTY := 0
const MARK := 1
const QUEEN := 2


static func attacks(size: int, regions: PackedInt32Array, a: int, b: int) -> bool:
	if a == b:
		return false
	var ra := a / size
	var ca := a % size
	var rb := b / size
	var cb := b % size
	if ra == rb or ca == cb or regions[a] == regions[b]:
		return true
	return absi(ra - rb) <= 1 and absi(ca - cb) <= 1


## 1 for every queen that shares a row, column or region with, or touches,
## another queen.
static func conflicts(size: int, regions: PackedInt32Array, cells: PackedInt32Array) -> PackedByteArray:
	var result := PackedByteArray()
	result.resize(cells.size())
	var queens: Array[int] = []
	for i in cells.size():
		if cells[i] == QUEEN:
			queens.append(i)
	for x in queens.size():
		for y in range(x + 1, queens.size()):
			if attacks(size, regions, queens[x], queens[y]):
				result[queens[x]] = 1
				result[queens[y]] = 1
	return result


## Solved when there are exactly size queens and none conflict. With size queens
## and no shared row, column or region, every row, column and region has one.
static func is_solved(size: int, regions: PackedInt32Array, cells: PackedInt32Array) -> bool:
	var count := 0
	for value in cells:
		if value == QUEEN:
			count += 1
	if count != size:
		return false
	for flag in conflicts(size, regions, cells):
		if flag == 1:
			return false
	return true
