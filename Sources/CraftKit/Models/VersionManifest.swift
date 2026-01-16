//
//  Models.swift
//  CraftKit
//

import Foundation

/// 版本清单响应
public struct VersionManifest: Codable {

  /// 最新版本信息
  public let latest: LatestVersions
  /// 所有版本列表
  public let versions: [VersionInfo]

  public init(latest: LatestVersions, versions: [VersionInfo]) {
    self.latest = latest
    self.versions = versions
  }
}
