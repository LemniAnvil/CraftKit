//
//  VersionInfo.swift
//  CraftKit
//

import Foundation

/// 版本信息
public struct VersionInfo: Codable, Identifiable, Hashable, Equatable {

  /// 版本 ID（如 "1.21.11"）
  public let id: String
  /// 版本类型
  public let type: VersionType
  /// 版本详情 URL
  public let url: String
  /// 最后更新时间
  public let time: Date
  /// 发布时间
  public let releaseTime: Date
  /// SHA1 校验和（仅在 v2 API 中可用）
  public let sha1: String?
  /// 合规等级（仅在 v2 API 中可用）
  public let complianceLevel: Int?

  public init(
    id: String,
    type: VersionType,
    url: String,
    time: Date,
    releaseTime: Date,
    sha1: String? = nil,
    complianceLevel: Int? = nil
  ) {
    self.id = id
    self.type = type
    self.url = url
    self.time = time
    self.releaseTime = releaseTime
    self.sha1 = sha1
    self.complianceLevel = complianceLevel
  }

  // MARK: - Codable

  enum CodingKeys: String, CodingKey {
    case id
    case type
    case url
    case time
    case releaseTime
    case sha1
    case complianceLevel
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    id = try container.decode(String.self, forKey: .id)
    type = try container.decode(VersionType.self, forKey: .type)
    url = try container.decode(String.self, forKey: .url)

    // Decode time - handle both String and Date
    if let timeString = try? container.decode(String.self, forKey: .time) {
      let formatter = ISO8601DateFormatter()
      formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
      if let date = formatter.date(from: timeString) {
        time = date
      } else {
        formatter.formatOptions = [.withInternetDateTime]
        time = formatter.date(from: timeString) ?? Date()
      }
    } else {
      time = try container.decode(Date.self, forKey: .time)
    }

    // Decode releaseTime - handle both String and Date
    if let releaseTimeString = try? container.decode(String.self, forKey: .releaseTime) {
      let formatter = ISO8601DateFormatter()
      formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
      if let date = formatter.date(from: releaseTimeString) {
        releaseTime = date
      } else {
        formatter.formatOptions = [.withInternetDateTime]
        releaseTime = formatter.date(from: releaseTimeString) ?? Date()
      }
    } else {
      releaseTime = try container.decode(Date.self, forKey: .releaseTime)
    }

    sha1 = try container.decodeIfPresent(String.self, forKey: .sha1)
    complianceLevel = try container.decodeIfPresent(Int.self, forKey: .complianceLevel)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(id, forKey: .id)
    try container.encode(type, forKey: .type)
    try container.encode(url, forKey: .url)

    // Encode as ISO8601 string
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    try container.encode(formatter.string(from: time), forKey: .time)
    try container.encode(formatter.string(from: releaseTime), forKey: .releaseTime)

    try container.encodeIfPresent(sha1, forKey: .sha1)
    try container.encodeIfPresent(complianceLevel, forKey: .complianceLevel)
  }

  // MARK: - Hashable & Equatable

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  public static func == (lhs: VersionInfo, rhs: VersionInfo) -> Bool {
    lhs.id == rhs.id
  }
}
