// swift-tools-version:6.2
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
            exclude: ["Info.plist"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .target(
            name: "KumoCoding",
            dependencies: [],
            exclude: ["Info.plist"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "KumoTests",
            dependencies: ["Kumo", "KumoCoding"],
            exclude: ["Info.plist"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        )
    ]
)
