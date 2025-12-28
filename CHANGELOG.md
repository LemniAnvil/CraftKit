# 更新日志

## [未发布] - 2025-12-29

### ✨ 新增功能

#### 版本详情 API
- 添加 `VersionDetails` 模型，支持完整的版本元数据
- 添加 `fetchVersionDetails(byId:)` 方法
- 添加 `fetchVersionDetails(for:)` 方法
- 支持解析游戏参数、JVM 参数、库依赖、资源索引等

#### API 版本兼容性
- 同时支持 v1 和 v2 Version Manifest API
- 添加 `fetchVersionManifest(useV2:)` 方法
- 默认使用 v2 API（包含 SHA1 和合规等级）
- `VersionInfo` 的 `sha1` 和 `complianceLevel` 改为可选字段

#### 新模型
- `VersionDetails` - 完整版本信息
- `Arguments` - 启动参数
- `Argument` - 单个参数（支持条件）
- `AssetIndex` - 资源索引
- `Downloads` / `DownloadInfo` - 下载信息
- `JavaVersion` - Java 版本信息
- `Library` / `LibraryDownloads` / `Artifact` - 库依赖
- `Rule` / `OSRule` - 规则和操作系统限制
- `Logging` / `ClientLogging` / `LogFile` - 日志配置

#### 扩展方法

**VersionInfo 扩展：**
- `isFromV2API` - 检查是否来自 v2 API
- `hasSHA1` - 检查是否有 SHA1
- `hasComplianceLevel` - 检查是否有合规等级

**VersionDetails 扩展：**
- `clientDownloadURL` / `serverDownloadURL` - 获取下载 URL
- `assetIndexURL` - 获取资源索引 URL
- `supportsOS(_:)` - 检查操作系统支持
- `gameArgumentStrings` / `jvmArgumentStrings` - 获取所有参数
- `libraries(for:)` - 获取特定操作系统的库
- `totalDownloadSize` / `formattedDownloadSize` - 计算下载大小

**Library 扩展：**
- `shortName` - 库的简短名称
- `version` - 库的版本号
- `isApplicable(for:)` - 检查是否适用于指定操作系统

**JavaVersion 扩展：**
- `isJava8` - 是否为 Java 8
- `isJava17Plus` - 是否为 Java 17 或更高
- `isJava21Plus` - 是否为 Java 21 或更高

#### 错误处理
- 添加 `MinecraftAPIError.versionNotFound(_:)` 错误类型

#### Demo 应用
- 添加"版本详情"标签页
- 支持查询任意版本的详细信息
- 显示 Java 要求、下载信息、依赖库等
- 支持按操作系统过滤库
- 查看游戏和 JVM 启动参数

#### 文档
- [Version Manifest API 文档](./Documentation/VersionManifestAPI.md) - v1/v2 对比和使用指南
- [Version Details API 文档](./Documentation/VersionDetailsAPI.md) - 详细信息 API 使用指南
- [API 兼容性文档](./Documentation/APICompatibility.md) - 兼容性说明和迁移指南
- [速查表](./CHEATSHEET.md) - 快速参考
- [主 README](./README.md) - 完整的项目文档

#### 测试
- 添加 `VersionManifestCompatibilityTests` 测试套件
- 测试 v1 和 v2 API 的兼容性
- 测试默认行为
- 测试版本详情获取

#### 示例代码
- 添加 `VersionDetailsExample.swift` 示例
- 展示如何使用版本详情 API
- 展示如何检查操作系统兼容性
- 展示如何获取和处理启动参数

### 🔄 变更

- `VersionInfo.sha1` 从 `String` 改为 `String?`（向后兼容）
- `VersionInfo.complianceLevel` 从 `Int` 改为 `Int?`（向后兼容）
- `fetchVersionManifest()` 现在默认使用 v2 API（之前也是）

### 🐛 修复

- 无

### 💥 破坏性变更

- 无（完全向后兼容）

### 📝 注意事项

所有现有代码继续正常工作。如果你的代码直接访问 `sha1` 或 `complianceLevel` 字段，建议改为可选绑定：

```swift
// 旧代码（如果数据来自 v1 会崩溃）
print(version.sha1)

// 新代码（推荐）
if let sha1 = version.sha1 {
    print(sha1)
}

// 或使用便利方法
if version.isFromV2API {
    print(version.sha1!)  // 安全
}
```

### 🔗 相关链接

- [Mojang API Wiki](https://wiki.vg/Mojang_API)
- [Version Manifest v1](https://piston-meta.mojang.com/mc/game/version_manifest.json)
- [Version Manifest v2](https://piston-meta.mojang.com/mc/game/version_manifest_v2.json)

---

## [1.0.0] - 2025-12-26

### ✨ 初始版本

- 基础版本信息 API
- 玩家档案 API
- 皮肤和披风下载
- SwiftUI Demo 应用
- 完整的类型安全支持
- Async/Await 支持
