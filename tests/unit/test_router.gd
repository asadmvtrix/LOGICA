extends "res://tests/test_case.gd"

var router: Router
var events: Array = []


func before_each() -> void:
	router = Router.new(Routes.TABS, Routes.HOME)
	router.route_changed.connect(func(route: StringName, direction: int) -> void: events.append([route, direction]))


func after_each() -> void:
	# The connected lambda references this test case; drop the router to break the cycle.
	router = null


func test_first_tab_selection_emits_replace() -> void:
	router.select_tab(Routes.HOME)
	assert_eq(router.current(), Routes.HOME)
	assert_eq(events, [[Routes.HOME, Router.Direction.REPLACE]])


func test_selecting_current_tab_again_does_nothing() -> void:
	router.select_tab(Routes.HOME)
	router.select_tab(Routes.HOME)
	assert_eq(events.size(), 1)


func test_push_and_back() -> void:
	router.select_tab(Routes.HOME)
	router.push(Routes.TRAINING)
	assert_eq(router.current(), Routes.TRAINING)
	assert_eq(router.active_tab(), Routes.HOME)
	assert_eq(router.depth(), 2)
	assert_true(router.back())
	assert_eq(router.current(), Routes.HOME)
	assert_eq(events.back(), [Routes.HOME, Router.Direction.BACK])


func test_pushing_a_tab_switches_tabs() -> void:
	router.select_tab(Routes.HOME)
	router.push(Routes.JOURNEY)
	assert_eq(router.current(), Routes.JOURNEY)
	assert_eq(router.depth(), 1)


func test_selecting_tab_clears_pushed_routes() -> void:
	router.select_tab(Routes.HOME)
	router.push(Routes.CHALLENGES)
	router.select_tab(Routes.SETTINGS)
	assert_eq(router.depth(), 1)
	assert_eq(router.current(), Routes.SETTINGS)


func test_back_from_other_tab_returns_home() -> void:
	router.select_tab(Routes.STATISTICS)
	assert_true(router.back())
	assert_eq(router.current(), Routes.HOME)


func test_back_at_home_root_returns_false() -> void:
	router.select_tab(Routes.HOME)
	assert_false(router.back())
	assert_eq(router.current(), Routes.HOME)


func test_push_carries_params_and_back_restores() -> void:
	router.select_tab(Routes.HOME)
	router.push(Routes.LESSON, &"tango")
	assert_eq(router.current_params(), &"tango")
	router.push(Routes.PLAY, "first")
	router.replace(Routes.PLAY, "second")
	assert_eq(router.depth(), 3)
	assert_eq(router.current_params(), "second")
	assert_true(router.back())
	assert_eq(router.current(), Routes.LESSON)
	assert_eq(router.current_params(), &"tango")


func test_unknown_tab_is_rejected() -> void:
	router.select_tab(Routes.TRAINING)
	assert_eq(router.depth(), 0)
	assert_eq(events.size(), 0)
