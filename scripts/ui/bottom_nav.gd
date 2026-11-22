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
		var item := NavItem.new(labels[id], ICONS.get(id, VectorIcons.Icon.HOME))
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


const ICONS := {
	&"home": VectorIcons.Icon.HOME,
	&"journey": VectorIcons.Icon.JOURNEY,
	&"daily": VectorIcons.Icon.DAILY,
	&"statistics": VectorIcons.Icon.STATS,
	&"settings": VectorIcons.Icon.SETTINGS,
}


## Icon over label; the active tab sits on a tinted pill.
class NavItem:
	extends Button

	var label_text: String
	var icon_id: VectorIcons.Icon
	var _pill := StyleBoxFlat.new()

	var active := false:
		set(new_value):
			active = new_value
			queue_redraw()

	func _init(p_label: String, p_icon: VectorIcons.Icon) -> void:
		label_text = p_label
		icon_id = p_icon
		tooltip_text = p_label
		theme_type_variation = ThemeFactory.BUTTON_NAV
		mouse_filter = Control.MOUSE_FILTER_PASS
		custom_minimum_size.y = DesignTokens.TOUCH_TARGET_MIN
		_pill.bg_color = DesignTokens.mode_tint(&"queens")
		_pill.set_corner_radius_all(DesignTokens.RADIUS_PILL)
		_pill.anti_aliasing = true

	func _draw() -> void:
		var icon_center := Vector2(size.x * 0.5, size.y * 0.36)
		var color := DesignTokens.COLOR_INK if active else DesignTokens.COLOR_INK_MUTED
		if active:
			draw_style_box(_pill, Rect2(icon_center - Vector2(68, 30), Vector2(136, 60)))
		VectorIcons.draw_icon(self, icon_id, icon_center, 66.0, color)
		var weight := DesignTokens.FONT_WEIGHT_SEMIBOLD if active else DesignTokens.FONT_WEIGHT_MEDIUM
		var font := BoardView.font(weight)
		var font_size := DesignTokens.FONT_SIZE_CAPTION
		draw_string(font, Vector2(0, size.y * 0.82), label_text, HORIZONTAL_ALIGNMENT_CENTER, size.x, font_size, color)
