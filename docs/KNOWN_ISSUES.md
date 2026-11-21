# Known Issues and Limitations

- **No local engine.** Code is compiled and tested only in CI; each check takes about 1.5 minutes per push.
- **Runtime errors inside a test are caught by the log check, not by the runner itself.** A crashing test is reported by `check_godot_log.sh` (CI fails), but the runner's own count may still say "0 failed".
- **Fonts.** The system sans-serif font is used (Roboto on Android). No custom typeface is bundled yet; CI screenshots use a different fallback font than devices.
- **Safe area and back gesture** are implemented but not yet checked on a physical device with a display cutout.
- **Debug keystore rotation.** The CI debug key is cached; if GitHub evicts the cache (7 days unused), a new key is generated and an installed debug build must be uninstalled before installing the new one. Fix later with a fixed debug keystore stored as a repository secret.
- **`sdkmanager` deprecation warning** in CI logs (Google is moving to a new Android CLI). Harmless for now; revisit if `android-actions/setup-android` changes.
- **First build after a Godot version change is slow** (about 1.3 GB template download, then cached).
- **Release builds are not configured** (no release keystore, no AAB export). The icon is a placeholder.
