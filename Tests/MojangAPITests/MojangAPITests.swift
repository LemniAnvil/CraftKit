import XCTest

@testable import MojangAPI

final class MojangAPITests: XCTestCase {

  var client: MinecraftAPIClient!

  override func setUp() {
    super.setUp()
    client = MinecraftAPIClient()
  }

  func testFetchVersionManifest() async throws {
    let manifest = try await client.fetchVersionManifest()
    XCTAssertFalse(manifest.versions.isEmpty, "版本列表不应为空")
    XCTAssertFalse(manifest.latest.release.isEmpty, "最新正式版不应为空")
    XCTAssertFalse(manifest.latest.snapshot.isEmpty, "最新快照版不应为空")
  }

  func testFetchReleaseVersions() async throws {
    let releases = try await client.fetchVersions(ofType: .release)
    XCTAssertFalse(releases.isEmpty, "正式版列表不应为空")
    XCTAssertTrue(releases.allSatisfy { $0.type == .release })
  }

  func testFindVersion() async throws {
    let version = try await client.findVersion(byId: "1.21.11")
    XCTAssertNotNil(version, "应该找到版本 1.21.11")
    XCTAssertEqual(version?.id, "1.21.11")
  }

  func testFetchPlayerProfileByName() async throws {
    let profile = try await client.fetchPlayerProfile(byName: "a_pi")
    XCTAssertEqual(profile.name, "A_Pi")
    XCTAssertEqual(profile.id, "c4bb2799e1664b6f970ca96c9e58f2d3")
    XCTAssertNil(profile.properties) // 通过名称查询，属性为空
  }

  func testFetchPlayerProfileByUUID() async throws {
    let uuid = "c4bb2799e1664b6f970ca96c9e58f2d3"
    let profile = try await client.fetchPlayerProfile(byUUID: uuid)

    XCTAssertEqual(profile.name, "A_Pi")
    XCTAssertEqual(profile.id, uuid)
    XCTAssertNotNil(profile.properties, "通过 UUID 查询，属性不应为空")
    XCTAssertNotNil(profile.profileActions)

    // 测试解码纹理
    XCTAssertNotNil(profile.getSkinURL(), "应该能获取到皮肤 URL")

    let texturesPayload = try profile.getTexturesPayload()
    XCTAssertNotNil(texturesPayload, "应该能成功解码纹理载荷")
    XCTAssertEqual(texturesPayload?.profileName, "A_Pi")
    XCTAssertEqual(texturesPayload?.textures.SKIN?.metadata?.model, "slim")
  }
}
