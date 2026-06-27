## Context

This project is a native macOS status bar utility to control Mihomo (formerly Clash) instances (remote or local) and toggle system proxy settings. The application is built using Swift 6, SwiftUI, and native macOS framework APIs, minimizing external dependencies and file size. It targets macOS 13.0+ to take advantage of modern SwiftUI APIs (e.g. `MenuBarExtra`) and Swift Concurrency.

## Goals / Non-Goals

**Goals:**
- Provide a responsive, high-performance, and visually appealing native macOS status bar popover.
- Allow adding, editing, and selecting multiple local/remote Mihomo controllers (URL, Secret).
- Dynamically parse and display selector-type proxy groups and their respective nodes.
- Display latency and support manual trigger for delay checks via Mihomo endpoints.
- Auto-detect active network service adapters (e.g., Wi-Fi, Ethernet) and configure/toggle system HTTP, HTTPS, and SOCKS proxy settings.
- Support Launch at Login using native macOS Service Management APIs.

**Non-Goals:**
- Running or managing the Mihomo engine/process locally (must be run separately).
- Configuration parsing/validation of Mihomo YAML configs.
- Downloading or updating subscription configs.

## Decisions

### 1. Manual App Packaging via Swift Package Manager (SPM)
- **Choice**: Structure the project as a Swift Package executable, compile it using `swift build -c release`, and wrap the binary in a manual `.app` bundle structure (incorporating a custom `Info.plist`).
- **Rationale**: Avoids the overhead of managing complex, binary-heavy Xcode project files (`.xcodeproj`) in git. Keeps the repository clean and developer-friendly using a simple Shell build script (`build.sh`).
- **Alternatives Considered**: Using Xcode project files directly. Rejected due to git conflicts and configuration complexity.

### 2. Native macOS System Proxy Toggling via `networksetup`
- **Choice**: Execute macOS CLI commands via Swift's `Process` class to list network interfaces and apply web/secureweb/socks proxy configurations.
- **Rationale**: Highly reliable, standard macOS utility. On macOS accounts with administrator privileges, these commands do not require root prompt escalation, making it seamless for developers and standard power users.
- **Alternatives Considered**: SystemConfiguration framework or Network Extension. SystemConfiguration APIs for modifying system preferences require helper tool installation or admin authentication dialogs for every run. Network Extension requires App Store Developer ID signing with special configurations.

### 3. CFNetwork System Proxy Detection
- **Choice**: Use the native `CFNetworkCopySystemProxySettings()` API to instantly query the status of macOS system proxy.
- **Rationale**: Faster and more efficient than parsing `networksetup` text output, returning accurate, real-time configuration mappings.

### 4. SwiftUI Popover with NSApplicationDelegateAdaptor
- **Choice**: Use a custom `NSPopover` hosted inside an `NSStatusItem` managed by a traditional `AppDelegate`.
- **Rationale**: SwiftUI's standard `MenuBarExtra` does not natively support complex popovers with focus, custom dismissal controls, and complex layouts easily. Standard popovers with window level monitors provide the exact native behavior expected.

## Risks / Trade-offs

- **[Risk] Sandboxing constraints** → The app cannot be sandboxed (App Sandbox disabled) as it needs to run system commands (`networksetup`) and query network configurations.
  - **Mitigation**: Distribute the app as an ad-hoc compiled app bundle or notarized build outside the Mac App Store.
- **[Risk] CLI command stability** → Apple might modify or restrict `networksetup` parameters in future macOS releases.
  - **Mitigation**: Catch execution errors, verify status codes, and falls back gracefully with warnings in the Settings UI.
