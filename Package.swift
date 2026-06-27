// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MenuSwitch",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "MenuSwitch", targets: ["MenuSwitch"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "MenuSwitch",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "MenuSwitchTests",
            dependencies: ["MenuSwitch"],
            path: "Tests/MenuSwitchTests"
        )
    ]
)
