class_name GameplayScreen
extends Screen
## Plays one puzzle described by the PuzzleLaunch route parameter.
## Generates it on a worker thread, restores a saved session for the same key,
## and offers undo, redo, reset, hints, pause and a completion summary.

const AUTOSAVE_INTERVAL := 3.0
const INSTRUCTIONS := {
	&"queens": "Tap to mark, tap again for a queen. Drag to mark several cells.",
	&"tango": "Tap to cycle sun, moon and empty.",
	&"shikaku": "Drag corner to corner to draw. Tap a rectangle to remove it.",
	&"sudoku": "Select a cell, then a digit. Notes toggles pencil marks.",
}

var launch: PuzzleLaunch
var game: PuzzleGame
var board: BoardView
var hints: HintPresentationController
var paused := false

var _task_id := -1
var _generated: PuzzleGame
var _column: VBoxContainer
var _body: VBoxContainer
var _status: Label
var _timer_label: Label
var _pause_button: IconButton
var _undo: ToolButton
var _redo: ToolButton
var _hint_button: ToolButton
var _explain_button: ToolButton
var _notes: ToolButton
var _notes_mode := false
var _overlay: ModalOverlay
var _dirty := false
var _save_clock := 0.0


func _build() -> void:
	launch = context.router.current_params() as PuzzleLaunch
	if launch == null:
		launch = ProgressionCatalog.journey_launch(PuzzleModes.QUEENS, 1)

	_column = VBoxContainer.new()
	_column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_column.add_theme_constant_override(&"separation", 0)
	add_child(_column)
	_column.add_child(_make_header())

	var page := MarginContainer.new()
	page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_theme_constant_override(&"margin_left", DesignTokens.PAGE_MARGIN)
	page.add_theme_constant_override(&"margin_right", DesignTokens.PAGE_MARGIN)
	page.add_theme_constant_override(&"margin_bottom", DesignTokens.SPACE_M)
	_column.add_child(page)
	_body = VBoxContainer.new()
	_body.add_theme_constant_override(&"separation", DesignTokens.SPACE_S)
	page.add_child(_body)

	var loading := UiFactory.label("Preparing a fresh puzzle…", ThemeFactory.LABEL_SECONDARY)
	loading.name = "Loading"
	loading.size_flags_vertical = Control.SIZE_EXPAND_FILL
	loading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loading.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_body.add_child(loading)

	_task_id = WorkerThreadPool.add_task(_generate, false, "Generate puzzle")


func _generate() -> void:
	_generated = PuzzleModes.generate(launch.mode, launch.difficulty, launch.key)


func is_ready() -> bool:
	return game != null


func _make_header() -> Control:
	var margin := MarginContainer.new()
	margin.custom_minimum_size.y = DesignTokens.HEADER_HEIGHT
	var back_offset := int((DesignTokens.TOUCH_TARGET_MIN - DesignTokens.CHEVRON_SIZE) * 0.5)
	margin.add_theme_constant_override(&"margin_left", DesignTokens.PAGE_MARGIN - back_offset)
	margin.add_theme_constant_override(&"margin_right", DesignTokens.PAGE_MARGIN - DesignTokens.SPACE_S)

	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", DesignTokens.SPACE_XS)
	margin.add_child(row)

	var back := BackButton.new()
	back.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	back.pressed.connect(_on_back_pressed)
	row.add_child(back)

	var titles := VBoxContainer.new()
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	titles.alignment = BoxContainer.ALIGNMENT_CENTER
	titles.add_theme_constant_override(&"separation", 0)
	row.add_child(titles)
	var title := UiFactory.label(PuzzleModes.title(launch.mode), ThemeFactory.LABEL_TITLE)
	titles.add_child(title)
	titles.add_child(UiFactory.label(launch.subtitle(), ThemeFactory.LABEL_SECONDARY))

	_timer_label = UiFactory.label("0:00", ThemeFactory.LABEL_STRONG)
	_timer_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_timer_label.visible = context.settings.show_timer
	row.add_child(_timer_label)

	_pause_button = IconButton.new(VectorIcons.Icon.PAUSE)
	_pause_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_pause_button.disabled = true
	_pause_button.pressed.connect(pause)
	row.add_child(_pause_button)
	return margin


## Blocks until generation finishes and shows the puzzle (used by tests).
func finish_generation_now() -> void:
	if _task_id >= 0:
		_finish_generation()


func _finish_generation() -> void:
	WorkerThreadPool.wait_for_task_completion(_task_id)
	_task_id = -1
	_start(_generated)
	_generated = null


func _process(delta: float) -> void:
	if _task_id >= 0 and WorkerThreadPool.is_task_completed(_task_id):
		_finish_generation()
	if game == null or paused or game.is_solved:
		return
	game.elapsed += delta
	_timer_label.text = TimeFormat.clock(game.elapsed)
	_save_clock += delta
	if _dirty and _save_clock >= AUTOSAVE_INTERVAL:
		_save_session()


func _start(generated: PuzzleGame) -> void:
	_body.get_node("Loading").queue_free()
	if generated == null:
		_body.add_child(UiFactory.paragraph("This puzzle could not be prepared. Please go back and try another.", ThemeFactory.LABEL_SECONDARY))
		return
	game = generated
	var saved := context.progress.session_state(launch.key)
	if not saved.is_empty() and not game.load_save(saved):
		push_warning("Saved session did not match the puzzle; starting fresh.")

	board = PuzzleModes.create_board(game)
	_body.add_child(board)

	_status = UiFactory.paragraph(INSTRUCTIONS.get(launch.mode, ""), ThemeFactory.LABEL_SECONDARY)
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_body.add_child(_status)

	if game is SudokuGame:
		_body.add_child(_make_number_pad())
	_body.add_child(_make_toolbar())

	hints = HintPresentationController.new()
	hints.board = board
	hints.reduce_motion = context.settings.reduced_motion
	hints.apply_requested.connect(_on_hint_applied)
	add_child(hints)

	game.changed.connect(_on_game_changed)
	game.completed.connect(_on_completed)
	_pause_button.disabled = false
	_timer_label.text = TimeFormat.clock(game.elapsed)
	_refresh_tools()
	if context.progress.session_key() != launch.key:
		_save_session()


func _make_toolbar() -> Control:
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override(&"separation", 0)
	_undo = _tool(bar, "Undo", VectorIcons.Icon.UNDO, _on_undo)
	_redo = _tool(bar, "Redo", VectorIcons.Icon.REDO, _on_redo)
	_tool(bar, "Reset", VectorIcons.Icon.RESET, _on_reset)
	_hint_button = _tool(bar, "Hint", VectorIcons.Icon.HINT, request_hint.bind(HintResult.Kind.REVEAL))
	_explain_button = _tool(bar, "Explain", VectorIcons.Icon.EXPLAIN, request_hint.bind(HintResult.Kind.TACTICAL))
	return bar


func _tool(bar: HBoxContainer, caption: String, icon: VectorIcons.Icon, callback: Callable) -> ToolButton:
	var button := ToolButton.new(caption, icon)
	button.accent = board.accent
	button.pressed.connect(callback)
	bar.add_child(button)
	return button


func _make_number_pad() -> Control:
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", DesignTokens.SPACE_XS)
	var digits := HBoxContainer.new()
	digits.add_theme_constant_override(&"separation", DesignTokens.SPACE_XS)
	column.add_child(digits)
	for d in range(1, 10):
		var key := Button.new()
		key.text = str(d)
		key.theme_type_variation = ThemeFactory.BUTTON_SECONDARY
		key.add_theme_font_override(&"font", ThemeFactory.display_font(500, 48))
		key.add_theme_font_size_override(&"font_size", DesignTokens.FONT_SIZE_TITLE)
		key.custom_minimum_size = Vector2(0, DesignTokens.TOUCH_TARGET_MIN)
		key.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		key.pressed.connect(enter_digit.bind(d))
		digits.add_child(key)
	var extra := HBoxContainer.new()
	extra.add_theme_constant_override(&"separation", 0)
	column.add_child(extra)
	_notes = ToolButton.new("Notes", VectorIcons.Icon.NOTES)
	_notes.accent = board.accent
	_notes.pressed.connect(_toggle_notes)
	extra.add_child(_notes)
	var erase := ToolButton.new("Erase", VectorIcons.Icon.ERASE)
	erase.pressed.connect(_on_erase)
	extra.add_child(erase)
	return column


# --- Actions -----------------------------------------------------------------

func enter_digit(digit: int) -> void:
	var sudoku := game as SudokuGame
	if sudoku == null or paused or board.selected < 0:
		return
	if _notes_mode:
		sudoku.toggle_note(board.selected, digit)
	else:
		sudoku.set_digit(board.selected, digit)
		context.settings.tap_feedback()


func _toggle_notes() -> void:
	_notes_mode = not _notes_mode
	_notes.active = _notes_mode


func _on_erase() -> void:
	var sudoku := game as SudokuGame
	if sudoku != null and board.selected >= 0:
		sudoku.erase(board.selected)


func _on_undo() -> void:
	hints.hide_hint()
	game.undo()


func _on_redo() -> void:
	hints.hide_hint()
	game.redo()


func _on_reset() -> void:
	hints.hide_hint()
	game.reset()


func request_hint(kind: HintResult.Kind) -> void:
	if game == null or game.is_solved or paused:
		return
	var engine := game.hint_engine()
	var result := engine.reveal(game) if kind == HintResult.Kind.REVEAL else engine.tactical(game)
	if result.available:
		if kind == HintResult.Kind.REVEAL:
			game.reveal_hints_used += 1
		else:
			game.tactical_hints_used += 1
		_dirty = true
	hints.show_hint(result)


func _on_hint_applied(result: HintResult) -> void:
	game.apply(result.changes)
	if board is SudokuBoardView and not result.changes.is_empty():
		board.select(result.changes[0][1])
	context.settings.tap_feedback()


func pause() -> void:
	if game == null or paused or game.is_solved:
		return
	paused = true
	hints.hide_hint()
	board.visible = false
	_save_session()
	_overlay = ModalOverlay.new()
	_overlay.content.add_child(UiFactory.caption(PuzzleModes.title(launch.mode)))
	_overlay.content.add_child(UiFactory.label("Paused", ThemeFactory.LABEL_HEADLINE))
	_overlay.content.add_child(UiFactory.label(TimeFormat.clock(game.elapsed), ThemeFactory.LABEL_SECONDARY))
	_overlay.content.add_child(UiFactory.spacer(DesignTokens.SPACE_S))
	_overlay.add_button("Resume", ThemeFactory.BUTTON_PRIMARY).pressed.connect(resume)
	_overlay.add_button("Start over").pressed.connect(_restart)
	_overlay.add_button("Leave puzzle").pressed.connect(_on_back_pressed)
	add_child(_overlay)
	_overlay.play_in(context.settings.reduced_motion)


func resume() -> void:
	if not paused:
		return
	paused = false
	board.visible = true
	if _overlay != null:
		_overlay.queue_free()
		_overlay = null


func _restart() -> void:
	game.reset()
	game.elapsed = 0.0
	resume()


# --- Events --------------------------------------------------------------------

func _on_game_changed() -> void:
	_dirty = true
	_refresh_tools()


func _refresh_tools() -> void:
	_undo.disabled = not game.history.can_undo()
	_redo.disabled = not game.history.can_redo()


func _on_completed() -> void:
	hints.hide_hint()
	_dirty = false
	var outcome := context.progress.record_solve(launch, game)
	_pause_button.disabled = true
	for button in [_undo, _redo, _hint_button, _explain_button]:
		button.disabled = true
	board.play_completion(context.settings.reduced_motion)
	if context.settings.reduced_motion or not is_inside_tree():
		_show_completion(outcome)
	else:
		get_tree().create_timer(0.9).timeout.connect(_show_completion.bind(outcome))


func _show_completion(outcome: Dictionary) -> void:
	if not is_inside_tree():
		return
	_overlay = ModalOverlay.new()
	var content := _overlay.content
	content.add_child(UiFactory.caption("%s · %s" % [PuzzleModes.title(launch.mode), launch.subtitle()]))
	content.add_child(UiFactory.label("Solved", ThemeFactory.LABEL_HEADLINE))
	var rows := RowGroup.new()
	content.add_child(rows)
	rows.add_row(InfoRow.new("Time", TimeFormat.clock(game.elapsed) + ("  ·  new best" if outcome.get("new_best", false) else "")))
	rows.add_row(InfoRow.new("Hints", str(game.reveal_hints_used + game.tactical_hints_used)))
	rows.add_row(InfoRow.new("Mistakes", str(game.mistakes)))
	if launch.source == PuzzleLaunch.CHALLENGE:
		var entry := ProgressionCatalog.challenge(launch.challenge_id)
		var text := "Challenge complete" if outcome.get("challenge_met", false) else "Goal missed: " + ProgressionCatalog.challenge_goal(entry).to_lower()
		content.add_child(UiFactory.paragraph(text, ThemeFactory.LABEL_SECONDARY))
	content.add_child(UiFactory.spacer(DesignTokens.SPACE_XS))
	if launch.source == PuzzleLaunch.JOURNEY and launch.level < ProgressionCatalog.JOURNEY_LEVELS:
		var next := ProgressionCatalog.journey_launch(launch.mode, launch.level + 1)
		_overlay.add_button("Level %d" % next.level, ThemeFactory.BUTTON_PRIMARY).pressed.connect(context.router.replace.bind(Routes.PLAY, next))
		_overlay.add_button("Done").pressed.connect(_on_back_pressed)
	else:
		_overlay.add_button("Done", ThemeFactory.BUTTON_PRIMARY).pressed.connect(_on_back_pressed)
	add_child(_overlay)
	_overlay.play_in(context.settings.reduced_motion)


func _save_session() -> void:
	_dirty = false
	_save_clock = 0.0
	if game != null and not game.is_solved:
		context.progress.save_session(launch, game)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		if game != null and not game.is_solved:
			pause()


func _exit_tree() -> void:
	if _task_id >= 0:
		WorkerThreadPool.wait_for_task_completion(_task_id)
		_task_id = -1
	if game != null and not game.is_solved and (_dirty or game.elapsed > 0.0):
		_save_session()
