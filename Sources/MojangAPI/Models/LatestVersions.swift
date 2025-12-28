//
//  LatestVersions.swift
//  MojangAPI
//

import Foundation

/// 最新版本
public struct LatestVersions: Codable {

  /// 最新正式版
  public let release: String
  /// 最新快照版
  public let snapshot: String

  public init(release: String, snapshot: String) {
    self.release = release
    self.snapshot = snapshot
  }
}
