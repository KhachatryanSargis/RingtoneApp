// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RingtoneKit",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "RingtoneKit",
            targets: ["RingtoneKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.0"))
    ],
    targets: [
        .target(
            name: "RingtoneKit",
            dependencies: [.product(name: "Alamofire", package: "Alamofire")]
        ),
        
    ]
)
