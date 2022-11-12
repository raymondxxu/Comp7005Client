// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Client",
    dependencies: [
        .package(url: "https://github.com/raymondxxu/Comp7005FinalProjectCommonLib", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "Client",
            dependencies: [
                .product(name: "CommonLib", package: "Comp7005FinalProjectCommonLib")
            ]),
        .testTarget(
            name: "ClientTests",
            dependencies: ["Client"]),
    ]
)
