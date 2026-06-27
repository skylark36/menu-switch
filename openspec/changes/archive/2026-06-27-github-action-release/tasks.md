## 1. Workflow Configuration

- [x] 1.1 Create the workflow file directory and release configuration file at `.github/workflows/release.yml`
- [x] 1.2 Define triggers for version tags matching the wildcard pattern `v*`

## 2. Build and Package Logic

- [x] 2.1 Configure workflow steps to run on `macos-latest` to check out repository code
- [x] 2.2 Configure execution permissions and run the package script `./build.sh`
- [x] 2.3 Add step to compress the output `build/MenuSwitch.app` folder into `build/MenuSwitch.zip`

## 3. Release Delivery

- [x] 3.1 Configure `softprops/action-gh-release@v1` to draft the release and upload the `build/MenuSwitch.zip` asset
