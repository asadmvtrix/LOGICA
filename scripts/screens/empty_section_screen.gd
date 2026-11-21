extends Screen
## Section whose content arrives in a later phase. Shows an honest empty state
## instead of placeholder controls.

const SECTIONS := {
	Routes.JOURNEY: {
		"title": "Journey",
		"empty_title": "No levels yet",
		"empty_message": "Journey levels will appear here once the first puzzle type is ready.",
	},
	Routes.DAILY: {
		"title": "Daily",
		"empty_title": "No daily puzzles yet",
		"empty_message": "A new set of puzzles will appear here each day.",
	},
	Routes.TRAINING: {
		"title": "Training",
		"empty_title": "No lessons yet",
		"empty_message": "Step-by-step lessons for each puzzle type will appear here.",
	},
	Routes.CHALLENGES: {
		"title": "Challenges",
		"empty_title": "No challenges yet",
		"empty_message": "Special puzzle sets and timed challenges will appear here.",
	},
	Routes.STATISTICS: {
		"title": "Statistics",
		"empty_title": "Nothing to show yet",
		"empty_message": "Your completed puzzles, best times and hint use will be tracked here.",
	},
}


func _build() -> void:
	var section: Dictionary = SECTIONS[route]
	var content := _make_fill_layout(section["title"], not context.router.is_tab(route))
	if route == Routes.DAILY:
		content.add_child(UiFactory.label(DateFormat.today(), ThemeFactory.LABEL_SECONDARY))
	content.add_child(EmptyState.new(section["empty_title"], section["empty_message"]))
