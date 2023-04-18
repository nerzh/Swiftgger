// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Swiftgger",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(name: "Swiftgger",targets: ["Swiftgger"]),
        .executable(name: "swiftgger-generator", targets: ["SwiftggerGenerator"]),
        .executable(name: "swiftgger-test-app", targets: ["SwiftggerTestApp"])
    ],
    dependencies: [
        .package(url: "https://github.com/Flight-School/AnyCodable", .upToNextMajor(from: "0.4.0")),
        .package(url: "https://github.com/nerzh/swift-extensions-pack", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .target(name: "Swiftgger", dependencies: [
            .product(name: "AnyCodable", package: "AnyCodable"),
            .product(name: "SwiftExtensionsPack", package: "swift-extensions-pack"),
        ]),
        .executableTarget(name: "SwiftggerGenerator",
                          dependencies: ["Swiftgger"],
                          resources: [
                              .process("URLSession.template")
                          ]),
        .executableTarget(name: "SwiftggerTestApp", dependencies: ["Swiftgger"]),
        .testTarget(name: "SwiftggerTests",
                    dependencies: ["Swiftgger"],
                    resources: [
                        .process("openapi.json")
                    ]
        )
    ]
)
