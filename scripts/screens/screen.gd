class_name Screen
extends Control
## Base class for top-level screens. Screens build their UI in code from shared
## components and read services from the AppContext they are given.

var context: AppContext
var route: StringName
var _content: VBoxContainer


func setup(p_context: AppContext, p_route: StringName) -> void:
	context = p_context
	route = p_route
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()


## Override to build the screen's content.
func _build() -> void:
	pass


## Header (omitted when title is empty) above a vertically scrolling content
## column with page margins. Returns the content column.
func _make_scrolling_layout(title: String, show_back: bool) -> VBoxContainer:
	var column := _make_column(title, show_back)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)

	var page := _make_page()
	scroll.add_child(page)
	return page.get_child(0) as VBoxContainer


## Header above a content column that fills the remaining height, for screens
## whose content is centred (such as empty states). Returns the content column.
func _make_fill_layout(title: String, show_back: bool) -> VBoxContainer:
	var column := _make_column(title, show_back)
	var page := _make_page()
	page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(page)
	return page.get_child(0) as VBoxContainer


func _make_column(title: String, show_back: bool) -> VBoxContainer:
	var column := VBoxContainer.new()
	column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	column.add_theme_constant_override(&"separation", 0)
	add_child(column)
	if not title.is_empty():
		var header := ScreenHeader.new(title, show_back)
		header.back_pressed.connect(_on_back_pressed)
		column.add_child(header)
	return column


## Page margins around a content column (the margin's only child).
func _make_page() -> MarginContainer:
	var page := MarginContainer.new()
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.add_theme_constant_override(&"margin_left", DesignTokens.PAGE_MARGIN)
	page.add_theme_constant_override(&"margin_right", DesignTokens.PAGE_MARGIN)
	page.add_theme_constant_override(&"margin_top", DesignTokens.SPACE_S)
	page.add_theme_constant_override(&"margin_bottom", DesignTokens.SPACE_XL)

	var content := VBoxContainer.new()
	content.add_theme_constant_override(&"separation", DesignTokens.SPACE_S)
	page.add_child(content)
	_content = content
	return page


## Content blocks fade in one after another, grid tiles included.
func _ready() -> void:
	if _content == null or context == null or context.settings.reduced_motion:
		return
	var items: Array[CanvasItem] = []
	for child in _content.get_children():
		if child is GridContainer:
			for tile in child.get_children():
				items.append(tile as CanvasItem)
		elif child is CanvasItem:
			items.append(child as CanvasItem)
	if items.is_empty():
		return
	var tween := create_tween().set_parallel(true)
	for i in items.size():
		var item := items[i]
		item.modulate.a = 0.0
		tween.tween_property(item, "modulate:a", 1.0, 0.3).set_delay(minf(i * 0.04, 0.5)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _on_back_pressed() -> void:
	context.router.back()
