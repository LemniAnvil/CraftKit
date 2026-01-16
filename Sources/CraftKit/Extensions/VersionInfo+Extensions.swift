//
//  VersionInfo+Extensions.swift
//  MojangAPI
//

import Foundation

extension VersionInfo {

  /// 是否为最新正式版
  public func isLatestRelease(in manifest: VersionManifest) -> Bool {
    return self.id == manifest.latest.release && self.type == .release
  }

  /// 是否为最新快照版
  public func isLatestSnapshot(in manifest: VersionManifest) -> Bool {
    return self.id == manifest.latest.snapshot && self.type == .snapshot
  }

  /// 格式化的发布时间
  public var formattedReleaseDate: String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter.string(from: releaseTime)
  }

  /// 是否来自 v2 API（包含额外的元数据）
  public var isFromV2API: Bool {
    sha1 != nil && complianceLevel != nil
  }

  /// 是否有 SHA1 校验和
  public var hasSHA1: Bool {
    sha1 != nil
  }

  /// 是否有合规等级信息
  public var hasComplianceLevel: Bool {
    complianceLevel != nil
  }
}
