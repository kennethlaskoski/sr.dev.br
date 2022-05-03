// swift-tools-version: 5.6

import PackageDescription

let package = Package(
  name: "sr.dev.br",
  products: [
    .library(name: "Content", targets: ["Content"]),
    .library(name: "Engine", targets: ["Engine"]),
    .library(name: "Prelude", targets: ["Prelude"]),
    .executable(name: "Server", targets: ["Server"]),
  ],

  dependencies: [
    .package(url: "https://github.com/apple/swift-nio.git", .upToNextMajor(from: "2.0.0")),
    .package(url: "https://github.com/swift-server/swift-backtrace.git", .upToNextMajor(from: "1.0.0")),
  ],

  targets: [
      .target(
        name: "Content",
        dependencies: [
          "Prelude",
        ]),

      .target(
        name: "Engine",
        dependencies: [
          "Prelude",
          .product(name: "NIO", package: "swift-nio"),
          .product(name: "Backtrace", package: "swift-backtrace"),
        ]),

        .target(
          name: "Prelude"
        ),

      .executableTarget(
        name: "Server",
        dependencies: [
          "Engine",
        ]),

      .testTarget(
        name: "ServerTests",
        dependencies: ["Server"]),
  ]
)
