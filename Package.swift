import PackageDescription

let package = Package(
    name: "SwiftOpenStreetMap",
    dependencies: [
        .Package(url: "https://github.com/antitypical/Result.git", majorVersion: 3),
        .Package(url: "https://github.com/cbguder/CBGPromise.git", majorVersion: 0, minor: 4),
        .Package(url: "https://github.com/younata/FutureHTTP.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", majorVersion: 3),
    ]
)
