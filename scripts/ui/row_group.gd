class_name RowGroup
extends VBoxContainer
## Vertical list of rows separated by hairlines.


func _init() -> void:
	add_theme_constant_override(&"separation", 0)


func add_row(row: Control) -> void:
	if get_child_count() > 0:
		add_child(HSeparator.new())
	add_child(row)
