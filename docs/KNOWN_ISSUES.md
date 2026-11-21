# Known Issues and Limitations

- **No local engine.** Code is compiled and tested only in CI.
- **Runtime errors inside a test are caught by the log check, not by the runner itself.** A crashing test is reported by `check_godot_log.sh` (CI fails), but the runner's own count may still say "0 failed".
- **Generation time.** Puzzles are generated on the device in a background thread. Expert Queens (9 × 9) and Expert Sudoku can take a few seconds on slower phones; a "Preparing" message shows meanwhile. Puzzles are not cached between sessions, apart from the in-progress one (regenerated from its key on resume).
- **Cross-version determinism.** Puzzle keys rely on Godot's string hash and random number generator. They are stable across devices on the same engine version; an engine upgrade could change which puzzle a key produces (in-progress sessions would then be discarded safely, because saved state that does not fit is rejected).
- **Hints follow the logic engine's technique order**, so the suggested step is always sound but not necessarily the one a strong solver would spot first.
- **Shikaku drawing** uses corner-to-corner drags; there is no long-press editing of an existing rectangle (tap to remove, then redraw).
- **Safe area, back gesture and haptics** are implemented but not yet checked on a physical device with a display cutout.
- **Debug keystore rotation.** The CI debug key is cached; if GitHub evicts the cache (7 days unused), a new key is generated and an installed debug build must be uninstalled before installing the new one.
- **No audio.**
- **Release builds are not configured** (no release keystore, no AAB export). The icon is a placeholder.
