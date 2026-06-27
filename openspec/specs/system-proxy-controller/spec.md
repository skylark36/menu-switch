# System Proxy Controller

TBD: Spec for System Proxy Controller.

## Requirements

### Requirement: Discover Active Network Services
The system proxy controller SHALL run shell commands to list network services on the macOS system and filter for active ones.

#### Scenario: List active services
- **WHEN** the proxy manager initialization is triggered
- **THEN** it executes `networksetup -listnetworkserviceorder` and parses the output to identify active services (like Wi-Fi, Ethernet) to be targeted for proxy changes

### Requirement: Enable System Proxies
The system proxy controller SHALL programmatically configure and enable HTTP, HTTPS, and SOCKS proxies on the identified active network services using macOS configuration utilities.

#### Scenario: Enable system proxy successfully
- **WHEN** the user toggles the system proxy option to ON and has configured host and ports
- **THEN** the app runs `networksetup` commands to set host, port, bypass domains, and enable state for web proxy, secure web proxy, and SOCKS proxy on all active services

### Requirement: Disable System Proxies
The system proxy controller SHALL programmatically disable HTTP, HTTPS, and SOCKS proxies on the active network services.

#### Scenario: Disable system proxy successfully
- **WHEN** the user toggles the system proxy option to OFF
- **THEN** the app runs `networksetup` commands to disable web proxy, secure web proxy, and SOCKS proxy states on all active services

### Requirement: Detect System Proxy State
The app SHALL automatically query and reflect the current system proxy status of the macOS system.

#### Scenario: App detects enabled system proxy
- **WHEN** the app starts or a change is detected via system configuration APIs
- **THEN** it queries system proxy preferences (using `CFNetworkCopySystemProxySettings()`) and syncs the popover UI switch state to match
