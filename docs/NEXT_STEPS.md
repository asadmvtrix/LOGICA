# Next Steps

1. **Owner:** install the Phase 1 APK and check: tab bar, Home rows, back arrow and Android back gesture, Reduce motion switch (should persist after restarting the app), and that nothing sits under the camera cutout or system bars.
2. **Phase 2: core gameplay.**
   - Shared board framework: grid model, cell selection, a command-based move history (undo/redo/reset), and a board view drawn with vector primitives using design tokens.
   - Queens: puzzle data model with regions, rule validation (row, column, region and diagonal-adjacency constraints), conflict highlighting, completion detection, a small set of hand-verified puzzles, plus a solver used for tests and uniqueness checks.
   - A gameplay screen reachable from Journey (temporary entry until progression exists), with pause and resume.
   - Tests for the validator, solver, move history and puzzle data.
3. Then Phase 3 (Reveal and Tactical hints for Queens), Phase 4 (Tango, Shikaku, Sudoku), Phase 5 (progression and statistics).

Decision needed before Phase 2: the Queens rule set. Proposed: one queen per row, column and colour region, with no two queens touching, diagonals included (the common rule set for region-based queens puzzles).
