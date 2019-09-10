// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Server",
    dependencies: [
        .package(url: "https://github.com/IBM-Swift/Kitura.git", .upToNextMinor(from: "2.8.1")),
        .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", .upToNextMinor(from: "1.9.0")),
        .package(
            url: "https://github.com/IBM-Swift/Kitura-StencilTemplateEngine.git",
            .upToNextMinor(from: "1.11.1")
        ),
    ],
    targets: [
        .target(
            name: "Server",
            dependencies: ["Kitura" , "HeliumLogger", "KituraStencil"]),
        .testTarget(
            name: "ServerTests",
            dependencies: ["Server"]),
    ]
)
