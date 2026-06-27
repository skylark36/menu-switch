## Why

Currently, compiling and packaging the native macOS `MenuSwitch.app` bundle requires manual execution of the local `build.sh` script. Introducing a GitHub Actions CI workflow triggered by version tags automates release builds and deliveries, ensuring consistency and ease of deployment.

## What Changes

- Add a GitHub Actions release workflow configured to execute on macOS runners.
- Automate Swift compilation and packaging of `MenuSwitch.app` (including AppIcon compilation).
- Archive the `.app` bundle into a `.zip` artifact to preserve macOS permissions.
- Create a GitHub Release corresponding to the pushed tag and upload the packaged zip archive as a release asset.

## Capabilities

### New Capabilities
- `automated-release-delivery`: Automatically compile, package, and publish MenuSwitch releases when version tags are pushed to GitHub.

### Modified Capabilities
