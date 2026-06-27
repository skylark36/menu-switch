## Context

To automate building and publishing `MenuSwitch` macOS releases, a GitHub Actions workflow must be configured. Since the project uses Swift Package Manager and packages native macOS targets, the workflow must run on a macOS runner (`macos-latest` or `macos-14`) to access the native Swift compiler and Xcode CLI tools.

## Goals / Non-Goals

**Goals:**
- Automate release compilation and packaging using the existing `./build.sh` script.
- Automatically create a GitHub Release when tags matching `v*` are pushed.
- Zip the compiled `.app` bundle to preserve macOS directory flags and permissions, and upload the zip archive to the created release.

**Non-Goals:**
- Distributing to the Mac App Store or handling developer signature notarization (ad-hoc code signing is sufficient for release packaging).
- Compiling targeting iOS, Windows, or Linux platforms.

## Decisions

- **Runner Environment:** Use `macos-latest` to ensure compatibility with Swift Package Manager and standard macOS CLI build tools.
- **Archive Format:** Use `zip -r` to archive the compiled `.app` directory. Compared to DMGs or raw tarballs, zip is lightweight, standard on macOS, and successfully retains application execution permissions.
- **GitHub Release action:** Leverage standard `softprops/action-gh-release@v1` to handle tag matching, drafting releases, and asset uploads automatically.

## Risks / Trade-offs

- **[Risk]** Running `sips` / `iconutil` inside `./build.sh` on CI fails due to graphic context lack.
  - **Mitigation** -> Standard Xcode command-line utilities (`sips` and `iconutil`) do not require visual window frames and run perfectly inside headless SSH/CI runner shells.
