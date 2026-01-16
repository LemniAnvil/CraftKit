//
//  CFFileHash.swift
//  CraftKit
//

import Foundation

/// CurseForge 文件哈希值
public struct CFFileHash: Codable, Hashable, Equatable {
  /// 哈希值
  public let value: String
  /// 算法类型 (1 = SHA1, 2 = MD5)
  public let algo: Int

  /// 算法名称
  public var algorithmName: String {
    switch algo {
    case 1: return "SHA1"
    case 2: return "MD5"
    default: return "Unknown"
    }
  }

  /// 是否为 SHA1
  public var isSHA1: Bool {
    return algo == 1
  }

  /// 是否为 MD5
  public var isMD5: Bool {
    return algo == 2
  }
}
