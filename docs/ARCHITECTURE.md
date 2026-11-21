# Architecture

## Engine and runtime

- Godot 4.7.2, GDScript with static typing, GL Compatibility renderer (widest Android GPU support, low overhead for a 2D UI game).
- Portrait, 1080 × 1920 reference viewport, `canvas_items` stretch with `expand` aspect, so layouts adapt to any phone ratio. Safe-area margins are applied at runtime.
- Package `com.asadmvtrix.logica`.

## Source layout

```
scenes/app/app.tscn          Main scene (root Control with the composition root script)
scripts/
  core/         app.gd (composition root), AppContext, SafeAreaContainer
  design_system/ DesignTokens, ThemeFactory, VectorIcons
  navigation/   Routes, Router (state), ScreenHost (presentation)
  persistence/  JsonFileStore (atomic writes, backup recovery)
  settings/     SettingsService (versioned preferences)
  screens/      Screen base class and the section screens
  ui/           Reusable components
  utilities/    DateFormat
tests/
  run_tests.gd               Headless runner
  test_case.gd               Assertion base
  unit/test_*.gd             Unit and integration tests
  capture_screenshots.gd     Renders every screen to PNG (CI review aid)
```

Planned for later phases: `scripts/gameplay/<mode>/`, `scripts/hints/`, `scripts/progression/`.

## Composition and dependencies

- `scripts/core/app.gd` is the only composition root. It creates `SettingsService` (with a `JsonFileStore`), `Router` and the `Theme`, builds the shell and connects signals.
- Services reach screens through an `AppContext` passed to `Screen.setup()`. There are no autoloads or global singletons.
- `Router` is pure state (no nodes) and is unit-tested on its own. `ScreenHost` only presents screens, and `BottomNav` only reports taps. The active tab always comes from router state.

## Navigation model

- Tabs: Home, Journey, Daily, Stats, Settings. Training and Challenges are pushed from Home with a back button.
- One stack whose first entry is the active tab. `select_tab` resets the stack; `push` adds to it; `back` pops, or returns to Home from another tab, or reports that there is nowhere to go.
- The Android back gesture (`NOTIFICATION_WM_GO_BACK_REQUEST`, with `quit_on_go_back=false`) and Escape on desktop both call `back`; at the Home root the app quits.

## Persistence

- `JsonFileStore` writes to `<file>.tmp`, moves the previous file to `<file>.bak`, then renames the temp file into place. Reads fall back to the backup if the main file is missing or invalid.
- Save files are versioned envelopes `{ "version": n, "data": {...} }`. Unknown or wrongly typed values are ignored and defaults are kept.
- Current files: `user://settings.json`.

## Screens

Screens are built in code from components (`Screen` subclasses), so all styling flows through the design system and there are no hand-maintained layout files to drift. Sections without content yet (Journey, Daily, Training, Challenges, Statistics) share `empty_section_screen.gd`, which shows an honest empty state.

## Build and test pipeline

GitHub Actions (`.github/workflows/android-debug.yml`): import → tests → headless smoke run → screenshots under a virtual display → debug APK export → signature verification → artifacts. Details in the README.
