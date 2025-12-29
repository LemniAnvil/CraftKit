//
//  CFSortableGameVersion.swift
//  MojangAPI
//

import Foundation

/// CurseForge 可排序的游戏版本信息
public struct CFSortableGameVersion: Codable, Hashable, Equatable {
  /// 游戏版本名称
  public let gameVersionName: String
  /// 填充后的游戏版本（用于排序）
  public let gameVersionPadded: String
  /// 游戏版本
  public let gameVersion: String
  /// 游戏版本发布日期
  public let gameVersionReleaseDate: Date
  /// 游戏版本类型 ID
  public let gameVersionTypeId: Int?
}
