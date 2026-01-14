//
//  CFFileModule.swift
//  MojangAPI
//

import Foundation

/// CurseForge 文件模块
public struct CFFileModule: Codable, Hashable, Equatable {
  /// 模块名称
  public let name: String
  /// 指纹
  public let fingerprint: Int64
}
