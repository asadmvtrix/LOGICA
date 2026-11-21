extends RefCounted
## Base for test scripts. Methods named test_* are run by tests/run_tests.gd.
## A fresh instance is created for every test method.

var tree: SceneTree

var _failures: PackedStringArray = []


func before_each() -> void:
	pass


func after_each() -> void:
	pass


func take_failures() -> PackedStringArray:
	var failures := _failures
	_failures = PackedStringArray()
	return failures


func fail(message: String) -> void:
	_failures.append(message)


func assert_true(condition: bool, message: String = "") -> void:
	if not condition:
		fail("Expected true. %s" % message)


func assert_false(condition: bool, message: String = "") -> void:
	if condition:
		fail("Expected false. %s" % message)


func assert_eq(actual: Variant, expected: Variant, message: String = "") -> void:
	if not _values_equal(actual, expected):
		fail("Expected <%s> but got <%s>. %s" % [str(expected), str(actual), message])


func assert_gte(actual: float, minimum: float, message: String = "") -> void:
	if actual < minimum:
		fail("Expected >= %s but got %s. %s" % [minimum, actual, message])


static func _values_equal(a: Variant, b: Variant) -> bool:
	var string_types := [TYPE_STRING, TYPE_STRING_NAME]
	var number_types := [TYPE_INT, TYPE_FLOAT]
	if typeof(a) != typeof(b):
		if typeof(a) in string_types and typeof(b) in string_types:
			return str(a) == str(b)
		if typeof(a) in number_types and typeof(b) in number_types:
			return is_equal_approx(float(a), float(b))
		return false
	return a == b
