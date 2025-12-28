# Version Manifest API - v1 vs v2

## 概述

Mojang 提供两个版本的 Version Manifest API：

- **v1**: `version_manifest.json` - 基础版本信息
- **v2**: `version_manifest_v2.json` - 包含额外的校验和合规信息

## API 差异

### v1 API (`version_manifest.json`)

每个版本信息包含：
```json
{
  "id": "1.21.4",
  "type": "release",
  "url": "https://...",
  "time": "2024-12-03T10:28:32+00:00",
  "releaseTime": "2024-12-03T10:17:41+00:00"
}
```

### v2 API (`version_manifest_v2.json`)

每个版本信息包含 v1 的所有字段，外加：
```json
{
  "id": "1.21.4",
  "type": "release",
  "url": "https://...",
  "time": "2024-12-03T10:28:32+00:00",
  "releaseTime": "2024-12-03T10:17:41+00:00",
  "sha1": "b9345ee364d36ef1c7ec26df6bf99d3e4a4393f5",
  "complianceLevel": 1
}
```

**新增字段：**
- `sha1`: 版本 JSON 文件的 SHA1 校验和
- `complianceLevel`: 合规等级（用于新启动器的功能兼容性）

## 使用方法

### 默认使用 v2 API（推荐）

```swift
let client = MinecraftAPIClient()

// 默认使用 v2 API
let manifest = try await client.fetchVersionManifest()

for version in manifest.versions.prefix(5) {
    print("\(version.id)")
    
    // v2 API 提供的额外信息
    if let sha1 = version.sha1 {
        print("  SHA1: \(sha1)")
    }
    if let compliance = version.complianceLevel {
        print("  Compliance: \(compliance)")
    }
}
```

### 显式指定 API 版本

```swift
let client = MinecraftAPIClient()

// 使用 v1 API
let manifestV1 = try await client.fetchVersionManifest(useV2: false)
print("V1 API - 版本数: \(manifestV1.versions.count)")

// 使用 v2 API
let manifestV2 = try await client.fetchVersionManifest(useV2: true)
print("V2 API - 版本数: \(manifestV2.versions.count)")
```

### 检测数据来源

```swift
let manifest = try await client.fetchVersionManifest()

for version in manifest.versions {
    if version.isFromV2API {
        print("\(version.id) - 来自 v2 API")
        print("  SHA1: \(version.sha1!)")
        print("  Compliance: \(version.complianceLevel!)")
    } else {
        print("\(version.id) - 来自 v1 API (无额外元数据)")
    }
}
```

### 兼容性检查

```swift
let version = manifest.versions.first!

// 检查是否有 SHA1
if version.hasSHA1 {
    print("SHA1 可用: \(version.sha1!)")
} else {
    print("SHA1 不可用（可能来自 v1 API）")
}

// 检查是否有合规等级
if version.hasComplianceLevel {
    print("Compliance Level: \(version.complianceLevel!)")
} else {
    print("Compliance Level 不可用")
}

// 一次性检查
if version.isFromV2API {
    print("完整的 v2 元数据可用")
} else {
    print("仅有基础信息")
}
```

## 数据模型

`VersionInfo` 结构体兼容两个版本：

```swift
public struct VersionInfo: Codable, Identifiable {
    public let id: String              // v1 & v2
    public let type: VersionType       // v1 & v2
    public let url: String             // v1 & v2
    public let time: Date              // v1 & v2
    public let releaseTime: Date       // v1 & v2
    public let sha1: String?           // 仅 v2
    public let complianceLevel: Int?   // 仅 v2
}
```

## 便利扩展方法

```swift
// 检查方法
version.isFromV2API          // true 如果有完整的 v2 数据
version.hasSHA1              // true 如果有 SHA1 字段
version.hasComplianceLevel   // true 如果有 complianceLevel 字段

// 现有方法（v1 & v2 都支持）
version.isLatestRelease(in: manifest)
version.isLatestSnapshot(in: manifest)
version.formattedReleaseDate
```

## 何时使用哪个版本？

### 使用 v2 API（默认，推荐）
- ✅ 需要验证下载的完整性（SHA1）
- ✅ 需要检查启动器兼容性（complianceLevel）
- ✅ 构建现代的启动器或工具
- ✅ 需要最新和最完整的信息

### 使用 v1 API
- ⚠️ 兼容旧系统或旧代码
- ⚠️ 不需要额外的元数据
- ⚠️ 网络带宽极其受限（v2 略大）

## 完整示例

```swift
import MojangAPI

let client = MinecraftAPIClient()

do {
    // 获取 v2 manifest
    let manifest = try await client.fetchVersionManifest(useV2: true)
    
    print("=== 最新版本 ===")
    print("正式版: \(manifest.latest.release)")
    print("快照版: \(manifest.latest.snapshot)")
    
    print("\n=== 最近的 5 个版本 ===")
    for version in manifest.versions.prefix(5) {
        print("\n\(version.id) (\(version.type))")
        print("  发布时间: \(version.formattedReleaseDate)")
        print("  URL: \(version.url)")
        
        if version.isFromV2API {
            print("  SHA1: \(version.sha1!)")
            print("  合规等级: \(version.complianceLevel!)")
        } else {
            print("  (v1 数据，无额外元数据)")
        }
    }
    
    // 获取特定类型的版本
    let releases = manifest.versions.filter { $0.type == .release }
    let snapshots = manifest.versions.filter { $0.type == .snapshot }
    
    print("\n=== 统计 ===")
    print("总版本数: \(manifest.versions.count)")
    print("正式版: \(releases.count)")
    print("快照版: \(snapshots.count)")
    
    // 检查数据来源
    let v2Count = manifest.versions.filter { $0.isFromV2API }.count
    print("v2 数据: \(v2Count) / \(manifest.versions.count)")
    
} catch {
    print("错误: \(error.localizedDescription)")
}
```

## 验证 SHA1 示例

```swift
// 如果从 v2 API 获取了版本信息，可以验证下载
let version = try await client.findVersion(byId: "1.21.4")!

if let expectedSHA1 = version.sha1 {
    // 下载版本详情
    let details = try await client.fetchVersionDetails(for: version)
    
    // 下载 JSON 数据
    let url = URL(string: version.url)!
    let (data, _) = try await URLSession.shared.data(from: url)
    
    // 计算实际的 SHA1
    import CryptoKit
    let hash = Insecure.SHA1.hash(data: data)
    let actualSHA1 = hash.map { String(format: "%02x", $0) }.joined()
    
    if actualSHA1 == expectedSHA1 {
        print("✅ SHA1 验证通过")
    } else {
        print("❌ SHA1 验证失败")
        print("预期: \(expectedSHA1)")
        print("实际: \(actualSHA1)")
    }
} else {
    print("⚠️ 无 SHA1 信息（可能来自 v1 API）")
}
```

## 迁移指南

如果你之前使用的是只支持 v2 的版本，现在的代码**完全向后兼容**。

### 之前的代码（仍然有效）
```swift
// 这些代码继续正常工作
let manifest = try await client.fetchVersionManifest()
print(manifest.versions.first!.sha1!)  // 如果是 v2，正常工作
```

### 新代码（更安全）
```swift
// 推荐的安全方式
let manifest = try await client.fetchVersionManifest()
let version = manifest.versions.first!

if let sha1 = version.sha1 {
    print("SHA1: \(sha1)")
} else {
    print("无 SHA1 信息")
}
```

## 参考

- [Mojang API Documentation](https://wiki.vg/Mojang_API)
- [Version Manifest Endpoint](https://piston-meta.mojang.com/mc/game/version_manifest.json)
- [Version Manifest v2 Endpoint](https://piston-meta.mojang.com/mc/game/version_manifest_v2.json)
