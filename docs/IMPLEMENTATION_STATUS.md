# Implementation Status

Version 0.4.0.

| Area | Status |
|---|---|
| Phase 0: foundation and cloud APK pipeline | Done; APK installed on the owner's device |
| Phase 1: design tokens, theme, components, navigation, settings | Done, tested |
| Design refresh | Done: bundled Fraunces (display) and Inter (interface), a colour per mode, drawn board previews, card-based Home, Journey grid, Daily cards |
| Game feel (0.4.0) | Done: Queens auto-cross with outward sweep; piece pop, conflict shake, row / column / region / box / rectangle flash, solve ripple and confetti; tiled rounded boards (merged Queens regions, Tango tiles, Shikaku blocks); mode-tinted play screen; icon tab bar; filled mode cards and dark daily card; press-scale buttons; staggered screen entrance; hint sheet slide-up; Sudoku pad disables digits placed nine times |
| Gameplay framework | Done: channels, undo/redo, batched drags, undoable reset, save/load, board view with touch, drag, hint highlights and completion wave |
| Queens | Done: model, rules, exhaustive solver, 5-technique logic, generator, controller, hints, board |
| Tango | Done: model, rules, solver, 6-technique logic (including line analysis and contradiction), generator with = / × clues, controller, hints, board |
| Shikaku | Done: model, rules, solver, 4-technique logic, generator, drag-to-draw controller, hints, board |
| Sudoku | Done: model, rules, solver, singles / pointing / claiming / pairs, generator, notes, number pad, hints, board |
| Hints (Reveal and Explain) | Done for all modes; unlimited; corrections for wrong entries; explicit "no hint" result |
| Gameplay screen | Done: background generation, timer, pause, start over, completion summary, next level, autosave and resume |
| Journey | Done: 60 levels per mode in four difficulty bands, unlocked in order |
| Daily | Done: four puzzles per date from the date key; difficulty by weekday; streak |
| Training | Done: per-mode lesson (rules and techniques) and a practice puzzle |
| Challenges | Done: eight fixed challenges with time / no-hint / no-mistake goals |
| Statistics | Done: totals, per-mode solved, best time per difficulty, journey position, hints used |
| Settings | Done: timer, haptics, auto-cross, reduce motion |
| Audio | Not started |
| Device checks: back gesture, safe area with cutout, haptics | Pending on a real device |
| Release signing and store build | Not started (debug APK only) |
