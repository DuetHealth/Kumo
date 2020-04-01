// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Kumo",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(name: "Kumo", targets: ["Kumo"])
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift", from: "5.0.0")
    ],
    targets: [
        .target(name: "Kumo", dependencies: ["RxSwift"], path: "Kumo"),
        .testTarget(name: "KumoTests", dependencies: ["Kumo"], path: "KumoTests")
    ]
)
