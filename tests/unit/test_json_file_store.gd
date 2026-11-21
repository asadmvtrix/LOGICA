extends "res://tests/test_case.gd"

const PATH := "user://test_store.json"

var store: JsonFileStore


func before_each() -> void:
	store = JsonFileStore.new(PATH)
	store.delete_all()


func after_each() -> void:
	store.delete_all()


func test_missing_file_reports_missing() -> void:
	var result := store.read()
	assert_false(result.ok)
	assert_eq(result.status, JsonFileStore.STATUS_MISSING)


func test_write_then_read_round_trips() -> void:
	assert_eq(store.write({"a": 1, "b": "two"}), OK)
	var result := store.read()
	assert_true(result.ok)
	assert_eq(result.status, JsonFileStore.STATUS_OK)
	assert_eq(result.data.get("a"), 1)
	assert_eq(result.data.get("b"), "two")
	assert_false(FileAccess.file_exists(store.temp_path()), "temp file should be renamed away")


func test_second_write_keeps_previous_as_backup() -> void:
	store.write({"v": 1})
	store.write({"v": 2})
	assert_eq(store.read().data.get("v"), 2)
	assert_true(FileAccess.file_exists(store.backup_path()))


func test_corrupt_main_file_falls_back_to_backup() -> void:
	store.write({"v": 1})
	store.write({"v": 2})
	_overwrite(PATH, "{ this is not json")
	var result := store.read()
	assert_true(result.ok)
	assert_eq(result.status, JsonFileStore.STATUS_RESTORED_FROM_BACKUP)
	assert_eq(result.data.get("v"), 1)


func test_corrupt_without_backup_reports_corrupt() -> void:
	_overwrite(PATH, "[1, 2, 3]")
	var result := store.read()
	assert_false(result.ok)
	assert_eq(result.status, JsonFileStore.STATUS_CORRUPT)


func _overwrite(file_path: String, text: String) -> void:
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(text)
	file.close()
