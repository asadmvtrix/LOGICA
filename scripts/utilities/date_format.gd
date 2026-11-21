class_name DateFormat
extends RefCounted
## Human-readable dates from Time date dictionaries.

const WEEKDAYS: Array[String] = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
const MONTHS: Array[String] = [
	"January", "February", "March", "April", "May", "June",
	"July", "August", "September", "October", "November", "December",
]


## Example: "Saturday, 21 November".
static func long_date(date: Dictionary) -> String:
	return "%s, %d %s" % [WEEKDAYS[int(date["weekday"])], int(date["day"]), MONTHS[int(date["month"]) - 1]]


static func today() -> String:
	return long_date(Time.get_date_dict_from_system())
