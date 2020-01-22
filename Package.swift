// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Kumo",
    products: [
        .library(name: "Kumo", targets: ["Kumo"])
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "Kumo",
            dependencies: ["RxSwift", "RxCocoa"]
        ),
        .testTarget(
            name: "KumoTests",
            dependencies: ["Kumo", "RxSwift", "RxCocoa"]
        )
    ]
)
