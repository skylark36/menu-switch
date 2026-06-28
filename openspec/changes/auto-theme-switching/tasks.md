## 1. Setup Theme Mode Settings

- [x] 1.1 Add `ThemeMode` enum in `SettingsManager.swift`
- [x] 1.2 Persist theme mode preference in `UserDefaults` and publish changes in `SettingsManager`
- [x] 1.3 Map `ThemeMode` to optional SwiftUI `ColorScheme` in `SettingsManager`

## 2. Dynamic preferredColorScheme in App

- [x] 2.1 Update `MenuSwitchApp` in `App.swift` to pass `settings.colorScheme` to the views inside `MenuBarExtra` and the `Window` scene

## 3. Dynamic Styling in PopoverView

- [x] 3.1 Declare `@Environment(\.colorScheme) private var colorScheme` in `PopoverView`
- [x] 3.2 Define computed properties for adaptive colors in `PopoverView` (background, sidebar background, sidebar selected item, service picker background, dividers, settings gear icon background)
- [x] 3.3 Apply adaptive colors to `PopoverView` UI components and dynamic text foreground colors based on selection and color scheme
- [x] 3.4 Update `NodeListButtonStyle` to support adaptive hover background colors based on `colorScheme`

## 4. SettingsView Improvements and Theme Selection

- [x] 4.1 Fix `activeInterfaces` text color bug in `SettingsView` by using `.foregroundColor(.primary)` instead of `.foregroundColor(.white)`
- [x] 4.2 Add theme mode selection Picker in the General Settings section of `SettingsView`

## 5. Verification

- [x] 5.1 Build and launch the application
- [ ] 5.2 Verify that changing system theme between Light and Dark automatically updates the app UI when theme mode is set to Auto
- [ ] 5.3 Verify that explicitly switching to Light or Dark theme override forces the selected mode
