// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RomanEmpire",
    platforms: [.iOS(.v15), .macOS(.v12), .watchOS(.v8), .tvOS(.v15)],
    products: [
        .library(name: "RomanEmpire", targets: ["RomanEmpire"]),
    ],
    dependencies: [
        .package(url: "https://github.com/OneSignal/OneSignal-XCFramework", from: "5.0.0"),
    ],
    targets: [
        .target(
            name: "RomanEmpire",
            dependencies: [
                .product(name: "OneSignalFramework", package: "OneSignal-XCFramework")
            ]
        ),
        .testTarget(
            name: "RomanEmpireTests",
            dependencies: ["RomanEmpire"]
        ),
    ]
)
