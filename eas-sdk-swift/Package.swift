// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "eas-sdk-swift",
    platforms: [.iOS(.v17), .watchOS(.v10)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "eas-sdk-swift",
            targets: ["eas-sdk-swift"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "eas-sdk-swift"),
        .testTarget(
            name: "eas-sdk-swiftTests",
            dependencies: ["eas-sdk-swift"]),
    ]
)
