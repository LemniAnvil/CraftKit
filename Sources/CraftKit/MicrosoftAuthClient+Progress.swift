//
//  MicrosoftAuthClient+Progress.swift
//  CraftKit
//
//  Microsoft 认证客户端进度回调扩展
//  提供带进度回调的登录和刷新流程
//

import Foundation

// MARK: - Progress Steps

extension MicrosoftAuthClient {

  /// 登录步骤枚举
  public enum LoginStep {
    /// 正在获取授权令牌
    case gettingToken
    /// 正在进行 Xbox Live 认证
    case authenticatingXBL
    /// 正在进行 XSTS 认证
    case authenticatingXSTS
    /// 正在进行 Minecraft 认证
    case authenticatingMinecraft
    /// 正在获取 Minecraft 档案
    case fetchingProfile
    /// 完成
    case completed
  }

  /// 刷新步骤枚举
  public enum RefreshStep {
    /// 正在刷新令牌
    case refreshingToken
    /// 正在进行 Xbox Live 认证
    case authenticatingXBL
    /// 正在进行 XSTS 认证
    case authenticatingXSTS
    /// 正在进行 Minecraft 认证
    case authenticatingMinecraft
    /// 正在获取 Minecraft 档案
    case fetchingProfile
    /// 完成
    case completed
  }

  /// 登录进度回调类型
  public typealias LoginProgressCallback = (LoginStep) -> Void

  /// 刷新进度回调类型
  public typealias RefreshProgressCallback = (RefreshStep) -> Void
}

// MARK: - Login with Progress

extension MicrosoftAuthClient {

  /// 完成从授权码到档案的完整登录流程（带进度回调）
  ///
  /// 此方法编排步骤 3-7 的认证流程，并在每个步骤完成时调用进度回调：
  /// 1. 将授权码交换为 Microsoft 令牌
  /// 2. Xbox Live 认证
  /// 3. XSTS 认证
  /// 4. Minecraft 认证
  /// 5. 获取 Minecraft 档案
  ///
  /// - Parameters:
  ///   - authCode: 回调中的授权码
  ///   - codeVerifier: generateLoginURL() 返回的 PKCE 代码验证器
  ///   - onProgress: 进度回调闭包，在每个步骤完成时调用
  /// - Returns: 包含档案和令牌的完整登录响应
  /// - Throws: 任何步骤失败时抛出 `MicrosoftAuthError`
  public func completeLoginWithProgress(
    authCode: String,
    codeVerifier: String,
    onProgress: @escaping LoginProgressCallback
  ) async throws -> CompleteLoginResponse {

    // 步骤 1：交换授权码为 Microsoft 令牌
    await MainActor.run { onProgress(.gettingToken) }
    let tokenResponse = try await exchangeAuthorizationCode(
      authCode: authCode,
      codeVerifier: codeVerifier
    )

    // 步骤 2：Xbox Live 认证
    await MainActor.run { onProgress(.authenticatingXBL) }
    let xblResponse = try await authenticateWithXboxLive(accessToken: tokenResponse.accessToken)
    let xblToken = xblResponse.token
    let userHash = xblResponse.displayClaims.xui[0].uhs

    // 步骤 3：XSTS 认证
    await MainActor.run { onProgress(.authenticatingXSTS) }
    let xstsResponse = try await authenticateWithXSTS(xblToken: xblToken)
    let xstsToken = xstsResponse.token

    // 步骤 4：Minecraft 认证
    await MainActor.run { onProgress(.authenticatingMinecraft) }
    let minecraftAuth = try await authenticateWithMinecraft(
      userHash: userHash,
      xstsToken: xstsToken
    )

    // 步骤 5：获取 Minecraft 档案
    await MainActor.run { onProgress(.fetchingProfile) }
    let profile = try await fetchMinecraftProfile(accessToken: minecraftAuth.accessToken)

    // 步骤 6：完成
    await MainActor.run { onProgress(.completed) }

    return CompleteLoginResponse(
      id: profile.id,
      name: profile.name,
      accessToken: minecraftAuth.accessToken,
      refreshToken: tokenResponse.refreshToken ?? "",
      skins: profile.skins,
      capes: profile.capes
    )
  }
}

// MARK: - Refresh with Progress

extension MicrosoftAuthClient {

  /// 完成刷新流程以获取新的访问令牌和档案（带进度回调）
  ///
  /// 此方法刷新 Microsoft 令牌，然后执行步骤 4-7 以获取新的 Minecraft 访问令牌和更新的档案，
  /// 并在每个步骤完成时调用进度回调。
  ///
  /// - Parameters:
  ///   - refreshToken: 之前登录返回的刷新令牌
  ///   - onProgress: 进度回调闭包，在每个步骤完成时调用
  /// - Returns: 包含更新令牌和档案的完整登录响应
  /// - Throws: 任何步骤失败时抛出 `MicrosoftAuthError`
  public func refreshLoginWithProgress(
    refreshToken: String,
    onProgress: @escaping RefreshProgressCallback
  ) async throws -> CompleteLoginResponse {

    // 步骤 1：刷新 Microsoft 令牌
    await MainActor.run { onProgress(.refreshingToken) }
    let tokenResponse = try await refreshMicrosoftToken(refreshToken: refreshToken)

    // 步骤 2：Xbox Live 认证
    await MainActor.run { onProgress(.authenticatingXBL) }
    let xblResponse = try await authenticateWithXboxLive(accessToken: tokenResponse.accessToken)
    let xblToken = xblResponse.token
    let userHash = xblResponse.displayClaims.xui[0].uhs

    // 步骤 3：XSTS 认证
    await MainActor.run { onProgress(.authenticatingXSTS) }
    let xstsResponse = try await authenticateWithXSTS(xblToken: xblToken)
    let xstsToken = xstsResponse.token

    // 步骤 4：Minecraft 认证
    await MainActor.run { onProgress(.authenticatingMinecraft) }
    let minecraftAuth = try await authenticateWithMinecraft(
      userHash: userHash,
      xstsToken: xstsToken
    )

    // 步骤 5：获取 Minecraft 档案
    await MainActor.run { onProgress(.fetchingProfile) }
    let profile = try await fetchMinecraftProfile(accessToken: minecraftAuth.accessToken)

    // 步骤 6：完成
    await MainActor.run { onProgress(.completed) }

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
