// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RingtoneUIKit",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "RingtoneUIKit",
            targets: ["RingtoneUIKit"]
        ),
    ],
    dependencies: [
        .package(path: "RingtoneKit")
    ],
    targets: [
        .target(
            name: "RingtoneUIKit",
            dependencies: ["RingtoneKit"]
        ),
        
    ]
)
