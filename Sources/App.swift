import SwiftUI

@main
struct MenuSwitchApp: App {
    @StateObject private var settings = SettingsManager.shared
    
    var body: some Scene {
        MenuBarExtra {
            PopoverView()
                .frame(width: 360, height: 400)
        } label: {
            Text(settings.systemProxyEnabled ? "🔰" : "🌐")
        }
        .menuBarExtraStyle(.window)
        
        Window("MenuSwitch Preferences", id: "settings-window") {
            SettingsView()
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
    }
}
