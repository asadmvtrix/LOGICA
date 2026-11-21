class_name SettingsService
extends RefCounted
## Player preferences, persisted as a versioned JSON envelope:
## { "version": int, "data": { ... } }.
## Unknown or wrongly typed values are ignored and defaults are kept.

signal changed(key: StringName)

const SAVE_VERSION := 1
const KEY_REDUCED_MOTION := &"reduced_motion"
const KEY_HAPTICS := &"haptics"
const KEY_SHOW_TIMER := &"show_timer"
const DEFAULTS := {
	KEY_REDUCED_MOTION: false,
	KEY_HAPTICS: true,
	KEY_SHOW_TIMER: true,
}

var reduced_motion := false
var haptics := true
var show_timer := true
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
	for key: StringName in DEFAULTS:
		var stored: Variant = data.get(String(key))
		if stored is bool:
			set(key, stored)


func set_reduced_motion(value: bool) -> void:
	_set_flag(KEY_REDUCED_MOTION, value)


func set_haptics(value: bool) -> void:
	_set_flag(KEY_HAPTICS, value)


func set_show_timer(value: bool) -> void:
	_set_flag(KEY_SHOW_TIMER, value)


## Short vibration for placements, when enabled and supported.
func tap_feedback() -> void:
	if haptics and OS.has_feature("mobile"):
		Input.vibrate_handheld(12)


func _set_flag(key: StringName, value: bool) -> void:
	if get(key) == value:
		return
	set(key, value)
	_save()
	changed.emit(key)


func _save() -> void:
	var data := {}
	for key: StringName in DEFAULTS:
		data[String(key)] = get(key)
	var error := _store.write({"version": SAVE_VERSION, "data": data})
	if error != OK:
		push_error("Saving settings failed: %s" % error_string(error))
