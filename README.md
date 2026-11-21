# LOGICA

An original collection of logic puzzles for Android, built with **Godot 4.7.2** and **GDScript**.

This repository currently contains only the project foundation and a cloud APK pipeline. There is no gameplay yet. See `docs/IMPLEMENTATION_STATUS.md`.

## Local machine requirements

You need only Cursor (or any editor), Git and a web browser. You do not need to install Godot, Java, the Android SDK or Android Studio locally. All Android builds run on GitHub-hosted runners.

## Repository layout

```
project.godot              Godot project settings (portrait, GL Compatibility renderer)
export_presets.cfg         Android export preset "Android Debug"
icon.svg                   Original placeholder app icon
scenes/boot/boot.tscn      Foundation boot scene (replaced in Phase 1)
scripts/boot/boot.gd       Boot script; prints "LOGICA boot ok" for CI smoke checks
.github/workflows/android-debug.yml   Cloud build pipeline
.github/scripts/           Shell scripts used by the pipeline
docs/                      Audit, architecture, status, test and planning documents
```

## Cloud build pipeline

Workflow: `.github/workflows/android-debug.yml`, runner `ubuntu-24.04`.

| Step | What it does |
|---|---|
| JDK | Temurin 17 via `actions/setup-java` |
| Android SDK | `android-actions/setup-android`; installs `platform-tools` and `build-tools;36.0.0` |
| Godot | Downloads the Godot 4.7.2 Linux editor and export templates from the official GitHub release, checks pinned SHA-512 checksums, and keeps only the Android templates. Cached between runs. |
| Keystore | Generates a debug keystore (standard `android` debug password) and caches it so successive debug APKs share a signature |
| Import | `godot --headless --import` |
| Smoke run | Runs the boot scene headless and fails on GDScript errors or if `LOGICA boot ok` is missing |
| Export | `godot --headless --export-debug "Android Debug"` (non-Gradle export using the prebuilt template) |
| Verify | `apksigner verify` and SHA-256 of the APK |
| Artifacts | `logica-debug-apk-<run number>` (the APK) and `logica-build-logs-<run number>` (logs), kept 14 days |

Pinned versions are in the workflow `env:` block. To upgrade Godot, change `GODOT_VERSION` and both SHA-512 values (from the release's `SHA512-SUMS.txt`), and update `config/features` in `project.godot`.

APK contents: arm64-v8a and armeabi-v7a, package `dev.logica.puzzles` (placeholder; change it before any store release, because it cannot change after publishing).

## Connecting to GitHub (one-time)

1. Create an empty repository on GitHub (for example `LOGICA`). Do not add a README, licence or .gitignore there.
2. In this folder:
   ```bash
   git remote add origin https://github.com/<your-user>/LOGICA.git
   git push -u origin main
   ```
3. On GitHub, open **Settings → Actions → General** and make sure Actions are allowed for the repository.

## Triggering a build

Any of these starts the workflow:

- Push a commit to `main`.
- Open or update a pull request.
- Manually: **Actions** tab → **Android debug APK** → **Run workflow** → choose `main` → **Run workflow**.

The first run downloads about 1.3 GB of export templates and takes longer. Later runs use the cache.

## Downloading the APK

1. Open the **Actions** tab and click the finished run (green check).
2. Scroll to **Artifacts** at the bottom of the run summary.
3. Download `logica-debug-apk-<number>`. GitHub delivers it as a `.zip` containing `logica-debug.apk`.
4. Copy the APK to an Android device (Android 7.0 / API 24 or newer), allow installs from that source, and install it.

If the run failed, download `logica-build-logs-<number>` for the import, smoke and export logs.

## Debug signing

Debug APKs are signed with a CI-generated debug key. It is cached, so updates normally install over each other. If the cache is evicted (after 7 days without use), a new key is created and Android will refuse to update: uninstall the old build first. Release signing is not configured yet.
