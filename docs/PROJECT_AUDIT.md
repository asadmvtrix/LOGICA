# Project Audit (Phase 0)

Date: 2026-11-21

## Repository state before this work

- No LOGICA repository, files, scenes or scripts existed on this machine. Searched `d:\Asad\Projects` and `d:\Asad`.
- The open workspace `d:\Asad\Projects\APK-Analysis` holds unrelated analysis of a third-party game. LOGICA was created in a separate folder, `d:\Asad\Projects\LOGICA`, so that no third-party material is mixed into this project.
- Nothing existing was modified, overwritten or deleted.

## Local environment

| Tool | Status |
|---|---|
| OS | Windows 10/11 (build 26300) |
| Git | 2.54.0 (installed) |
| GitHub CLI (`gh`) | Not installed (not required) |
| Python | 3.12 (used only for local file checks) |
| Godot, Unity, Java, Android SDK | Not installed, and intentionally not installed (cloud-only build policy) |

## Engine decision

The original directive specified Unity 6 and C#. That was superseded by the approved cloud-build approach: **Godot 4 with GDScript**, built only on GitHub Actions.

Reasons Godot fits the cloud-only constraint: the editor is a single ~78 MB download, needs no licence activation on CI runners, and can export Android APKs headless from official prebuilt templates without Gradle or the NDK.

## Toolchain research (verified against upstream sources)

- Latest Godot stable: **4.7.2** (released 2026-08-18). Release assets and SHA-512 sums were checked on GitHub.
- Godot 4.7 Android export docs: OpenJDK 17 recommended. NDK and CMake are needed only for Gradle builds, which this project does not use.
- Godot 4.7.2 exporter source (`platform/android/export/export_plugin.cpp`): default min SDK 24, target SDK 36. `apksigner` is taken from the `build-tools` directory matching the target SDK, so build-tools **36.0.0** is pinned. `JAVA_HOME` and `ANDROID_HOME` are read as defaults. Debug keystore env vars `GODOT_ANDROID_KEYSTORE_DEBUG_PATH/USER/PASSWORD` are supported.
- Export template archive: confirmed it contains `templates/android_debug.apk`, `templates/android_release.apk` and `templates/version.txt` (read via HTTP range request on the archive index; the 1.28 GB file was not downloaded).
- GitHub Actions used at their latest majors: `actions/checkout@v7`, `actions/setup-java@v6`, `actions/cache@v6`, `actions/upload-artifact@v7`, `android-actions/setup-android@v4`.

## Missing prerequisites (owner action)

- A GitHub repository and a push from this folder (see README).
- GitHub Actions enabled on that repository.
