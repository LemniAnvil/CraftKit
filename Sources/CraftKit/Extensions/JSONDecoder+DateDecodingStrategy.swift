//
//  JSONDecoder+DateDecodingStrategy.swift
//  MojangAPI
//

import Foundation

extension JSONDecoder.DateDecodingStrategy {

  /// 灵活的 ISO8601 日期解码策略
  ///
  /// 支持多种毫秒精度的 ISO8601 日期格式：
  /// - 无毫秒: `2024-01-01T12:00:00Z` 或 `2024-01-01T12:00:00+00:00`
  /// - 1-7位毫秒: `2024-01-01T12:00:00.123Z` 到 `2024-01-01T12:00:00.1234567Z`
  /// - 带时区偏移: `2024-01-01T12:00:00+00:00` 或 `2024-01-01T12:00:00.123+00:00`
  ///
  /// 适用于 CurseForge API、Minecraft API 等返回可变毫秒位数的 API
  public static var flexibleISO8601: JSONDecoder.DateDecodingStrategy {
    return .custom { decoder in
      let container = try decoder.singleValueContainer()
      let dateString = try container.decode(String.self)

      // 尝试使用标准 ISO8601DateFormatter（支持可选的毫秒）
      let iso8601Formatter = ISO8601DateFormatter()
      iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

      if let date = iso8601Formatter.date(from: dateString) {
        return date
      }

      // 如果标准格式化器失败，尝试自定义格式
      // 这处理不同毫秒精度的情况
      let dateFormatter = DateFormatter()
      dateFormatter.locale = Locale(identifier: "en_US_POSIX")
      dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

      // 按常见程度排序的格式列表
      let formats = [
        "yyyy-MM-dd'T'HH:mm:ssXXX",  // 无毫秒，带时区偏移（如 +00:00）
        "yyyy-MM-dd'T'HH:mm:ss.SSSXXX",  // 3位毫秒，带时区偏移
        "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",  // 3位毫秒（最常见）
        "yyyy-MM-dd'T'HH:mm:ss'Z'",  // 无毫秒
        "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXX",  // 6位毫秒，带时区偏移
        "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSXXX",  // 7位毫秒，带时区偏移
        "yyyy-MM-dd'T'HH:mm:ss.SSSSSXXX",  // 5位毫秒，带时区偏移
        "yyyy-MM-dd'T'HH:mm:ss.SSSSXXX",  // 4位毫秒，带时区偏移
        "yyyy-MM-dd'T'HH:mm:ss.SSXXX",  // 2位毫秒，带时区偏移
        "yyyy-MM-dd'T'HH:mm:ss.SXXX",  // 1位毫秒，带时区偏移
        "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'",  // 6位毫秒
        "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z'",  // 7位毫秒
        "yyyy-MM-dd'T'HH:mm:ss.SSSSS'Z'",  // 5位毫秒
        "yyyy-MM-dd'T'HH:mm:ss.SSSS'Z'",  // 4位毫秒
        "yyyy-MM-dd'T'HH:mm:ss.SS'Z'",  // 2位毫秒
        "yyyy-MM-dd'T'HH:mm:ss.S'Z'",  // 1位毫秒
      ]

      for format in formats {
        dateFormatter.dateFormat = format
        if let date = dateFormatter.date(from: dateString) {
          return date
        }
      }

      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "无法解析日期字符串: \(dateString). 期望 ISO8601 格式。"
      )
    }
  }

  /// 严格的 ISO8601 日期解码策略（仅标准格式）
  ///
  /// 只接受标准的 ISO8601 格式，不进行额外的格式尝试
  public static var strictISO8601: JSONDecoder.DateDecodingStrategy {
    return .custom { decoder in
      let container = try decoder.singleValueContainer()
      let dateString = try container.decode(String.self)

      let iso8601Formatter = ISO8601DateFormatter()
      iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

      if let date = iso8601Formatter.date(from: dateString) {
        return date
      }

      // 尝试不带毫秒的格式
      iso8601Formatter.formatOptions = [.withInternetDateTime]
      if let date = iso8601Formatter.date(from: dateString) {
        return date
      }

      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "无效的 ISO8601 日期格式: \(dateString)"
      )
    }
  }
}
