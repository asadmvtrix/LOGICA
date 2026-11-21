class_name BottomNav
extends PanelContainer
## Text-only tab bar. Emits the id of the tapped tab; the active tab is set
## from navigation state, never from the tap itself.

signal item_selected(id: StringName)

var _items: Dictionary = {}


func _init(ids: Array[StringName], labels: Dictionary) -> void:
	theme_type_variation = ThemeFactory.PANEL_NAV_BAR
	custom_minimum_size.y = DesignTokens.NAV_HEIGHT

	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 0)
	add_child(row)

	for id in ids:
		var item := NavItem.new(labels[id])
		item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		item.pressed.connect(item_selected.emit.bind(id))
		row.add_child(item)
		_items[id] = item


func set_active(id: StringName) -> void:
	for key: StringName in _items:
		(_items[key] as NavItem).active = key == id


func active_id() -> StringName:
	for key: StringName in _items:
		if (_items[key] as NavItem).active:
			return key
	return &""


class NavItem:
	extends Button

	var active := false:
		set(new_value):
			active = new_value
			theme_type_variation = ThemeFactory.BUTTON_NAV_ACTIVE if active else ThemeFactory.BUTTON_NAV
			queue_redraw()

	func _init(label_text: String) -> void:
		text = label_text
		theme_type_variation = ThemeFactory.BUTTON_NAV
		mouse_filter = Control.MOUSE_FILTER_PASS
		custom_minimum_size.y = DesignTokens.TOUCH_TARGET_MIN

	func _draw() -> void:
		if not active:
			return
		var indicator := DesignTokens.NAV_INDICATOR_SIZE
		var rect := Rect2(Vector2((size.x - indicator.x) * 0.5, 0.0), indicator)
		draw_rect(rect, DesignTokens.COLOR_ACCENT)
