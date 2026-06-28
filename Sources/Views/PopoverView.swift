import SwiftUI

struct PopoverView: View {
    @StateObject private var settings = SettingsManager.shared
    @Environment(\.openWindow) private var openWindow
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var proxies: [String: ProxyItem] = [:]
    @State private var orderedKeys: [String] = []
    @State private var selectedGroup: String = ""
    @State private var routingMode: String = "rule"
    @State private var searchQuery: String = ""
    @State private var errorMessage: String? = nil
    @State private var isTestingLatency = false
    @State private var isProxyEnabled = false
    @State private var testingNodes: Set<String> = []
    @State private var hoveredNode: String? = nil
    
    private let timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    
    // Adaptive theme colors
    private var popoverBackground: LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [Color(red: 0.05, green: 0.07, blue: 0.12), Color(red: 0.02, green: 0.03, blue: 0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color(red: 0.95, green: 0.97, blue: 0.98), Color(red: 0.90, green: 0.92, blue: 0.95)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var sidebarBackgroundColor: Color {
        colorScheme == .dark ? Color.black.opacity(0.18) : Color.black.opacity(0.04)
    }
    
    private var itemSelectedBackgroundColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.06)
    }
    
    private var servicePickerBackgroundColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.04) : Color.black.opacity(0.04)
    }
    
    private var dividerBackgroundColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.08)
    }
    
    private var gearIconBackgroundColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.05)
    }
    
    private var textColorPrimary: Color {
        colorScheme == .dark ? .white : .primary
    }
    
    private var textColorSecondary: Color {
        colorScheme == .dark ? .gray : .secondary
    }
    
    var body: some View {
        ZStack {
            // Elegant Dynamic Glassmorphic background
            popoverBackground
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                // MARK: - Header
                HStack(spacing: 8) {
                    Text("MenuSwitch")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.black)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.cyan, Color.blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Spacer()
                    
                    // System Proxy quick toggle button
                    Button(action: toggleProxy) {
                        HStack(spacing: 5) {
                            Circle()
                                .fill(isProxyEnabled ? Color.emerald : Color.red)
                                .frame(width: 7, height: 7)
                                .shadow(color: isProxyEnabled ? Color.emerald.opacity(0.8) : Color.red.opacity(0.8), radius: 3)
                            
                            Text(isProxyEnabled ? "Proxy: ON" : "Proxy: OFF")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(textColorPrimary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(isProxyEnabled ? Color.emerald.opacity(0.15) : (colorScheme == .dark ? Color.white : Color.black).opacity(0.05))
                        )
                        .overlay(
                            Capsule()
                                .strokeBorder(isProxyEnabled ? Color.emerald.opacity(0.4) : (colorScheme == .dark ? Color.white : Color.black).opacity(0.1), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .help("Toggle macOS System Proxy")
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                
                // MARK: - Active Service Dropdown
                HStack {
                    Image(systemName: "server.rack")
                        .foregroundColor(.gray)
                        .font(.system(size: 11))
                    
                    if settings.services.isEmpty {
                        Text("No services configured")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    } else {
                        Picker("", selection: $settings.activeServiceId) {
                            ForEach(settings.services) { service in
                                Text(service.name).tag(Optional(service.id))
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.menu)
                        .frame(height: 24)
                        .background(servicePickerBackgroundColor)
                        .cornerRadius(6)
                        .onChange(of: settings.activeServiceId) { _ in
                            Task { await loadProxies() }
                        }
                    }
                    
                    Spacer()
                    
                    // Segmented routing mode control
                    Picker("", selection: $routingMode) {
                        Text("Rule").tag("rule")
                        Text("Global").tag("global")
                        Text("Direct").tag("direct")
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                    .frame(width: 135)
                    .scaleEffect(0.85)
                    .onChange(of: routingMode) { newMode in
                        switchRoutingMode(newMode)
                    }
                }
                .padding(.horizontal, 16)
                
                Divider()
                    .background(dividerBackgroundColor)
                
                if let error = errorMessage {
                    // Error view
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.amber)
                        
                        Text("Connection Failed")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(textColorPrimary)
                        
                        Text(error)
                            .font(.system(size: 11))
                            .foregroundColor(textColorSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        
                        Button("Retry") {
                            Task { await loadProxies() }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                        .padding(.top, 8)
                    }
                    Spacer()
                } else if proxies.isEmpty {
                    // Loading State
                    Spacer()
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(0.8)
                    Text("Fetching proxy groups...")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                    Spacer()
                } else {
                    // MARK: - Two-Column Split Body
                    HStack(spacing: 0) {
                        // Left Column: Selector groups sidebar list
                        VStack(alignment: .leading, spacing: 0) {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 2) {
                                     let selectorGroups: [String] = {
                                         var groups: [String] = []
                                         let globalKey = proxies.keys.first { $0.uppercased() == "GLOBAL" } ?? "GLOBAL"
                                         if let globalAll = proxies[globalKey]?.all {
                                             let others = globalAll.filter { name in
                                                 name.uppercased() != "GLOBAL" && proxies[name]?.type == "Selector"
                                             }
                                             groups.append(contentsOf: others)
                                         }
                                         if proxies[globalKey] != nil {
                                             groups.append(globalKey)
                                         }
                                         if groups.isEmpty {
                                             groups = orderedKeys.filter { proxies[$0]?.type == "Selector" }
                                         }
                                         return groups
                                     }()
                                    
                                    ForEach(selectorGroups, id: \.self) { group in
                                        let isSelected = group == selectedGroup
                                        Button(action: {
                                            withAnimation(.easeOut(duration: 0.12)) {
                                                selectedGroup = group
                                            }
                                        }) {
                                            VStack(alignment: .leading, spacing: 2) {
                                                HStack {
                                                    Text(group)
                                                        .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                                                        .foregroundColor(isSelected ? textColorPrimary : textColorSecondary)
                                                        .lineLimit(1)
                                                    Spacer()
                                                    if isSelected {
                                                        Image(systemName: "chevron.right")
                                                            .font(.system(size: 8, weight: .bold))
                                                            .foregroundColor(.blue)
                                                    }
                                                }
                                                
                                                if let nowSelected = proxies[group]?.now {
                                                    Text(nowSelected)
                                                        .font(.system(size: 9))
                                                        .foregroundColor(isSelected ? .blue : textColorSecondary)
                                                        .lineLimit(1)
                                                }
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(isSelected ? itemSelectedBackgroundColor : Color.clear)
                                            .cornerRadius(6)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 8)
                            }
                        }
                        .frame(width: 110)
                        .background(sidebarBackgroundColor)
                        
                        Divider()
                            .background(dividerBackgroundColor)
                        
                        // Right Column: Scrollable nodes list
                        VStack(spacing: 0) {
                            let currentGroupItems = proxies[selectedGroup]?.all ?? []
                            if currentGroupItems.isEmpty {
                                Spacer()
                                Text("No nodes available")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 11))
                                Spacer()
                            } else {
                                ScrollView {
                                    LazyVStack(spacing: 2) {
                                        ForEach(currentGroupItems, id: \.self) { nodeName in
                                            let isSelected = nodeName == proxies[selectedGroup]?.now
                                            let delay = getDelayForNode(nodeName)
                                            
                                            HStack {
                                                if isSelected {
                                                    Circle()
                                                        .fill(Color.blue)
                                                        .frame(width: 6, height: 6)
                                                        .shadow(color: Color.blue.opacity(0.8), radius: 2)
                                                } else {
                                                    Circle()
                                                        .fill(Color.clear)
                                                        .frame(width: 6, height: 6)
                                                }
                                                
                                                Text(nodeName)
                                                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                                                    .foregroundColor(isSelected ? textColorPrimary : textColorSecondary)
                                                    .lineLimit(1)
                                                
                                                Spacer()
                                                
                                                let upperNodeName = nodeName.uppercased()
                                                if upperNodeName != "DIRECT" &&
                                                   upperNodeName != "REJECT" &&
                                                   upperNodeName != "REJECT-DROP" {
                                                    Button(action: { triggerNodeLatencyTest(nodeName) }) {
                                                        if testingNodes.contains(nodeName) {
                                                            ProgressView()
                                                                .progressViewStyle(.circular)
                                                                .scaleEffect(0.3)
                                                                .frame(width: 10, height: 10)
                                                        } else {
                                                            Text(delayString(for: delay))
                                                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                                        }
                                                    }
                                                    .buttonStyle(.plain)
                                                    .foregroundColor(delayColor(for: delay))
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(
                                                        Capsule()
                                                            .fill(delayColor(for: delay).opacity(0.12))
                                                    )
                                                    .help("Click to test latency for \(nodeName)")
                                                }
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(
                                                isSelected ? itemSelectedBackgroundColor : 
                                                (hoveredNode == nodeName ? (colorScheme == .dark ? Color.white.opacity(0.04) : Color.black.opacity(0.04)) : Color.clear)
                                            )
                                            .cornerRadius(6)
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                selectNode(nodeName)
                                            }
                                            .onHover { isHovered in
                                                if isHovered {
                                                    hoveredNode = nodeName
                                                } else if hoveredNode == nodeName {
                                                    hoveredNode = nil
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 8)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxHeight: .infinity)
                }
                
                Divider()
                    .background(dividerBackgroundColor)
                
                // MARK: - Footer
                HStack {
                    // Test Latency Button
                    Button(action: triggerLatencyTest) {
                        HStack(spacing: 4) {
                            if isTestingLatency {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .scaleEffect(0.4)
                                    .frame(width: 12, height: 12)
                            } else {
                                Image(systemName: "bolt.fill")
                            }
                            Text("Test Latency")
                        }
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .disabled(isTestingLatency || proxies.isEmpty || selectedGroup.isEmpty)
                    
                    Spacer()
                    
                    // Settings Button
                    Button(action: {
                        openWindow(id: "settings-window")
                        NSApp.activate(ignoringOtherApps: true)
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 13))
                            .foregroundColor(textColorSecondary)
                            .padding(6)
                            .background(gearIconBackgroundColor)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .help("Preferences (Cmd+,)")
                    
                    // Quit Button
                    Button(action: { NSApp.terminate(nil) }) {
                        Image(systemName: "power")
                            .font(.system(size: 13))
                            .foregroundColor(.red)
                            .padding(6)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .help("Quit MenuSwitch")
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
            }
        }
        .onAppear {
            isProxyEnabled = ProxyManager.shared.checkSystemProxyStatus()
            Task { await loadProxies() }
        }
        .onReceive(timer) { _ in
            if !proxies.isEmpty && !isTestingLatency {
                Task { await loadProxies() }
            }
        }
    }
    
    // MARK: - Helpers & Calculations
    
    private func loadProxies() async {
        guard let service = settings.activeService else {
            DispatchQueue.main.async {
                self.errorMessage = "No Mihomo service configured. Go to Preferences to add one."
                self.proxies = [:]
            }
            return
        }
        do {
            async let proxiesVar = MihomoAPI.shared.fetchProxies(service: service)
            async let modeVar = MihomoAPI.shared.fetchMode(service: service)
            
            let response = try await proxiesVar
            let mode = try await modeVar
            
            DispatchQueue.main.async {
                self.proxies = response.proxies
                self.orderedKeys = response.orderedKeys
                self.routingMode = mode.lowercased()
                self.errorMessage = nil
                
                let selectorGroups: [String] = {
                     var groups: [String] = []
                     let globalKey = response.proxies.keys.first { $0.uppercased() == "GLOBAL" } ?? "GLOBAL"
                     if let globalAll = response.proxies[globalKey]?.all {
                         let others = globalAll.filter { name in
                             name.uppercased() != "GLOBAL" && response.proxies[name]?.type == "Selector"
                         }
                         groups.append(contentsOf: others)
                     }
                     if response.proxies[globalKey] != nil {
                         groups.append(globalKey)
                     }
                     if groups.isEmpty {
                         groups = response.orderedKeys.filter { response.proxies[$0]?.type == "Selector" }
                     }
                     return groups
                 }()
                
                if self.selectedGroup.isEmpty || !selectorGroups.contains(self.selectedGroup) {
                    self.selectedGroup = selectorGroups.first(where: { $0.lowercased() == "proxy" || $0.lowercased() == "global" })
                        ?? selectorGroups.first
                        ?? ""
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.proxies = [:]
            }
        }
    }
    
    private func switchRoutingMode(_ mode: String) {
        guard let service = settings.activeService else { return }
        Task {
            do {
                try await MihomoAPI.shared.updateMode(service: service, mode: mode)
                await loadProxies()
            } catch {
                print("[PopoverView] Error switching routing mode: \(error)")
            }
        }
    }
    
    private func selectNode(_ nodeName: String) {
        guard let service = settings.activeService, !selectedGroup.isEmpty else { return }
        // Optimistic UI update
        if let currentGroup = proxies[selectedGroup] {
            let updatedGroup = ProxyItem(
                name: currentGroup.name,
                type: currentGroup.type,
                now: nodeName,
                all: currentGroup.all,
                history: currentGroup.history
            )
            proxies[selectedGroup] = updatedGroup
        }
        
        Task {
            do {
                try await MihomoAPI.shared.switchNode(service: service, groupName: selectedGroup, nodeName: nodeName)
                await loadProxies()
            } catch {
                print("[PopoverView] Error switching node: \(error)")
                await loadProxies() // Revert to correct state
            }
        }
    }
    
    private func triggerLatencyTest() {
        guard let service = settings.activeService, !selectedGroup.isEmpty else { return }
        isTestingLatency = true
        Task {
            do {
                try await MihomoAPI.shared.testLatency(service: service, groupName: selectedGroup)
                await loadProxies()
            } catch {
                print("[PopoverView] Error testing latency: \(error)")
            }
            DispatchQueue.main.async {
                self.isTestingLatency = false
            }
        }
    }
    
    private func triggerNodeLatencyTest(_ nodeName: String) {
        guard let service = settings.activeService else { return }
        testingNodes.insert(nodeName)
        Task {
            do {
                let delay = try await MihomoAPI.shared.testNodeLatency(service: service, nodeName: nodeName)
                DispatchQueue.main.async {
                    if let node = proxies[nodeName] {
                        let newHistoryItem = HistoryItem(time: "", delay: delay)
                        let updatedHistory = (node.history ?? []) + [newHistoryItem]
                        let updatedNode = ProxyItem(
                            name: node.name,
                            type: node.type,
                            now: node.now,
                            all: node.all,
                            history: updatedHistory
                        )
                        proxies[nodeName] = updatedNode
                    }
                    Task { await loadProxies() }
                }
            } catch {
                print("[PopoverView] Error testing node latency for \(nodeName): \(error)")
                DispatchQueue.main.async {
                    if let node = proxies[nodeName] {
                        let newHistoryItem = HistoryItem(time: "", delay: 0)
                        let updatedHistory = (node.history ?? []) + [newHistoryItem]
                        let updatedNode = ProxyItem(
                            name: node.name,
                            type: node.type,
                            now: node.now,
                            all: node.all,
                            history: updatedHistory
                        )
                        proxies[nodeName] = updatedNode
                    }
                }
            }
            DispatchQueue.main.async {
                testingNodes.remove(nodeName)
            }
        }
    }
    
    private func toggleProxy() {
        let nextState = !isProxyEnabled
        isProxyEnabled = nextState
        Task {
            await ProxyManager.shared.toggleSystemProxy(
                enabled: nextState,
                host: settings.proxyHost,
                port: settings.port,
                bypassDomains: settings.bypassDomains
            )
        }
    }
    
    private func getDelayForNode(_ nodeName: String) -> Int? {
        if let node = proxies[nodeName] {
            return node.history?.last?.delay
        }
        return nil
    }
    
    private func delayString(for delay: Int?) -> String {
        guard let delay = delay else { return "--" }
        if delay == 0 { return "timeout" }
        return "\(delay)ms"
    }
    
    private func delayColor(for delay: Int?) -> Color {
        guard let delay = delay else { return .gray }
        if delay == 0 { return .red }
        if delay < 120 { return .emerald }
        if delay < 300 { return .yellow }
        return .orange
    }
}

// Custom Colors
extension Color {
    static let emerald = Color(red: 0.06, green: 0.73, blue: 0.51) // Emerald Green (#10B981)
    static let amber = Color(red: 0.96, green: 0.59, blue: 0.11)  // Amber (#F59E0B)
}

// Button Hover Effects
struct NodeListButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .background(
                configuration.isPressed ? 
                    (colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.06)) : 
                    Color.clear
            )
    }
}
