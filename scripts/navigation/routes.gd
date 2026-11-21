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
## Pushed with a PuzzleLaunch parameter.
const PLAY := &"play"
## Pushed with a mode id parameter.
const LESSON := &"lesson"

const TABS: Array[StringName] = [HOME, JOURNEY, DAILY, STATISTICS, SETTINGS]

## Routes shown without the tab bar.
const FULL_SCREEN: Array[StringName] = [PLAY]

const TAB_LABELS := {
	HOME: "Home",
	JOURNEY: "Journey",
	DAILY: "Daily",
	STATISTICS: "Stats",
	SETTINGS: "Settings",
}
