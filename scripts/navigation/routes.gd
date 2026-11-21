class_name Routes
extends RefCounted
## Route identifiers and tab configuration.

const HOME := &"home"
const JOURNEY := &"journey"
const DAILY := &"daily"
const TRAINING := &"training"
const CHALLENGES := &"challenges"
const STATISTICS := &"statistics"
const SETTINGS := &"settings"

const TABS: Array[StringName] = [HOME, JOURNEY, DAILY, STATISTICS, SETTINGS]

const TAB_LABELS := {
	HOME: "Home",
	JOURNEY: "Journey",
	DAILY: "Daily",
	STATISTICS: "Stats",
	SETTINGS: "Settings",
}
