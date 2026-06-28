import SwiftUI

struct SettingsView: View {
    @StateObject private var settings = SettingsManager.shared
    
    @State private var selectedServiceId: UUID? = nil
    
    // Editor fields for a new/selected service
    @State private var editName: String = ""
    @State private var editUrl: String = ""
    @State private var editSecret: String = ""
    
    // Temporary System Proxy settings for editing before clicking Apply
    @State private var tempHost: String = ""
    @State private var tempPortString: String = "7890"
    @State private var tempBypassDomains: String = ""
    
    // Focus management and success feedback states
    @FocusState private var isFocused: Bool
    @State private var showServicesSuccess = false
    @State private var showProxySuccess = false
    
    // Detected active interfaces list
    @State private var activeInterfaces: [String] = []
    
    var body: some View {
        TabView {
            // MARK: - Services Tab
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    // Left list of services
                    VStack(alignment: .leading, spacing: 0) {
                        List(selection: $selectedServiceId) {
                            ForEach(settings.services) { service in
                                Text(service.name)
                                    .tag(service.id)
                            }
                        }
                        .listStyle(.sidebar)
                        
                        Divider()
                        
                        HStack {
                            Button(action: addService) {
                                Image(systemName: "plus")
                            }
                            .buttonStyle(.plain)
                            .padding(.leading, 12)
                            
                            Button(action: removeSelectedService) {
                                Image(systemName: "minus")
                            }
                            .buttonStyle(.plain)
                            .disabled(selectedServiceId == nil || settings.services.count <= 1)
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .background(Color(NSColor.windowBackgroundColor))
                    }
                    .frame(width: 150)
                    .frame(maxHeight: .infinity)
                    
                    Divider()
                    
                    // Right detail editor
                    VStack(alignment: .leading, spacing: 14) {
                        if let selectedId = selectedServiceId,
                           let index = settings.services.firstIndex(where: { $0.id == selectedId }) {
                            Text("Edit Mihomo Service")
                                .font(.headline)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Service Name")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    TextField("e.g. Local Server", text: $editName)
                                        .textFieldStyle(.roundedBorder)
                                        .focused($isFocused)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("API URL")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    TextField("e.g. http://127.0.0.1:9090", text: $editUrl)
                                        .textFieldStyle(.roundedBorder)
                                        .focused($isFocused)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("API Secret (Token)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    SecureField("Optional Token", text: $editSecret)
                                        .textFieldStyle(.roundedBorder)
                                        .focused($isFocused)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                Button("Apply") {
                                    isFocused = false
                                    settings.services[index].name = editName
                                    settings.services[index].url = editUrl
                                    settings.services[index].secret = editSecret
                                    
                                    // Trigger reactivity if active service is edited
                                    if settings.activeServiceId == selectedId {
                                        settings.activeServiceId = nil
                                        settings.activeServiceId = selectedId
                                    }
                                    
                                    withAnimation {
                                        showServicesSuccess = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                        withAnimation {
                                            showServicesSuccess = false
                                        }
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                
                                if showServicesSuccess {
                                    Text("✓ Saved")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.emerald)
                                        .transition(.opacity)
                                }
                                
                                Spacer()
                            }
                            .padding(.top, 8)
                            
                            Spacer()
                        } else {
                            Spacer()
                            HStack {
                                Spacer()
                                Text("Select a service or click + to add one.")
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .tabItem {
                Label("Services", systemImage: "server.rack")
            }
            .onChange(of: selectedServiceId) { newId in
                if let newId = newId,
                   let service = settings.services.first(where: { $0.id == newId }) {
                    editName = service.name
                    editUrl = service.url
                    editSecret = service.secret
                } else {
                    editName = ""
                    editUrl = ""
                    editSecret = ""
                }
            }
            .onAppear {
                if selectedServiceId == nil {
                    selectedServiceId = settings.activeServiceId ?? settings.services.first?.id
                }
            }
            
            // MARK: - System Proxy Tab
            Form {
                Section(header: Text("Network Mappings").font(.headline)) {
                    HStack {
                        Text("Proxy Host")
                            .frame(width: 110, alignment: .leading)
                        TextField("", text: $tempHost)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 140)
                            .focused($isFocused)
                    }
                    
                    HStack {
                        Text("Mixed Port")
                            .frame(width: 110, alignment: .leading)
                        TextField("", text: $tempPortString)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                            .focused($isFocused)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Bypass Domains (comma separated)")
                        TextEditor(text: $tempBypassDomains)
                            .frame(height: 50)
                            .border(Color.gray.opacity(0.2), width: 1)
                            .cornerRadius(4)
                            .font(.system(.body, design: .monospaced))
                            .focused($isFocused)
                    }
                }
                
                Section(header: Text("General Settings").font(.headline)) {
                    Toggle("Launch at Login", isOn: $settings.launchAtLogin)
                        .padding(.vertical, 4)
                    
                    HStack {
                        Text("Theme Mode")
                            .frame(width: 110, alignment: .leading)
                        Picker("", selection: $settings.themeMode) {
                            ForEach(ThemeMode.allCases) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.menu)
                        .frame(width: 120)
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Detected Network Services:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(activeInterfaces.isEmpty ? "None" : activeInterfaces.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.primary)
                            .fontWeight(.semibold)
                    }
                }
                
                Section {
                    HStack {
                        Spacer()
                        
                        if showProxySuccess {
                            Text("✓ Applied")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.emerald)
                                .transition(.opacity)
                                .padding(.trailing, 8)
                        }
                        
                        Button("Apply Settings") {
                            isFocused = false
                            let targetPort = Int(tempPortString) ?? 7890
                            settings.proxyHost = tempHost
                            settings.port = targetPort
                            settings.bypassDomains = tempBypassDomains
                            
                            // Re-apply settings if system proxy is currently enabled
                            if settings.systemProxyEnabled {
                                Task {
                                    await ProxyManager.shared.toggleSystemProxy(
                                        enabled: true,
                                        host: tempHost,
                                        port: targetPort,
                                        bypassDomains: tempBypassDomains
                                    )
                                }
                            }
                            
                            withAnimation {
                                showProxySuccess = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation {
                                    showProxySuccess = false
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding(20)
            .tabItem {
                Label("System Proxy", systemImage: "network")
            }
            .onAppear {
                tempHost = settings.proxyHost
                tempPortString = String(settings.port)
                tempBypassDomains = settings.bypassDomains
                activeInterfaces = ProxyManager.shared.getActiveNetworkServices()
            }
        }
        .frame(width: 480, height: 340)
    }
    
    // MARK: - Actions
    
    private func addService() {
        let newService = MihomoService(name: "New Service", url: "http://127.0.0.1:9090", secret: "")
        settings.services.append(newService)
        selectedServiceId = newService.id
        settings.activeServiceId = newService.id
    }
    
    private func removeSelectedService() {
        guard let selectedId = selectedServiceId else { return }
        guard settings.services.count > 1 else { return }
        
        if let index = settings.services.firstIndex(where: { $0.id == selectedId }) {
            settings.services.remove(at: index)
            selectedServiceId = settings.services.first?.id
            settings.activeServiceId = settings.services.first?.id
        }
    }
}
