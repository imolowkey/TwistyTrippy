// swift-tools-version: 5.9
//
//  Package.swift
//  TwistyTrippy
//
//  Created by Mohi on October 8, 2026.
//

import PackageDescription

let package = Package(
    name: "TwistyTrippy",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "TwistyTrippy", targets: ["TwistyTrippy"])
    ],
    targets: [
        .target(name: "TwistyTrippy")
    ]
)
