// swift-tools-version: 5.6

import PackageDescription

let package = Package(
  name: "sr.dev.br",
  products: [
    .library(name: "Network", targets: ["Network"]),
    .executable(name: "server", targets: ["server"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-nio.git", .upToNextMajor(from: "2.0.0")),
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0"),
  ],

  targets: [
    .target(
      name: "Network",
      dependencies: [
        .product(name: "NIOPosix", package: "swift-nio"),
        .product(name: "NIOCore", package: "swift-nio"),
      ]
    ),
    .testTarget(
      name: "NetworkTests",
      dependencies: ["Network"]
    ),

    .executableTarget(
      name: "server",
      dependencies: [
        "Network",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]
    ),
    .testTarget(
      name: "serverTests",
      dependencies: ["server"]
    ),
  ]
)
