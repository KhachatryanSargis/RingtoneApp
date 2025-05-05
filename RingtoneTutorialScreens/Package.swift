// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RingtoneTutorialScreens",
    products: [
        .library(
            name: "RingtoneTutorialScreens",
            targets: ["RingtoneTutorialScreens"]
        ),
    ],
    dependencies: [
        .package(path: "RingtoneUIKit")
    ],
    targets: [
        .target(
            name: "RingtoneTutorialScreens",
            dependencies: ["RingtoneUIKit"]
        ),
    ]
)
