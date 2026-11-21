class_name AppContext
extends RefCounted
## Services shared with screens. Created once by the composition root (App)
## and passed explicitly; nothing is reached through globals.

var router: Router
var settings: SettingsService


func _init(p_router: Router, p_settings: SettingsService) -> void:
	router = p_router
	settings = p_settings


static func app_version() -> String:
	return str(ProjectSettings.get_setting("application/config/version", "dev"))
