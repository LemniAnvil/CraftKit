//
//  SkinVariantExample.swift
//  CraftKit
//
//  演示如何使用皮肤变体更改功能
//

import Foundation

/// 皮肤变体更改示例
///
/// 此文件包含使用 `changeSkinVariant` 和 `getProfile` 方法的示例代码。
public enum SkinVariantExample {

  // MARK: - 示例 1: 获取当前账户档案信息

  /// 获取并显示当前账户的所有皮肤和披风
  static func example1_getProfile() async throws {
    let client = MinecraftAuthenticatedClient(bearerToken: "your_bearer_token")

    // 获取账户档案
    let profile = try await client.getProfile()

    print("玩家: \(profile.name) (\(profile.id))")
    print("\n皮肤列表:")
    for skin in profile.skins {
      let status = skin.isActive ? "✓ 激活" : "  未激活"
      print("\(status) - \(skin.variant.rawValue) - \(skin.url)")
      if let alias = skin.alias {
        print("       别名: \(alias)")
      }
    }

    print("\n披风列表:")
    for cape in profile.capes {
      let status = cape.isActive ? "✓ 激活" : "  未激活"
      print("\(status) - \(cape.alias) - \(cape.url)")
    }
  }

  // MARK: - 示例 2: 更改当前皮肤的模型类型

  /// 将当前皮肤从 classic 改为 slim（或反之）
  static func example2_changeSkinVariant() async throws {
    let client = MinecraftAuthenticatedClient(bearerToken: "your_bearer_token")

    // 获取当前皮肤信息
    let profile = try await client.getProfile()
    guard let currentSkin = profile.activeSkin else {
      print("当前没有自定义皮肤")
      return
    }

    print("当前皮肤模型: \(currentSkin.variant.rawValue)")

    // 切换到另一个模型类型
    let newVariant: SkinVariant = currentSkin.variant == .classic ? .slim : .classic
    print("正在更改为: \(newVariant.rawValue)")

    try await client.changeSkinVariant(newVariant)
    print("皮肤模型已更改!")
  }

  // MARK: - 示例 3: 强制设置为 slim 模型

  /// 无论当前是什么模型，都设置为 slim
  static func example3_forceSlimModel() async throws {
    let client = MinecraftAuthenticatedClient(bearerToken: "your_bearer_token")

    try await client.changeSkinVariant(.slim)
    print("已强制设置为 slim 模型")
  }

  // MARK: - 示例 4: 强制设置为 classic 模型

  /// 无论当前是什么模型，都设置为 classic
  static func example4_forceClassicModel() async throws {
    let client = MinecraftAuthenticatedClient(bearerToken: "your_bearer_token")

    try await client.changeSkinVariant(.classic)
    print("已强制设置为 classic 模型")
  }

  // MARK: - 示例 5: 检查并更改皮肤模型

  /// 检查当前模型，只在需要时更改
  static func example5_conditionalChange() async throws {
    let client = MinecraftAuthenticatedClient(bearerToken: "your_bearer_token")

    let profile = try await client.getProfile()
    guard let currentSkin = profile.activeSkin else {
      print("当前没有自定义皮肤，无法更改模型")
      return
    }

    let desiredVariant: SkinVariant = .slim

    if currentSkin.variant == desiredVariant {
      print("当前已经是 \(desiredVariant.rawValue) 模型，无需更改")
    } else {
      print("当前是 \(currentSkin.variant.rawValue) 模型，正在更改为 \(desiredVariant.rawValue)")
      try await client.changeSkinVariant(desiredVariant)
      print("更改完成!")
    }
  }

  // MARK: - 示例 6: 错误处理

  /// 演示如何处理可能的错误
  static func example6_errorHandling() async {
    let client = MinecraftAuthenticatedClient(bearerToken: "your_bearer_token")

    do {
      try await client.changeSkinVariant(.slim)
      print("皮肤模型更改成功")
    } catch MinecraftAPIError.noSkinAvailable {
      print("错误: 当前没有自定义皮肤，无法更改模型")
      print("请先上传或设置一个皮肤")
    } catch MinecraftAPIError.invalidBearerToken {
      print("错误: Bearer Token 无效或已过期")
    } catch MinecraftAPIError.networkError(let error) {
      print("网络错误: \(error.localizedDescription)")
    } catch {
      print("未知错误: \(error)")
    }
  }

  // MARK: - 示例 7: 完整工作流程

  /// 上传皮肤并设置模型类型
  static func example7_uploadAndSetVariant() async throws {
    let client = MinecraftAuthenticatedClient(bearerToken: "your_bearer_token")

    // 1. 读取本地皮肤文件
    let skinURL = URL(fileURLWithPath: "/path/to/skin.png")
    let skinData = try Data(contentsOf: skinURL)

    // 2. 上传皮肤（默认 classic 模型）
    print("正在上传皮肤...")
    try await client.uploadSkin(imageData: skinData, variant: .classic)
    print("皮肤上传成功")

    // 3. 稍后更改为 slim 模型（无需重新上传）
    print("正在更改为 slim 模型...")
    try await client.changeSkinVariant(.slim)
    print("模型类型已更改为 slim")
  }

  // MARK: - 示例 8: 获取激活皮肤的详细信息

  /// 显示当前激活皮肤的所有信息
  static func example8_getActiveSkinDetails() async throws {
    let client = MinecraftAuthenticatedClient(bearerToken: "your_bearer_token")

    let profile = try await client.getProfile()

    if let activeSkin = profile.activeSkin {
      print("=== 当前激活的皮肤 ===")
      print("ID: \(activeSkin.id)")
      print("模型: \(activeSkin.variant.rawValue)")
      print("URL: \(activeSkin.url)")
      if let alias = activeSkin.alias {
        print("别名: \(alias)")
      }
      print("状态: \(activeSkin.state.displayName)")
    } else {
      print("当前使用默认皮肤（Steve 或 Alex）")
    }
  }

  // MARK: - 示例 9: 列出所有可用的皮肤

  /// 显示账户中所有的皮肤（包括未激活的）
  static func example9_listAllSkins() async throws {
    let client = MinecraftAuthenticatedClient(bearerToken: "your_bearer_token")

    let profile = try await client.getProfile()

    print("=== 所有皮肤 (\(profile.skins.count) 个) ===")
    for (index, skin) in profile.skins.enumerated() {
      print("\n皮肤 #\(index + 1):")
      print("  ID: \(skin.id)")
      print("  模型: \(skin.variant.rawValue)")
      print("  状态: \(skin.state.displayName)")
      print("  URL: \(skin.url)")
      if let alias = skin.alias {
        print("  别名: \(alias)")
      }
    }
  }

  // MARK: - 示例 10: 比较 Python 版本的用法

  /// 演示与 Python 版本等效的用法
  static func example10_pythonEquivalent() async throws {
    let client = MinecraftAuthenticatedClient(bearerToken: "your_bearer_token")

    // Python: client.change_skin_variant("slim")
    // Swift:
    try await client.changeSkinVariant(.slim)

    // Python: profile = client.get_profile()
    // Swift:
    let profile = try await client.getProfile()

    // Python: profile.skins[0].variant
    // Swift:
    if let activeSkin = profile.activeSkin {
      print("当前模型: \(activeSkin.variant.rawValue)")
    }
  }
}
