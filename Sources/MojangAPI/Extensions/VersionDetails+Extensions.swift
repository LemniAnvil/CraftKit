//
//  VersionDetails+Extensions.swift
//  MojangAPI
//

import Foundation

extension VersionDetails {

  /// 获取客户端下载 URL
  public var clientDownloadURL: URL? {
    URL(string: downloads.client.url)
  }

  /// 获取服务端下载 URL
  public var serverDownloadURL: URL? {
    guard let server = downloads.server else { return nil }
    return URL(string: server.url)
  }

  /// 获取资源索引下载 URL
  public var assetIndexURL: URL? {
    URL(string: assetIndex.url)
  }

  /// 检查是否支持指定的操作系统
  public func supportsOS(_ osName: String) -> Bool {
    // 检查库中是否有针对该操作系统的特殊规则
    for library in libraries {
      if let rules = library.rules {
        for rule in rules {
          if let os = rule.os, os.name == osName {
            return rule.action == "allow"
          }
        }
      }
    }
    return true
  }

  /// 获取所有游戏参数字符串
  public var gameArgumentStrings: [String] {
    // 新版本使用结构化 arguments
    if let arguments = arguments {
      var result: [String] = []
      for arg in arguments.game {
        switch arg {
        case .string(let value):
          result.append(value)
        case .conditional(let conditional):
          switch conditional.value {
          case .single(let value):
            result.append(value)
          case .multiple(let values):
            result.append(contentsOf: values)
          }
        }
      }
      return result
    }

    // 旧版本使用简单字符串 minecraftArguments
    if let minecraftArguments = minecraftArguments {
      return minecraftArguments.components(separatedBy: " ")
    }

    return []
  }

  /// 获取所有 JVM 参数字符串
  public var jvmArgumentStrings: [String] {
    // 仅新版本提供 JVM 参数
    guard let arguments = arguments else { return [] }

    var result: [String] = []
    for arg in arguments.jvm {
      switch arg {
      case .string(let value):
        result.append(value)
      case .conditional(let conditional):
        switch conditional.value {
        case .single(let value):
          result.append(value)
        case .multiple(let values):
          result.append(contentsOf: values)
        }
      }
    }
    return result
  }

  /// 获取适用于指定操作系统的库列表
  public func libraries(for osName: String) -> [Library] {
    libraries.filter { library in
      guard let rules = library.rules else { return true }

      for rule in rules {
        if let os = rule.os {
          if os.name == osName {
            return rule.action == "allow"
          }
        }
      }
      return true
    }
  }

  /// 获取总下载大小（字节）
  public var totalDownloadSize: Int {
    var total = downloads.client.size
    if let server = downloads.server {
      total += server.size
    }
    total += assetIndex.size

    for library in libraries {
      total += library.downloads.artifact.size
    }

    return total
  }

  /// 格式化的下载大小
  public var formattedDownloadSize: String {
    ByteCountFormatter.string(fromByteCount: Int64(totalDownloadSize), countStyle: .file)
  }
}

extension Library {
  /// 获取库的简短名称（不含版本号）
  public var shortName: String {
    let components = name.components(separatedBy: ":")
    return components.first ?? name
  }

  /// 获取库的版本号
  public var version: String? {
    let components = name.components(separatedBy: ":")
    return components.count > 2 ? components[2] : nil
  }

  /// 检查是否适用于指定操作系统
  public func isApplicable(for osName: String) -> Bool {
    guard let rules = rules else { return true }

    for rule in rules {
      if let os = rule.os, os.name == osName {
        return rule.action == "allow"
      }
    }
    return true
  }
}

extension JavaVersion {
  /// 是否为 Java 8
  public var isJava8: Bool {
    majorVersion == 8
  }

  /// 是否为 Java 17 或更高
  public var isJava17Plus: Bool {
    majorVersion >= 17
  }

  /// 是否为 Java 21 或更高
  public var isJava21Plus: Bool {
    majorVersion >= 21
  }
}
