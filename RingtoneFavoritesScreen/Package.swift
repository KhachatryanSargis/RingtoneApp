// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RingtoneFavoritesScreen",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "RingtoneFavoritesScreen",
            targets: ["RingtoneFavoritesScreen"]
        ),
    ],
    dependencies: [.package(path: "RingtoneUIKit")],
    targets: [
        .target(
            name: "RingtoneFavoritesScreen",
            dependencies: ["RingtoneUIKit"]
        ),
    ]
)
