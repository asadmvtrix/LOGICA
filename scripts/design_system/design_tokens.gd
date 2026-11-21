class_name DesignTokens
extends RefCounted
## Single source of truth for visual constants.
## Sizes are in reference-viewport pixels (1080 x 1920 portrait); the stretch
## mode scales them to each device. Roughly 2.6 px = 1 dp on a typical phone.

# --- Colour: surfaces and ink ---------------------------------------------
const COLOR_BACKGROUND := Color("#F4F1EB")
const COLOR_SURFACE := Color("#FBF9F5")
const COLOR_SURFACE_SUNKEN := Color("#E9E4DA")
const COLOR_INK := Color("#22201D")
const COLOR_INK_SECONDARY := Color("#69645C")
const COLOR_INK_MUTED := Color("#A39D92")
const COLOR_SEPARATOR := Color("#DCD6CB")
const COLOR_ACCENT := Color("#A84E2A")
const COLOR_ERROR := Color("#B3261E")
const COLOR_SUCCESS := Color("#4E7A4A")
const COLOR_SCRIM := Color(0.133, 0.125, 0.114, 0.55)

# --- Colour: puzzle modes (one identity colour each) -----------------------
const COLOR_MODE_QUEENS := Color("#A84E2A")
const COLOR_MODE_TANGO := Color("#2F6A6E")
const COLOR_MODE_SHIKAKU := Color("#9C7424")
const COLOR_MODE_SUDOKU := Color("#3D4C7A")

# --- Colour: board -----------------------------------------------------------
const COLOR_BOARD_LINE := Color("#CFC8BB")
const COLOR_BOARD_LINE_STRONG := Color("#22201D")
const COLOR_BOARD_SELECTED := Color("#E7D3C4")
const COLOR_BOARD_PEER := Color("#EFE9DF")
const COLOR_HINT_FOCUS := Color("#A84E2A")
const COLOR_HINT_RELATED := Color(0.659, 0.306, 0.165, 0.14)
const COLOR_BOARD_GIVEN := Color("#EDE8DF")
const COLOR_CONFLICT_FILL := Color(0.702, 0.149, 0.118, 0.14)
const COLOR_SUN := Color("#D08A1E")
const COLOR_MOON := Color("#46588A")
## Muted fills for Queens regions; names are used in hint explanations.
const REGION_COLORS: Array[Color] = [
	Color("#E9D3BF"), Color("#CBDCC6"), Color("#D5D1E6"), Color("#F0DCAA"), Color("#C4DBE4"),
	Color("#E8C6C2"), Color("#DCE5BE"), Color("#D8CDBF"), Color("#C3CFDA"), Color("#EAD9E3"),
]
const REGION_NAMES: Array[String] = [
	"sand", "sage", "lavender", "wheat", "mist", "rose", "pistachio", "taupe", "slate", "blush",
]

# --- Typography -----------------------------------------------------------
const FONT_UI_PATH := "res://assets/fonts/Inter.ttf"
const FONT_DISPLAY_PATH := "res://assets/fonts/Fraunces.ttf"
const FONT_WEIGHT_REGULAR := 400
const FONT_WEIGHT_MEDIUM := 500
const FONT_WEIGHT_SEMIBOLD := 600

const FONT_SIZE_CAPTION := 30
const FONT_SIZE_NAV := 31
const FONT_SIZE_BODY_SMALL := 36
const FONT_SIZE_BODY := 42
const FONT_SIZE_TITLE := 52
const FONT_SIZE_HEADLINE := 72
const FONT_SIZE_DISPLAY := 104
const FONT_SIZE_NUMERAL := 64
const FONT_SIZE_BOARD_DIGIT := 56
const CAPTION_TRACKING := 3

# --- Spacing --------------------------------------------------------------
const SPACE_XXS := 6
const SPACE_XS := 12
const SPACE_S := 24
const SPACE_M := 36
const SPACE_L := 48
const SPACE_XL := 72
const SPACE_XXL := 96
const PAGE_MARGIN := 60

# --- Shape ----------------------------------------------------------------
const RADIUS_S := 8
const RADIUS_M := 16
const HAIRLINE := 2
const BOARD_LINE := 2
const BOARD_LINE_STRONG := 5

# --- Component geometry ---------------------------------------------------
const TOUCH_TARGET_MIN := 132
const ROW_HEIGHT := 150
const ROW_HEIGHT_TALL := 186
const HEADER_HEIGHT := 168
const NAV_HEIGHT := 168
const NAV_INDICATOR_SIZE := Vector2(56, 6)
const CHEVRON_SIZE := 22.0
const ICON_STROKE := 4.0
const TOGGLE_SIZE := Vector2(110, 62)
const TOGGLE_INSET := 6.0
const TILE_PREVIEW_SIZE := 150.0
const TOOL_BUTTON_HEIGHT := 150
const SHEET_MAX_HEIGHT := 760

# --- Motion (seconds) -----------------------------------------------------
const MOTION_FAST := 0.12
const MOTION_STANDARD := 0.2
const MOTION_SLOW := 0.32
const MOTION_SCREEN_OFFSET := 48.0
const MOTION_CELL_STAGGER := 0.012

# --- Interactive states ---------------------------------------------------
const DISABLED_ALPHA := 0.4


static func mode_color(mode_id: StringName) -> Color:
	match mode_id:
		&"queens":
			return COLOR_MODE_QUEENS
		&"tango":
			return COLOR_MODE_TANGO
		&"shikaku":
			return COLOR_MODE_SHIKAKU
		&"sudoku":
			return COLOR_MODE_SUDOKU
	return COLOR_ACCENT
