# 批量 UUID 查询并发优化

## 概述

`fetchUUIDs` 方法已经升级为使用 Swift Concurrency 的 `TaskGroup` 进行真正的并发处理，显著提升了批量查询的性能。

## 技术细节

### 之前的实现（串行）

```swift
// 旧实现：串行处理每个批次
var allResults: [String: String] = [:]
let batches = cleanedNames.chunked(into: effectiveBatchSize)

for batch in batches {
  let batchResults = try await fetchUUIDBatch(names: batch)
  allResults.merge(batchResults) { _, new in new }
}
```

**问题**：
- 批次按顺序执行，第二批必须等待第一批完成
- 对于 30 个玩家（3 个批次），总时间 = 批次1时间 + 批次2时间 + 批次3时间
- 没有充分利用网络带宽和 CPU 资源

### 新实现（并发）

```swift
// 新实现：使用 TaskGroup 并发处理所有批次
return try await withThrowingTaskGroup(of: [String: String].self) { group in
  // 为每个批次创建并发任务
  for batch in batches {
    group.addTask {
      try Task.checkCancellation()  // 支持任务取消
      return try await self.fetchUUIDBatch(names: batch)
    }
  }

  // 收集所有批次的结果
  var allResults: [String: String] = [:]
  for try await batchResults in group {
    allResults.merge(batchResults) { _, new in new }
  }

  return allResults
}
```

**优势**：
- ✅ 所有批次并发执行，充分利用网络资源
- ✅ 总时间 ≈ max(批次1时间, 批次2时间, 批次3时间)
- ✅ 支持任务取消（通过 `Task.checkCancellation()`）
- ✅ 类型安全的错误处理
- ✅ 自动资源管理

## 性能对比

### 测试场景：查询 30 个玩家（3 个批次）

假设每个批次耗时 1 秒：

| 实现方式 | 总耗时 | 加速比 |
|---------|--------|--------|
| 串行版本 | ~3.0 秒 | 1x |
| 并发版本 | ~1.0 秒 | 3x |

**实际测试结果**：
```
批量查询 15 个玩家，耗时 0.95 秒
找到 15 个玩家
批次数量: 2
```

## 使用示例

### 基本用法

```swift
import CraftKit

let client = MinecraftAPIClient()

// 查询多个玩家（自动并发分批）
let names = [
  "Notch", "jeb_", "Dinnerbone", "Grumm", "ez",
  "Searge", "Marc_IRL", "Hypixel", "Simon", "Dream",
  "GeorgeNotFound", "Sapnap", "TommyInnit", "Tubbo", "Ranboo"
]

let results = try await client.fetchUUIDs(names: names)

for (name, uuid) in results {
  print("\(name): \(uuid)")
}
```

### 支持任务取消

```swift
let task = Task {
  let results = try await client.fetchUUIDs(names: largePlayerList)
  return results
}

// 在某个时刻取消任务
task.cancel()

do {
  let results = try await task.value
} catch is CancellationError {
  print("查询已取消")
}
```

### Demo 应用示例

Demo 应用中的 `BatchUUIDLookupView` 展示了完整的功能：

1. **性能统计**：显示执行时间、批次数量等
2. **实时进度**：显示已找到的结果数量
3. **取消支持**：用户可以随时取消正在进行的查询
4. **示例数据**：一键加载 30 个知名玩家进行测试

```swift
// Demo 中的关键代码
let startTime = Date()

currentTask = Task {
  do {
    let fetchedResults = try await client.fetchUUIDs(names: names)
    
    try Task.checkCancellation()
    
    await MainActor.run {
      results = fetchedResults
      executionTime = Date().timeIntervalSince(startTime)
    }
  } catch is CancellationError {
    await MainActor.run {
      errorMessage = "查询已取消"
    }
  }
}
```

## 技术要点

### 1. TaskGroup 并发模式

`withThrowingTaskGroup` 提供了结构化并发：
- 自动等待所有子任务完成
- 任何子任务抛出错误时，会取消其他任务
- 保证资源正确释放

### 2. 错误传播

```swift
try await withThrowingTaskGroup(of: [String: String].self) { group in
  // 任何批次失败都会导致整个操作失败
  for batch in batches {
    group.addTask {
      return try await self.fetchUUIDBatch(names: batch)
    }
  }
  // ...
}
```

### 3. 任务取消检查

```swift
group.addTask {
  try Task.checkCancellation()  // 检查任务是否被取消
  return try await self.fetchUUIDBatch(names: batch)
}
```

### 4. 结果收集

```swift
var allResults: [String: String] = [:]
for try await batchResults in group {
  // 异步迭代所有完成的批次
  allResults.merge(batchResults) { _, new in new }
}
```

## API 限制

Mojang API 的限制：
- 每次请求最多 10 个玩家名
- 建议使用默认批次大小（10）
- 过快的请求可能被限流

## 最佳实践

1. **适当的批次大小**：使用默认的 10 个/批次
2. **错误处理**：捕获并处理网络错误和 API 错误
3. **取消支持**：为长时间运行的查询提供取消选项
4. **用户反馈**：显示进度和性能统计

## 相关资源

- [Swift Concurrency Documentation](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [TaskGroup API Reference](https://developer.apple.com/documentation/swift/taskgroup)
- [Structured Concurrency](https://developer.apple.com/videos/play/wwdc2021/10134/)

## 测试

项目包含两个测试用例：

1. **testFetchUUIDsConcurrency**：验证并发功能和性能
2. **testFetchUUIDsCancellation**：验证取消机制

运行测试：
```bash
swift test --filter testFetchUUIDs
```
