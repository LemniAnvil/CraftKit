//
//  CFLogo.swift
//  MojangAPI
//

import Foundation

/// CurseForge Logo/图标信息
public struct CFLogo: Codable, Hashable, Equatable {
  /// Logo ID
  public let id: Int
  /// Mod ID
  public let modId: Int
  /// 标题
  public let title: String
  /// 描述
  public let description: String
  /// 缩略图 URL
  public let thumbnailUrl: String
  /// 完整图片 URL
  public let url: String
}
