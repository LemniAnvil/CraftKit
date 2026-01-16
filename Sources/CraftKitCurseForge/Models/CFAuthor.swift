//
//  CFAuthor.swift
//  CraftKit
//

import Foundation

/// CurseForge 作者信息
public struct CFAuthor: Codable, Identifiable, Hashable, Equatable {
  /// 作者 ID
  public let id: Int
  /// 作者名称
  public let name: String
  /// 作者页面 URL
  public let url: String
  /// 头像 URL
  public let avatarUrl: String?

  /// 是否有头像
  public var hasAvatar: Bool {
    return avatarUrl != nil
  }
}
