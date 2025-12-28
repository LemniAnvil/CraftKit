# MojangAPI - Swift Minecraft API Client

一个现代的、类型安全的 Swift 客户端库，用于访问 Mojang 的 Minecraft API。

## 特性

- ✅ **版本信息** - 获取所有 Minecraft 版本列表和详细信息
- ✅ **玩家档案** - 通过用户名或 UUID 查询玩家信息
- ✅ **皮肤和披风** - 下载玩家皮肤和披风
- ✅ **API 版本兼容** - 同时支持 v1 和 v2 版本清单 API
- ✅ **类型安全** - 完整的 Swift 类型支持
- ✅ **Async/Await** - 现代的异步 API
- ✅ **完整文档** - 详细的文档和示例代码

## 安装

### Swift Package Manager

在 `Package.swift` 中添加依赖：

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/MojangAPI.git", from: "1.0.0")
]
```

## 快速开始

### 获取版本信息

```swift
import MojangAPI

let client = MinecraftAPIClient()

// 获取版本清单
let manifest = try await client.fetchVersionManifest()
print("最新正式版: \(manifest.latest.release)")
print("最新快照版: \(manifest.latest.snapshot)")

// 获取特定版本的详细信息
let details = try await client.fetchVersionDetails(byId: "1.21.4")
print("Java 版本: \(details.javaVersion.majorVersion)")
print("下载大小: \(details.formattedDownloadSize)")
```

### 查询玩家信息

```swift
// 通过用户名查询
let profile = try await client.fetchPlayerProfile(byName: "Notch")
print("UUID: \(profile.id)")
print("用户名: \(profile.name)")

// 下载玩家皮肤
let skinData = try await client.downloadSkin(byName: "Notch")
// 使用 skinData 显示图片
```

## API 文档

### 版本 API

#### 获取版本清单

```swift
// 使用 v2 API（推荐，包含 SHA1 和合规等级）
let manifest = try await client.fetchVersionManifest()

// 显式指定 API 版本
let manifestV1 = try await client.fetchVersionManifest(useV2: false)
let manifestV2 = try await client.fetchVersionManifest(useV2: true)
```

**v1 vs v2 差异：**
- v1: 基础版本信息（id, type, url, time, releaseTime）
- v2: v1 的所有字段 + `sha1` + `complianceLevel`

详见 [Version Manifest API 文档](./Documentation/VersionManifestAPI.md)

#### 获取版本详细信息

```swift
// 通过版本 ID
let details = try await client.fetchVersionDetails(byId: "1.21.4")

// 通过 VersionInfo 对象
let versionInfo = try await client.findVersion(byId: "1.21.4")
if let info = versionInfo {
    let details = try await client.fetchVersionDetails(for: info)
}
```

详见 [Version Details API 文档](./Documentation/VersionDetailsAPI.md)

#### 过滤版本

```swift
let manifest = try await client.fetchVersionManifest()

// 获取所有正式版
let releases = manifest.versions.filter { $0.type == .release }

// 获取所有快照版
let snapshots = manifest.versions.filter { $0.type == .snapshot }

// 使用便利方法
let releaseVersions = try await client.fetchVersions(ofType: .release)
```

### 玩家档案 API

#### 通过用户名查询

```swift
let profile = try await client.fetchPlayerProfile(byName: "Notch")
print("UUID: \(profile.id)")
print("用户名: \(profile.name)")
```

#### 通过 UUID 查询

```swift
// 获取完整档案（包含皮肤信息）
let profile = try await client.fetchPlayerProfile(byUUID: "069a79f4-44e9-4726-a5be-fca90e38aaf5")

// 获取纹理信息
let textures = try profile.getTexturesPayload()
if let skin = textures.textures.SKIN {
    print("皮肤 URL: \(skin.url)")
    print("皮肤模型: \(skin.skinModel.displayName)")
}
```

### 纹理 API

#### 获取皮肤和披风 URL

```swift
// 获取皮肤 URL
if let skinURL = try await client.fetchSkinURL(byName: "Notch") {
    print("皮肤 URL: \(skinURL)")
}

// 获取披风 URL
if let capeURL = try await client.fetchCapeURL(byName: "Notch") {
    print("披风 URL: \(capeURL)")
}
```

#### 下载皮肤和披风

```swift
// 下载皮肤数据
let skinData = try await client.downloadSkin(byName: "Notch")

#if canImport(UIKit)
let image = UIImage(data: skinData)
#elseif canImport(AppKit)
let image = NSImage(data: skinData)
#endif

// 下载披风数据
if let capeData = try? await client.downloadCape(byName: "Notch") {
    // 处理披风图片
}
```

## 数据模型

### VersionInfo

```swift
public struct VersionInfo: Codable {
    public let id: String              // 版本 ID（如 "1.21.4"）
    public let type: VersionType       // 版本类型
    public let url: String             // 详情 URL
    public let time: Date              // 更新时间
    public let releaseTime: Date       // 发布时间
    public let sha1: String?           // SHA1（仅 v2）
    public let complianceLevel: Int?   // 合规等级（仅 v2）
}
```

### VersionDetails

```swift
public struct VersionDetails: Codable {
    public let id: String
    public let type: VersionType
    public let mainClass: String
    public let javaVersion: JavaVersion
    public let downloads: Downloads
    public let libraries: [Library]
    public let arguments: Arguments
    // ... 更多字段
}
```

### PlayerProfile

```swift
public struct PlayerProfile: Codable {
    public let id: String              // UUID
    public let name: String            // 用户名
    public let properties: [Property]? // 属性（包含纹理）
}
```

## 便利扩展

### VersionInfo 扩展

```swift
// 检查 API 版本
version.isFromV2API          // 是否来自 v2 API
version.hasSHA1              // 是否有 SHA1
version.hasComplianceLevel   // 是否有合规等级

// 版本比较
version.isLatestRelease(in: manifest)
version.isLatestSnapshot(in: manifest)

// 格式化
version.formattedReleaseDate  // 格式化的发布日期
```

### VersionDetails 扩展

```swift
// 下载信息
details.clientDownloadURL     // 客户端下载 URL
details.serverDownloadURL     // 服务端下载 URL
details.totalDownloadSize     // 总下载大小（字节）
details.formattedDownloadSize // 格式化的大小

// 操作系统支持
details.supportsOS("osx")     // 检查 macOS 支持
details.libraries(for: "osx") // 获取 macOS 库

// 参数
details.gameArgumentStrings   // 所有游戏参数
details.jvmArgumentStrings    // 所有 JVM 参数

// Java 版本
details.javaVersion.isJava8
details.javaVersion.isJava17Plus
details.javaVersion.isJava21Plus
```

### PlayerProfile 扩展

```swift
profile.hasCustomSkin         // 是否有自定义皮肤
profile.hasProperties         // 是否有属性
profile.isSigned              // 是否有签名

// 获取信息
profile.getSkinURL()          // 皮肤 URL
profile.getCapeURL()          // 披风 URL
profile.getTexturesPayload()  // 完整纹理信息
```

## 错误处理

```swift
do {
    let profile = try await client.fetchPlayerProfile(byName: "NonExistentPlayer")
} catch MinecraftAPIError.playerNotFound(let name) {
    print("玩家不存在: \(name)")
} catch MinecraftAPIError.versionNotFound(let versionId) {
    print("版本不存在: \(versionId)")
} catch MinecraftAPIError.networkError(let error) {
    print("网络错误: \(error)")
} catch {
    print("未知错误: \(error)")
}
```

## 配置

```swift
var config = MinecraftAPIConfiguration()
config.timeout = 30.0
config.cachePolicy = .reloadIgnoringLocalCacheData

let client = MinecraftAPIClient(configuration: config)
```

## Demo 应用

项目包含一个完整的 SwiftUI demo 应用，展示所有功能：

- 玩家档案查询和皮肤预览
- 版本信息浏览
- 版本详细信息查看
- 依赖库列表
- 启动参数查看

运行 demo：
```bash
cd Demo/MojangAPIDemo
open MojangAPIDemo.xcodeproj
```

## 系统要求

- iOS 15.0+ / macOS 12.0+
- Swift 5.9+
- Xcode 15.0+

## 文档

- [Version Manifest API](./Documentation/VersionManifestAPI.md) - v1 和 v2 版本清单 API
- [Version Details API](./Documentation/VersionDetailsAPI.md) - 版本详细信息
- [API 参考](./Documentation/API.md) - 完整的 API 参考

## 示例代码

查看 [Examples](./Sources/MojangAPI/Examples/) 目录获取更多示例。

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！

## 相关链接

- [Mojang API Wiki](https://wiki.vg/Mojang_API)
- [Minecraft Wiki](https://minecraft.fandom.com/wiki/Minecraft_Wiki)
- [Piston Meta API](https://piston-meta.mojang.com/)
