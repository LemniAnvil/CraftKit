//
//  UUID+Flexible.swift
//  CraftKit
//

import Foundation

extension UUID {
  /// 从带或不带横杠的字符串初始化 UUID
  ///
  /// 此扩展支持解析两种格式的 UUID 字符串：
  /// - 标准格式（带横杠）：`"550e8400-e29b-41d4-a716-446655440000"`
  /// - 紧凑格式（不带横杠）：`"550e8400e29b41d4a716446655440000"`
  ///
  /// Mojang API 在不同端点返回不同格式的 UUID，此扩展可以统一处理。
  ///
  /// - Parameter flexibleString: UUID 字符串（带或不带横杠）
  /// - Returns: 如果解析成功返回 UUID，否则返回 nil
  ///
  /// 示例：
  /// ```swift
  /// // 标准格式
  /// let uuid1 = UUID(flexibleString: "550e8400-e29b-41d4-a716-446655440000")
  ///
  /// // 紧凑格式
  /// let uuid2 = UUID(flexibleString: "550e8400e29b41d4a716446655440000")
  ///
  /// // uuid1 == uuid2
  /// ```
  public init?(flexibleString: String) {
    // 如果字符串已包含横杠，尝试直接解析
    if flexibleString.contains("-") {
      self.init(uuidString: flexibleString)
      return
    }

    // 如果没有横杠，插入标准格式的横杠
    guard flexibleString.count == 32 else {
      return nil
    }

    let chars = Array(flexibleString)
    let formatted =
      "\(String(chars[0..<8]))-\(String(chars[8..<12]))-\(String(chars[12..<16]))-\(String(chars[16..<20]))-\(String(chars[20..<32]))"

    self.init(uuidString: formatted)
  }
}
