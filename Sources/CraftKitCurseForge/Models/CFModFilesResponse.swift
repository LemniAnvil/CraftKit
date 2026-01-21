//
//  CFModFilesResponse.swift
//  CraftKit
//

import Foundation

/// CurseForge mod files response
public struct CFModFilesResponse: Codable, Equatable {
  /// File list
  public let data: [CFFile]
  /// Pagination info
  public let pagination: CFPagination

  /// Whether the response is empty
  public var isEmpty: Bool {
    return data.isEmpty
  }

  /// Number of files
  public var count: Int {
    return data.count
  }
}
