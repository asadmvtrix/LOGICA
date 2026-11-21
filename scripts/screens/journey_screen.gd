extends Screen
## Journey: 60 levels per mode in rising difficulty, unlocked in order.
## Solved levels stay replayable.

const GRID_COLUMNS := 6
const BANDS := [[1, 12], [13, 30], [31, 48], [49, 60]]

var _mode: StringName
var _levels: VBoxContainer


func _build() -> void:
	var content := _make_scrolling_layout("Journey", false)
	_mode = context.journey_mode
	var tabs := ModeTabs.new(_mode)
	tabs.mode_selected.connect(_on_mode_selected)
	content.add_child(tabs)
	_levels = VBoxContainer.new()
	_levels.add_theme_constant_override(&"separation", DesignTokens.SPACE_S)
	content.add_child(_levels)
	_fill()


func _on_mode_selected(mode: StringName) -> void:
	_mode = mode
	context.journey_mode = mode
	for child in _levels.get_children():
		child.queue_free()
	_fill()


func _fill() -> void:
	var progress := context.progress
	var accent := DesignTokens.mode_color(_mode)
	var completed := progress.journey_completed(_mode)
	var next := progress.next_journey_level(_mode)

	_levels.add_child(UiFactory.spacer(DesignTokens.SPACE_XS))
	var card := CardButton.new()
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", DesignTokens.SPACE_M)
	card.content.add_child(row)
	row.add_child(ModePreview.new(_mode, 170.0))
	var text := VBoxContainer.new()
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(text)
	var caption := UiFactory.caption("%d of %d solved" % [completed, ProgressionCatalog.JOURNEY_LEVELS])
	caption.add_theme_color_override(&"font_color", accent)
	text.add_child(caption)
	text.add_child(UiFactory.label("Level %d" % next, ThemeFactory.LABEL_HEADLINE))
	text.add_child(UiFactory.label(Difficulty.name_of(ProgressionCatalog.difficulty_for_level(next)), ThemeFactory.LABEL_SECONDARY))
	card.pressed.connect(_play.bind(next))
	_levels.add_child(card)

	for band: Array in BANDS:
		var first: int = band[0]
		var last: int = band[1]
		_levels.add_child(UiFactory.spacer(DesignTokens.SPACE_XS))
		_levels.add_child(UiFactory.caption("%s · %d–%d" % [Difficulty.name_of(ProgressionCatalog.difficulty_for_level(first)), first, last]))
		var grid := GridContainer.new()
		grid.columns = GRID_COLUMNS
		grid.add_theme_constant_override(&"h_separation", DesignTokens.SPACE_XS)
		grid.add_theme_constant_override(&"v_separation", DesignTokens.SPACE_XS)
		_levels.add_child(grid)
		for level in range(first, last + 1):
			var state := LevelCell.State.LOCKED
			if progress.is_solved(ProgressionCatalog.journey_launch(_mode, level).key) or level <= completed:
				state = LevelCell.State.SOLVED
			elif level == next:
				state = LevelCell.State.NEXT
			elif progress.is_level_unlocked(_mode, level):
				state = LevelCell.State.OPEN
			var cell := LevelCell.new(level, state, accent)
			cell.pressed.connect(_play.bind(level))
			grid.add_child(cell)


func _play(level: int) -> void:
	context.router.push(Routes.PLAY, ProgressionCatalog.journey_launch(_mode, level))
