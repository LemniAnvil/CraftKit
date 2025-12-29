//
//  CFFile.swift
//  MojangAPI
//

import Foundation

/// CurseForge 文件信息
public struct CFFile: Codable, Identifiable, Hashable, Equatable {
  /// 文件 ID
  public let id: Int
  /// 游戏 ID
  public let gameId: Int
  /// Mod ID
  public let modId: Int
  /// 是否可用
  public let isAvailable: Bool
  /// 显示名称
  public let displayName: String
  /// 文件名
  public let fileName: String
  /// 发布类型 (1=Release, 2=Beta, 3=Alpha)
  public let releaseType: Int
  /// 文件状态
  public let fileStatus: Int
  /// 哈希值列表
  public let hashes: [CFFileHash]
  /// 文件日期
  public let fileDate: Date
  /// 文件大小（字节）
  public let fileLength: Int
  /// 下载次数
  public let downloadCount: Int
  /// 磁盘占用大小（字节，可选）
  public let fileSizeOnDisk: Int?
  /// 下载 URL（某些文件可能没有下载链接）
  public let downloadUrl: String?
  /// 游戏版本列表
  public let gameVersions: [String]
  /// 可排序的游戏版本列表
  public let sortableGameVersions: [CFSortableGameVersion]
  /// 依赖列表
  public let dependencies: [CFFileDependency]
  /// 备用文件 ID
  public let alternateFileId: Int
  /// 是否为服务器包
  public let isServerPack: Bool
  /// 服务器包文件 ID（可选）
  public let serverPackFileId: Int?
  /// 文件指纹
  public let fileFingerprint: Int64
  /// 模块列表
  public let modules: [CFFileModule]

  /// 发布类型名称
  public var releaseTypeName: String {
    switch releaseType {
    case 1: return "正式版"
    case 2: return "测试版"
    case 3: return "内测版"
    default: return "未知"
    }
  }

  /// 格式化的文件大小
  public var formattedFileSize: String {
    let bytes = Double(fileLength)
    if bytes < 1024 {
      return "\(Int(bytes)) B"
    } else if bytes < 1024 * 1024 {
      return String(format: "%.1f KB", bytes / 1024)
    } else if bytes < 1024 * 1024 * 1024 {
      return String(format: "%.1f MB", bytes / (1024 * 1024))
    } else {
      return String(format: "%.2f GB", bytes / (1024 * 1024 * 1024))
    }
  }

  /// SHA1 哈希值
  public var sha1Hash: String? {
    return hashes.first(where: { $0.isSHA1 })?.value
  }

  /// MD5 哈希值
  public var md5Hash: String? {
    return hashes.first(where: { $0.isMD5 })?.value
  }

  /// 是否有服务器包
  public var hasServerPack: Bool {
    return serverPackFileId != nil
  }

  /// 必需依赖列表
  public var requiredDependencies: [CFFileDependency] {
    return dependencies.filter { $0.isRequired }
  }

  /// 可选依赖列表
  public var optionalDependencies: [CFFileDependency] {
    return dependencies.filter { $0.isOptional }
  }
}
