import Foundation
import XCTest

@testable import MojangAPI

/// MinecraftAuthenticatedClient 单元测试
///
/// 注意：这些测试主要验证客户端的初始化和参数验证逻辑。
/// 实际的网络请求测试需要有效的 Bearer Token，若未配置会自动 `XCTSkip`。
final class MinecraftAuthenticatedClientTests: XCTestCase {

  // MARK: - Test Configuration

  /// ⚠️ 集成测试配置：通过环境变量注入 Bearer Token
  ///
  /// 如何获取 Bearer Token：
  /// 1. 打开 https://www.minecraft.net/ 并登录
  /// 2. 打开浏览器开发者工具（F12）
  /// 3. 在 Network 标签中找到对 api.minecraftservices.com 的请求
  /// 4. 在请求头中找到 Authorization: Bearer <token>
  /// 5. 复制 token 部分（可以包含或不包含 "Bearer " 前缀）
  ///
  /// 使用方式：
  /// - 在运行测试前设置 `MINECRAFT_TEST_BEARER_TOKEN=<your_token>` 环境变量
  ///   （例如在 Xcode scheme、`.env` 文件或 CLI `swift test` 命令中）
  /// - 或者直接在 `inlineTestBearerToken` 变量中粘贴一次性 token（仅用于本地调试）
  /// - Token 有时效性，通常几小时后过期
  /// - 请勿将真实 token 提交到版本控制
  /// - 如果未设置，所有依赖网络的测试会自动跳过
  private let testTokenEnvironmentKey = "MINECRAFT_TEST_BEARER_TOKEN"

  /// 在此处直接粘贴一次性使用的 Bearer Token（仅用于本地调试，勿提交真实 token）
  private let inlineTestBearerToken: String? = nil

  /// 从环境变量读取 Bearer Token
  private var testBearerToken: String? {
    if let inlineToken = inlineTestBearerToken?.trimmingCharacters(in: .whitespacesAndNewlines),
      !inlineToken.isEmpty
    {
      return inlineToken
    }

    guard let rawValue = ProcessInfo.processInfo.environment[testTokenEnvironmentKey] else {
      return nil
    }

    let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
  }

  /// 检查是否配置了测试 token
  private var hasTestToken: Bool {
    testBearerToken != nil
  }

  /// 获取测试客户端（如果未配置 token 则跳过测试）
  private func getTestClient() throws -> MinecraftAuthenticatedClient {
    guard let token = testBearerToken, !token.isEmpty else {
      throw XCTSkip(
        "需要配置 Bearer Token 才能运行此测试。请在 inlineTestBearerToken 中粘贴 token 或通过环境变量 \(testTokenEnvironmentKey) 注入有效 token。"
      )
    }
    return MinecraftAuthenticatedClient(bearerToken: token)
  }

  // MARK: - Initialization Tests

  /// 测试使用完整 Bearer Token 初始化
  func testInitializationWithFullBearerToken() {
    let token = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    let client = MinecraftAuthenticatedClient(bearerToken: token)
    XCTAssertNotNil(client)
  }

  /// 测试使用不带 Bearer 前缀的 Token 初始化
  func testInitializationWithTokenOnly() {
    let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    let client = MinecraftAuthenticatedClient(bearerToken: token)
    XCTAssertNotNil(client)
  }

  /// 测试使用空 Token 初始化
  func testInitializationWithEmptyToken() {
    let token = ""
    let client = MinecraftAuthenticatedClient(bearerToken: token)
    XCTAssertNotNil(client, "客户端应该可以用空 token 初始化，但请求会失败")
  }

  /// 测试使用自定义配置初始化
  func testInitializationWithCustomConfiguration() {
    let token = "Bearer test_token"
    let config = MinecraftAPIConfiguration(timeout: 60.0)
    let client = MinecraftAuthenticatedClient(bearerToken: token, configuration: config)
    XCTAssertNotNil(client)
  }

  // MARK: - Skin Variant Tests

  /// 测试 SkinVariant 枚举值
  func testSkinVariantValues() {
    XCTAssertEqual(SkinVariant.classic.rawValue, "classic")
    XCTAssertEqual(SkinVariant.slim.rawValue, "slim")
  }

  /// 测试 SkinVariant 编码
  func testSkinVariantEncoding() throws {
    let classic = SkinVariant.classic
    let slim = SkinVariant.slim

    let classicData = try JSONEncoder().encode(classic)
    let slimData = try JSONEncoder().encode(slim)

    let classicString = String(data: classicData, encoding: .utf8)
    let slimString = String(data: slimData, encoding: .utf8)

    XCTAssertEqual(classicString, "\"classic\"")
    XCTAssertEqual(slimString, "\"slim\"")
  }

  /// 测试 SkinVariant 解码
  func testSkinVariantDecoding() throws {
    let classicJSON = "\"classic\"".data(using: .utf8)!
    let slimJSON = "\"slim\"".data(using: .utf8)!

    let classic = try JSONDecoder().decode(SkinVariant.self, from: classicJSON)
    let slim = try JSONDecoder().decode(SkinVariant.self, from: slimJSON)

    XCTAssertEqual(classic, .classic)
    XCTAssertEqual(slim, .slim)
  }

  // MARK: - Error Tests

  /// 测试 skinTooLarge 错误消息
  func testSkinTooLargeError() {
    let error = MinecraftAPIError.skinTooLarge
    XCTAssertEqual(error.errorDescription, "皮肤文件过大（最大 24 KB）")
  }

  /// 测试 invalidSkinFormat 错误消息
  func testInvalidSkinFormatError() {
    let error = MinecraftAPIError.invalidSkinFormat
    XCTAssertEqual(error.errorDescription, "无效的皮肤格式（必须是 PNG，64x32 或 64x64）")
  }

  /// 测试 authenticationRequired 错误消息
  func testAuthenticationRequiredError() {
    let error = MinecraftAPIError.authenticationRequired
    XCTAssertEqual(error.errorDescription, "此操作需要认证")
  }

  /// 测试 invalidBearerToken 错误消息
  func testInvalidBearerTokenError() {
    let error = MinecraftAPIError.invalidBearerToken
    XCTAssertEqual(error.errorDescription, "无效的 Bearer Token")
  }

  // MARK: - Data Extension Tests

  /// 测试 Data 扩展的 append(String) 方法
  func testDataAppendString() {
    var data = Data()
    data.append("Hello")
    data.append(" ")
    data.append("World")

    let result = String(data: data, encoding: .utf8)
    XCTAssertEqual(result, "Hello World")
  }

  /// 测试 Data 扩展处理空字符串
  func testDataAppendEmptyString() {
    var data = Data()
    data.append("")

    XCTAssertEqual(data.count, 0)
  }

  /// 测试 Data 扩展处理特殊字符
  func testDataAppendSpecialCharacters() {
    var data = Data()
    data.append("测试\r\n")
    data.append("🎮")

    let result = String(data: data, encoding: .utf8)
    XCTAssertEqual(result, "测试\r\n🎮")
  }

  // MARK: - Validation Tests

  /// 测试皮肤大小验证 - 正常大小
  func testSkinSizeValidation_Normal() {
    let normalSizeData = Data(count: 10000)  // 10 KB
    XCTAssertTrue(normalSizeData.count <= 24576, "10 KB 应该在限制内")
  }

  /// 测试皮肤大小验证 - 最大允许大小
  func testSkinSizeValidation_MaxSize() {
    let maxSizeData = Data(count: 24576)  // 24 KB
    XCTAssertTrue(maxSizeData.count <= 24576, "24 KB 应该在限制内")
  }

  /// 测试皮肤大小验证 - 超过限制
  func testSkinSizeValidation_TooLarge() {
    let tooLargeData = Data(count: 30000)  // 30 KB
    XCTAssertFalse(tooLargeData.count <= 24576, "30 KB 应该超过限制")
  }

  // MARK: - Multipart Form Data Construction Tests

  /// 测试 multipart/form-data 构建
  func testMultipartFormDataConstruction() {
    let boundary = "Boundary-Test123"
    var body = Data()

    // 添加 variant 字段
    body.append("--\(boundary)\r\n")
    body.append("Content-Disposition: form-data; name=\"variant\"\r\n\r\n")
    body.append("classic\r\n")

    // 添加文件字段
    body.append("--\(boundary)\r\n")
    body.append("Content-Disposition: form-data; name=\"file\"; filename=\"skin.png\"\r\n")
    body.append("Content-Type: image/png\r\n\r\n")
    body.append(Data([0x89, 0x50, 0x4E, 0x47]))  // PNG 文件头
    body.append("\r\n")
    body.append("--\(boundary)--\r\n")

    // 验证构建的数据包含预期内容
    func assertBodyContains(_ substring: String, file: StaticString = #filePath, line: UInt = #line) {
      let target = Data(substring.utf8)
      XCTAssertNotNil(
        body.range(of: target),
        "multipart body 应包含: \(substring)",
        file: file,
        line: line)
    }

    assertBodyContains("Content-Disposition: form-data; name=\"variant\"")
    assertBodyContains("classic")
    assertBodyContains("Content-Disposition: form-data; name=\"file\"")
    assertBodyContains("filename=\"skin.png\"")
    assertBodyContains("Content-Type: image/png")
  }

  /// 测试 multipart boundary 格式
  func testMultipartBoundaryFormat() {
    let boundary = UUID().uuidString
    XCTAssertFalse(boundary.isEmpty)
    XCTAssertTrue(boundary.count > 0)

    // Boundary 应该只包含允许的字符
    let allowedCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-")
    XCTAssertTrue(
      boundary.unicodeScalars.allSatisfy { allowedCharacters.contains($0) },
      "Boundary 应该只包含字母、数字和横杠"
    )
  }
}

// MARK: - Integration Tests (Network)

/// 集成测试 - 在注入有效 Bearer Token 且具备网络时自动运行
///
/// 使用方式：
/// 1. 设置环境变量 `MINECRAFT_TEST_BEARER_TOKEN=<your_token>`
/// 2. 运行 `swift test` 或在 Xcode 中执行测试
///
/// 当环境变量缺失时，`getTestClient()` 会触发 `XCTSkip`，因此这些测试默认不会在 CI 上误触发。
extension MinecraftAuthenticatedClientTests {

  /// 通过 URL 更改皮肤（需要纹理链接可达）
  func testChangeSkinFromURL() async throws {
    let client = try getTestClient()

    let skinURL = URL(string: "http://textures.minecraft.net/texture/2b4461bf27b8b73cb575ea092f418eddab847108f97088d38cadfe3d35ba75e6")!

    try await client.changeSkin(url: skinURL, variant: .classic)

    print("✅ 皮肤已成功通过 URL 更改")
  }

  /// 上传本地皮肤文件
  func testUploadSkin() async throws {
    let client = try getTestClient()

    // 创建一个测试用的 PNG 数据（64x64 透明图片）
    let testImageData = createTestSkinData()

    try await client.uploadSkin(imageData: testImageData, variant: .slim)

    print("✅ 皮肤已成功上传")
  }

  /// 通过玩家名称复制皮肤
  func testCopySkinByName() async throws {
    let client = try getTestClient()

    try await client.copySkin(from: "Notch")

    print("✅ 已成功复制 Notch 的皮肤")
  }

  /// 通过 UUID 复制皮肤
  func testCopySkinByUUID() async throws {
    let client = try getTestClient()

    let uuid = "069a79f444e94726a5befca90e38aaf5"  // Notch 的 UUID
    try await client.copySkin(fromUUID: uuid)

    print("✅ 已成功通过 UUID 复制皮肤")
  }

  /// 重置为默认皮肤
  func testResetSkin() async throws {
    let client = try getTestClient()

    try await client.resetSkin()

    print("✅ 已重置为默认皮肤")
  }

  /// 禁用披风
  func testDisableCape() async throws {
    let client = try getTestClient()

    try await client.disableCape()

    print("✅ 披风已禁用")
  }

  /// 验证 invalidBearerToken 错误
  func testInvalidTokenErrorHandling() async throws {
    try XCTSkipIf(!hasTestToken, "设置 \(testTokenEnvironmentKey) 环境变量后再运行集成测试。")
    let client = MinecraftAuthenticatedClient(bearerToken: "invalid_token")

    do {
      let skinURL = URL(string: "https://example.com/skin.png")!
      try await client.changeSkin(url: skinURL, variant: .classic)
      XCTFail("应该抛出 invalidBearerToken 错误")
    } catch MinecraftAPIError.invalidBearerToken {
      print("✅ 正确捕获了 invalidBearerToken 错误")
    } catch {
      XCTFail("应该抛出 invalidBearerToken 错误，但得到了: \(error)")
    }
  }

  /// 验证服务器对超大皮肤的报错
  func testSkinTooLargeErrorHandling() async throws {
    let client = try getTestClient()
    let largeSkinData = Data(count: 30000)  // 30 KB，超过 24 KB 限制

    do {
      try await client.uploadSkin(imageData: largeSkinData, variant: .classic)
      XCTFail("应该抛出 skinTooLarge 错误")
    } catch MinecraftAPIError.skinTooLarge {
      // 预期的错误
      print("✅ 正确捕获了 skinTooLarge 错误")
    } catch {
      XCTFail("应该抛出 skinTooLarge 错误，但得到了: \(error)")
    }
  }

  /// 一个完整的皮肤管理流程示例（复制 -> 等待 -> 重置）
  func testCompleteSkinWorkflow() async throws {
    let client = try getTestClient()

    print("📝 开始完整的皮肤管理流程测试...")

    // 1. 复制一个玩家的皮肤
    print("1️⃣ 正在复制 jeb_ 的皮肤...")
    try await client.copySkin(from: "jeb_")
    print("✅ 皮肤已复制")

    // 等待 3 秒
    try await Task.sleep(nanoseconds: 3_000_000_000)

    // 2. 重置为默认皮肤
    print("2️⃣ 正在重置为默认皮肤...")
    try await client.resetSkin()
    print("✅ 已重置为默认皮肤")

    print("🎉 完整流程测试完成")
  }

  // MARK: - Helper Methods

  /// 创建测试用的皮肤数据（64x64 透明 PNG）
  private func createTestSkinData() -> Data {
    Self.transparentSkinPNGData
  }

  /// 预生成的 64x64 RGBA 透明 PNG（二进制为 base64 编码，避免依赖外部资源）
  private static let transparentSkinPNGBase64 = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAAJ0lEQVR4nO3BAQ0AAADCoPdPbQ43oAAAAAAAAAAAAAAAAAAAAIB3A0BAAAGP8slRAAAAAElFTkSuQmCC"

  /// 解码后的透明 PNG 数据
  private static let transparentSkinPNGData = Data(base64Encoded: transparentSkinPNGBase64, options: .ignoreUnknownCharacters)!
}
