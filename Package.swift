// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CryptoTracker",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "CryptoTracker",
            targets: ["CryptoTracker"]),
    ],
    targets: [
        .target(
            name: "CryptoTracker",
            dependencies: [],
            path: "CryptoTracker"),
        .testTarget(
            name: "CryptoTrackerTests",
            dependencies: ["CryptoTracker"],
            path: "Tests/CryptoTrackerTests"),
    ]
)
