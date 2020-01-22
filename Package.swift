// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Kumo",
    products: [
        .library(name: "Kumo", targets: ["Kumo"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Kumo",
            dependencies: [],
            path: "Kumo"
        ),
        .testTarget(
            name: "KumoTests",
            dependencies: ["Kumo"],
            path: "KumoTests"
        )
    ]
)
