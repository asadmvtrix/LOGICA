extends "res://tests/test_case.gd"


func test_long_date_format() -> void:
	var date := {"year": 2026, "month": 11, "day": 21, "weekday": 6}
	assert_eq(DateFormat.long_date(date), "Saturday, 21 November")


func test_safe_area_without_cutouts_has_no_margins() -> void:
	var margins := SafeAreaContainer.compute_margins(Rect2i(0, 0, 1080, 2400), Vector2i(1080, 2400), Vector2(1080, 2400))
	assert_eq(margins, Vector4.ZERO)


func test_safe_area_scales_cutouts_into_viewport_space() -> void:
	# Window 540x1200 shown in a 1080x2400 viewport: margins double.
	var margins := SafeAreaContainer.compute_margins(Rect2i(0, 40, 540, 1140), Vector2i(540, 1200), Vector2(1080, 2400))
	assert_eq(margins, Vector4(0, 80, 0, 40))


func test_safe_area_unavailable_returns_zero() -> void:
	var margins := SafeAreaContainer.compute_margins(Rect2i(), Vector2i(1080, 1920), Vector2(1080, 1920))
	assert_eq(margins, Vector4.ZERO)
