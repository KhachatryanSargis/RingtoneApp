// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RingtoneiOS",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "RingtoneiOS",
            targets: ["RingtoneiOS"]
        ),
    ],
    dependencies: [
        .package(path: "RingtoneUIKit"),
        .package(path: "RingtoneDiscoverScreen"),
        .package(path: "RingtoneFavoritesScreen"),
        .package(path: "RingtoneCreatedScreen")
    ],
    targets: [
        .target(
            name: "RingtoneiOS",
            dependencies: [
                "RingtoneUIKit",
                "RingtoneDiscoverScreen",
                "RingtoneFavoritesScreen",
                "RingtoneCreatedScreen"
            ]
        ),
    ]
)
