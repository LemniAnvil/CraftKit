//
//  APIConfiguration.swift
//  CraftKitCore
//

import Foundation

/// Shared API configuration contract used across CraftKit modules.
public protocol APIConfiguration {
  var timeout: TimeInterval { get }
  var cachePolicy: URLRequest.CachePolicy { get }
}
