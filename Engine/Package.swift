// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HearthEngine",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "HearthEngine", targets: ["HearthEngine"]),
    ],
    targets: [
        .target(name: "HearthEngine"),
        .testTarget(name: "HearthEngineTests", dependencies: ["HearthEngine"]),
    ]
)
