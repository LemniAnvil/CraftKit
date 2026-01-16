//
//  CFFileIndex.swift
//  CraftKit
//

import Foundation

/// CurseForge 文件索引
public struct CFFileIndex: Codable, Hashable, Equatable {
  /// 游戏版本
  public let gameVersion: String
  /// 文件 ID
  public let fileId: Int
  /// 文件名
  public let filename: String
  /// 发布类型
  public let releaseType: Int
  /// 游戏版本类型 ID
  public let gameVersionTypeId: Int?
  /// Mod 加载器类型 (1=Forge, 4=Fabric, 5=Quilt, 6=NeoForge)
  public let modLoader: Int?

  /// Mod 加载器名称
  public var modLoaderName: String? {
    guard let modLoader = modLoader else { return nil }
    switch modLoader {
    case 1: return "Forge"
    case 4: return "Fabric"
    case 5: return "Quilt"
    case 6: return "NeoForge"
    default: return "未知"
    }
  }

  /// 发布类型名称
  public var releaseTypeName: String {
    switch releaseType {
    case 1: return "正式版"
    case 2: return "测试版"
    case 3: return "内测版"
    default: return "未知"
    }
  }
}
