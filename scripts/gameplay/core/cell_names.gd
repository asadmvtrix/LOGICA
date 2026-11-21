class_name CellNames
extends RefCounted
## Player-facing names for grid positions (1-based).


static func row(r: int) -> String:
	return "row %d" % (r + 1)


static func column(c: int) -> String:
	return "column %d" % (c + 1)


static func cell(index: int, width: int) -> String:
	return "row %d, column %d" % [index / width + 1, index % width + 1]


static func line(is_row: bool, number: int) -> String:
	return row(number) if is_row else column(number)


static func sentence_case(text: String) -> String:
	return text.left(1).to_upper() + text.substr(1)
