import Foundation
import Cocoa

class ProxyManager {
    static let shared = ProxyManager()
    
    private init() {}
    
    private func runCommand(path: String, arguments: [String]) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = arguments
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()
        
        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8)
        } catch {
            print("[ProxyManager] Failed to run command \(path) with args \(arguments): \(error)")
            return nil
        }
    }
    
    func getActiveNetworkServices() -> [String] {
        guard let output = runCommand(path: "/usr/sbin/networksetup", arguments: ["-listnetworkserviceorder"]) else {
            return []
        }
        
        var services: [String] = []
        let lines = output.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.hasPrefix("(") && !trimmed.contains("*") {
                if let closeParenIndex = trimmed.firstIndex(of: ")") {
                    let afterParen = trimmed[trimmed.index(after: closeParenIndex)...]
                    let serviceName = afterParen.trimmingCharacters(in: .whitespaces)
                    if !serviceName.isEmpty {
                        services.append(serviceName)
                    }
                }
            }
        }
        return services
    }
    
    func checkSystemProxyStatus() -> Bool {
        guard let settingsRef = CFNetworkCopySystemProxySettings() else { return false }
        let settings = settingsRef.takeRetainedValue() as Dictionary
        
        let httpEnable = settings[kCFNetworkProxiesHTTPEnable] as? Int ?? 0
        let socksEnable = settings[kCFNetworkProxiesSOCKSEnable] as? Int ?? 0
        
        return httpEnable == 1 || socksEnable == 1
    }
    
    func toggleSystemProxy(
        enabled: Bool,
        host: String = "127.0.0.1",
        port: Int = 7890,
        bypassDomains: String = ""
    ) async {
        let services = getActiveNetworkServices()
        let bypassList = bypassDomains
            .components(separatedBy: CharacterSet(charactersIn: ", "))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        for service in services {
            if enabled {
                // Set and enable HTTP Proxy
                _ = runCommand(path: "/usr/sbin/networksetup", arguments: ["-setwebproxy", service, host, String(port)])
                _ = runCommand(path: "/usr/sbin/networksetup", arguments: ["-setwebproxystate", service, "on"])
                
                // Set and enable HTTPS Proxy
                _ = runCommand(path: "/usr/sbin/networksetup", arguments: ["-setsecurewebproxy", service, host, String(port)])
                _ = runCommand(path: "/usr/sbin/networksetup", arguments: ["-setsecurewebproxystate", service, "on"])
                
                // Set and enable SOCKS Proxy
                _ = runCommand(path: "/usr/sbin/networksetup", arguments: ["-setsocksfirewallproxy", service, host, String(port)])
                _ = runCommand(path: "/usr/sbin/networksetup", arguments: ["-setsocksfirewallproxystate", service, "on"])
                
                // Apply bypass list if specified
                if !bypassList.isEmpty {
                    var args = ["-setproxybypassdomains", service]
                    args.append(contentsOf: bypassList)
                    _ = runCommand(path: "/usr/sbin/networksetup", arguments: args)
                }
            } else {
                // Disable all proxies
                _ = runCommand(path: "/usr/sbin/networksetup", arguments: ["-setwebproxystate", service, "off"])
                _ = runCommand(path: "/usr/sbin/networksetup", arguments: ["-setsecurewebproxystate", service, "off"])
                _ = runCommand(path: "/usr/sbin/networksetup", arguments: ["-setsocksfirewallproxystate", service, "off"])
            }
        }
        
        // Notify SettingsManager to update status dynamically
        DispatchQueue.main.async {
            SettingsManager.shared.systemProxyEnabled = enabled
        }
    }
}
