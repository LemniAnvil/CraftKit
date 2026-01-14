//
//  CFServerAffiliation.swift
//  MojangAPI
//

import Foundation

/// CurseForge 服务器联属信息
public struct CFServerAffiliation: Codable, Hashable, Equatable {
  /// 是否启用
  public let isEnabled: Bool
  /// 是否使用默认横幅
  public let isDefaultBanner: Bool
  /// 是否有折扣
  public let hasDiscount: Bool
  /// 联属服务 (2=Nodecraft 等)
  public let affiliationService: Int
  /// 自定义图片 URL
  public let customImageUrl: String?
  /// 联属链接
  public let affiliationLink: String?

  /// 服务名称
  public var serviceName: String {
    switch affiliationService {
    case 2: return "Nodecraft"
    default: return "未知服务"
    }
  }
}
