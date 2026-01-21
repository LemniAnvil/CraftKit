//
//  CFCategoriesResponse.swift
//  CraftKit
//

import Foundation

/// CurseForge categories response
public struct CFCategoriesResponse: Codable, Equatable {
  /// Category list
  public let data: [CFCategory]

  /// Whether the response is empty
  public var isEmpty: Bool {
    return data.isEmpty
  }

  /// Number of categories
  public var count: Int {
    return data.count
  }
}
