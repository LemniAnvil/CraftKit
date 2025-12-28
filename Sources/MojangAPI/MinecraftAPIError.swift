//
//  MinecraftAPIError.swift
//  MojangAPI
//

import Foundation

/// Minecraft API 错误类型
public enum MinecraftAPIError: Error, LocalizedError {
  case invalidURL
  case networkError(Error)
  case decodingError(Error)
  case serverError(statusCode: Int)
  case timeout
  case invalidUUID(String)
  case emptyUUID
  case emptyPlayerName
  case playerNotFound(String)
  case apiError(path: String, message: String)
  case noSkinAvailable
  case noCapeAvailable
  case textureDownloadFailed
  case versionNotFound(String)

  public var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "无效的 URL"
    case .networkError(let error):
      return "网络错误: \(error.localizedDescription)"
    case .decodingError(let error):
      return "数据解析错误: \(error.localizedDescription)"
    case .serverError(let statusCode):
      return "服务器错误: HTTP \(statusCode)"
    case .timeout:
      return "请求超时"
    case .invalidUUID(let uuid):
      return "无效的 UUID: \(uuid)"
    case .emptyUUID:
      return "UUID 不能为空"
    case .emptyPlayerName:
      return "玩家名称不能为空"
    case .playerNotFound(let identifier):
      return "玩家不存在: \(identifier)"
    case .apiError(let path, let message):
      return "API 错误 [\(path)]: \(message)"
    case .noSkinAvailable:
      return "该玩家没有自定义皮肤"
    case .noCapeAvailable:
      return "该玩家没有披风"
    case .textureDownloadFailed:
      return "纹理下载失败"
    case .versionNotFound(let versionId):
      return "版本不存在: \(versionId)"
    }
  }
}

/// API 错误响应
struct APIErrorResponse: Codable {
  let path: String?
  let errorMessage: String?
  let error: String?
}
