// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "FlooidCoreData",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "FlooidCoreData",
            targets: ["FlooidCoreData"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "FlooidCoreData",
            path: "FlooidCoreData",
            exclude: ["Info.plist", "FlooidCoreData.h"]
        )
    ]
)
