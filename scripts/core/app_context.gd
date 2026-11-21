class_name AppContext
extends RefCounted
## Services shared with screens. Created once by the composition root (App)
## and passed explicitly; nothing is reached through globals.

var router: Router
var settings: SettingsService
var progress: ProgressService
## When set, used instead of the system date (tests and screenshots).
var today_override := {}
## Mode last shown in the Journey tab, kept for this app run.
var journey_mode: StringName = &"queens"


func _init(p_router: Router, p_settings: SettingsService, p_progress: ProgressService) -> void:
	router = p_router
	settings = p_settings
	progress = p_progress


static func app_version() -> String:
	return str(ProjectSettings.get_setting("application/config/version", "dev"))


func today() -> Dictionary:
	return today_override if not today_override.is_empty() else Time.get_date_dict_from_system()
