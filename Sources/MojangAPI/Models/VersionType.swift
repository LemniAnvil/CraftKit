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
    case .release: return "正式版"
    case .snapshot: return "快照版"
    case .oldBeta: return "Beta"
    case .oldAlpha: return "Alpha"
    }
  }
}
