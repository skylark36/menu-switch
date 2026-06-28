# Menu Bar Controller

## Purpose
Spec for the Menu Bar Controller that handles menu status and proxy service switching.
## Requirements
### Requirement: Show Status Bar Icon and Handle Popover Display
The app SHALL display a native status bar icon in the macOS menu bar. Clicking this icon SHALL toggle the visibility of a custom SwiftUI popover panel.

#### Scenario: User clicks the status bar icon to open
- **WHEN** the user clicks the status bar icon while the popover is closed
- **THEN** the popover panel is displayed directly below the status bar icon and keyboard focus is requested

#### Scenario: User clicks outside to dismiss
- **WHEN** the popover is active and the user clicks anywhere outside the popover boundaries
- **THEN** the popover panel is dismissed automatically

### Requirement: Active Mihomo Service Selector
The popover panel SHALL display a dropdown or list picker showing all configured Mihomo services. The user SHALL be able to select an active service to switch the app's controller context.

#### Scenario: Switch active service
- **WHEN** the user selects a different Mihomo service from the service picker
- **THEN** the app updates the current active service setting and triggers a refresh of the proxy groups and nodes from the new service API

### Requirement: Dynamic Proxy Group Selector
The popover panel SHALL dynamically fetch all proxy groups of type `Selector` from the active Mihomo service's `/proxies` API, displaying them as selectable tab/capsule items.

#### Scenario: Display proxy groups
- **WHEN** the popover is opened or the active service is switched
- **THEN** the app fetches all proxies from the Mihomo API, filters out groups of type `Selector`, and displays them as selection tabs with the currently selected node name highlighted

### Requirement: Node Search Filter
The popover panel SHALL provide a search field allowing users to filter the list of proxy nodes in the currently selected group by name.

#### Scenario: Filter nodes by keyword
- **WHEN** the user types a search query in the search field
- **THEN** the node list instantly updates to only show nodes whose names contain the typed query (case-insensitive)

### Requirement: Select and Switch Proxy Node
The popover panel SHALL show a scrollable list of all nodes in the active proxy group. Clicking a node item SHALL call the Mihomo API to switch the active proxy selection for that group.

#### Scenario: Switch proxy node successfully
- **WHEN** the user clicks on a node item in the list
- **THEN** the app sends a PUT request to the active Mihomo service's `/proxies/{group_name}` endpoint with the body `{"name": "{node_name}"}`, updates the selection status mark in the list, and triggers a refresh of the group info

### Requirement: Latency Indicators and Testing
The app SHALL display the last-known latency for each node in the list. It SHALL also provide a manual latency test trigger.

#### Scenario: Trigger latency test
- **WHEN** the user clicks the "Test Latency" button in the popover footer
- **THEN** the app sends a delay test request to the active Mihomo service's API for the current group and updates the displayed latency (in milliseconds or timeout) once the response is received

### Requirement: Open Standalone Settings Window
The popover panel SHALL contain a settings button (gear icon) in the footer to open the standalone app Settings Window.

#### Scenario: Open settings window
- **WHEN** the user clicks the gear settings button in the popover footer
- **THEN** the app instantiates or focuses the native, standalone Settings Window and dismisses the status bar popover

### Requirement: Theme Mode Configuration and Auto Switching
The app SHALL provide a Theme Mode configuration setting with options: Auto (system theme), Light, and Dark. The app SHALL dynamically monitor and adapt its interface elements, background colors, and typography colors to match the active color scheme.

#### Scenario: Auto theme mode adapts to macOS light mode
- **WHEN** the user sets Theme Mode to Auto and the macOS system theme is set to light mode
- **THEN** the popover and settings windows SHALL render in light mode style with a light background and dark high-contrast text

#### Scenario: Auto theme mode adapts to macOS dark mode
- **WHEN** the user sets Theme Mode to Auto and the macOS system theme is set to dark mode
- **THEN** the popover and settings windows SHALL render in dark mode style with a dark background and white/gray high-contrast text

#### Scenario: Force light theme override
- **WHEN** the user sets Theme Mode to Light
- **THEN** the app SHALL render in light mode style regardless of the macOS system theme

#### Scenario: Force dark theme override
- **WHEN** the user sets Theme Mode to Dark
- **THEN** the app SHALL render in dark mode style regardless of the macOS system theme

