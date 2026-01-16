//
//  SkinUploadExample.swift
//  CraftKit
//
//  皮肤上传和管理的使用示例
//

import Foundation

#if canImport(UIKit)
  import UIKit
#elseif canImport(AppKit)
  import AppKit
#endif

/// 皮肤上传和管理示例
///
/// 注意：这些示例需要有效的 Bearer Token 才能运行。
/// 你可以通过 Microsoft OAuth2 流程获取 token，或从浏览器开发者工具中提取。
enum SkinUploadExample {

  // MARK: - 基础示例

  /// 示例 1：通过 URL 更改皮肤
  static func changeSkinFromURL() async throws {
    // 初始化认证客户端（需要提供有效的 Bearer Token）
    let client = MinecraftAuthenticatedClient(bearerToken: "YOUR_BEARER_TOKEN_HERE")

    // 皮肤图片的公开 URL
    let skinURL = URL(string: "https://example.com/my-awesome-skin.png")!

    // 更改为 slim 模型（Alex）
    try await client.changeSkin(url: skinURL, variant: .slim)

    print("✅ 皮肤已成功更改为 slim 模型")
  }

  /// 示例 2：上传本地皮肤文件
  static func uploadLocalSkin() async throws {
    let client = MinecraftAuthenticatedClient(bearerToken: "YOUR_BEARER_TOKEN_HERE")

    // 从本地文件加载皮肤数据
    #if canImport(UIKit)
      // iOS/iPadOS
      guard let image = UIImage(named: "my-skin"),
        let imageData = image.pngData()
      else {
        print("❌ 无法加载图片")
        return
      }
    #elseif canImport(AppKit)
      // macOS
      guard let image = NSImage(named: "my-skin"),
        let tiffData = image.tiffRepresentation,
        let bitmapImage = NSBitmapImageRep(data: tiffData),
        let imageData = bitmapImage.representation(using: .png, properties: [:])
      else {
        print("❌ 无法加载图片")
        return
      }
    #else
      // 其他平台：直接从文件读取
      let imageData = try Data(contentsOf: URL(fileURLWithPath: "path/to/skin.png"))
    #endif

    // 上传皮肤（classic 模型 - Steve）
    try await client.uploadSkin(imageData: imageData, variant: .classic)

    print("✅ 皮肤已成功上传（classic 模型）")
  }

  /// 示例 3：复制其他玩家的皮肤
  static func copyPlayerSkin() async throws {
    let client = MinecraftAuthenticatedClient(bearerToken: "YOUR_BEARER_TOKEN_HERE")

    // 复制 Notch 的皮肤
    try await client.copySkin(from: "Notch")

    print("✅ 已成功复制 Notch 的皮肤")
  }

  /// 示例 4：通过 UUID 复制皮肤
  static func copySkinByUUID() async throws {
    let client = MinecraftAuthenticatedClient(bearerToken: "YOUR_BEARER_TOKEN_HERE")

    // 通过 UUID 复制皮肤
    let uuid = "069a79f444e94726a5befca90e38aaf5"  // Notch 的 UUID
    try await client.copySkin(fromUUID: uuid)

    print("✅ 已成功复制玩家的皮肤")
  }

  /// 示例 5：重置为默认皮肤
  static func resetToDefaultSkin() async throws {
    let client = MinecraftAuthenticatedClient(bearerToken: "YOUR_BEARER_TOKEN_HERE")

    // 重置为默认皮肤（Steve 或 Alex）
    try await client.resetSkin()

    print("✅ 已重置为默认皮肤")
  }

  /// 示例 6：禁用披风
  static func disableCape() async throws {
    let client = MinecraftAuthenticatedClient(bearerToken: "YOUR_BEARER_TOKEN_HERE")

    // 隐藏当前披风
    try await client.disableCape()

    print("✅ 披风已禁用")
  }

  // MARK: - 高级示例

  /// 示例 7：完整的皮肤管理流程
  static func completeSkinManagementFlow() async throws {
    let client = MinecraftAuthenticatedClient(bearerToken: "YOUR_BEARER_TOKEN_HERE")

    // 1. 复制一个喜欢的玩家的皮肤
    print("📥 正在复制 jeb_ 的皮肤...")
    try await client.copySkin(from: "jeb_")
    print("✅ 皮肤已复制")

    // 2. 等待一段时间...
    try await Task.sleep(nanoseconds: 5_000_000_000)  // 5 秒

    // 3. 上传自己的皮肤
    print("📤 正在上传自定义皮肤...")
    let skinData = try Data(contentsOf: URL(fileURLWithPath: "path/to/custom-skin.png"))
    try await client.uploadSkin(imageData: skinData, variant: .slim)
    print("✅ 自定义皮肤已上传")

    // 4. 等待一段时间...
    try await Task.sleep(nanoseconds: 5_000_000_000)  // 5 秒

    // 5. 重置为默认皮肤
    print("🔄 正在重置为默认皮肤...")
    try await client.resetSkin()
    print("✅ 已重置为默认皮肤")
  }

  /// 示例 8：错误处理
  static func errorHandlingExample() async {
    let client = MinecraftAuthenticatedClient(bearerToken: "YOUR_BEARER_TOKEN_HERE")

    do {
      // 尝试上传一个过大的皮肤文件
      let largeSkinData = Data(count: 30000)  // 超过 24 KB 限制
      try await client.uploadSkin(imageData: largeSkinData, variant: .classic)

    } catch MinecraftAPIError.skinTooLarge {
      print("❌ 皮肤文件过大（最大 24 KB）")

    } catch MinecraftAPIError.invalidBearerToken {
      print("❌ Bearer Token 无效或已过期")

    } catch MinecraftAPIError.playerNotFound(let name) {
      print("❌ 玩家不存在: \(name)")

    } catch MinecraftAPIError.noSkinAvailable {
      print("❌ 该玩家没有自定义皮肤")

    } catch {
      print("❌ 发生未知错误: \(error.localizedDescription)")
    }
  }

  /// 示例 9：验证皮肤尺寸（辅助函数）
  static func validateSkinDimensions(imageData: Data) -> Bool {
    #if canImport(UIKit)
      guard let image = UIImage(data: imageData) else {
        return false
      }
      let size = image.size
      let scale = image.scale
      let width = Int(size.width * scale)
      let height = Int(size.height * scale)

      // 有效的皮肤尺寸：64x32 或 64x64
      return (width == 64 && (height == 32 || height == 64))

    #elseif canImport(AppKit)
      guard let image = NSImage(data: imageData) else {
        return false
      }
      let size = image.size
      let width = Int(size.width)
      let height = Int(size.height)

      // 有效的皮肤尺寸：64x32 或 64x64
      return (width == 64 && (height == 32 || height == 64))

    #else
      // 其他平台无法验证
      return true
    #endif
  }
}

// MARK: - 使用说明

/*
 如何获取 Bearer Token：

 方法 1：通过浏览器开发者工具
 1. 打开 https://www.minecraft.net/en-us
 2. 登录你的 Microsoft 账户
 3. 打开浏览器开发者工具（F12）
 4. 在 Network 标签中找到对 api.minecraftservices.com 的请求
 5. 在请求头中找到 Authorization: Bearer <token>
 6. 复制 token 部分（不包括 "Bearer "）

 方法 2：实现完整的 Microsoft OAuth2 流程（推荐但复杂）
 - 需要实现 Microsoft Identity Platform 认证
 - 需要注册 Azure AD 应用
 - 参考 Python 版本的实现：mojang/client.py

 注意事项：
 - Bearer Token 有时效性（通常几小时后过期）
 - 过期后需要重新获取或使用 refresh token 刷新
 - 请勿将 token 硬编码在代码中或提交到版本控制
 - 建议使用 Keychain（iOS/macOS）或其他安全存储方式
 */
