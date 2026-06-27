## 1. Project Scaffolding

- [x] 1.1 Create Swift Package Manager configuration (Package.swift)
- [x] 1.2 Create the main application entry point (Sources/App.swift)
- [x] 1.3 Create AppDelegate to manage NSStatusItem and NSPopover (Sources/Views/AppDelegate.swift)
- [x] 1.4 Create build and app-packaging script (build.sh)

## 2. Core Service Layers

- [x] 2.1 Implement SettingsManager to handle UserDefaults configuration persistence and SMAppService auto-launch (Sources/Services/SettingsManager.swift)
- [x] 2.2 Implement MihomoAPI client using native URLSession async/await (Sources/Services/MihomoAPI.swift)
- [x] 2.3 Implement ProxyManager using Process execution of networksetup and CFNetwork APIs (Sources/Services/ProxyManager.swift)

## 3. UI Views & Integration

- [x] 3.1 Implement PopoverView UI with dynamic group selector, search filter, node list, latency pills, and system proxy toggle (Sources/Views/PopoverView.swift)
- [x] 3.2 Implement SettingsWindowController and dual-pane SettingsView for service endpoints and port/bypass configs (Sources/Views/SettingsView.swift)
- [x] 3.3 Connect state pipelines between Services and Views

## 4. Verification & Packaging

- [x] 4.1 Create unit tests for Mihomo API response JSON parsing (Tests/MenuSwitchTests/MenuSwitchTests.swift)
- [x] 4.2 Run build.sh, run compiled MenuSwitch.app, and verify active node switches & system proxy toggling
