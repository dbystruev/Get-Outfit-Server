// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Server",
    dependencies: [
        .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", .upToNextMajor(from: "1.9.0")),
        .package(url: "https://github.com/IBM-Swift/Kitura.git", .upToNextMajor(from: "2.8.1")),
        .package(url: "https://github.com/IBM-Swift/Kitura-redis.git", .upToNextMajor(from: "2.1.1")),
        .package(url: "https://github.com/IBM-Swift/Kitura-StencilTemplateEngine.git", .upToNextMajor(from: "1.11.1")),
        .package(url: "https://github.com/IBM-Swift/swift-html-entities.git", .upToNextMajor(from: "3.0.13")),
        .package(url: "https://github.com/IBM-Swift/Kitura-CORS.git", from: "2.1.1"),
    ],
    targets: [
        .target(
            name: "Server",
            dependencies: [
                "HeliumLogger",
                "HTMLEntities",
                "Kitura",
                "KituraCORS",
                "KituraStencil",
                "SwiftRedis",
            ]
        ),
        .testTarget(
            name: "ServerTests",
            dependencies: ["Server"]),
    ]
)
