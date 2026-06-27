## Why

Currently, macOS users of Mihomo (formerly Clash) who want to quickly switch proxy nodes or toggle system proxy settings are forced to use heavy dashboard web interfaces or full-fledged client applications that also run the Mihomo engine. There is a need for a lightweight, native macOS menu bar application that purely controls existing local or remote Mihomo service instances and quickly toggles macOS system proxy settings.

## What Changes

- **Status Bar App**: A new status bar icon (MenuBarExtra) that triggers a custom popup panel.
- **Dynamic Node Switcher**: Fetches proxy groups dynamically from the configured Mihomo service API and allows node switching.
- **Latency Indicators**: Shows node delay details and allows manually triggering latency tests via Mihomo's API.
- **System Proxy Toggle**: A quick switch in the popover to toggle HTTP/HTTPS/SOCKS system proxy configurations using the macOS `networksetup` utility.
- **Standalone Settings**: A native settings window to manage multiple Mihomo service endpoints (URL, Secret) and configure custom proxy ports/bypass lists.

## Capabilities

### New Capabilities

- `menu-bar-controller`: Dynamic SwiftUI popover rendering the Mihomo proxy groups, search filter, node list, and latency status.
- `system-proxy-controller`: Configuration and toggling of HTTP, HTTPS, and SOCKS proxy settings across active network services.

### Modified Capabilities

## Impact

- **Build Pipeline**: Creates Swift Package Manager configuration and custom build packaging scripts (`build.sh`) to build `.app` bundles on macOS.
- **External Dependencies**: No external package dependencies; uses native macOS frameworks (SwiftUI, URLSession, CFNetwork, Process) to keep the app ultra-lightweight.
