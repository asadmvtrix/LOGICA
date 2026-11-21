# Architecture

## Engine and runtime

- Godot 4.7.2, GDScript with static typing, GL Compatibility renderer (widest Android GPU support, low overhead for a 2D UI game).
- Portrait, 1080 × 1920 reference viewport, `canvas_items` stretch with `expand` aspect, so layouts adapt to any phone ratio. Safe-area margins are applied at runtime.
- Package `com.asadmvtrix.logica`.

## Source layout

```
scenes/app/app.tscn          Main scene (root Control with the composition root script)
assets/fonts/                Inter and Fraunces variable fonts (SIL OFL, licences alongside)
scripts/
  core/          app.gd (composition root), AppContext, SafeAreaContainer
  design_system/ DesignTokens, ThemeFactory, VectorIcons
  navigation/    Routes, Router (state + route parameters), ScreenHost (presentation)
  persistence/   JsonFileStore (atomic writes, backup recovery)
  settings/      SettingsService (versioned preferences)
  gameplay/
    core/        PuzzleGame, MoveHistory, BoardView, SeededRandom, Difficulty, CellNames
    queens/ tango/ shikaku/ sudoku/
                 <Mode>Puzzle (model), <Mode>Rules (validator), <Mode>Solver (exhaustive,
                 uniqueness proofs), <Mode>Logic (human techniques), <Mode>Generator,
                 <Mode>Game (controller), <Mode>HintEngine, <Mode>BoardView
    puzzle_modes.gd  Registry: names, rules text, techniques, difficulty config, factories
  hints/         HintEngine, HintResult, HintStep, Deduction, HintPresentationController
  progression/   PuzzleLaunch, ProgressionCatalog (journey/daily/challenges/training), ProgressService
  screens/       Screen base class, section screens, GameplayScreen, LessonScreen
  ui/            Reusable components (rows, cards, tiles, tool buttons, overlays, previews)
  utilities/     DateFormat, TimeFormat
tests/
  run_tests.gd               Headless runner
  test_case.gd, hint_test_util.gd
  unit/test_*.gd             Unit and integration tests
  capture_screenshots.gd     Renders screens, including each mode in play, to PNG (CI review aid)
```

## Composition and dependencies

- `scripts/core/app.gd` is the only composition root. It creates `SettingsService` and `ProgressService` (each with its own `JsonFileStore`), the `Router` and the `Theme`, builds the shell and connects signals.
- Services reach screens through an `AppContext` passed to `Screen.setup()`. There are no autoloads or global singletons. Save paths are exported properties so tests use isolated files.
- `Router` is pure state (no nodes). Pushed routes carry a parameter: `PLAY` takes a `PuzzleLaunch`, `LESSON` a mode id. `replace()` swaps the top route (used for "next level").

## Puzzle model

- Player state lives in integer channels (`Array[PackedInt32Array]`, one value per cell). Queens: empty/mark/queen. Tango: empty/sun/moon. Shikaku: rectangle id per cell. Sudoku: digits plus a notes bitmask channel.
- `PuzzleGame.apply()` takes `[channel, index, value]` triples and records one undoable move; `begin_batch`/`end_batch` merge drags into a single step. Reset is itself an undoable move. `to_save`/`load_save` serialise channels, time, hint counts and mistakes; loading rejects data that would change givens.
- Generation is deterministic: `SeededRandom.create(key)` seeds a RandomNumberGenerator from the puzzle key (`journey/queens/12`, `daily/2026-11-21/tango`, `challenge/purist`, `training/sudoku`). Sessions store only the key and player state; the puzzle is regenerated on resume.

## Puzzle quality

Each generator accepts a puzzle only if the mode's logic engine solves it completely using techniques up to the difficulty's ceiling. Every logic step is a sound deduction, so solving by logic alone also proves the solution is unique. Tests independently confirm uniqueness with the exhaustive solvers.

| Mode | Generation | Difficulty |
|---|---|---|
| Queens | Random non-touching queens, regions grown from them by random flood fill, exactly-one-solution check, logic check | Board 6–9 and technique ceiling 2–4 |
| Tango | Random valid 6 × 6 grid; givens removed in random order, an = / × edge tried when a removal breaks solvability | Technique ceiling 1–4 |
| Shikaku | Random rectangle partition, one number per rectangle | Board 5–8, max area 6–12, ceiling 2–3 |
| Sudoku | Random full grid; clues removed in symmetric pairs | Ceiling 1–4, with a minimum hardest technique for harder levels |

## Hints

- `HintEngine` provides both contracts the brief names: `reveal()` (the `IRevealHintEngine` role) and `tactical()` (the `ITacticalHintEngine` role). GDScript has no interfaces, so `HintEngine` is the shared base (`IHintEngine`) and each mode subclasses it.
- Order of checks: already solved (no hint) → correction (a player entry that disagrees with the unique solution is pointed out and removed) → a chain of `Deduction`s from the current position ending in the first placement.
- `HintResult` holds title, `HintStep`s (text plus focus and related cells) and the changes to apply. Reveal shows the deciding step; Explain shows every step of the chain. When the logic finds nothing, the result is `available = false` with a reason; no guessing.
- `HintPresentationController` is the bottom sheet: steps one at a time, highlights cells on the board, Apply/Close.

## Navigation model

- Tabs: Home, Journey, Daily, Stats, Settings. Training, Lesson, Challenges and Play are pushed with a back button. The tab bar is hidden during Play.
- The Android back gesture and Escape call `back`; during Play they first close an open hint sheet.

## Persistence

- `JsonFileStore` writes to `<file>.tmp`, moves the previous file to `<file>.bak`, then renames the temp file into place. Reads fall back to the backup if the main file is missing or invalid.
- Versioned envelopes `{ "version": n, "data": {...} }`. Files: `user://settings.json`, `user://progress.json` (journey, records, stats, daily, challenges, current session).
- The session autosaves every few seconds after a change, on pause, when the app loses focus and when leaving the puzzle.

## Build and test pipeline

GitHub Actions (`.github/workflows/android-debug.yml`): import → tests → headless smoke run → screenshots under a virtual display → debug APK export → signature verification → artifacts. Details in the README.
