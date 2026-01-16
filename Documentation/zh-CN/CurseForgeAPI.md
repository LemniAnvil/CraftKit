# CurseForge API 文档

CurseForge Minecraft 整合包/模组 API 集成完整参考。

## 目录

- [快速开始](#快速开始)
- [搜索 API](#搜索-api)
  - [搜索整合包](#搜索整合包)
  - [搜索模组](#搜索模组)
  - [搜索参数](#搜索参数)
- [Mod 详情 API](#mod-详情-api)
  - [获取 Mod 详情](#获取-mod-详情)
- [数据模型](#数据模型)
- [分页](#分页)
- [错误处理](#错误处理)

## 快速开始

### 配置

```swift
import CraftKit

// 从环境变量读取 API 密钥（推荐）
let apiKey = ProcessInfo.processInfo.environment["CURSEFORGE_API_KEY"] ?? "YOUR_API_KEY"
let config = CurseForgeAPIConfiguration(apiKey: apiKey)
let client = CurseForgeAPIClient(configuration: config)
```

### API 密钥

使用此 API 需要 CurseForge API 密钥。从以下位置获取：
- [CurseForge for Studios](https://console.curseforge.com/?#/api-keys)

**安全提示**：永远不要在源代码中硬编码 API 密钥。使用环境变量或安全配置文件。

## 搜索 API

### 搜索整合包

```swift
// 基础搜索
let response = try await client.searchModpacks()

// 带关键词搜索
let response = try await client.searchModpacks(
    searchFilter: "sky",
    sortField: .totalDownloads,
    sortOrder: .desc,
    pageSize: 20
)

// 按游戏版本过滤
let response = try await client.searchModpacks(
    gameVersion: "1.20.1",
    pageSize: 10
)

// 按分类过滤
let response = try await client.searchModpacks(
    categoryIds: [4475, 4483], // 冒险与 RPG，战斗 / PvP
    pageSize: 15
)
```

### 搜索模组

```swift
let response = try await client.searchMods(
    gameId: .minecraft,
    classId: .mod,
    searchFilter: "optifine",
    sortField: .totalDownloads,
    sortOrder: .desc,
    index: 0,
    pageSize: 25,
    gameVersion: "1.20.1",
    modLoaderType: .forge
)
```

### 搜索参数

**排序字段：**
- `.featured` - 精选模组
- `.popularity` - 人气
- `.lastUpdated` - 最后更新
- `.name` - 名称（字母顺序）
- `.author` - 作者名称
- `.totalDownloads` - 总下载量
- `.category` - 分类
- `.gameVersion` - 游戏版本

**排序顺序：**
- `.asc` - 升序
- `.desc` - 降序

**Mod 加载器：**
- `.any` - 任意加载器
- `.forge` - Forge
- `.cauldron` - Cauldron
- `.liteLoader` - LiteLoader
- `.fabric` - Fabric
- `.quilt` - Quilt
- `.neoForge` - NeoForge

## Mod 详情 API

### 获取 Mod 详情

```swift
// 通过 mod ID 获取
let response = try await client.fetchModDetails(modId: 285109)
let mod = response.data

print("名称: \(mod.name)")
print("下载量: \(mod.formattedDownloadCount)")
print("作者: \(mod.primaryAuthor?.name ?? "未知")")
print("简介: \(mod.summary)")

// 访问分类
for category in mod.categories {
    print("分类: \(category.name)")
}

// 访问最新文件
if let latestRelease = mod.latestReleaseFile {
    print("最新正式版: \(latestRelease.displayName)")
    print("文件大小: \(latestRelease.formattedFileSize)")
    print("游戏版本: \(latestRelease.gameVersions.joined(separator: ", "))")
}

// 访问链接
print("网站: \(mod.links.websiteUrl)")
if let wiki = mod.links.wikiUrl {
    print("Wiki: \(wiki)")
}

// 访问社交链接
if let socialLinks = mod.socialLinks {
    for link in socialLinks {
        print("\(link.typeName): \(link.url)")
    }
}
```

## 数据模型

### CFMod

模组和整合包的主要模型：

```swift
public struct CFMod: Codable {
    public let id: Int                      // Mod ID
    public let name: String                 // Mod 名称
    public let slug: String                 // URL 友好名称
    public let summary: String              // 简短描述
    public let downloadCount: Int           // 总下载量
    public let categories: [CFCategory]     // 分类
    public let authors: [CFAuthor]          // 作者
    public let logo: CFLogo                 // Logo/图标
    public let latestFiles: [CFFile]        // 最新文件
    public let links: CFLinks               // 外部链接
    public let socialLinks: [CFSocialLink]? // 社交媒体链接
    public let screenshots: [CFScreenshot]? // 截图
    // ... 更多字段
}
```

### CFFile

文件信息：

```swift
public struct CFFile: Codable {
    public let id: Int                   // 文件 ID
    public let fileName: String          // 文件名
    public let displayName: String       // 显示名称
    public let downloadUrl: String?      // 下载 URL
    public let fileLength: Int           // 文件大小（字节）
    public let downloadCount: Int        // 下载次数
    public let releaseType: Int          // 1=正式版，2=测试版，3=内测版
    public let gameVersions: [String]    // 支持的游戏版本
    public let hashes: [CFFileHash]      // SHA1/MD5 哈希
    public let fileDate: Date            // 文件日期
    public let isServerPack: Bool        // 是否为服务器包
    public let dependencies: [CFFileDependency] // 依赖关系
    // ... 更多字段
}
```

### CFModsSearchResponse

带分页的搜索响应：

```swift
public struct CFModsSearchResponse: Codable {
    public let data: [CFMod]           // 搜索结果
    public let pagination: CFPagination // 分页信息
}
```

## 分页

### 使用分页

```swift
let pageSize = 20
var currentIndex = 0

// 第一页
let page1 = try await client.searchModpacks(
    index: currentIndex,
    pageSize: pageSize
)

print("第 \(page1.pagination.currentPage) / \(page1.pagination.totalPages) 页")
print("总结果数: \(page1.pagination.totalCount)")

// 下一页
if page1.pagination.hasNextPage {
    currentIndex = page1.pagination.nextIndex!
    let page2 = try await client.searchModpacks(
        index: currentIndex,
        pageSize: pageSize
    )
}

// 上一页
if page1.pagination.hasPreviousPage {
    currentIndex = page1.pagination.previousIndex!
    let page0 = try await client.searchModpacks(
        index: currentIndex,
        pageSize: pageSize
    )
}
```

### 分页辅助方法

```swift
let pagination: CFPagination

pagination.hasNextPage      // 是否有下一页
pagination.hasPreviousPage  // 是否有上一页
pagination.nextIndex        // 下一页索引
pagination.previousIndex    // 上一页索引
pagination.currentPage      // 当前页码（从 1 开始）
pagination.totalPages       // 总页数
```

## 便利扩展

### CFMod 扩展

```swift
mod.isModpack                    // 是否为整合包？
mod.formattedDownloadCount       // "27.8M" 格式
mod.primaryAuthor                // 第一作者
mod.latestReleaseFile            // 最新正式版
mod.latestBetaFile               // 最新测试版
mod.latestAlphaFile              // 最新内测版
mod.supportedGameVersions        // 所有支持的版本
mod.hasScreenshots               // 是否有截图
mod.hasSocialLinks               // 是否有社交链接
mod.discordLink                  // Discord 邀请链接
mod.websiteLink                  // 官方网站
```

### CFFile 扩展

```swift
file.formattedFileSize      // "49.0 MB" 格式
file.releaseTypeName        // "正式版"、"测试版"、"内测版"
file.sha1Hash               // SHA1 哈希值
file.md5Hash                // MD5 哈希值

let hash: CFFileHash
hash.isSHA1                 // 是否为 SHA1（在 CFFileHash 上定义）
hash.isMD5                  // 是否为 MD5
```

## 错误处理

```swift
do {
    let response = try await client.searchModpacks()
} catch CurseForgeAPIError.unauthorized {
    print("API 密钥无效")
} catch CurseForgeAPIError.rateLimitExceeded {
    print("超出速率限制，请稍后再试")
} catch CurseForgeAPIError.serverError(let statusCode) {
    print("服务器错误: \(statusCode)")
} catch CurseForgeAPIError.networkError(let error) {
    print("网络错误: \(error.localizedDescription)")
} catch {
    print("未知错误: \(error)")
}
```

## 常见用例

### 显示整合包列表

```swift
let response = try await client.searchModpacks(
    sortField: .totalDownloads,
    sortOrder: .desc,
    pageSize: 20
)

for modpack in response.data {
    print("\(modpack.name)")
    print("  作者: \(modpack.primaryAuthor?.name ?? "未知")")
    print("  下载量: \(modpack.formattedDownloadCount)")
    print("  简介: \(modpack.summary)")
    print("  Logo: \(modpack.logo.thumbnailUrl)")
    print()
}
```

### 查找特定版本的整合包

```swift
let response = try await client.searchModpacks(
    gameVersion: "1.20.1",
    sortField: .totalDownloads,
    sortOrder: .desc,
    pageSize: 10
)

for modpack in response.data {
    let versions = modpack.supportedGameVersions
    print("\(modpack.name) 支持: \(versions.joined(separator: ", "))")
}
```

### 获取完整的 Mod 信息

```swift
// 首先，搜索 mod
let searchResponse = try await client.searchModpacks(
    searchFilter: "RLCraft",
    pageSize: 1
)

if let mod = searchResponse.data.first {
    // 然后，获取完整详情
    let detailResponse = try await client.fetchModDetails(modId: mod.id)
    let fullMod = detailResponse.data
    
    print("\(fullMod.name) 的完整信息:")
    print("  分类: \(fullMod.categories.map { $0.name }.joined(separator: ", "))")
    print("  文件数: \(fullMod.latestFiles.count)")
    print("  截图数: \(fullMod.screenshots?.count ?? 0)")
}
```

## API 限制

- **速率限制**：CurseForge API 有速率限制。请遵守限制以避免被封禁。
- **页面大小**：最大页面大小通常为 50。
- **API 版本**：本库使用 CurseForge API v1。

## 相关资源

- [CurseForge API 文档](https://docs.curseforge.com/)
- [CurseForge for Studios 控制台](https://console.curseforge.com/)
