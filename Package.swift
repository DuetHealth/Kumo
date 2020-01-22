// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Kumo",
    products: [
        .library(name: "Kumo", targets: ["Kumo"])
    ],
    dependencies: [
        .package(url: "https://github.com/reactivex/rxswift.git", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "Kumo",
            dependencies: ["RxSwift"]
        ),
        .testTarget(
            name: "KumoTests",
            dependencies: ["Kumo", "RxSwift"]
        )
    ]
)
