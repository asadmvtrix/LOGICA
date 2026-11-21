# Known Issues and Limitations

- **Pipeline not yet proven.** The workflow has never run on GitHub. The first run may expose problems that cannot be found without Godot (for example an export-preset option Godot rejects). Logs are uploaded as an artifact even on failure.
- **Scene and project files were written by hand**, not saved by the Godot editor. Godot will add `uid` values and may normalise the files when the project is first opened or imported; that is expected.
- **Debug keystore rotation.** The CI debug key is cached; if GitHub evicts the cache (7 days unused), a new key is generated and an installed debug build must be uninstalled before installing the new one. Fix later by storing a fixed debug keystore as a repository secret.
- **First build is slow.** The export template archive is about 1.3 GB; it is downloaded once and then cached.
- **Placeholder identity.** Package name `dev.logica.puzzles` and the icon are placeholders.
- **Release builds are not configured** (no release keystore, no AAB export).
