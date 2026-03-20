// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "Kumo",
    platforms: [
        .iOS(.v18),
        .tvOS(.v18),
        .macOS(.v15),
    ],
    products: [
        .library(name: "Kumo", targets: ["Kumo"]),
        .library(name: "KumoCoding", targets: ["KumoCoding"])
    ],
    targets: [
        .target(
            name: "Kumo",
            dependencies: ["KumoCoding"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .target(
            name: "KumoCoding",
            dependencies: [],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "KumoTests",
            dependencies: ["Kumo", "KumoCoding"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        )
    ]
)
