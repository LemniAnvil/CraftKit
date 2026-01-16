//
//  MicrosoftAuthError.swift
//  CraftKit
//

import Foundation

/// Microsoft 认证流程专用错误类型
public enum MicrosoftAuthError: LocalizedError {
  case invalidURL
  case stateMismatch
  case authCodeNotFound
  case httpError(statusCode: Int, message: String?)
  case xblAuthFailed(Error)
  case xstsAuthFailed(Error)
  case xstsError(code: Int, message: String)
  case minecraftAuthFailed(Error)
  case profileFetchFailed(Error)
  case azureAppNotPermitted
  case accountNotOwnMinecraft
  case invalidRefreshToken
  case networkError(Error)
  case decodingError(Error)

  public var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "无效的 URL"
    case .stateMismatch:
      return "State 参数不匹配 - 可能存在 CSRF 攻击"
    case .authCodeNotFound:
      return "回调 URL 中未找到授权码"
    case .httpError(let statusCode, let message):
      if let message = message {
        return "HTTP 错误 \(statusCode): \(message)"
      }
      return "HTTP 错误: \(statusCode)"
    case .xblAuthFailed(let error):
      return "Xbox Live 认证失败: \(error.localizedDescription)"
    case .xstsAuthFailed(let error):
      return "XSTS 认证失败: \(error.localizedDescription)"
    case .xstsError(let code, let message):
      return "XSTS 错误 \(code): \(message)"
    case .minecraftAuthFailed(let error):
      return "Minecraft 认证失败: \(error.localizedDescription)"
    case .profileFetchFailed(let error):
      return "获取 Minecraft 档案失败: \(error.localizedDescription)"
    case .azureAppNotPermitted:
      return "Azure 应用未获得访问 Minecraft API 的权限"
    case .accountNotOwnMinecraft:
      return "该账户未拥有 Minecraft"
    case .invalidRefreshToken:
      return "无效或已过期的刷新令牌"
    case .networkError(let error):
      return "网络错误: \(error.localizedDescription)"
    case .decodingError(let error):
      return "数据解析错误: \(error.localizedDescription)"
    }
  }
}

/// XSTS 错误响应
struct XSTSErrorResponse: Codable {
  let identity: String?
  let xerr: Int?
  let message: String?
  let redirect: String?

  enum CodingKeys: String, CodingKey {
    case identity = "Identity"
    case xerr = "XErr"
    case message = "Message"
    case redirect = "Redirect"
  }
}
