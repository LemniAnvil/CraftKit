//
//  CFCategory.swift
//  CraftKit
//

import Foundation

/// CurseForge 分类
public struct CFCategory: Codable, Identifiable, Hashable, Equatable {
  /// 分类 ID
  public let id: Int
  /// 游戏 ID
  public let gameId: Int
  /// 分类名称
  public let name: String
  /// 分类 slug
  public let slug: String
  /// 分类 URL
  public let url: String
  /// 图标 URL
  public let iconUrl: String
  /// 最后修改日期
  public let dateModified: Date
  /// 是否为类别（class）
  public let isClass: Bool
  /// 类别 ID
  public let classId: Int?
  /// 父分类 ID
  public let parentCategoryId: Int?

  /// 是否为顶级分类
  public var isTopLevel: Bool {
    return parentCategoryId == nil || parentCategoryId == classId
  }
}
