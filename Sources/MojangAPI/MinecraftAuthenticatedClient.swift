//
//  MinecraftAuthenticatedClient.swift
//  MojangAPI
//

import Foundation

/// Minecraft 认证 API 客户端
///
/// 此客户端用于执行需要认证的操作，例如上传皮肤、修改用户名等。
/// 需要提供有效的 Microsoft/Xbox Live Bearer Token。
///
/// 示例：
/// ```swift
/// let client = MinecraftAuthenticatedClient(bearerToken: "your_access_token")
/// try await client.changeSkin(url: skinURL, variant: .slim)
/// ```
public class MinecraftAuthenticatedClient {

  // MARK: - Properties

  private let bearerToken: String
  private let baseClient: BaseAPIClient
  private let servicesBaseURL = "https://api.minecraftservices.com"

  // MARK: - Initialization

  /// 初始化认证客户端
  /// - Parameters:
  ///   - bearerToken: Microsoft/Xbox Live Bearer Token（可以包含或不包含 "Bearer " 前缀）
  ///   - configuration: API 配置（可选）
  public init(
    bearerToken: String,
    configuration: MinecraftAPIConfiguration = MinecraftAPIConfiguration()
  ) {
    // 处理 Bearer Token 格式
    if bearerToken.hasPrefix("Bearer ") {
      self.bearerToken = bearerToken
    } else {
      self.bearerToken = "Bearer \(bearerToken)"
    }

    self.baseClient = BaseAPIClient(
      configuration: configuration,
      dateDecodingStrategy: .iso8601
    )
  }

  // MARK: - Profile Management

  /// 获取当前账户的档案信息
  ///
  /// 返回包含所有皮肤和披风的完整账户档案。
  ///
  /// - Returns: 账户档案信息，包含所有皮肤和披风列表
  ///
  /// - Throws:
  ///   - `MinecraftAPIError.invalidURL` 如果 URL 无效
  ///   - `MinecraftAPIError.invalidBearerToken` 如果认证失败
  ///   - `MinecraftAPIError.networkError` 如果网络请求失败
  ///   - `MinecraftAPIError.decodingError` 如果响应解析失败
  public func getProfile() async throws -> AccountProfile {
    let endpoint = "\(servicesBaseURL)/minecraft/profile"
    guard let requestURL = URL(string: endpoint) else {
      throw MinecraftAPIError.invalidURL
    }

    do {
      let profile: AccountProfile = try await baseClient.get(
        url: requestURL,
        headers: authHeaders()
      )
      return profile
    } catch let error as NetworkError {
      throw mapNetworkError(error)
    } catch {
      throw MinecraftAPIError.networkError(error)
    }
  }

  // MARK: - Skin Management

  /// 通过 URL 更改皮肤
  ///
  /// - Parameters:
  ///   - url: 皮肤图片的 URL（必须是可公开访问的 PNG 图片）
  ///   - variant: 皮肤模型类型（classic 或 slim）
  ///
  /// - Throws:
  ///   - `MinecraftAPIError.invalidURL` 如果 URL 无效
  ///   - `MinecraftAPIError.invalidBearerToken` 如果认证失败
  ///   - `MinecraftAPIError.networkError` 如果网络请求失败
  ///
  /// 皮肤要求：
  /// - 格式：PNG
  /// - 尺寸：64x32 或 64x64 像素
  /// - 最大文件大小：24 KB
  public func changeSkin(url: URL, variant: SkinVariant = .classic) async throws {
    let endpoint = "\(servicesBaseURL)/minecraft/profile/skins"
    guard let requestURL = URL(string: endpoint) else {
      throw MinecraftAPIError.invalidURL
    }

    let payload = [
      "url": url.absoluteString,
      "variant": variant.rawValue,
    ]

    var headers = authHeaders()
    headers["Content-Type"] = "application/json"

    do {
      _ = try await baseClient.post(url: requestURL, body: payload, headers: headers)
    } catch let error as NetworkError {
      throw mapNetworkError(error)
    } catch {
      throw MinecraftAPIError.networkError(error)
    }
  }

  /// 通过本地文件上传皮肤
  ///
  /// - Parameters:
  ///   - imageData: 皮肤图片的二进制数据（PNG 格式）
  ///   - variant: 皮肤模型类型（classic 或 slim）
  ///
  /// - Throws:
  ///   - `MinecraftAPIError.skinTooLarge` 如果文件超过 24 KB
  ///   - `MinecraftAPIError.invalidURL` 如果 URL 无效
  ///   - `MinecraftAPIError.invalidBearerToken` 如果认证失败
  ///   - `MinecraftAPIError.networkError` 如果网络请求失败
  ///
  /// 皮肤要求：
  /// - 格式：PNG
  /// - 尺寸：64x32 或 64x64 像素
  /// - 最大文件大小：24 KB（24576 字节）
  public func uploadSkin(imageData: Data, variant: SkinVariant = .classic) async throws {
    // 验证图片大小
    guard imageData.count <= 24576 else {
      throw MinecraftAPIError.skinTooLarge
    }

    let endpoint = "\(servicesBaseURL)/minecraft/profile/skins"
    guard let requestURL = URL(string: endpoint) else {
      throw MinecraftAPIError.invalidURL
    }

    // 构建 multipart/form-data
    let boundary = "Boundary-\(UUID().uuidString)"
    var body = Data()

    // 添加 variant 字段
    body.append("--\(boundary)\r\n")
    body.append("Content-Disposition: form-data; name=\"variant\"\r\n\r\n")
    body.append("\(variant.rawValue)\r\n")

    // 添加文件字段
    body.append("--\(boundary)\r\n")
    body.append("Content-Disposition: form-data; name=\"file\"; filename=\"skin.png\"\r\n")
    body.append("Content-Type: image/png\r\n\r\n")
    body.append(imageData)
    body.append("\r\n")
    body.append("--\(boundary)--\r\n")

    // 设置请求头
    var headers = authHeaders()
    headers["Content-Type"] = "multipart/form-data; boundary=\(boundary)"

    do {
      _ = try await baseClient.postRaw(url: requestURL, body: body, headers: headers)
    } catch let error as NetworkError {
      throw mapNetworkError(error)
    } catch {
      throw MinecraftAPIError.networkError(error)
    }
  }

  /// 重置为默认皮肤
  ///
  /// 移除当前自定义皮肤，恢复为 Steve 或 Alex 默认皮肤。
  ///
  /// - Throws:
  ///   - `MinecraftAPIError.invalidURL` 如果 URL 无效
  ///   - `MinecraftAPIError.invalidBearerToken` 如果认证失败
  ///   - `MinecraftAPIError.networkError` 如果网络请求失败
  public func resetSkin() async throws {
    let endpoint = "\(servicesBaseURL)/minecraft/profile/skins/active"
    guard let requestURL = URL(string: endpoint) else {
      throw MinecraftAPIError.invalidURL
    }

    do {
      _ = try await baseClient.delete(url: requestURL, headers: authHeaders())
    } catch let error as NetworkError {
      throw mapNetworkError(error)
    } catch {
      throw MinecraftAPIError.networkError(error)
    }
  }

  /// 复制其他玩家的皮肤
  ///
  /// 从指定玩家复制皮肤和皮肤模型类型到当前账户。
  ///
  /// - Parameter username: 要复制皮肤的玩家用户名
  ///
  /// - Throws:
  ///   - `MinecraftAPIError.playerNotFound` 如果玩家不存在
  ///   - `MinecraftAPIError.noSkinAvailable` 如果玩家使用默认皮肤
  ///   - `MinecraftAPIError.invalidBearerToken` 如果认证失败
  ///   - `MinecraftAPIError.networkError` 如果网络请求失败
  ///
  /// 注意：如果目标玩家使用默认皮肤，此方法会将当前账户的皮肤重置为默认皮肤。
  public func copySkin(from username: String) async throws {
    // 1. 获取目标玩家的 UUID
    let api = MinecraftAPIClient()
    let profile = try await api.fetchPlayerProfile(byName: username)

    // 2. 获取完整档案（包含纹理）
    let fullProfile = try await api.fetchPlayerProfile(byUUID: profile.id)

    // 3. 解析皮肤信息
    guard let skinURL = fullProfile.getSkinURL() else {
      // 如果玩家没有自定义皮肤，重置为默认皮肤
      try await resetSkin()
      return
    }

    // 4. 确定皮肤模型类型
    let textures = try fullProfile.getTexturesPayload()
    let variant: SkinVariant = textures.textures.SKIN?.metadata?.model == "slim" ? .slim : .classic

    // 5. 使用 URL 设置皮肤
    try await changeSkin(url: skinURL, variant: variant)
  }

  /// 复制其他玩家的皮肤（通过 UUID）
  ///
  /// 从指定玩家复制皮肤和皮肤模型类型到当前账户。
  ///
  /// - Parameter uuid: 要复制皮肤的玩家 UUID
  ///
  /// - Throws:
  ///   - `MinecraftAPIError.playerNotFound` 如果玩家不存在
  ///   - `MinecraftAPIError.noSkinAvailable` 如果玩家使用默认皮肤
  ///   - `MinecraftAPIError.invalidBearerToken` 如果认证失败
  ///   - `MinecraftAPIError.networkError` 如果网络请求失败
  public func copySkin(fromUUID uuid: String) async throws {
    // 1. 获取完整档案（包含纹理）
    let api = MinecraftAPIClient()
    let fullProfile = try await api.fetchPlayerProfile(byUUID: uuid)

    // 2. 解析皮肤信息
    guard let skinURL = fullProfile.getSkinURL() else {
      // 如果玩家没有自定义皮肤，重置为默认皮肤
      try await resetSkin()
      return
    }

    // 3. 确定皮肤模型类型
    let textures = try fullProfile.getTexturesPayload()
    let variant: SkinVariant = textures.textures.SKIN?.metadata?.model == "slim" ? .slim : .classic

    // 4. 使用 URL 设置皮肤
    try await changeSkin(url: skinURL, variant: variant)
  }

  /// 更改当前皮肤的模型类型
  ///
  /// 保持当前皮肤图片不变，仅更改模型类型（classic 或 slim）。
  /// 此方法会获取当前激活的皮肤 URL，然后使用新的 variant 重新设置。
  ///
  /// - Parameter variant: 新的皮肤模型类型
  ///
  /// - Throws:
  ///   - `MinecraftAPIError.noSkinAvailable` 如果当前没有自定义皮肤
  ///   - `MinecraftAPIError.invalidBearerToken` 如果认证失败
  ///   - `MinecraftAPIError.networkError` 如果网络请求失败
  ///
  /// 注意：此操作需要当前账户已设置自定义皮肤。如果使用默认皮肤，会抛出错误。
  public func changeSkinVariant(_ variant: SkinVariant) async throws {
    // 1. 获取当前账户档案
    let profile = try await getProfile()

    // 2. 检查是否有激活的皮肤
    guard let activeSkin = profile.activeSkin else {
      throw MinecraftAPIError.noSkinAvailable
    }

    // 3. 获取当前皮肤的 URL
    guard let skinURL = activeSkin.urlObject else {
      throw MinecraftAPIError.invalidURL
    }

    // 4. 使用当前皮肤 URL 和新的 variant 重新设置皮肤
    try await changeSkin(url: skinURL, variant: variant)
  }

  // MARK: - Cape Management

  /// 禁用披风
  ///
  /// 隐藏当前装备的披风，不会删除披风本身。
  ///
  /// - Throws:
  ///   - `MinecraftAPIError.invalidURL` 如果 URL 无效
  ///   - `MinecraftAPIError.invalidBearerToken` 如果认证失败
  ///   - `MinecraftAPIError.networkError` 如果网络请求失败
  public func disableCape() async throws {
    let endpoint = "\(servicesBaseURL)/minecraft/profile/capes/active"
    guard let requestURL = URL(string: endpoint) else {
      throw MinecraftAPIError.invalidURL
    }

    do {
      _ = try await baseClient.delete(url: requestURL, headers: authHeaders())
    } catch let error as NetworkError {
      throw mapNetworkError(error)
    } catch {
      throw MinecraftAPIError.networkError(error)
    }
  }

  // MARK: - Private Methods

  /// 获取认证请求头
  private func authHeaders() -> [String: String] {
    return ["Authorization": bearerToken]
  }

  /// 将 NetworkError 映射为 MinecraftAPIError
  private func mapNetworkError(_ error: NetworkError) -> MinecraftAPIError {
    switch error {
    case .invalidResponse:
      return .networkError(URLError(.badServerResponse))
    case .httpError(let statusCode, _):
      if statusCode == 401 || statusCode == 403 {
        return .invalidBearerToken
      }
      return .serverError(statusCode: statusCode)
    case .decodingError(let decodingError):
      return .decodingError(decodingError)
    case .networkError(let networkError):
      return .networkError(networkError)
    }
  }
}
