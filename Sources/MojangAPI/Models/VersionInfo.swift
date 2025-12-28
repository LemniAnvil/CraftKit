//
//  VersionInfo.swift
//  MojangAPI
//

import Foundation

/// 版本信息
public struct VersionInfo: Codable, Identifiable {

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
  /// SHA1 校验和
  public let sha1: String
  /// 合规等级
  public let complianceLevel: Int

  public init(
    id: String,
    type: VersionType,
    url: String,
    time: Date,
    releaseTime: Date,
    sha1: String,
    complianceLevel: Int
  ) {
    self.id = id
    self.type = type
    self.url = url
    self.time = time
    self.releaseTime = releaseTime
    self.sha1 = sha1
    self.complianceLevel = complianceLevel
  }
}
