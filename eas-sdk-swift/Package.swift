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
    dependencies: [
        .package(url: "https://github.com/Boilertalk/Web3.swift.git", from: "0.8.8")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "eas-sdk-swift",
            dependencies: [
                .product(name: "Web3", package: "Web3.swift"),
                .product(name: "Web3ContractABI", package: "Web3.swift"),
            ]),
        .testTarget(
            name: "eas-sdk-swiftTests",
            dependencies: ["eas-sdk-swift"]),
    ]
)
