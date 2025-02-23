// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RingtoneDiscoverScreen",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "RingtoneDiscoverScreen",
            targets: ["RingtoneDiscoverScreen"]
        ),
    ],
    dependencies: [.package(path: "RingtoneUIKit")],
    targets: [
        .target(
            name: "RingtoneDiscoverScreen",
            dependencies: ["RingtoneUIKit"]
        ),
    ]
)
