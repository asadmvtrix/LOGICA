extends "res://tests/test_case.gd"

const PATH := "user://test_settings.json"

var store: JsonFileStore


func before_each() -> void:
	store = JsonFileStore.new(PATH)
	store.delete_all()


func after_each() -> void:
	store.delete_all()


func test_defaults_when_no_file() -> void:
	var settings := SettingsService.new(store)
	settings.load_settings()
	assert_false(settings.reduced_motion)
	assert_eq(settings.load_status, JsonFileStore.STATUS_MISSING)


func test_change_is_persisted_and_reloaded() -> void:
	var settings := SettingsService.new(store)
	settings.load_settings()
	settings.set_reduced_motion(true)

	var reloaded := SettingsService.new(store)
	reloaded.load_settings()
	assert_true(reloaded.reduced_motion)
	assert_eq(int(store.read().data.get("version")), SettingsService.SAVE_VERSION)


func test_change_emits_signal_once() -> void:
	var settings := SettingsService.new(store)
	var keys: Array = []
	settings.changed.connect(func(key: StringName) -> void: keys.append(key))
	settings.set_reduced_motion(true)
	settings.set_reduced_motion(true)
	assert_eq(keys, [SettingsService.KEY_REDUCED_MOTION])


func test_all_flags_persist() -> void:
	var settings := SettingsService.new(store)
	assert_true(settings.haptics)
	assert_true(settings.show_timer)
	settings.set_haptics(false)
	settings.set_show_timer(false)
	var reloaded := SettingsService.new(store)
	reloaded.load_settings()
	assert_false(reloaded.haptics)
	assert_false(reloaded.show_timer)
	assert_false(reloaded.reduced_motion)


func test_wrong_value_type_is_ignored() -> void:
	store.write({"version": 1, "data": {"reduced_motion": "yes"}})
	var settings := SettingsService.new(store)
	settings.load_settings()
	assert_false(settings.reduced_motion)


func test_missing_data_section_uses_defaults() -> void:
	store.write({"version": 1})
	var settings := SettingsService.new(store)
	settings.load_settings()
	assert_false(settings.reduced_motion)
	assert_eq(settings.load_status, JsonFileStore.STATUS_CORRUPT)
