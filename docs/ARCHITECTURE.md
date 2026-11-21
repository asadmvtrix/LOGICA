# Architecture

Status: foundation only. Gameplay architecture is designed in Phase 1 and needs approval before implementation.

## Engine and runtime

- Godot 4.7.2, GDScript, GL Compatibility renderer (widest Android GPU support, low overhead for a 2D UI game).
- Portrait, 1080×1920 reference viewport, `canvas_items` stretch with `expand` aspect, so layouts adapt to any phone ratio.
- ETC2/ASTC texture import enabled (required for Android export).

## Build architecture

- Source of truth: Git repository. Builds are produced only by GitHub Actions (`.github/workflows/android-debug.yml`).
- Non-Gradle export: Godot repackages its official prebuilt `android_debug.apk` template with the project PCK, then signs it with `apksigner`. No Gradle, NDK or custom Android code is involved.
- Toolchain versions are pinned in the workflow `env:` block; downloads are verified with SHA-512.

## Planned source layout (proposal for Phase 1)

```
scenes/          Scenes, grouped by feature (shell/, home/, gameplay/<mode>/ …)
scripts/
  core/          Composition root, service registry, app lifecycle
  design_system/ Tokens (colours, type, spacing, motion) and the generated Theme
  navigation/    Screen router
  gameplay/      Shared board framework + one folder per mode (queens/, tango/, shikaku/, sudoku/)
  hints/         Hint interfaces and presentation
  progression/   Journey, daily, training, challenges, statistics
  persistence/   Versioned save data, atomic writes, recovery
tests/           Headless GDScript tests run in CI
```

Open decisions for Phase 1: test framework (a small in-repo runner vs. the GUT add-on, which is MIT-licensed and free), and whether the composition root is an autoload (Godot's standard mechanism) or a root scene node.
