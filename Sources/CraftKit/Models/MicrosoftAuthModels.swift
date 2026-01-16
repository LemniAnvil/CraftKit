//
//  MicrosoftAuthModels.swift
//  MojangAPI
//
//  Microsoft OAuth 2.0 认证模型
//

import Foundation

// MARK: - Microsoft Token 响应

/// Microsoft OAuth 2.0 Token 响应
public struct MicrosoftTokenResponse: Codable, Sendable {
  /// 访问令牌
  public let accessToken: String

  /// 令牌类型（通常为 "Bearer"）
  public let tokenType: String

  /// 令牌过期时间（秒）
  public let expiresIn: Int

  /// 刷新令牌
  public let refreshToken: String?

  /// 授权范围
  public let scope: String

  /// 扩展过期时间（秒）
  public let extExpiresIn: Int?

  enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
    case tokenType = "token_type"
    case expiresIn = "expires_in"
    case refreshToken = "refresh_token"
    case scope
    case extExpiresIn = "ext_expires_in"
  }

  public init(
    accessToken: String,
    tokenType: String,
    expiresIn: Int,
    refreshToken: String? = nil,
    scope: String,
    extExpiresIn: Int? = nil
  ) {
    self.accessToken = accessToken
    self.tokenType = tokenType
    self.expiresIn = expiresIn
    self.refreshToken = refreshToken
    self.scope = scope
    self.extExpiresIn = extExpiresIn
  }
}

/// Microsoft OAuth 2.0 授权令牌响应（类型别名）
///
/// 这是 `MicrosoftTokenResponse` 的别名，用于向后兼容和语义清晰。
/// 在 Microsoft OAuth 2.0 认证流程中，此响应包含访问令牌、刷新令牌等信息。
public typealias AuthorizationTokenResponse = MicrosoftTokenResponse

// MARK: - Xbox Live 认证

/// Xbox Live 认证请求
public struct XBLAuthRequest: Codable, Sendable {
  public let properties: XBLProperties
  public let relyingParty: String
  public let tokenType: String

  enum CodingKeys: String, CodingKey {
    case properties = "Properties"
    case relyingParty = "RelyingParty"
    case tokenType = "TokenType"
  }

  public init(accessToken: String) {
    self.properties = XBLProperties(
      authMethod: "RPS",
      siteName: "user.auth.xboxlive.com",
      rpsTicket: "d=\(accessToken)"
    )
    self.relyingParty = "http://auth.xboxlive.com"
    self.tokenType = "JWT"
  }
}

/// Xbox Live 属性
public struct XBLProperties: Codable, Sendable {
  public let authMethod: String
  public let siteName: String
  public let rpsTicket: String

  enum CodingKeys: String, CodingKey {
    case authMethod = "AuthMethod"
    case siteName = "SiteName"
    case rpsTicket = "RpsTicket"
  }

  public init(authMethod: String, siteName: String, rpsTicket: String) {
    self.authMethod = authMethod
    self.siteName = siteName
    self.rpsTicket = rpsTicket
  }
}

/// Xbox Live 认证响应
public struct XBLAuthResponse: Codable, Sendable {
  /// 签发时间
  public let issueInstant: String

  /// 过期时间
  public let notAfter: String

  /// Xbox Live 令牌
  public let token: String

  /// 显示声明（包含用户哈希）
  public let displayClaims: DisplayClaims

  enum CodingKeys: String, CodingKey {
    case issueInstant = "IssueInstant"
    case notAfter = "NotAfter"
    case token = "Token"
    case displayClaims = "DisplayClaims"
  }

  public init(
    issueInstant: String,
    notAfter: String,
    token: String,
    displayClaims: DisplayClaims
  ) {
    self.issueInstant = issueInstant
    self.notAfter = notAfter
    self.token = token
    self.displayClaims = displayClaims
  }
}

/// 显示声明
public struct DisplayClaims: Codable, Sendable {
  public let xui: [XUIElement]

  public init(xui: [XUIElement]) {
    self.xui = xui
  }
}

/// XUI 元素
public struct XUIElement: Codable, Sendable {
  /// 用户哈希
  public let uhs: String

  public init(uhs: String) {
    self.uhs = uhs
  }
}

// MARK: - XSTS 认证

/// XSTS 认证请求
public struct XSTSAuthRequest: Codable, Sendable {
  public let properties: XSTSProperties
  public let relyingParty: String
  public let tokenType: String

  enum CodingKeys: String, CodingKey {
    case properties = "Properties"
    case relyingParty = "RelyingParty"
    case tokenType = "TokenType"
  }

  public init(xblToken: String) {
    self.properties = XSTSProperties(
      sandboxId: "RETAIL",
      userTokens: [xblToken]
    )
    self.relyingParty = "rp://api.minecraftservices.com/"
    self.tokenType = "JWT"
  }
}

/// XSTS 属性
public struct XSTSProperties: Codable, Sendable {
  public let sandboxId: String
  public let userTokens: [String]

  enum CodingKeys: String, CodingKey {
    case sandboxId = "SandboxId"
    case userTokens = "UserTokens"
  }

  public init(sandboxId: String, userTokens: [String]) {
    self.sandboxId = sandboxId
    self.userTokens = userTokens
  }
}

/// XSTS 认证响应（与 XBL 响应结构相同）
public typealias XSTSAuthResponse = XBLAuthResponse

// MARK: - Minecraft 认证

/// Minecraft 认证请求
public struct MinecraftAuthRequest: Codable, Sendable {
  /// 身份令牌（格式：XBL3.0 x={userHash};{xstsToken}）
  public let identityToken: String

  /// 使用用户哈希和 XSTS 令牌创建请求
  public init(userHash: String, xstsToken: String) {
    self.identityToken = "XBL3.0 x=\(userHash);\(xstsToken)"
  }

  /// 使用预构建的身份令牌创建请求
  public init(identityToken: String) {
    self.identityToken = identityToken
  }
}

/// Minecraft 认证响应
public struct MinecraftAuthResponse: Codable, Sendable {
  /// 用户名
  public let username: String?

  /// 角色列表
  public let roles: [String]?

  /// Minecraft 访问令牌
  public let accessToken: String

  /// 令牌类型
  public let tokenType: String

  /// 令牌过期时间（秒）
  public let expiresIn: Int

  enum CodingKeys: String, CodingKey {
    case username
    case roles
    case accessToken = "access_token"
    case tokenType = "token_type"
    case expiresIn = "expires_in"
  }
}

// MARK: - Minecraft 档案

/// 纹理状态
public enum TextureState: String, Codable, Sendable {
  case active = "ACTIVE"
  case inactive = "INACTIVE"
}

/// Minecraft 档案响应
public struct MinecraftProfileResponse: Codable, Sendable {
  /// 玩家 UUID
  public let id: String

  /// 玩家用户名
  public let name: String

  /// 玩家皮肤列表
  public let skins: [SkinInfo]?

  /// 玩家披风列表
  public let capes: [CapeInfo]?

  public init(
    id: String,
    name: String,
    skins: [SkinInfo]? = nil,
    capes: [CapeInfo]? = nil
  ) {
    self.id = id
    self.name = name
    self.skins = skins
    self.capes = capes
  }
}

/// 皮肤信息
public struct SkinInfo: Codable, Sendable {
  /// 皮肤 ID
  public let id: String

  /// 皮肤 URL
  public let url: String

  /// 皮肤元数据
  public let metadata: SkinInfoMetadata?

  /// 皮肤状态
  public let state: TextureState

  /// 皮肤变体
  public let variant: String?

  /// 皮肤别名
  public let alias: String?

  public init(
    id: String,
    url: String,
    metadata: SkinInfoMetadata? = nil,
    state: TextureState = .active,
    variant: String? = nil,
    alias: String? = nil
  ) {
    self.id = id
    self.url = url
    self.metadata = metadata
    self.state = state
    self.variant = variant
    self.alias = alias
  }
}

/// 皮肤元数据
public struct SkinInfoMetadata: Codable, Sendable {
  /// 皮肤模型类型
  public let model: String

  public init(model: String) {
    self.model = model
  }
}

/// 披风信息
public struct CapeInfo: Codable, Sendable {
  /// 披风 ID
  public let id: String

  /// 披风 URL
  public let url: String

  /// 披风状态
  public let state: TextureState

  /// 披风别名
  public let alias: String?

  public init(id: String, url: String, state: TextureState = .active, alias: String? = nil) {
    self.id = id
    self.url = url
    self.state = state
    self.alias = alias
  }
}

// MARK: - 完整登录响应

/// 完整登录响应
///
/// 包含成功认证后所需的所有信息
public struct CompleteLoginResponse: Codable {
  /// 玩家 UUID
  public let id: String

  /// 玩家用户名
  public let name: String

  /// Minecraft 访问令牌（用于 API 调用）
  public let accessToken: String

  /// Microsoft 刷新令牌（用于刷新会话）
  public let refreshToken: String

  /// 玩家皮肤列表
  public let skins: [SkinInfo]?

  /// 玩家披风列表
  public let capes: [CapeInfo]?

  /// 响应创建时间戳
  public let timestamp: Date

  public init(
    id: String,
    name: String,
    accessToken: String,
    refreshToken: String,
    skins: [SkinInfo]?,
    capes: [CapeInfo]?
  ) {
    self.id = id
    self.name = name
    self.accessToken = accessToken
    self.refreshToken = refreshToken
    self.skins = skins
    self.capes = capes
    self.timestamp = Date()
  }
}
