class_name JsonFileStore
extends RefCounted
## Stores one JSON dictionary in a file with crash-safe writes.
## Writes go to a temporary file which then replaces the main file; the
## previous main file is kept as a backup and used if the main file is
## missing or unreadable.

const STATUS_OK := &"ok"
const STATUS_RESTORED_FROM_BACKUP := &"restored_from_backup"
const STATUS_MISSING := &"missing"
const STATUS_CORRUPT := &"corrupt"

var path: String


class ReadResult:
	var ok := false
	var status: StringName = &"missing"
	var data: Dictionary = {}


func _init(file_path: String) -> void:
	path = file_path


func backup_path() -> String:
	return path + ".bak"


func temp_path() -> String:
	return path + ".tmp"


func write(data: Dictionary) -> Error:
	var file := FileAccess.open(temp_path(), FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(data, "\t"))
	file.flush()
	var error := file.get_error()
	file.close()
	if error != OK:
		return error

	if FileAccess.file_exists(path):
		if FileAccess.file_exists(backup_path()):
			error = DirAccess.remove_absolute(backup_path())
			if error != OK:
				return error
		error = DirAccess.rename_absolute(path, backup_path())
		if error != OK:
			return error
	return DirAccess.rename_absolute(temp_path(), path)


func read() -> ReadResult:
	var main := _read_file(path)
	if main.ok:
		return main
	var backup := _read_file(backup_path())
	if backup.ok:
		backup.status = STATUS_RESTORED_FROM_BACKUP
		return backup
	if main.status == STATUS_MISSING and backup.status == STATUS_MISSING:
		return main
	var result := ReadResult.new()
	result.status = STATUS_CORRUPT
	return result


func delete_all() -> void:
	for file_path in [path, backup_path(), temp_path()]:
		if FileAccess.file_exists(file_path):
			DirAccess.remove_absolute(file_path)


func _read_file(file_path: String) -> ReadResult:
	var result := ReadResult.new()
	if not FileAccess.file_exists(file_path):
		result.status = STATUS_MISSING
		return result
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(file_path)) != OK or not (json.data is Dictionary):
		result.status = STATUS_CORRUPT
		return result
	result.ok = true
	result.status = STATUS_OK
	result.data = json.data
	return result
