// swift-tools-version: 5.9
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
