//
//  MicrosoftAuthClient.swift
//  CraftKit
//
//  Microsoft OAuth 2.0 认证客户端
//  处理完整的 Microsoft → Xbox Live → XSTS → Minecraft 认证流程
//

import Foundation
import CraftKitCore

/// Microsoft 认证客户端
///
/// 提供 Microsoft OAuth 2.0 认证流程方法，无 UI 依赖。
/// 应用层需要负责：
/// - 在浏览器中打开授权 URL
/// - 监听回调 URL
/// - 将回调 URL 提供给此客户端
///
/// 使用示例：
/// ```swift
/// let client = MicrosoftAuthClient(
///   clientID: "your-client-id",
///   redirectURI: "your-app://auth"
/// )
///
/// // 1. 生成登录 URL
/// let loginData = try client.generateLoginURL()
/// // 在浏览器中打开 loginData.url（应用层负责）
///
/// // 2. 解析回调 URL（用户授权后）
/// let authCode = try client.parseCallback(
///   url: callbackURL,
///   expectedState: loginData.state
/// )
///
/// // 3. 完成登录
/// let response = try await client.completeLogin(
///   authCode: authCode,
///   codeVerifier: loginData.codeVerifier
/// )
/// ```
public class MicrosoftAuthClient {

  // MARK: - 属性

  /// Microsoft 应用客户端 ID
  public let clientID: String

  /// OAuth 重定向 URI
  public let redirectURI: String

  /// OAuth 授权范围
  public let scope: String

  /// 基础 API 客户端
  private let baseClient: BaseAPIClient

  // MARK: - API 端点

  private let microsoftAuthURL = "https://login.microsoftonline.com/consumers/oauth2/v2.0/authorize"
  private let microsoftTokenURL = "https://login.microsoftonline.com/consumers/oauth2/v2.0/token"
  private let microsoftRefreshURL = "https://login.live.com/oauth20_token.srf"
  private let xboxLiveAuthURL = "https://user.auth.xboxlive.com/user/authenticate"
  private let xstsAuthURL = "https://xsts.auth.xboxlive.com/xsts/authorize"
  private let minecraftAuthURL = "https://api.minecraftservices.com/authentication/login_with_xbox"
  private let minecraftProfileURL = "https://api.minecraftservices.com/minecraft/profile"

  // MARK: - 初始化

  /// 初始化 Microsoft 认证客户端
  ///
  /// - Parameters:
  ///   - clientID: Microsoft 应用客户端 ID（从 Azure 门户获取）
  ///   - redirectURI: OAuth 重定向 URI（例如 "myapp://auth"）
  ///   - scope: OAuth 授权范围（默认："XboxLive.signin offline_access"）
  ///   - configuration: API 配置
  public init(
    clientID: String,
    redirectURI: String,
    scope: String = "XboxLive.signin offline_access",
    session: URLSession? = nil,
    configuration: APIConfiguration = MicrosoftAuthConfiguration()
  ) {
    self.clientID = clientID
    self.redirectURI = redirectURI
    self.scope = scope
    self.baseClient = BaseAPIClient(
      configuration: configuration,
      session: session,
      dateDecodingStrategy: .iso8601
    )
  }

  // MARK: - 登录数据结构

  /// 安全登录数据，包含 URL 和安全参数
  public struct LoginData {
    /// 授权 URL（在浏览器中打开）
    public let url: URL

    /// CSRF 保护 state（必须在回调中验证）
    public let state: String

    /// PKCE 代码验证器（交换授权码时使用）
    public let codeVerifier: String
  }

  // MARK: - 步骤 1：生成登录 URL

  /// 生成带 PKCE 和 state 参数的授权 URL
  ///
  /// 应用应在浏览器中打开此 URL 供用户认证。
  ///
  /// - Returns: 包含 URL、state 和代码验证器的登录数据
  /// - Throws: 如果 URL 构建失败则抛出 `MicrosoftAuthError.invalidURL`
  public func generateLoginURL() throws -> LoginData {
    let state = PKCEHelper.generateState()
    let codePair = PKCEHelper.generateCodePair()

    guard var components = URLComponents(string: microsoftAuthURL) else {
      throw MicrosoftAuthError.invalidURL
    }

    components.queryItems = [
      URLQueryItem(name: "client_id", value: clientID),
      URLQueryItem(name: "response_type", value: "code"),
      URLQueryItem(name: "redirect_uri", value: redirectURI),
      URLQueryItem(name: "response_mode", value: "query"),
      URLQueryItem(name: "scope", value: scope),
      URLQueryItem(name: "state", value: state),
      URLQueryItem(name: "code_challenge", value: codePair.challenge),
      URLQueryItem(name: "code_challenge_method", value: "S256"),
    ]

    guard let url = components.url else {
      throw MicrosoftAuthError.invalidURL
    }

    return LoginData(
      url: url,
      state: state,
      codeVerifier: codePair.verifier
    )
  }

  // MARK: - 步骤 2：解析回调 URL

  /// 从回调 URL 解析授权码
  ///
  /// 验证 state 参数以防止 CSRF 攻击。
  ///
  /// - Parameters:
  ///   - url: 浏览器重定向的回调 URL
  ///   - expectedState: generateLoginURL() 返回的 state 值
  /// - Returns: 授权码
  /// - Throws: 如果 URL 格式错误、state 不匹配或缺少授权码则抛出错误
  public func parseCallback(url: String, expectedState: String) throws -> String {
    guard let parsedURL = URL(string: url),
      let components = URLComponents(url: parsedURL, resolvingAgainstBaseURL: false)
    else {
      throw MicrosoftAuthError.invalidURL
    }

    // 验证 state 以防止 CSRF 攻击
    if let stateItem = components.queryItems?.first(where: { $0.name == "state" }),
      let state = stateItem.value
    {
      guard state == expectedState else {
        throw MicrosoftAuthError.stateMismatch
      }
    }

    // 提取授权码
    guard let codeItem = components.queryItems?.first(where: { $0.name == "code" }),
      let code = codeItem.value
    else {
      throw MicrosoftAuthError.authCodeNotFound
    }

    return code
  }

  // MARK: - 步骤 3：交换授权码

  /// 将授权码交换为 Microsoft 访问令牌
  internal func exchangeAuthorizationCode(
    authCode: String,
    codeVerifier: String
  ) async throws -> MicrosoftTokenResponse {
    guard let url = URL(string: microsoftTokenURL) else {
      throw MicrosoftAuthError.invalidURL
    }

    let parameters = [
      "client_id": clientID,
      "scope": scope,
      "code": authCode,
      "redirect_uri": redirectURI,
      "grant_type": "authorization_code",
      "code_verifier": codeVerifier,
    ]

    let body =
      parameters
      .map {
        "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
      }
      .joined(separator: "&")
      .data(using: .utf8)!

    let headers = ["Content-Type": "application/x-www-form-urlencoded"]

    do {
      let data = try await baseClient.postRaw(
        url: url,
        body: body,
        headers: headers
      )
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      return try decoder.decode(MicrosoftTokenResponse.self, from: data)
    } catch let error as DecodingError {
      throw MicrosoftAuthError.decodingError(error)
    } catch {
      throw MicrosoftAuthError.networkError(error)
    }
  }

  // MARK: - 步骤 4：Xbox Live 认证

  /// 使用 Microsoft 访问令牌进行 Xbox Live 认证
  internal func authenticateWithXboxLive(accessToken: String) async throws -> XBLAuthResponse {
    guard let url = URL(string: xboxLiveAuthURL) else {
      throw MicrosoftAuthError.invalidURL
    }

    let request = XBLAuthRequest(accessToken: accessToken)
    let headers = [
      "Content-Type": "application/json",
      "Accept": "application/json",
    ]

    do {
      let data = try await baseClient.post(
        url: url,
        body: request,
        headers: headers
      )
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      return try decoder.decode(XBLAuthResponse.self, from: data)
    } catch let error as DecodingError {
      throw MicrosoftAuthError.xblAuthFailed(error)
    } catch {
      throw MicrosoftAuthError.xblAuthFailed(error)
    }
  }

  // MARK: - 步骤 5：XSTS 认证

  /// 使用 Xbox Live 令牌进行 XSTS 认证
  internal func authenticateWithXSTS(xblToken: String) async throws -> XSTSAuthResponse {
    guard let url = URL(string: xstsAuthURL) else {
      throw MicrosoftAuthError.invalidURL
    }

    let request = XSTSAuthRequest(xblToken: xblToken)
    let headers = [
      "Content-Type": "application/json",
      "Accept": "application/json",
    ]

    do {
      let data = try await baseClient.post(
        url: url,
        body: request,
        headers: headers
      )
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      return try decoder.decode(XSTSAuthResponse.self, from: data)
    } catch let error as DecodingError {
      // 尝试解析 XSTS 错误响应
      if let data = try? await baseClient.post(url: url, body: request, headers: headers) as Data,
        let errorResponse = try? JSONDecoder().decode(XSTSErrorResponse.self, from: data),
        let xerr = errorResponse.xerr
      {

        // 处理特定的 XSTS 错误代码
        switch xerr {
        case 2_148_916_233:
          throw MicrosoftAuthError.accountNotOwnMinecraft
        case 2_148_916_235:
          throw MicrosoftAuthError.xstsError(code: xerr, message: "Xbox Live 在您所在的国家/地区不可用")
        case 2_148_916_236, 2_148_916_237:
          throw MicrosoftAuthError.xstsError(code: xerr, message: "该账户需要成人验证")
        case 2_148_916_238:
          throw MicrosoftAuthError.xstsError(code: xerr, message: "该账户属于儿童账户，需要添加到家庭组")
        default:
          throw MicrosoftAuthError.xstsError(
            code: xerr, message: errorResponse.message ?? "未知 XSTS 错误")
        }
      }
      throw MicrosoftAuthError.xstsAuthFailed(error)
    } catch {
      throw MicrosoftAuthError.xstsAuthFailed(error)
    }
  }

  // MARK: - 步骤 6：Minecraft 认证

  /// 使用 XSTS 令牌进行 Minecraft Services 认证
  internal func authenticateWithMinecraft(
    userHash: String,
    xstsToken: String
  ) async throws -> MinecraftAuthResponse {
    guard let url = URL(string: minecraftAuthURL) else {
      throw MicrosoftAuthError.invalidURL
    }

    let request = MinecraftAuthRequest(userHash: userHash, xstsToken: xstsToken)
    let headers = [
      "Content-Type": "application/json",
      "Accept": "application/json",
    ]

    do {
      let data = try await baseClient.post(
        url: url,
        body: request,
        headers: headers
      )
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      let response = try decoder.decode(MinecraftAuthResponse.self, from: data)

      // 检查访问令牌是否存在（表示用户拥有 Minecraft）
      guard !response.accessToken.isEmpty else {
        throw MicrosoftAuthError.accountNotOwnMinecraft
      }

      return response
    } catch let error as MicrosoftAuthError {
      throw error
    } catch let error as DecodingError {
      throw MicrosoftAuthError.minecraftAuthFailed(error)
    } catch {
      throw MicrosoftAuthError.minecraftAuthFailed(error)
    }
  }

  // MARK: - 步骤 7：获取 Minecraft 档案

  /// 使用 Minecraft 访问令牌获取档案
  internal func fetchMinecraftProfile(accessToken: String) async throws -> MinecraftProfileResponse
  {
    guard let url = URL(string: minecraftProfileURL) else {
      throw MicrosoftAuthError.invalidURL
    }

    let headers = ["Authorization": "Bearer \(accessToken)"]

    do {
      let profile: MinecraftProfileResponse = try await baseClient.get(
        url: url,
        headers: headers
      )
      return profile
    } catch let error as DecodingError {
      throw MicrosoftAuthError.profileFetchFailed(error)
    } catch {
      throw MicrosoftAuthError.profileFetchFailed(error)
    }
  }

  // MARK: - 完整登录流程

  /// 完成从授权码到档案的完整登录流程
  ///
  /// 此方法编排步骤 3-7 的认证流程：
  /// 1. 将授权码交换为 Microsoft 令牌
  /// 2. Xbox Live 认证
  /// 3. XSTS 认证
  /// 4. Minecraft 认证
  /// 5. 获取 Minecraft 档案
  ///
  /// - Parameters:
  ///   - authCode: 回调中的授权码
  ///   - codeVerifier: generateLoginURL() 返回的 PKCE 代码验证器
  /// - Returns: 包含档案和令牌的完整登录响应
  /// - Throws: 任何步骤失败时抛出 `MicrosoftAuthError`
  public func completeLogin(
    authCode: String,
    codeVerifier: String
  ) async throws -> CompleteLoginResponse {
    // 步骤 3：交换授权码为 Microsoft 令牌
    let tokenResponse = try await exchangeAuthorizationCode(
      authCode: authCode,
      codeVerifier: codeVerifier
    )

    // 步骤 4：Xbox Live 认证
    let xblResponse = try await authenticateWithXboxLive(accessToken: tokenResponse.accessToken)
    let xblToken = xblResponse.token
    let userHash = xblResponse.displayClaims.xui[0].uhs

    // 步骤 5：XSTS 认证
    let xstsResponse = try await authenticateWithXSTS(xblToken: xblToken)
    let xstsToken = xstsResponse.token

    // 步骤 6：Minecraft 认证
    let minecraftAuth = try await authenticateWithMinecraft(
      userHash: userHash,
      xstsToken: xstsToken
    )

    // 步骤 7：获取 Minecraft 档案
    let profile = try await fetchMinecraftProfile(accessToken: minecraftAuth.accessToken)

    return CompleteLoginResponse(
      id: profile.id,
      name: profile.name,
      accessToken: minecraftAuth.accessToken,
      refreshToken: tokenResponse.refreshToken ?? "",
      skins: profile.skins,
      capes: profile.capes
    )
  }

  // MARK: - 令牌刷新

  /// 使用刷新令牌刷新认证
  ///
  /// 用于在不需要用户交互的情况下获取新的访问令牌。
  internal func refreshMicrosoftToken(refreshToken: String) async throws -> MicrosoftTokenResponse {
    guard let url = URL(string: microsoftRefreshURL) else {
      throw MicrosoftAuthError.invalidURL
    }

    let parameters = [
      "client_id": clientID,
      "scope": scope,
      "refresh_token": refreshToken,
      "grant_type": "refresh_token",
    ]

    let body =
      parameters
      .map {
        "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
      }
      .joined(separator: "&")
      .data(using: .utf8)!

    let headers = ["Content-Type": "application/x-www-form-urlencoded"]

    do {
      let data = try await baseClient.postRaw(
        url: url,
        body: body,
        headers: headers
      )
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      return try decoder.decode(MicrosoftTokenResponse.self, from: data)
    } catch is DecodingError {
      throw MicrosoftAuthError.invalidRefreshToken
    } catch {
      throw MicrosoftAuthError.invalidRefreshToken
    }
  }

  /// 完成刷新流程以获取新的访问令牌和档案
  ///
  /// 此方法刷新 Microsoft 令牌，然后执行步骤 4-7 以获取新的 Minecraft 访问令牌和更新的档案。
  ///
  /// - Parameter refreshToken: 之前登录返回的刷新令牌
  /// - Returns: 包含更新令牌和档案的完整登录响应
  /// - Throws: 任何步骤失败时抛出 `MicrosoftAuthError`
  public func refreshLogin(refreshToken: String) async throws -> CompleteLoginResponse {
    // 刷新 Microsoft 令牌
    let tokenResponse = try await refreshMicrosoftToken(refreshToken: refreshToken)

    // 执行步骤 4-7
    let xblResponse = try await authenticateWithXboxLive(accessToken: tokenResponse.accessToken)
    let xblToken = xblResponse.token
    let userHash = xblResponse.displayClaims.xui[0].uhs

    let xstsResponse = try await authenticateWithXSTS(xblToken: xblToken)
    let xstsToken = xstsResponse.token

    let minecraftAuth = try await authenticateWithMinecraft(
      userHash: userHash,
      xstsToken: xstsToken
    )

    let profile = try await fetchMinecraftProfile(accessToken: minecraftAuth.accessToken)

    return CompleteLoginResponse(
      id: profile.id,
      name: profile.name,
      accessToken: minecraftAuth.accessToken,
      refreshToken: tokenResponse.refreshToken ?? refreshToken,
      skins: profile.skins,
      capes: profile.capes
    )
  }
}
