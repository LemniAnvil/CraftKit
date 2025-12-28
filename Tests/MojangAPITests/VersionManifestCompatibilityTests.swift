//
//  VersionManifestCompatibilityTests.swift
//  MojangAPITests
//

import XCTest

@testable import MojangAPI

final class VersionManifestCompatibilityTests: XCTestCase {

  let client = MinecraftAPIClient()

  // MARK: - v1 API Tests

  func testFetchVersionManifestV1() async throws {
    let manifest = try await client.fetchVersionManifest(useV2: false)

    XCTAssertFalse(manifest.versions.isEmpty, "版本列表不应为空")
    XCTAssertFalse(manifest.latest.release.isEmpty, "最新正式版不应为空")
    XCTAssertFalse(manifest.latest.snapshot.isEmpty, "最新快照版不应为空")

    // v1 API 应该没有 sha1 和 complianceLevel
    let firstVersion = manifest.versions.first!
    print("V1 API - 第一个版本: \(firstVersion.id)")
    print("  sha1: \(firstVersion.sha1 ?? "nil")")
    print("  complianceLevel: \(firstVersion.complianceLevel?.description ?? "nil")")
  }

  // MARK: - v2 API Tests

  func testFetchVersionManifestV2() async throws {
    let manifest = try await client.fetchVersionManifest(useV2: true)

    XCTAssertFalse(manifest.versions.isEmpty, "版本列表不应为空")
    XCTAssertFalse(manifest.latest.release.isEmpty, "最新正式版不应为空")
    XCTAssertFalse(manifest.latest.snapshot.isEmpty, "最新快照版不应为空")

    // v2 API 应该有 sha1 和 complianceLevel
    let firstVersion = manifest.versions.first!
    print("V2 API - 第一个版本: \(firstVersion.id)")
    print("  sha1: \(firstVersion.sha1 ?? "nil")")
    print("  complianceLevel: \(firstVersion.complianceLevel?.description ?? "nil")")

    XCTAssertTrue(firstVersion.isFromV2API, "应该来自 v2 API")
    XCTAssertNotNil(firstVersion.sha1, "v2 API 应该有 sha1")
    XCTAssertNotNil(firstVersion.complianceLevel, "v2 API 应该有 complianceLevel")
  }

  // MARK: - Default API Tests

  func testFetchVersionManifestDefault() async throws {
    // 默认应该使用 v2
    let manifest = try await client.fetchVersionManifest()

    let firstVersion = manifest.versions.first!
    print("Default API - 第一个版本: \(firstVersion.id)")
    print("  isFromV2API: \(firstVersion.isFromV2API)")

    // 默认使用 v2，所以应该有完整数据
    XCTAssertTrue(firstVersion.isFromV2API, "默认应该使用 v2 API")
  }

  // MARK: - Compatibility Tests

  func testVersionInfoCompatibility() async throws {
    let manifestV1 = try await client.fetchVersionManifest(useV2: false)
    let manifestV2 = try await client.fetchVersionManifest(useV2: true)

    // 两个版本应该返回相同数量的版本
    XCTAssertEqual(
      manifestV1.versions.count,
      manifestV2.versions.count,
      "v1 和 v2 应该返回相同数量的版本"
    )

    // 比较第一个版本的基础字段
    let v1First = manifestV1.versions.first!
    let v2First = manifestV2.versions.first!

    XCTAssertEqual(v1First.id, v2First.id, "版本 ID 应该相同")
    XCTAssertEqual(v1First.type, v2First.type, "版本类型应该相同")
    XCTAssertEqual(v1First.url, v2First.url, "URL 应该相同")

    // v1 不应该有额外字段
    XCTAssertFalse(v1First.isFromV2API, "v1 版本不应该有 v2 数据")

    // v2 应该有额外字段
    XCTAssertTrue(v2First.isFromV2API, "v2 版本应该有 v2 数据")
    XCTAssertNotNil(v2First.sha1, "v2 应该有 SHA1")
    XCTAssertNotNil(v2First.complianceLevel, "v2 应该有合规等级")
  }

  func testVersionInfoExtensions() async throws {
    let manifest = try await client.fetchVersionManifest(useV2: true)
    let version = manifest.versions.first!

    // 测试扩展方法
    XCTAssertTrue(version.hasSHA1, "v2 版本应该有 SHA1")
    XCTAssertTrue(version.hasComplianceLevel, "v2 版本应该有合规等级")
    XCTAssertTrue(version.isFromV2API, "应该识别为 v2 数据")

    // 测试格式化日期
    let formattedDate = version.formattedReleaseDate
    XCTAssertFalse(formattedDate.isEmpty, "格式化日期不应为空")
    print("发布日期: \(formattedDate)")
  }

  // MARK: - Integration Tests

  func testFetchVersionDetailsFromBothAPIs() async throws {
    // 从 v1 获取版本信息
    let manifestV1 = try await client.fetchVersionManifest(useV2: false)
    guard let versionV1 = manifestV1.versions.first else {
      XCTFail("找不到版本")
      return
    }

    // 从 v2 获取版本信息
    let manifestV2 = try await client.fetchVersionManifest(useV2: true)
    guard let versionV2 = manifestV2.versions.first else {
      XCTFail("找不到版本")
      return
    }

    // 无论来自哪个 API，都应该能获取详细信息
    let detailsFromV1 = try await client.fetchVersionDetails(for: versionV1)
    let detailsFromV2 = try await client.fetchVersionDetails(for: versionV2)

    // 详细信息应该相同
    XCTAssertEqual(detailsFromV1.id, detailsFromV2.id)
    XCTAssertEqual(detailsFromV1.mainClass, detailsFromV2.mainClass)
    XCTAssertEqual(detailsFromV1.libraries.count, detailsFromV2.libraries.count)

    print("从 v1 获取的详情: \(detailsFromV1.id)")
    print("从 v2 获取的详情: \(detailsFromV2.id)")
  }

  func testCompareAPIResponses() async throws {
    print("\n=== 比较 v1 和 v2 API ===")

    let manifestV1 = try await client.fetchVersionManifest(useV2: false)
    let manifestV2 = try await client.fetchVersionManifest(useV2: true)

    print("\n最新版本:")
    print("  正式版: \(manifestV1.latest.release)")
    print("  快照版: \(manifestV1.latest.snapshot)")

    print("\n版本数量:")
    print("  v1: \(manifestV1.versions.count)")
    print("  v2: \(manifestV2.versions.count)")

    print("\n前 3 个版本:")
    for (index, version) in manifestV2.versions.prefix(3).enumerated() {
      print("\n[\(index + 1)] \(version.id) (\(version.type))")
      print("  发布时间: \(version.formattedReleaseDate)")
      if let sha1 = version.sha1 {
        print("  SHA1: \(sha1.prefix(16))...")
      }
      if let compliance = version.complianceLevel {
        print("  合规等级: \(compliance)")
      }
    }
  }
}
