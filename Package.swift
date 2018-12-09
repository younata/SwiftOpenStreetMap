// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "SwiftOpenStreetMap",
    products: [
        .library(name: "SwiftOpenStreetMap", targets: ["SwiftOpenStreetMap"]),
    ],
    dependencies: [
        .package(url: "https://github.com/antitypical/Result.git", .upToNextMinor(from: "4.0.0")),
        .package(url: "https://github.com/cbguder/CBGPromise.git", .upToNextMinor(from: "0.5.0")),
        .package(url: "https://github.com/younata/FutureHTTP.git", .upToNextMinor(from: "0.1.8")),
        .package(url: "https://github.com/swiftyjson/SwiftyJSON.git", .upToNextMinor(from: "4.2.0")),

        .package(url: "https://github.com/quick/Quick.git", .upToNextMinor(from: "1.3.2")),
        .package(url: "https://github.com/quick/Nimble.git", .upToNextMinor(from: "7.3.1"))
    ],
    targets: [
        .target(name: "SwiftOpenStreetMap", dependencies: ["Result", "CBGPromise", "FutureHTTP", "SwiftyJSON"]),
        .testTarget(name: "SwiftOpenStreetMapTests", dependencies: ["SwiftOpenStreetMap", "Quick", "Nimble"])
    ]
)
