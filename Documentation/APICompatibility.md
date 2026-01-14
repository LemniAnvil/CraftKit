# API 兼容性总结

## ✅ 已完成的更新

### 1. 模型兼容性
- **VersionInfo** 现在完全兼容 v1 和 v2 API
  - `sha1: String?` - 可选字段（仅 v2）
  - `complianceLevel: Int?` - 可选字段（仅 v2）

### 2. API 方法
```swift
// 默认使用 v2 API（推荐）
let manifest = try await client.fetchVersionManifest()

// 显式指定版本
let manifestV1 = try await client.fetchVersionManifest(useV2: false)
let manifestV2 = try await client.fetchVersionManifest(useV2: true)
```

### 3. 便利扩展
```swift
// 检测 API 版本
version.isFromV2API          // 是否包含 v2 数据
version.hasSHA1              // 是否有 SHA1 字段
version.hasComplianceLevel   // 是否有合规等级
```

## 🔄 向后兼容性

### 完全兼容
所有现有代码继续正常工作：

```swift
// 这些代码无需修改
let manifest = try await client.fetchVersionManifest()
let versions = manifest.versions

// 如果确定是 v2 数据，可以安全使用
if let sha1 = versions.first?.sha1 {
    print("SHA1: \(sha1)")
}
```

### 推荐的新写法
```swift
// 更安全的方式
let version = manifest.versions.first!

if version.isFromV2API {
    // 确保有完整数据
    print("SHA1: \(version.sha1!)")
    print("Compliance: \(version.complianceLevel!)")
} else {
    print("仅有基础信息")
}
```

## 📊 API 对比

| 字段 | v1 API | v2 API |
|------|--------|--------|
| `id` | ✅ | ✅ |
| `type` | ✅ | ✅ |
| `url` | ✅ | ✅ |
| `time` | ✅ | ✅ |
| `releaseTime` | ✅ | ✅ |
| `sha1` | ❌ | ✅ |
| `complianceLevel` | ❌ | ✅ |

## 🎯 使用建议

### 何时使用 v2 API（默认）
- ✅ 需要验证文件完整性
- ✅ 需要检查启动器兼容性
- ✅ 开发新项目
- ✅ 需要最完整的信息

### 何时使用 v1 API
- ⚠️ 兼容旧代码
- ⚠️ 不需要额外元数据
- ⚠️ 极端网络带宽限制

## 📝 迁移检查清单

- [x] ✅ VersionInfo 支持可选的 sha1 和 complianceLevel
- [x] ✅ 添加 fetchVersionManifest(useV2:) 方法
- [x] ✅ 默认使用 v2 API
- [x] ✅ 添加便利的检查方法
- [x] ✅ 完整的文档和示例
- [x] ✅ 测试用例覆盖
- [x] ✅ Demo 应用更新（可选）

## 🧪 测试

运行兼容性测试：
```bash
swift test --filter VersionManifestCompatibilityTests
```

## 📚 相关文档

- [Version Manifest API 详细文档](./VersionManifestAPI.md)
- [Version Details API 文档](./VersionDetailsAPI.md)
- [主 README](../README.md)

## 🔍 示例代码

### 基本使用
```swift
import CraftKit

let client = MinecraftAPIClient()

// 使用 v2 API（推荐）
let manifest = try await client.fetchVersionManifest()

for version in manifest.versions.prefix(5) {
    print("\(version.id) - \(version.type)")
    
    if version.isFromV2API {
        print("  SHA1: \(version.sha1!)")
        print("  Compliance: \(version.complianceLevel!)")
    }
}
```

### 验证完整性
```swift
let manifest = try await client.fetchVersionManifest(useV2: true)
let version = manifest.versions.first!

if let expectedSHA1 = version.sha1 {
    // 下载并验证
    let url = URL(string: version.url)!
    let (data, _) = try await URLSession.shared.data(from: url)
    
    // 计算实际 SHA1 并比较
    // ... 验证逻辑
} else {
    print("⚠️ 无 SHA1 信息可用")
}
```

## ⚡ 性能影响

- **响应大小**: v2 比 v1 略大（每个版本多 ~100 字节）
- **解析性能**: 可忽略的差异
- **网络影响**: 在正常网络条件下可忽略

## 🐛 已知问题

无已知问题。所有测试通过。

## 📞 支持

如有问题，请：
1. 查看文档
2. 运行测试用例
3. 提交 Issue
