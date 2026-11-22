class_name Confetti
extends Control
## One-shot burst of paper confetti over the whole screen; frees itself.

const LIFETIME := 2.4
const COUNT := 90
const GRAVITY := 1900.0

var colors: Array[Color] = []
var _pieces: Array = []
var _time := 0.0


func _init(p_colors: Array[Color], seed_value: int = 7) -> void:
	colors = p_colors
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in COUNT:
		var from_left := i % 2 == 0
		_pieces.append({
			"x": 0.0 if from_left else 1.0,
			"y": 0.62,
			"vx": rng.randf_range(500.0, 1500.0) * (1.0 if from_left else -1.0),
			"vy": rng.randf_range(-2700.0, -1500.0),
			"spin": rng.randf_range(-12.0, 12.0),
			"angle": rng.randf_range(0.0, TAU),
			"w": rng.randf_range(16.0, 30.0),
			"h": rng.randf_range(8.0, 16.0),
			"color": colors[i % colors.size()],
			"delay": rng.randf_range(0.0, 0.18),
		})


func _process(delta: float) -> void:
	_time += delta
	if _time >= LIFETIME:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var fade := clampf((LIFETIME - _time) / 0.5, 0.0, 1.0)
	for piece: Dictionary in _pieces:
		var t: float = _time - float(piece["delay"])
		if t <= 0.0:
			continue
		var drag := 1.0 / (1.0 + t * 1.6)
		var pos := Vector2(float(piece["x"]) * size.x + float(piece["vx"]) * t * drag,
			float(piece["y"]) * size.y + float(piece["vy"]) * t + 0.5 * GRAVITY * t * t)
		var angle: float = float(piece["angle"]) + float(piece["spin"]) * t
		var w: float = piece["w"]
		var h: float = float(piece["h"]) * absf(cos(angle * 1.7))
		draw_set_transform(pos, angle)
		draw_rect(Rect2(-w * 0.5, -h * 0.5, w, maxf(h, 2.0)), Color(piece["color"] as Color, fade))
	draw_set_transform(Vector2.ZERO)
