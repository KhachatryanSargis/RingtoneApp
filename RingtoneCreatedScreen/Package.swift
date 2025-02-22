// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RingtoneCreatedScreen",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "RingtoneCreatedScreen",
            targets: ["RingtoneCreatedScreen"]
        ),
    ],
    dependencies: [.package(path: "RingtoneUIKit")],
    targets: [
        .target(
            name: "RingtoneCreatedScreen",
            dependencies: ["RingtoneUIKit"]
        ),
    ]
)
