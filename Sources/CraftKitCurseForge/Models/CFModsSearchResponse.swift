//
//  CFModsSearchResponse.swift
//  CraftKit
//

import Foundation

/// CurseForge Mods 搜索响应
public struct CFModsSearchResponse: Codable, Equatable {
  /// Mod 列表
  public let data: [CFMod]
  /// 分页信息
  public let pagination: CFPagination

  /// 是否为空结果
  public var isEmpty: Bool {
    return data.isEmpty
  }

  /// 结果数量
  public var count: Int {
    return data.count
  }
}
