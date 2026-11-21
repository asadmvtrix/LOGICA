class_name TimeFormat
extends RefCounted
## Durations for display.


## Example: 75 -> "1:15", 3725 -> "1:02:05".
static func clock(seconds: float) -> String:
	var total := int(seconds)
	var hours := total / 3600
	var minutes := (total % 3600) / 60
	var secs := total % 60
	if hours > 0:
		return "%d:%02d:%02d" % [hours, minutes, secs]
	return "%d:%02d" % [minutes, secs]
