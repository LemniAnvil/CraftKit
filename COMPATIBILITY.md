# 版本兼容性说明

## 概述

CraftKit 包已完全兼容 Minecraft 所有版本（从最早的 rd-132211 到最新的快照版本）的不同 JSON 格式。

## 主要兼容性变化

### 1. 启动参数格式 (Arguments)

#### 新版本 (1.13+)
- 使用结构化的 `arguments` 字段
- 包含 `game` 和 `jvm` 两个数组
- 支持条件规则

```swift
if version.usesStructuredArguments {
    let gameArgs = version.gameArgumentStrings
    let jvmArgs = version.jvmArgumentStrings
}
```

#### 旧版本 (≤ 1.12.2)
- 使用简单的 `minecraftArguments` 字符串
- 参数用空格分隔

```swift
if version.usesLegacyArguments {
    let args = version.gameArgumentStrings  // 自动解析空格分隔的参数
}
```

### 2. 日志配置 (Logging)

- **1.11+**: 提供 `logging` 字段
- **< 1.11**: `logging` 为 `nil`

```swift
if let logging = version.logging {
    print("日志配置: \(logging.client.type)")
}
```

### 3. 下载文件 (Downloads)

#### 始终可用
- `client`: 客户端 JAR 文件

#### 可选字段
- `server`: 服务端 JAR（某些版本提供）
- `clientMappings`: 客户端混淆映射（1.14.4+）
- `serverMappings`: 服务端混淆映射（1.14.4+）
- `windowsServer`: Windows 服务端（某些旧版本）

```swift
// 客户端始终可用
let clientURL = version.downloads.client.url

// 服务端可能不存在
if let server = version.downloads.server {
    let serverURL = server.url
}

// 混淆映射（用于模组开发）
if let mappings = version.downloads.clientMappings {
    print("客户端映射: \(mappings.url)")
}
```

## 版本检测

使用便利属性判断版本格式：

```swift
// 检查参数格式
if version.usesStructuredArguments {
    // 新版本 (1.13+)
    print("使用结构化参数")
} else if version.usesLegacyArguments {
    // 旧版本 (≤ 1.12.2)
    print("使用传统参数")
}
```

## 统一 API

无论哪个版本，都可以使用统一的扩展方法：

```swift
// 获取游戏参数（自动处理新旧格式）
let gameArgs = version.gameArgumentStrings

// 获取 JVM 参数（旧版本返回空数组）
let jvmArgs = version.jvmArgumentStrings

// 下载 URL
let clientURL = version.clientDownloadURL
let serverURL = version.serverDownloadURL

// 总下载大小
let size = version.totalDownloadSize
let formatted = version.formattedDownloadSize  // "175.7 MB"
```

## 测试覆盖

运行兼容性测试：

```bash
swift test --filter VersionDetailsCompatibilityTests
```

## Schema 分析结果

根据对 859 个版本的分析：

- **通用字段 (100% 覆盖)**: 31 个
  - `id`, `type`, `assets`, `downloads.client`, `libraries`, 等

- **部分字段 (50-99% 覆盖)**: 1 个
  - `minecraftArguments`: 75% (旧版本使用)

- **稀有字段 (< 50% 覆盖)**: 37 个
  - `arguments`: 25% (新版本使用)
  - `logging`: 33.3% (1.11+ 版本)
  - `downloads.server`: 41.7% (部分版本提供)
  - `clientMappings/serverMappings`: 8.3% (最新版本)

详细分析结果见 `schema_comparison_results.json`。
