# Test Report

Tests run in CI with `godot --headless --path . --script res://tests/run_tests.gd`. The step fails if any test fails, if no tests are found, or if the log contains a GDScript runtime error (the log check is needed because a test that crashes would otherwise only abort silently).

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
