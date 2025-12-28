//
//  PlayerProfile.swift
//  MojangAPI
//

import Foundation

/// 玩家档案
public struct PlayerProfile: Codable, Sendable {
  public let id: String
  public let name: String
  public let properties: [ProfileProperty]?
  public let profileActions: [String]?

  /// 获取纹理属性
  public func getTextureProperty() -> ProfileProperty? {
    return properties?.first { $0.name == "textures" }
  }

  /// 解码纹理载荷
  public func getTexturesPayload() throws -> TexturesPayload {
    guard let property = getTextureProperty() else {
      throw TextureError.noTextureProperty
    }
    return try property.decodeValue()
  }

  /// 获取皮肤 URL
  public func getSkinURL() -> URL? {
    return try? getTexturesPayload().textures.SKIN?.url
  }

  /// 获取披风 URL
  public func getCapeURL() -> URL? {
    return try? getTexturesPayload().textures.CAPE?.url
  }

  /// 获取皮肤模型类型
  public func getSkinModel() -> SkinModel {
    guard let metadata = try? getTexturesPayload().textures.SKIN?.metadata else {
      return .classic
    }
    return metadata.model == "slim" ? .slim : .classic
  }

  /// 检查是否有披风
  public var hasCape: Bool {
    return getCapeURL() != nil
  }

  /// 检查是否有自定义皮肤
  public var hasCustomSkin: Bool {
    return getSkinURL() != nil
  }

  /// 获取签名（用于验证）
  public func getSignature() -> String? {
    return getTextureProperty()?.signature
  }

  /// 检查是否有签名
  public var isSigned: Bool {
    return getSignature() != nil
  }

  /// 获取纹理时间戳
  public func getTextureTimestamp() -> Date? {
    guard let timestamp = try? getTexturesPayload().timestamp else {
      return nil
    }
    return Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000)
  }

  /// 获取皮肤纹理 ID（从 URL 提取）
  public func getSkinTextureId() -> String? {
    guard let url = getSkinURL() else { return nil }
    return url.lastPathComponent
  }

  /// 获取披风纹理 ID（从 URL 提取）
  public func getCapeTextureId() -> String? {
    guard let url = getCapeURL() else { return nil }
    return url.lastPathComponent
  }
}

/// 档案属性
public struct ProfileProperty: Codable, Sendable {
  public let name: String
  public let value: String
  public let signature: String?

  /// 解码 Base64 值
  public func decodeValue<T: Decodable>() throws -> T {
    guard let data = Data(base64Encoded: value) else {
      throw TextureError.invalidBase64
    }
    do {
      return try JSONDecoder().decode(T.self, from: data)
    } catch {
      throw TextureError.decodingFailed(error)
    }
  }

  /// 获取原始 JSON 字符串
  public func getRawJSON() throws -> String {
    guard let data = Data(base64Encoded: value),
          let json = String(data: data, encoding: .utf8) else {
      throw TextureError.invalidBase64
    }
    return json
  }
}

/// 皮肤模型类型
public enum SkinModel: String, Codable, Sendable {
  case classic = "classic"  // Steve 模型（默认）
  case slim = "slim"        // Alex 模型

  public var displayName: String {
    switch self {
    case .classic: return "经典 (Steve)"
    case .slim: return "纤细 (Alex)"
    }
  }
}

/// 纹理错误
public enum TextureError: Error, LocalizedError {
  case noTextureProperty
  case invalidBase64
  case decodingFailed(Error)

  public var errorDescription: String? {
    switch self {
    case .noTextureProperty:
      return "档案中没有纹理属性"
    case .invalidBase64:
      return "无效的 Base64 编码"
    case .decodingFailed(let error):
      return "纹理数据解码失败: \(error.localizedDescription)"
    }
  }
}

