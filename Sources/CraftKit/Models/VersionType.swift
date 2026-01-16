//
//  VersionType.swift
//  MojangAPI
//

import Foundation

/// 版本类型
public enum VersionType: String, Codable, CaseIterable {
  case release = "release"
  case snapshot = "snapshot"
  case oldBeta = "old_beta"
  case oldAlpha = "old_alpha"

  public var displayName: String {
    switch self {
    case .release: return "Release"
    case .snapshot: return "Snapshot"
    case .oldBeta: return "Beta"
    case .oldAlpha: return "Alpha"
    }
  }

  public var color: String {
    switch self {
    case .release: return "green"
    case .snapshot: return "orange"
    case .oldBeta: return "blue"
    case .oldAlpha: return "purple"
    }
  }
}
