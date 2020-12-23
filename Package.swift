// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "SwiftOpenStreetMap",
    products: [
        .library(name: "SwiftOpenStreetMap", targets: ["SwiftOpenStreetMap"]),
    ],
    dependencies: [
        .package(url: "https://github.com/cbguder/CBGPromise.git", .upToNextMinor(from: "0.6.0")),
        .package(url: "https://github.com/younata/FutureHTTP.git", .upToNextMinor(from: "1.2.0")),

        .package(url: "https://github.com/quick/Quick.git", .upToNextMinor(from: "3.0.0")),
        .package(url: "https://github.com/quick/Nimble.git", .upToNextMinor(from: "9.0.0"))
    ],
    targets: [
        .target(name: "SwiftOpenStreetMap", dependencies: ["CBGPromise", "FutureHTTP"]),
        .testTarget(name: "SwiftOpenStreetMapTests", dependencies: ["SwiftOpenStreetMap", "Quick", "Nimble"])
    ]
)
