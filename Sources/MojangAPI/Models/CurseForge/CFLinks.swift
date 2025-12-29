//
//  CFLinks.swift
//  MojangAPI
//

import Foundation

/// CurseForge 链接信息
public struct CFLinks: Codable, Hashable, Equatable {
  /// 网站 URL
  public let websiteUrl: String
  /// Wiki URL
  public let wikiUrl: String?
  /// 问题追踪 URL
  public let issuesUrl: String?
  /// 源代码 URL
  public let sourceUrl: String?

  /// 是否有 Wiki
  public var hasWiki: Bool {
    return wikiUrl != nil
  }

  /// 是否有问题追踪
  public var hasIssueTracker: Bool {
    return issuesUrl != nil
  }

  /// 是否有源代码
  public var hasSourceCode: Bool {
    return sourceUrl != nil
  }
}
