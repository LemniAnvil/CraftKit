// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "CraftKit",
  platforms: [
    .macOS(.v13),
    .iOS(.v15),
  ],
  products: [
    .library(
      name: "CraftKitCore",
      targets: ["CraftKitCore"]
    ),
    .library(
      name: "CraftKitMojang",
      targets: ["CraftKitMojang"]
    ),
    .library(
      name: "CraftKitCurseForge",
      targets: ["CraftKitCurseForge"]
    ),
    .library(
      name: "CraftKitAuth",
      targets: ["CraftKitAuth"]
    ),
    .library(
      name: "CraftKit",
      targets: ["CraftKit"]
    ),
  ],
  targets: [
    .target(
      name: "CraftKitCore",
      path: "Sources/CraftKitCore"
    ),
    .target(
      name: "CraftKitMojang",
      dependencies: ["CraftKitCore"],
      path: "Sources/CraftKitMojang"
    ),
    .target(
      name: "CraftKitCurseForge",
      dependencies: ["CraftKitCore"],
      path: "Sources/CraftKitCurseForge"
    ),
    .target(
      name: "CraftKitAuth",
      dependencies: ["CraftKitCore"],
      path: "Sources/CraftKitAuth"
    ),
    .target(
      name: "CraftKit",
      dependencies: [
        "CraftKitCore",
        "CraftKitMojang",
        "CraftKitCurseForge",
        "CraftKitAuth",
      ],
      path: "Sources/CraftKit"
    ),
    .testTarget(
      name: "CraftKitTests",
      dependencies: ["CraftKit"]
    ),
  ]
)
