// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RingtoneImportScreens",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "RingtoneImportScreens",
            targets: ["RingtoneImportScreens"]
        ),
    ],
    dependencies: [.package(path: "RingtoneUIKit")],
    targets: [
        .target(
            name: "RingtoneImportScreens",
            dependencies: ["RingtoneUIKit"]
        ),
    ]
)
