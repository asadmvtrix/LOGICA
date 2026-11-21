extends SceneTree
## Headless test runner.
## Usage: godot --headless --path . --script res://tests/run_tests.gd
## Runs every test_* method in tests/unit/test_*.gd. Exits with code 1 on any
## failure, or if no tests were found.

const TEST_DIR := "res://tests/unit"
const PASS_MARKER := "ALL TESTS PASSED"


func _initialize() -> void:
	var total := 0
	var failed := 0

	for file_name in _test_files():
		var script := load(TEST_DIR.path_join(file_name)) as GDScript
		if script == null or not script.can_instantiate():
			print("FAIL %s: script could not be loaded" % file_name)
			failed += 1
			continue
		for method in script.get_script_method_list():
			var method_name: String = method["name"]
			if not method_name.begins_with("test_"):
				continue
			total += 1
			var failures := _run_test(script, method_name)
			if failures.is_empty():
				print("ok   %s.%s" % [file_name.get_basename(), method_name])
			else:
				failed += 1
				print("FAIL %s.%s" % [file_name.get_basename(), method_name])
				for failure in failures:
					print("       %s" % failure)

	print("")
	print("%d tests, %d failed" % [total, failed])
	if total == 0:
		print("No tests found in %s" % TEST_DIR)
		quit(1)
	elif failed > 0:
		quit(1)
	else:
		print(PASS_MARKER)
		quit(0)


func _run_test(script: GDScript, method_name: String) -> PackedStringArray:
	var test_case: Object = script.new()
	test_case.set("tree", self)
	test_case.call("before_each")
	test_case.call(method_name)
	test_case.call("after_each")
	return test_case.call("take_failures")


func _test_files() -> PackedStringArray:
	var files := PackedStringArray()
	for file_name in DirAccess.get_files_at(TEST_DIR):
		if file_name.begins_with("test_") and file_name.ends_with(".gd"):
			files.append(file_name)
	files.sort()
	return files
