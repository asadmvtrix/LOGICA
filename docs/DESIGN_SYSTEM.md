# Design System

Source of truth: `scripts/design_system/design_tokens.gd`. The Godot `Theme` is generated from it by `scripts/design_system/theme_factory.gd`. Screens and components never hard-code colours or font sizes; they use tokens or theme type variations.

Sizes are in reference-viewport pixels (1080 × 1920 portrait, stretched to the device). About 2.6 px equals 1 dp on a typical phone.

## Principles

- Warm, quiet neutrals; one accent colour, used only for state (active tab, switch on, later: selection and hints).
- Hierarchy from type size and weight, not boxes. Lists are separated by hairlines, not cards.
- Generous page margins and a consistent spacing scale.
- No gradients, glass effects, neon colours or decorative icons. Icons are drawn as vectors only where they carry meaning (chevrons).
- Motion is short, interruptible and can be reduced by the player.

## Colour

| Token | Value | Use |
|---|---|---|
| `COLOR_BACKGROUND` | `#F4F1EB` | App background, tab bar |
| `COLOR_SURFACE` | `#FAF8F4` | Raised elements, switch knob |
| `COLOR_SURFACE_SUNKEN` | `#E9E4DA` | Pressed state |
| `COLOR_INK` | `#22201D` | Primary text and icons |
| `COLOR_INK_SECONDARY` | `#69645C` | Secondary text, captions |
| `COLOR_INK_MUTED` | `#A39D92` | Non-text affordances (chevrons) |
| `COLOR_SEPARATOR` | `#DCD6CB` | Hairlines, switch off track |
| `COLOR_ACCENT` | `#A84E2A` | Active and selected state |

Contrast is enforced by tests: primary text ≥ 7:1 (WCAG AAA) and secondary text ≥ 4.5:1 (AA) on the background and pressed surfaces.

## Typography

Fonts: system sans-serif (`Roboto` on Android) via `SystemFont`, so no font files are bundled yet.

| Role | Variation | Size | Weight |
|---|---|---|---|
| Wordmark | `WordmarkLabel` | 56 | 600, tracking 12 |
| Headline (screen titles) | `HeadlineLabel` | 64 | 500 |
| Title | `TitleLabel` | 50 | 500 |
| Body | default `Label` | 42 | 400 |
| Secondary | `SecondaryLabel` | 36 | 400 |
| Caption (section labels, uppercase) | `CaptionLabel` | 30 | 500 |
| Tab labels | `NavButton` / `NavButtonActive` | 30 | 500 |

## Spacing, shape, geometry

- Spacing scale: 6, 12, 24, 36, 48, 72, 96. Page margin 60.
- Radii: 8 (small), 16 (medium). Hairline: 2.
- Minimum touch target: 132 (about 50 dp). Rows 150 / 186 (with subtitle). Header and tab bar 168.

## Motion

| Token | Seconds | Use |
|---|---|---|
| `MOTION_FAST` | 0.12 | Switch knob, outgoing screen fade |
| `MOTION_STANDARD` | 0.20 | Incoming screen (fade plus 48 px slide) |
| `MOTION_SLOW` | 0.32 | Reserved for completion effects |

Forward navigation slides in from the right and back navigation from the left; tab changes only fade. With **Reduce motion** on, screens change instantly and switches jump.

## Interactive states

- Pressed: `COLOR_SURFACE_SUNKEN` fill with a 16 px radius. List rows extend the pressed fill 24 px beyond the text column, so text stays aligned to the page margin.
- Hover is drawn the same as normal (avoids hover states sticking on touch screens).
- Disabled: 40 % alpha.
- Active tab: ink-coloured label plus a 56 × 6 accent bar.

## Components (`scripts/ui/`)

`ListRow`, `ToggleRow`, `InfoRow`, `RowGroup`, `EmptyState`, `ScreenHeader`, `BackButton`, `BottomNav`, and `UiFactory` helpers (label, paragraph, caption, spacer, row text).
