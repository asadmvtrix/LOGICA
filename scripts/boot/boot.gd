extends Control
## Foundation boot screen. Proves the exported APK starts and runs GDScript.
## Replaced by the application shell in Phase 1.

@onready var _version_label: Label = %VersionLabel


func _ready() -> void:
	var version: String = ProjectSettings.get_setting("application/config/version", "dev")
	_version_label.text = "LOGICA %s" % version
	print("LOGICA boot ok (version %s)" % version)
