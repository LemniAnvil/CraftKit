//
//  BaseAPIClient.swift
//  CraftKitCore
//

import Foundation

/// 基础 API 客户端 - 提供共享的网络请求功能
public final class BaseAPIClient {

  // MARK: - Properties

  public let session: URLSession
  public let decoder: JSONDecoder

  // MARK: - Initialization

  public init(
    configuration: APIConfiguration,
    dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .iso8601
  ) {
    // 配置 URLSession
    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = configuration.timeout
    config.requestCachePolicy = configuration.cachePolicy
    self.session = URLSession(configuration: config)

    // 配置 JSON 解码器
    self.decoder = JSONDecoder()
    self.decoder.dateDecodingStrategy = dateDecodingStrategy
  }

  // MARK: - Request Methods

  /// 执行 GET 请求
  /// - Parameters:
  ///   - url: 请求 URL
  ///   - headers: 自定义请求头
  /// - Returns: 解码后的响应数据
  public func get<T: Decodable>(
    url: URL,
    headers: [String: String] = [:]
  ) async throws -> T {
    var request = URLRequest(url: url)
    request.httpMethod = "GET"

    // 添加自定义请求头
    for (key, value) in headers {
      request.setValue(value, forHTTPHeaderField: key)
    }

    return try await performRequest(request: request)
  }

  /// 执行 POST 请求
  /// - Parameters:
  ///   - url: 请求 URL
  ///   - body: 请求体（可编码对象）
  ///   - headers: 自定义请求头
  /// - Returns: 响应数据
  public func post<T: Encodable>(
    url: URL,
    body: T,
    headers: [String: String] = [:]
  ) async throws -> Data {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    // 添加自定义请求头
    for (key, value) in headers {
      request.setValue(value, forHTTPHeaderField: key)
    }

    // 编码请求体
    request.httpBody = try JSONEncoder().encode(body)

    let (data, response) = try await session.data(for: request)
    try validateResponse(response: response, data: data)

    return data
  }

  /// 执行 POST 请求（原始数据）
  /// - Parameters:
  ///   - url: 请求 URL
  ///   - body: 原始请求体数据
  ///   - headers: 自定义请求头
  /// - Returns: 响应数据
  public func postRaw(
    url: URL,
    body: Data,
    headers: [String: String] = [:]
  ) async throws -> Data {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = body

    // 添加自定义请求头
    for (key, value) in headers {
      request.setValue(value, forHTTPHeaderField: key)
    }

    let (data, response) = try await session.data(for: request)
    try validateResponse(response: response, data: data)

    return data
  }

  /// 执行 DELETE 请求
  /// - Parameters:
  ///   - url: 请求 URL
  ///   - headers: 自定义请求头
  /// - Returns: 响应数据
  public func delete(
    url: URL,
    headers: [String: String] = [:]
  ) async throws -> Data {
    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"

    // 添加自定义请求头
    for (key, value) in headers {
      request.setValue(value, forHTTPHeaderField: key)
    }

    let (data, response) = try await session.data(for: request)
    try validateResponse(response: response, data: data)

    return data
  }

  // MARK: - Private Methods

  /// 执行网络请求并解码响应
  private func performRequest<T: Decodable>(request: URLRequest) async throws -> T {
    let (data, response) = try await session.data(for: request)
    try validateResponse(response: response, data: data)

    do {
      return try decoder.decode(T.self, from: data)
    } catch {
      throw NetworkError.decodingError(error)
    }
  }

  /// 验证 HTTP 响应
  private func validateResponse(response: URLResponse, data: Data) throws {
    guard let httpResponse = response as? HTTPURLResponse else {
      throw NetworkError.invalidResponse
    }

    guard (200...299).contains(httpResponse.statusCode) else {
      throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
    }
  }
}
