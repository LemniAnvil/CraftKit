# MojangAPI 速查表

## 🚀 快速开始

```swift
import MojangAPI

let client = MinecraftAPIClient()
```

## 📦 版本 API

### 获取版本清单
```swift
// v2 API（推荐）
let manifest = try await client.fetchVersionManifest()

// v1 API
let manifestV1 = try await client.fetchVersionManifest(useV2: false)

// 最新版本
print(manifest.latest.release)   // "1.21.4"
print(manifest.latest.snapshot)  // "26.1-snapshot-1"
```

### 获取版本详情
```swift
// 通过 ID
let details = try await client.fetchVersionDetails(byId: "1.21.4")

// 通过 VersionInfo
let info = try await client.findVersion(byId: "1.21.4")
let details = try await client.fetchVersionDetails(for: info!)
```

### 过滤版本
```swift
// 所有正式版
let releases = try await client.fetchVersions(ofType: .release)

// 所有快照版
let snapshots = try await client.fetchVersions(ofType: .snapshot)

// 手动过滤
let oldAlpha = manifest.versions.filter { $0.type == .old_alpha }
```

## 👤 玩家 API

### 查询玩家
```swift
// 通过用户名
let profile = try await client.fetchPlayerProfile(byName: "Notch")

// 通过 UUID
let profile = try await client.fetchPlayerProfile(
    byUUID: "069a79f4-44e9-4726-a5be-fca90e38aaf5"
)
```

### 获取皮肤/披风
```swift
// 获取 URL
let skinURL = try await client.fetchSkinURL(byName: "Notch")
let capeURL = try await client.fetchCapeURL(byName: "Notch")

// 下载数据
let skinData = try await client.downloadSkin(byName: "Notch")
let capeData = try await client.downloadCape(byName: "Notch")
```

### 纹理信息
```swift
let textures = try await client.fetchTextures(byName: "Notch")

if let skin = textures.textures.SKIN {
    print("皮肤 URL: \(skin.url)")
    print("模型: \(skin.skinModel.displayName)")
}

if let cape = textures.textures.CAPE {
    print("披风 URL: \(cape.url)")
}
```

## 🔍 常用扩展

### VersionInfo
```swift
version.isFromV2API           // 是否来自 v2 API
version.hasSHA1               // 是否有 SHA1
version.hasComplianceLevel    // 是否有合规等级
version.formattedReleaseDate  // 格式化日期
version.isLatestRelease(in: manifest)
version.isLatestSnapshot(in: manifest)
```

### VersionDetails
```swift
details.clientDownloadURL      // 客户端 URL
details.serverDownloadURL      // 服务端 URL
details.totalDownloadSize      // 总大小（字节）
details.formattedDownloadSize  // 格式化大小
details.supportsOS("osx")      // OS 支持
details.libraries(for: "osx")  // OS 专用库
details.gameArgumentStrings    // 游戏参数
details.jvmArgumentStrings     // JVM 参数
```

### JavaVersion
```swift
javaVersion.isJava8       // 是否 Java 8
javaVersion.isJava17Plus  // 是否 Java 17+
javaVersion.isJava21Plus  // 是否 Java 21+
```

### PlayerProfile
```swift
profile.hasCustomSkin     // 有自定义皮肤
profile.hasProperties     // 有属性
profile.isSigned          // 有签名
profile.getSkinURL()      // 皮肤 URL
profile.getCapeURL()      // 披风 URL
profile.getTexturesPayload()  // 纹理信息
```

## ⚙️ 配置

```swift
var config = MinecraftAPIConfiguration()
config.timeout = 30.0
config.cachePolicy = .reloadIgnoringLocalCacheData

let client = MinecraftAPIClient(configuration: config)
```

## ❌ 错误处理

```swift
do {
    let profile = try await client.fetchPlayerProfile(byName: "...")
} catch MinecraftAPIError.playerNotFound(let name) {
    print("玩家不存在: \(name)")
} catch MinecraftAPIError.versionNotFound(let id) {
    print("版本不存在: \(id)")
} catch MinecraftAPIError.invalidUUID(let uuid) {
    print("无效的 UUID: \(uuid)")
} catch MinecraftAPIError.networkError(let error) {
    print("网络错误: \(error)")
} catch {
    print("其他错误: \(error)")
}
```

## 📋 完整示例

### 获取并显示版本信息
```swift
let client = MinecraftAPIClient()

// 获取清单
let manifest = try await client.fetchVersionManifest()

// 最新版本详情
let latest = try await client.fetchVersionDetails(
    byId: manifest.latest.release
)

print("版本: \(latest.id)")
print("Java: \(latest.javaVersion.majorVersion)")
print("大小: \(latest.formattedDownloadSize)")
print("库: \(latest.libraries.count) 个")

// macOS 库
let macLibs = latest.libraries(for: "osx")
print("macOS 库: \(macLibs.count) 个")

// 下载信息
if let clientURL = latest.clientDownloadURL {
    print("客户端: \(clientURL)")
}
```

### 查询玩家并下载皮肤
```swift
let client = MinecraftAPIClient()

// 查询玩家
let profile = try await client.fetchPlayerProfile(byName: "Notch")
print("UUID: \(profile.id)")

// 检查是否有自定义皮肤
if profile.hasCustomSkin {
    // 下载皮肤
    let skinData = try await client.downloadSkin(byUUID: profile.id)
    
    // 显示图片
    #if canImport(UIKit)
    let image = UIImage(data: skinData)
    #elseif canImport(AppKit)
    let image = NSImage(data: skinData)
    #endif
}

// 获取纹理详情
let textures = try profile.getTexturesPayload()
if let skin = textures.textures.SKIN {
    print("皮肤模型: \(skin.skinModel.displayName)")
}
```

### 比较版本
```swift
let manifest = try await client.fetchVersionManifest()

// 最新的 3 个正式版
let releases = manifest.versions
    .filter { $0.type == .release }
    .prefix(3)

for release in releases {
    print("\n\(release.id)")
    print("  发布: \(release.formattedReleaseDate)")
    
    if release.isFromV2API {
        print("  SHA1: \(release.sha1!.prefix(16))...")
        print("  合规: \(release.complianceLevel!)")
    }
}
```

## 🎯 最佳实践

### ✅ 推荐
```swift
// 使用 v2 API
let manifest = try await client.fetchVersionManifest()

// 安全检查可选值
if let sha1 = version.sha1 {
    print("SHA1: \(sha1)")
}

// 使用便利扩展
if version.isFromV2API {
    // 使用 v2 数据
}
```

### ❌ 避免
```swift
// 强制解包可选值（可能崩溃）
print(version.sha1!)  // 如果是 v1 数据会崩溃

// 忽略错误
try? client.fetchPlayerProfile(byName: "...")  // 丢失错误信息
```

## 📚 更多资源

- [完整文档](./README.md)
- [API 参考](./Documentation/API.md)
- [Version Manifest API](./Documentation/VersionManifestAPI.md)
- [Version Details API](./Documentation/VersionDetailsAPI.md)
- [示例代码](./Sources/MojangAPI/Examples/)
