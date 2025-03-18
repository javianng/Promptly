// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Promptly",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "Promptly",
            targets: ["Promptly"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Promptly",
            dependencies: [],
            path: "Sources/Promptly"
        ),
        .testTarget(
            name: "PromptlyTests",
            dependencies: ["Promptly"],
            path: "Tests/PromptlyTests"
        )
    ]
) 