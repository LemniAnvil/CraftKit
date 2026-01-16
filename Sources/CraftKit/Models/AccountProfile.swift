//
//  AccountProfile.swift
//  CraftKit
//

import Foundation

/// 账户档案信息
///
/// 包含当前认证账户的完整信息，包括所有皮肤和披风。
public struct AccountProfile: Codable, Sendable {
  /// 玩家 UUID
  public let id: String

  /// 玩家用户名
  public let name: String

  /// 所有皮肤列表
  public let skins: [AccountSkin]

  /// 所有披风列表
  public let capes: [AccountCape]

  /// 获取当前激活的皮肤
  public var activeSkin: AccountSkin? {
    return skins.first { $0.state == .active }
  }

  /// 获取当前激活的披风
  public var activeCape: AccountCape? {
    return capes.first { $0.state == .active }
  }

  /// 检查是否有自定义皮肤
  public var hasCustomSkin: Bool {
    return activeSkin != nil
  }

  /// 检查是否有激活的披风
  public var hasCape: Bool {
    return activeCape != nil
  }
}

/// 账户皮肤信息
public struct AccountSkin: Codable, Sendable, Identifiable {
  /// 皮肤 ID
  public let id: String

  /// 激活状态
  public let state: SkinState

  /// 皮肤 URL
  public let url: String

  /// 纹理键（SHA-256 哈希值）
  public let textureKey: String

  /// 皮肤模型类型（classic 或 slim）
  public let variant: SkinVariant

  /// 皮肤别名（可选）
  public let alias: String?

  /// 是否为激活状态
  public var isActive: Bool {
    return state == .active
  }

  /// 获取 URL 对象
  public var urlObject: URL? {
    return URL(string: url)
  }
}

/// 账户披风信息
public struct AccountCape: Codable, Sendable, Identifiable {
  /// 披风 ID
  public let id: String

  /// 激活状态
  public let state: CapeState

  /// 披风 URL
  public let url: String

  /// 披风别名
  public let alias: String

  /// 是否为激活状态
  public var isActive: Bool {
    return state == .active
  }

  /// 获取 URL 对象
  public var urlObject: URL? {
    return URL(string: url)
  }
}

/// 皮肤状态
public enum SkinState: String, Codable, Sendable {
  case active = "ACTIVE"
  case inactive = "INACTIVE"

  public var displayName: String {
    switch self {
    case .active: return "激活"
    case .inactive: return "未激活"
    }
  }
}

/// 披风状态
public enum CapeState: String, Codable, Sendable {
  case active = "ACTIVE"
  case inactive = "INACTIVE"

  public var displayName: String {
    switch self {
    case .active: return "激活"
    case .inactive: return "未激活"
    }
  }
}
