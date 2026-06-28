import Foundation
import ServiceManagement
import SwiftUI

struct MihomoService: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String
    var url: String
    var secret: String
}

enum ThemeMode: String, CaseIterable, Identifiable, Codable {
    case auto = "Auto"
    case light = "Light"
    case dark = "Dark"
    
    var id: String { rawValue }
}

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    private let servicesKey = "menu_switch_services"
    private let activeServiceIdKey = "menu_switch_active_service_id"
    private let portKey = "menu_switch_port"
    private let proxyHostKey = "menu_switch_proxy_host"
    private let bypassDomainsKey = "menu_switch_bypass_domains"
    private let themeModeKey = "menu_switch_theme_mode"
    
    @Published var services: [MihomoService] {
        didSet {
            saveServices()
        }
    }
    
    @Published var activeServiceId: UUID? {
        didSet {
            UserDefaults.standard.set(activeServiceId?.uuidString, forKey: activeServiceIdKey)
        }
    }
    
    @Published var port: Int {
        didSet {
            UserDefaults.standard.set(port, forKey: portKey)
        }
    }
    
    @Published var proxyHost: String {
        didSet {
            UserDefaults.standard.set(proxyHost, forKey: proxyHostKey)
        }
    }
    
    @Published var bypassDomains: String {
        didSet {
            UserDefaults.standard.set(bypassDomains, forKey: bypassDomainsKey)
        }
    }
    
    @Published var launchAtLogin: Bool = false {
        didSet {
            setLaunchAtLogin(launchAtLogin)
        }
    }
    
    @Published var systemProxyEnabled: Bool = false
    
    @Published var themeMode: ThemeMode {
        didSet {
            UserDefaults.standard.set(themeMode.rawValue, forKey: themeModeKey)
        }
    }
    
    var colorScheme: ColorScheme? {
        switch themeMode {
        case .auto: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    private init() {
        // 1. Load services
        let loadedServices: [MihomoService]
        if let data = UserDefaults.standard.data(forKey: servicesKey),
           let decoded = try? JSONDecoder().decode([MihomoService].self, from: data) {
            loadedServices = decoded
        } else {
            // Default configuration
            let defaultService = MihomoService(name: "Local Mihomo", url: "http://127.0.0.1:9090", secret: "")
            loadedServices = [defaultService]
        }
        self.services = loadedServices
        
        // 2. Load proxy settings
        let savedPort = UserDefaults.standard.integer(forKey: portKey)
        self.port = savedPort == 0 ? 7890 : savedPort
        
        self.proxyHost = UserDefaults.standard.string(forKey: proxyHostKey) ?? "127.0.0.1"
        self.bypassDomains = UserDefaults.standard.string(forKey: bypassDomainsKey) ?? "127.0.0.1, 192.168.0.0/16, 10.0.0.0/8, 172.16.0.0/12, 100.64.0.0/10, localhost, *.local, <local>"
        
        // 3. Load active service ID
        if let idString = UserDefaults.standard.string(forKey: activeServiceIdKey),
           let uuid = UUID(uuidString: idString) {
            self.activeServiceId = uuid
        } else {
            self.activeServiceId = loadedServices.first?.id
        }
        
        // 4. Synchronize initial launch status
        self.launchAtLogin = SMAppService.mainApp.status == .enabled
        self.systemProxyEnabled = ProxyManager.shared.checkSystemProxyStatus()
        
        // 5. Load theme mode settings
        let savedTheme = UserDefaults.standard.string(forKey: themeModeKey) ?? ThemeMode.auto.rawValue
        self.themeMode = ThemeMode(rawValue: savedTheme) ?? .auto
    }
    
    var activeService: MihomoService? {
        services.first(where: { $0.id == activeServiceId })
    }
    
    private func saveServices() {
        if let encoded = try? JSONEncoder().encode(services) {
            UserDefaults.standard.set(encoded, forKey: servicesKey)
        }
    }
    
    private func setLaunchAtLogin(_ enable: Bool) {
        let status = SMAppService.mainApp.status
        do {
            if enable {
                if status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else {
                if status == .enabled {
                    try SMAppService.mainApp.unregister()
                }
            }
        } catch {
            print("[SettingsManager] Failed to change launch at login setting: \(error)")
        }
    }
}
