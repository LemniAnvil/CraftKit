//
//  CraftKit.swift
//  CraftKit
//
//  Umbrella module to preserve backward compatibility while modules split out.
//

@_exported import CraftKitCore
@_exported import CraftKitMojang
@_exported import CraftKitCurseForge
@_exported import CraftKitAuth

/// Version surface for the CraftKit umbrella module.
public struct CraftKitVersion {
  public static let current = "2.0.0"

  /// Module version mapping for optional dependency selection.
  public static let modules: [String: String] = [
    "Core": current,
    "Mojang": current,
    "CurseForge": current,
    "Auth": current,
  ]
}
