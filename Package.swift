// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DogecoinSwift",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.ccb
        .library(
            name: "DogecoinSwift",
            targets: ["DogecoinSwift"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.4.1"),
        .package(url: "https://github.com/mathwallet/Secp256k1Swift", from: "2.0.0"),
        .package(url: "https://github.com/mathwallet/BIP39swift", from: "1.0.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DogecoinSwift",
            dependencies: ["CryptoSwift", "BIP39swift", "Secp256k1Swift", .product(name: "BIP32Swift", package: "Secp256k1Swift")]),
        .testTarget(
            name: "DogecoinSwiftTests",
            dependencies: ["DogecoinSwift"]
        ),
    ]
)
