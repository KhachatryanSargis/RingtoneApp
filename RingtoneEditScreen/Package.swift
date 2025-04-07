// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RingtoneEditScreen",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "RingtoneEditScreen",
            targets: ["RingtoneEditScreen"]
        ),
    ],
    dependencies: [
        .package(path: "RingtoneUIKit"),
        .package(path: "RingtoneKit")
    ],
    targets: [
        .target(
            name: "RingtoneEditScreen",
            dependencies: [
                "RingtoneUIKit",
                "RingtoneKit"
            ]
        ),
    ]
)
