class_name DesignTokens
extends RefCounted
## Single source of truth for visual constants.
## Sizes are in reference-viewport pixels (1080 x 1920 portrait); the stretch
## mode scales them to each device. Roughly 2.6 px = 1 dp on a typical phone.

# --- Colour ---------------------------------------------------------------
const COLOR_BACKGROUND := Color("#F4F1EB")
const COLOR_SURFACE := Color("#FAF8F4")
const COLOR_SURFACE_SUNKEN := Color("#E9E4DA")
const COLOR_INK := Color("#22201D")
const COLOR_INK_SECONDARY := Color("#69645C")
const COLOR_INK_MUTED := Color("#A39D92")
const COLOR_SEPARATOR := Color("#DCD6CB")
const COLOR_ACCENT := Color("#A84E2A")

# --- Typography -----------------------------------------------------------
const FONT_FAMILIES: Array[String] = ["Roboto", "Noto Sans", "sans-serif"]
const FONT_WEIGHT_REGULAR := 400
const FONT_WEIGHT_MEDIUM := 500
const FONT_WEIGHT_SEMIBOLD := 600

const FONT_SIZE_CAPTION := 30
const FONT_SIZE_NAV := 30
const FONT_SIZE_BODY_SMALL := 36
const FONT_SIZE_BODY := 42
const FONT_SIZE_TITLE := 50
const FONT_SIZE_HEADLINE := 64
const FONT_SIZE_WORDMARK := 56
const WORDMARK_TRACKING := 12

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

# --- Motion (seconds) -----------------------------------------------------
const MOTION_FAST := 0.12
const MOTION_STANDARD := 0.2
const MOTION_SLOW := 0.32
const MOTION_SCREEN_OFFSET := 48.0

# --- Interactive states ---------------------------------------------------
const DISABLED_ALPHA := 0.4
