## ADDED Requirements

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
