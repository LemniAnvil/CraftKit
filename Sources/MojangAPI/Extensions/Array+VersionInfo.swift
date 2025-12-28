//
//  Array+VersionInfo.swift
//  MojangAPI
//

import Foundation

extension Array where Element == VersionInfo {

  /// 按发布时间排序
  public func sortedByReleaseDate(ascending: Bool = false) -> [VersionInfo] {
    return sorted {
      ascending
        ? $0.releaseTime < $1.releaseTime : $0.releaseTime > $1.releaseTime
    }
  }

  /// 按类型分组
  public func groupedByType() -> [VersionType: [VersionInfo]] {
    return Dictionary(grouping: self, by: { $0.type })
  }
}
