//
//  CFPagination.swift
//  MojangAPI
//

import Foundation

/// CurseForge API 分页信息
public struct CFPagination: Codable, Equatable {
  /// 当前页偏移量
  public let index: Int
  /// 每页结果数
  public let pageSize: Int
  /// 当前页实际结果数
  public let resultCount: Int
  /// 总结果数
  public let totalCount: Int

  /// 总页数
  public var totalPages: Int {
    return (totalCount + pageSize - 1) / pageSize
  }

  /// 当前页码（从 1 开始）
  public var currentPage: Int {
    return (index / pageSize) + 1
  }

  /// 是否有下一页
  public var hasNextPage: Bool {
    return index + pageSize < totalCount
  }

  /// 是否有上一页
  public var hasPreviousPage: Bool {
    return index > 0
  }

  /// 下一页的 index
  public var nextIndex: Int? {
    return hasNextPage ? index + pageSize : nil
  }

  /// 上一页的 index
  public var previousIndex: Int? {
    return hasPreviousPage ? max(0, index - pageSize) : nil
  }
}
