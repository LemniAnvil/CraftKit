//
//  NetworkError.swift
//  CraftKitCore
//

import Foundation

/// Common network error surface shared by all API clients.
public enum NetworkError: Error {
  case invalidResponse
  case httpError(statusCode: Int, data: Data)
  case decodingError(Error)
  case networkError(Error)
}
