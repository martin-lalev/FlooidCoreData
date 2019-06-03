//
//  Package.swit.swift
//  FlooidCoreData
//
//  Created by Martin Lalev on 4.06.19.
//  Copyright © 2019 Martin Lalev. All rights reserved.
//


import PackageDescription

let package = Package(
    name: "FlooidCoreData",
    products: [
        .library(
            name: "FlooidCoreData",
            targets: ["FlooidCoreData"])
    ],
    targets: [
        .target(
            name: "FlooidCoreData",
            path: "FlooidCoreData")
    ],
    swiftLanguageVersions: [.v3, .v4, .v5]
)
