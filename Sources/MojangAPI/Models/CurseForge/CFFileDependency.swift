//
//  CFFileDependency.swift
//  MojangAPI
//

import Foundation

/// CurseForge 文件依赖
public struct CFFileDependency: Codable, Hashable, Equatable {
  /// 依赖的 Mod ID
  public let modId: Int
  /// 依赖类型 (1=嵌入, 2=可选, 3=必需, 4=工具, 5=不兼容, 6=包含)
  public let relationType: Int

  /// 依赖关系类型名称
  public var relationTypeName: String {
    switch relationType {
    case 1: return "嵌入"
    case 2: return "可选"
    case 3: return "必需"
    case 4: return "工具"
    case 5: return "不兼容"
    case 6: return "包含"
    default: return "未知"
    }
  }

  /// 是否为必需依赖
  public var isRequired: Bool {
    return relationType == 3
  }

  /// 是否为可选依赖
  public var isOptional: Bool {
    return relationType == 2
  }
}
