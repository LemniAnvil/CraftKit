//
//  MicrosoftAuthConfiguration.swift
//  CraftKitAuth
//

import Foundation
import CraftKitCore

/// Configuration for Microsoft authentication flows.
public struct MicrosoftAuthConfiguration: APIConfiguration {
  public let timeout: TimeInterval
  public let cachePolicy: URLRequest.CachePolicy

  public init(
    timeout: TimeInterval = 30,
    cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
  ) {
    self.timeout = timeout
    self.cachePolicy = cachePolicy
  }
}
