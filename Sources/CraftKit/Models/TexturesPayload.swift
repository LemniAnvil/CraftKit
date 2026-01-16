//
//  TexturesPayload.swift
//  CraftKit
//

import Foundation

/// 纹理载荷（Base64 解码后的内容）
public struct TexturesPayload: Codable, Sendable {
  public let timestamp: Int64
  public let profileId: String
  public let profileName: String
  public let signatureRequired: Bool?
  public let textures: Textures

  /// 获取时间戳对应的日期
  public var timestampDate: Date {
    return Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000)
  }

  /// 格式化的时间戳
  public var formattedTimestamp: String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .medium
    return formatter.string(from: timestampDate)
  }
}

/// 纹理集合
public struct Textures: Codable, Sendable {
  public let SKIN: TextureInfo?
  public let CAPE: TextureInfo?

  /// 检查是否有任何纹理
  public var isEmpty: Bool {
    return SKIN == nil && CAPE == nil
  }

  /// 获取所有可用纹理类型
  public var availableTypes: [TextureType] {
    var types: [TextureType] = []
    if SKIN != nil { types.append(.skin) }
    if CAPE != nil { types.append(.cape) }
    return types
  }
}

/// 纹理类型
public enum TextureType: String, CaseIterable, Sendable {
  case skin = "SKIN"
  case cape = "CAPE"
  
  public var displayName: String {
    switch self {
    case .skin: return "皮肤"
    case .cape: return "披风"
    }
  }
}

/// 纹理信息
public struct TextureInfo: Codable, Sendable {
  public let url: URL
  public let metadata: TextureMetadata?

  /// 获取纹理 ID（URL 最后一段）
  public var textureId: String {
    return url.lastPathComponent
  }

  /// 获取皮肤模型（仅对皮肤有效）
  public var skinModel: SkinModel {
    guard let model = metadata?.model else {
      return .classic
    }
    return model == "slim" ? .slim : .classic
  }
}

/// 纹理元数据
public struct TextureMetadata: Codable, Sendable {
  public let model: String?
}
