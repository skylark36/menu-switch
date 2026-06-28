## Context

The current user interface of MenuSwitch has hardcoded dark styling. In light mode, native views (such as menus, segmented picker text, and default system controls) adapt to light theme, but they are rendered against a dark space-blue custom background, leading to very low contrast and illegible text.

We need to support:
1. Standard macOS system theme matching (light/dark mode auto-switching).
2. Manual Light and Dark overrides.

## Goals / Non-Goals

**Goals:**
- Implement dynamic theme selection (`Auto`, `Light`, `Dark`) stored in `UserDefaults`.
- Transition the custom popover background and text styling dynamically between space-blue dark style and icy-gray light style depending on the active scheme.
- Fix hardcoded white text colors in `SettingsView` that cause text to be invisible in light mode.

**Non-Goals:**
- Creating a completely custom color theme manager (only standard light, dark, and auto modes are needed).

## Decisions

### 1. Leverage SwiftUI `.preferredColorScheme`
We will map the `ThemeMode` preference to an optional `ColorScheme`:
- `.auto` -> `nil` (uses system theme)
- `.light` -> `.light`
- `.dark` -> `.dark`

This color scheme is applied as `.preferredColorScheme(settings.colorScheme)` to the popover view content and settings view content. SwiftUI propagates this to `@Environment(\.colorScheme)`, which we can read inside child views.

### 2. Semantic/Conditional Colors in PopoverView
To preserve the premium appearance, we will define computed properties in `PopoverView` that switch colors depending on `colorScheme`:

| Element | Dark Mode Color | Light Mode Color |
| :--- | :--- | :--- |
| **Background** | Space Blue Gradient `(0.05, 0.07, 0.12) -> (0.02, 0.03, 0.05)` | Icy Gray Gradient `(0.95, 0.97, 0.98) -> (0.90, 0.92, 0.95)` |
| **Sidebar Background** | `Color.black.opacity(0.18)` | `Color.black.opacity(0.04)` |
| **Selected Item BG** | `Color.white.opacity(0.06)` | `Color.black.opacity(0.06)` |
| **Text (Selected)** | `Color.white` | `Color.primary` |
| **Text (Unselected)** | `Color.gray` | `Color.secondary` |
| **Dividers** | `Color.white.opacity(0.08)` | `Color.black.opacity(0.08)` |
| **Active Service BG** | `Color.white.opacity(0.04)` | `Color.black.opacity(0.04)` |

### 3. Add Theme Picker in Preferences
A theme picker will be added in `SettingsView` under the "General Settings" section:
```swift
Picker("Theme Mode", selection: $settings.themeMode) {
    ForEach(ThemeMode.allCases) { mode in
        Text(mode.rawValue).tag(mode)
    }
}
.pickerStyle(.menu)
```

## Risks / Trade-offs

- **Risk**: Setting `.preferredColorScheme` at view level might not immediately update system-drawn elements like status bar popover margins or shadow colors.
  - *Mitigation*: Applying preferred color scheme directly on the views inside `MenuBarExtra` and the `Window` scene resolves this. macOS correctly propagates the theme down the rendering tree.
