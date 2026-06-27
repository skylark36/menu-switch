# Automated Release Delivery

TBD: Spec for Automated Release Delivery.

## Requirements

### Requirement: Compile and Package on Tag Trigger
The GitHub Actions workflow SHALL automatically trigger when a tag matching the version pattern `v*` is pushed. It SHALL execute on a macOS runner, check out the repository, run the compilation build script `./build.sh`, and successfully package the compiled `MenuSwitch.app` bundle inside the build folder.

#### Scenario: Pushing a version tag triggers macOS compile build
- **WHEN** the user pushes a version tag like `v1.0.0` to GitHub
- **THEN** the workflow starts on a macOS runner, pulls the repository code, executes `./build.sh`, and creates `build/MenuSwitch.app` with compiled icns assets

### Requirement: Create and Upload Release Artifacts
The workflow SHALL compress the packaged `MenuSwitch.app` bundle into a `.zip` archive to preserve macOS bundle directory permissions. It SHALL then create a new GitHub Release corresponding to the pushed tag and upload the compressed zip archive as a release asset.

#### Scenario: Zipping and uploading bundle artifact to GitHub Release
- **WHEN** the compilation build step completes successfully on the runner
- **THEN** the workflow creates a zip archive of `build/MenuSwitch.app`, drafts a GitHub Release for the pushed tag, and uploads the zip asset to the release
