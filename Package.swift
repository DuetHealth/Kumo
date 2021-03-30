// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Kumo",
    platforms: [
        .iOS(.v11),
        .tvOS(.v11),
        .macOS(.v10_13),
    ],
    products: [
        .library(name: "Kumo", targets: ["Kumo"]),
        .library(name: "KumoCoding", targets: ["KumoCoding"])
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift", from: "6.0.0")
    ],
    targets: [
        .target(name: "Kumo", dependencies: ["RxSwift", "KumoCoding"]),
        .target(name: "KumoCoding", dependencies: []),
        .testTarget(name: "KumoTests", dependencies: ["Kumo", "KumoCoding"])
    ]
)
