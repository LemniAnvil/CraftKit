//
//  VersionDetails.swift
//  MojangAPI
//

import Foundation

/// 完整的版本详细信息
public struct VersionDetails: Codable {
  /// 启动参数（1.13+ 版本使用结构化参数）
  public let arguments: Arguments?
  /// Minecraft 参数（1.12.2 及更早版本使用的简单字符串参数）
  public let minecraftArguments: String?
  /// 资源索引信息
  public let assetIndex: AssetIndex
  /// 资源版本 ID
  public let assets: String
  /// 合规等级
  public let complianceLevel: Int
  /// 下载信息
  public let downloads: Downloads
  /// 版本 ID
  public let id: String
  /// Java 版本要求
  public let javaVersion: JavaVersion
  /// 依赖库列表
  public let libraries: [Library]
  /// 日志配置（1.11+ 版本提供）
  public let logging: Logging?
  /// 主类
  public let mainClass: String
  /// 最低启动器版本
  public let minimumLauncherVersion: Int
  /// 发布时间
  public let releaseTime: Date
  /// 更新时间
  public let time: Date
  /// 版本类型
  public let type: VersionType

  /// 判断是否为新版本格式（使用结构化 arguments）
  public var usesStructuredArguments: Bool {
    return arguments != nil
  }

  /// 判断是否为旧版本格式（使用简单字符串 minecraftArguments）
  public var usesLegacyArguments: Bool {
    return minecraftArguments != nil
  }
}

// MARK: - Arguments

/// 启动参数
public struct Arguments: Codable {
  /// 游戏参数
  public let game: [Argument]
  /// JVM 参数
  public let jvm: [Argument]
}

/// 参数（可以是字符串或带规则的对象）
public enum Argument: Codable {
  case string(String)
  case conditional(ConditionalArgument)

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()

    if let string = try? container.decode(String.self) {
      self = .string(string)
    } else if let conditional = try? container.decode(ConditionalArgument.self) {
      self = .conditional(conditional)
    } else {
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Argument must be either a String or ConditionalArgument"
      )
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .string(let value):
      try container.encode(value)
    case .conditional(let value):
      try container.encode(value)
    }
  }
}

/// 带条件的参数
public struct ConditionalArgument: Codable {
  /// 规则列表
  public let rules: [Rule]
  /// 参数值（可以是单个字符串或字符串数组）
  public let value: ArgumentValue
}

/// 参数值
public enum ArgumentValue: Codable {
  case single(String)
  case multiple([String])

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()

    if let string = try? container.decode(String.self) {
      self = .single(string)
    } else if let array = try? container.decode([String].self) {
      self = .multiple(array)
    } else {
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "ArgumentValue must be either a String or [String]"
      )
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .single(let value):
      try container.encode(value)
    case .multiple(let value):
      try container.encode(value)
    }
  }
}

// MARK: - Asset Index

/// 资源索引信息
public struct AssetIndex: Codable {
  /// 资源索引 ID
  public let id: String
  /// SHA1 校验和
  public let sha1: String
  /// 文件大小
  public let size: Int
  /// 总大小
  public let totalSize: Int
  /// 下载 URL
  public let url: String
}

// MARK: - Downloads

/// 下载信息
public struct Downloads: Codable {
  /// 客户端下载信息
  public let client: DownloadInfo
  /// 服务端下载信息
  public let server: DownloadInfo?
  /// 客户端混淆映射（1.14.4+ 版本提供，用于模组开发）
  public let clientMappings: DownloadInfo?
  /// 服务端混淆映射（1.14.4+ 版本提供，用于模组开发）
  public let serverMappings: DownloadInfo?
  /// Windows 服务端下载信息（某些旧版本提供）
  public let windowsServer: DownloadInfo?

  enum CodingKeys: String, CodingKey {
    case client
    case server
    case clientMappings = "client_mappings"
    case serverMappings = "server_mappings"
    case windowsServer = "windows_server"
  }
}

/// 单个下载信息
public struct DownloadInfo: Codable {
  /// SHA1 校验和
  public let sha1: String
  /// 文件大小
  public let size: Int
  /// 下载 URL
  public let url: String
}

// MARK: - Java Version

/// Java 版本信息
public struct JavaVersion: Codable {
  /// 组件名称
  public let component: String
  /// 主版本号
  public let majorVersion: Int
}

// MARK: - Library

/// 依赖库信息
public struct Library: Codable {
  /// 下载信息
  public let downloads: LibraryDownloads
  /// 库名称（Maven 坐标格式）
  public let name: String
  /// 应用规则
  public let rules: [Rule]?
}

/// 库下载信息
public struct LibraryDownloads: Codable {
  /// 主要构件（某些原生库可能没有，只有 classifiers）
  public let artifact: Artifact?
  /// 平台特定的构件（原生库使用）
  public let classifiers: [String: Artifact]?
}

/// 构件信息
public struct Artifact: Codable {
  /// 相对路径
  public let path: String
  /// SHA1 校验和
  public let sha1: String
  /// 文件大小
  public let size: Int
  /// 下载 URL
  public let url: String
}

// MARK: - Rule

/// 规则
public struct Rule: Codable {
  /// 动作（allow 或 disallow）
  public let action: String
  /// 操作系统限制
  public let os: OSRule?
  /// 功能要求
  public let features: [String: Bool]?
}

/// 操作系统规则
public struct OSRule: Codable {
  /// 操作系统名称
  public let name: String?
  /// CPU 架构
  public let arch: String?
}

// MARK: - Logging

/// 日志配置
public struct Logging: Codable {
  /// 客户端日志配置
  public let client: ClientLogging
}

/// 客户端日志配置
public struct ClientLogging: Codable {
  /// 日志参数
  public let argument: String
  /// 日志配置文件信息
  public let file: LogFile
  /// 日志类型
  public let type: String
}

/// 日志文件信息
public struct LogFile: Codable {
  /// 文件 ID
  public let id: String
  /// SHA1 校验和
  public let sha1: String
  /// 文件大小
  public let size: Int
  /// 下载 URL
  public let url: String
}
