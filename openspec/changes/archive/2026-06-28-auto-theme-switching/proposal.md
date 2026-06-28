## Why

Currently, the menu bar popover has a fixed dark theme. When the macOS system is in light mode during the daytime, the contrast is poor and the text/pickers are hard to read. Providing automatic theme switching matching the system settings along with manual Light/Dark overrides will improve usability and visual integration.

## What Changes

- Add a `ThemeMode` settings option (System/Auto, Always Light, Always Dark) persisted in `SettingsManager`.
- Update `PopoverView`'s layout colors, text, separators, lists, and segmented pickers to dynamically adapt to the active color scheme (Light or Dark).
- Fix a text color issue in `SettingsView` where `activeInterfaces` text is hardcoded to white, making it invisible in light mode.
- Update `SettingsView` General Settings section to let users select their preferred theme.
- Propagate the preferred color scheme from `SettingsManager` to all views in the main app scene.

## Capabilities

### New Capabilities

<!-- None -->

### Modified Capabilities

- `menu-bar-controller`: Add requirements for automatic/manual theme mode selection and visual adaptations for both Light and Dark color schemes.

## Impact

- **Views**:
  - [PopoverView.swift](file:///Users/chien/Projects/menu-switch/Sources/Views/PopoverView.swift): Dynamic backgrounds, text foregrounds, borders, pickers, and dividers that respond to `colorScheme` environment.
  - [SettingsView.swift](file:///Users/chien/Projects/menu-switch/Sources/Views/SettingsView.swift): Option control for theme selection and fix text color visibility bug.
- **Services**:
  - [SettingsManager.swift](file:///Users/chien/Projects/menu-switch/Sources/Services/SettingsManager.swift): Manage theme preference persistence and map selection to `ColorScheme?` for SwiftUI scene-wide propagation.
- **App**:
  - [App.swift](file:///Users/chien/Projects/menu-switch/Sources/App.swift): Apply `.preferredColorScheme` modifier on scenes based on the user's setting.
