//
//  Data+Multipart.swift
//  CraftKit
//

import Foundation

extension Data {
  /// 向 Data 添加字符串内容（用于构建 multipart/form-data）
  mutating func append(_ string: String) {
    if let data = string.data(using: .utf8) {
      append(data)
    }
  }
}
