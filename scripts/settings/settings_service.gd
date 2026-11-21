class_name SettingsService
extends RefCounted
## Player preferences, persisted as a versioned JSON envelope:
## { "version": int, "data": { ... } }.
## Unknown or wrongly typed values are ignored and defaults are kept.

signal changed(key: StringName)

const SAVE_VERSION := 1
const KEY_REDUCED_MOTION := &"reduced_motion"

var reduced_motion := false
var load_status: StringName = &""

var _store: JsonFileStore


func _init(store: JsonFileStore) -> void:
	_store = store


func load_settings() -> void:
	var result := _store.read()
	load_status = result.status
	if not result.ok:
		if result.status == JsonFileStore.STATUS_CORRUPT:
			push_warning("Settings file is unreadable; using defaults.")
		return
	var data: Variant = result.data.get("data")
	if not (data is Dictionary):
		load_status = JsonFileStore.STATUS_CORRUPT
		push_warning("Settings file has no data section; using defaults.")
		return
	var stored_reduced_motion: Variant = data.get(String(KEY_REDUCED_MOTION))
	if stored_reduced_motion is bool:
		reduced_motion = stored_reduced_motion


func set_reduced_motion(value: bool) -> void:
	if value == reduced_motion:
		return
	reduced_motion = value
	_save()
	changed.emit(KEY_REDUCED_MOTION)


func _save() -> void:
	var envelope := {
		"version": SAVE_VERSION,
		"data": {String(KEY_REDUCED_MOTION): reduced_motion},
	}
	var error := _store.write(envelope)
	if error != OK:
		push_error("Saving settings failed: %s" % error_string(error))
