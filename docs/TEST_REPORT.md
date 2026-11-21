# Test Report

Tests run in CI with `godot --headless --path . --script res://tests/run_tests.gd`. The step fails if any test fails, if no tests are found, or if the log contains a GDScript runtime error (the log check is needed because a test that crashes would otherwise only abort silently).

## 2026-11-21: 0.3.0 (all four modes, hints, progression, redesign)

CI run [44936997740](https://github.com/asadmvtrix/LOGICA/actions/runs/44936997740): **73 tests, 0 failed**, smoke run passed, APK exported and signature verified.

| Suite | Tests | Covers |
|---|---|---|
| `test_queens` | 9 | Attack rules; generated puzzles have exactly one solution (exhaustive solver) that matches the stored one; logic solves within its level; determinism; each region holds one queen; undo/redo/reset/save; drag batching; correction hint for a wrong queen; solving the whole puzzle with hints alone |
| `test_tango` | 7 | Three-in-a-row and edge conflicts; random grids valid; uniqueness and logic solvability at all four levels; determinism; pair explanation; givens locked; solving with hints alone |
| `test_sudoku` | 8 | Units/peers; duplicate conflicts; random grid valid; uniqueness and logic solvability; harder ceiling; entry clears peer notes in one undo step; correction for a wrong digit; solving with hints alone |
| `test_shikaku` | 5 | Uniqueness and full coverage; solution satisfies rules; drawing over a rectangle replaces it, tap removes, undo restores; correction for a wrong rectangle; solving with hints alone |
| `test_progress_service` | 6 | Journey advance and persistence; new best; daily streak; session round trip and clearing on solve; challenge goals; corrupt file |
| `test_router` | 9 | Previous cases plus route parameters, `replace` and back |
| `test_settings_service` | 6 | Previous cases plus haptics and timer flags |
| `test_design_tokens` | 7 | Previous cases plus distinct legible mode colours, bundled fonts load, all theme variations |
| `test_app_shell` | 7 | Every tab and pushed section; lessons for every mode; Play screen generates, shows and applies a hint, pauses, saves the session on leaving; every mode's board builds |
| `test_json_file_store`, `test_utilities` | 9 | Unchanged |

"Solving with hints alone" repeatedly applies Reveal hints from an empty board and requires: a hint is always available, each has an explanation, Explain is at least as detailed, no hint ever places a wrong value (mistakes stay 0), the puzzle ends solved, and no hint is offered afterwards.

Visual check: 17 screenshots rendered in CI (`logica-screenshots-8`), including each mode in play and with Explain open. The first render showed cards collapsing on Home, Journey, Daily, Training and Challenges; fixed in 0b00ec7 and verified in the second render.

Not yet verified on a device: 0.3.0.

## 2026-11-21: Phase 1

CI run [44928651552](https://github.com/asadmvtrix/LOGICA/actions/runs/44928651552): **31 tests, 0 failed**. Smoke run passed. APK exported and verified (APK Signature Scheme v2 and v3).

| Suite | Tests | Covers |
|---|---|---|
| `test_router` | 8 | Tab selection, push/back, tab switching clears stack, back to Home, back at root, unknown tab rejected |
| `test_json_file_store` | 5 | Missing file, round trip, temp file removed, backup kept, corrupt main falls back to backup, corrupt without backup |
| `test_settings_service` | 5 | Defaults, persistence and reload, change signal once, wrong value type ignored, missing data section |
| `test_design_tokens` | 5 | Text contrast (AAA/AA), spacing scale order, touch targets, every theme variation defined |
| `test_utilities` | 4 | Date formatting, safe-area margin conversion (no cutout, scaled cutout, unavailable) |
| `test_app_shell` | 4 | Boots the real app scene; every tab shows its screen and highlights its tab; Training/Challenges push and return; tab-bar tap navigates |

Expected log lines during tests: `ERROR: Unknown tab: training` (from the rejection test) and a settings warning (from the missing-data test).

Visual check: all seven screens were rendered under a virtual display in CI (`logica-screenshots-<run>` artifact) and reviewed. They show the intended layout. CI renders with a fallback Linux font; devices use Roboto.

Not yet verified on a device: Phase 1 build (navigation feel, Android back gesture, safe area on a phone with a cutout).

## 2026-11-21: Phase 0

Local checks (script syntax, workflow YAML, release checksums, template paths) passed; CI run [#1](https://github.com/asadmvtrix/LOGICA/actions/runs/44925154328) built the first APK, which the owner installed and launched successfully.
