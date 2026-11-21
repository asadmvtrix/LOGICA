# Test Report

## 2026-11-21: foundation (local checks only)

| Check | Result |
|---|---|
| `bash -n` syntax check of the three CI scripts | Pass |
| Workflow YAML parses (PyYAML); triggers `push`, `pull_request`, `workflow_dispatch`; 15 steps | Pass |
| Godot 4.7.2 release assets exist; SHA-512 values copied from the official `SHA512-SUMS.txt` | Pass |
| Template archive contains `android_debug.apk`, `android_release.apk`, `version.txt` at the extracted paths | Pass (archive index read remotely) |
| `build-tools;36.0.0` exists in Google's SDK repository | Pass |
| Godot import, headless smoke run, APK export, `apksigner verify` | **Not run**: these happen on the first GitHub Actions run |

No game tests exist yet because no gameplay exists.
