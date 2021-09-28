// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Kumo",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "Kumo", targets: ["Kumo"]),
        .library(name: "KumoCoding", targets: ["KumoCoding"]),
        .library(name: "KumoDebugger", targets: [])
    ],
    targets: [
        .target(name: "Kumo", dependencies: ["KumoCoding"]),
        .target(name: "KumoCoding", dependencies: []),
        .target(name: "KumoDebugger", dependencies: []),
        .testTarget(name: "KumoTests", dependencies: ["Kumo", "KumoCoding"]),
        .testTarget(name: "KumoDebuggerRTests", dependencies: ["Kumo", "KumoCoding"])
    ]
)
