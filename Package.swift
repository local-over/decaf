// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Cafaine",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "Cafaine",
            path: "Sources/Caffeinate"
        ),
    ]
)
