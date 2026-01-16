//
//  SkinVariant.swift
//  MojangAPI
//

import Foundation

/// Minecraft 皮肤模型类型
public enum SkinVariant: Sendable {
  /// Steve 模型（宽臂，经典模型）
  case classic
  /// Alex 模型（细臂，苗条模型）
  case slim

  /// 小写形式（用于 POST 请求）
  public var lowercased: String {
    switch self {
    case .classic: return "classic"
    case .slim: return "slim"
    }
  }

  /// 大写形式（API 响应格式）
  public var uppercased: String {
    switch self {
    case .classic: return "CLASSIC"
    case .slim: return "SLIM"
    }
  }
}

// MARK: - Codable

extension SkinVariant: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let value = try container.decode(String.self)

    // 支持大小写不敏感的解码
    switch value.uppercased() {
    case "CLASSIC":
      self = .classic
    case "SLIM":
      self = .slim
    default:
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Cannot initialize SkinVariant from invalid String value \(value)"
      )
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    // 编码时使用小写（用于 POST 请求）
    try container.encode(lowercased)
  }
}

// MARK: - RawRepresentable (for compatibility)

extension SkinVariant: RawRepresentable {
  public var rawValue: String {
    return uppercased
  }

  public init?(rawValue: String) {
    switch rawValue.uppercased() {
    case "CLASSIC":
      self = .classic
    case "SLIM":
      self = .slim
    default:
      return nil
    }
  }
}
