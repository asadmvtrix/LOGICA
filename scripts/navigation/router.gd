class_name Router
extends RefCounted
## Navigation state. A single stack whose first entry is always the active tab;
## pushed routes sit on top of it, each with an optional parameter. Holds no
## nodes; the shell renders the current route when route_changed fires.

## direction is a Router.Direction value.
signal route_changed(route: StringName, direction: int)

enum Direction { REPLACE, FORWARD, BACK }

var _tabs: Array[StringName]
var _home: StringName
var _stack: Array[StringName] = []
var _params: Array = []


func _init(tabs: Array[StringName], home: StringName) -> void:
	assert(home in tabs, "Home route must be one of the tabs")
	_tabs = tabs
	_home = home


func current() -> StringName:
	return &"" if _stack.is_empty() else _stack.back()


## Parameter passed when the current route was pushed (null for tabs).
func current_params() -> Variant:
	return null if _params.is_empty() else _params.back()


func active_tab() -> StringName:
	return &"" if _stack.is_empty() else _stack.front()


func depth() -> int:
	return _stack.size()


func is_tab(route: StringName) -> bool:
	return route in _tabs


func select_tab(tab: StringName) -> void:
	if not is_tab(tab):
		push_error("Unknown tab: %s" % tab)
		return
	if _stack.size() == 1 and _stack[0] == tab:
		return
	_stack = [tab]
	_params = [null]
	route_changed.emit(tab, Direction.REPLACE)


func push(route: StringName, params: Variant = null) -> void:
	if is_tab(route):
		select_tab(route)
		return
	if _stack.is_empty():
		push_error("Cannot push %s before a tab is selected" % route)
		return
	if current() == route and params == null and current_params() == null:
		return
	_stack.append(route)
	_params.append(params)
	route_changed.emit(route, Direction.FORWARD)


## Replaces the current pushed route (for example "next level") without
## growing the stack.
func replace(route: StringName, params: Variant = null) -> void:
	if _stack.size() <= 1:
		push(route, params)
		return
	_stack[_stack.size() - 1] = route
	_params[_params.size() - 1] = params
	route_changed.emit(route, Direction.FORWARD)


## Returns false when there is nowhere to go back to (home tab at root).
func back() -> bool:
	if _stack.size() > 1:
		_stack.pop_back()
		_params.pop_back()
		route_changed.emit(current(), Direction.BACK)
		return true
	if not _stack.is_empty() and active_tab() != _home:
		_stack = [_home]
		_params = [null]
		route_changed.emit(_home, Direction.BACK)
		return true
	return false
