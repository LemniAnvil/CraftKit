//
//  CFSocialLink.swift
//  CraftKit
//

import Foundation

/// CurseForge 社交链接
public struct CFSocialLink: Codable, Hashable, Equatable {
  /// 链接类型 (2=Discord, 3=Website, 10=YouTube 等)
  public let type: Int
  /// 链接 URL
  public let url: String

  /// 链接类型名称
  public var typeName: String {
    switch type {
    case 2: return "Discord"
    case 3: return "Website"
    case 10: return "YouTube"
    default: return "其他"
    }
  }
}
