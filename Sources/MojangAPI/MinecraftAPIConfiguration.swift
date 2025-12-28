//
//  MinecraftAPIConfiguration.swift
//  MojangAPI
//

import Foundation

/// Minecraft API 客户端配置
public struct MinecraftAPIConfiguration {

  public let versionBaseURL: String
  public let servicesBaseURL: String
  public let sessionServerBaseURL: String
  public let timeout: TimeInterval
  public let cachePolicy: URLRequest.CachePolicy

  public init(
    versionBaseURL: String = "https://piston-meta.mojang.com",
    servicesBaseURL: String = "https://api.minecraftservices.com",
    sessionServerBaseURL: String = "https://sessionserver.mojang.com",
    timeout: TimeInterval = 30,
    cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
  ) {
    self.versionBaseURL = versionBaseURL
    self.servicesBaseURL = servicesBaseURL
    self.sessionServerBaseURL = sessionServerBaseURL
    self.timeout = timeout
    self.cachePolicy = cachePolicy
  }
}
