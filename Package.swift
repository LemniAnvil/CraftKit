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
      name: "CraftKit",
      dependencies: ["CraftKitCore"],
      path: "Sources/CraftKit"
    ),
    .testTarget(
      name: "CraftKitTests",
      dependencies: ["CraftKit"]
    ),
  ]
)
