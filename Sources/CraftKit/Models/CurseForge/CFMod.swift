//
//  CFMod.swift
//  MojangAPI
//

import Foundation

/// CurseForge Mod/整合包信息
public struct CFMod: Codable, Identifiable, Hashable, Equatable {
  /// Mod ID
  public let id: Int
  /// 游戏 ID
  public let gameId: Int
  /// 名称
  public let name: String
  /// Slug（URL 友好的名称）
  public let slug: String
  /// 链接信息
  public let links: CFLinks
  /// 简介
  public let summary: String
  /// 状态
  public let status: Int
  /// 下载次数
  public let downloadCount: Int
  /// 是否为精选
  public let isFeatured: Bool
  /// 主要分类 ID
  public let primaryCategoryId: Int
  /// 分类列表
  public let categories: [CFCategory]
  /// 类别 ID (4471 = Modpacks)
  public let classId: Int
  /// 作者列表
  public let authors: [CFAuthor]
  /// Logo
  public let logo: CFLogo
  /// 主文件 ID
  public let mainFileId: Int
  /// 最新文件列表
  public let latestFiles: [CFFile]
  /// 最新文件索引
  public let latestFilesIndexes: [CFFileIndex]
  /// 早期访问文件索引
  public let latestEarlyAccessFilesIndexes: [CFFileIndex]
  /// 创建日期
  public let dateCreated: Date
  /// 修改日期
  public let dateModified: Date
  /// 发布日期
  public let dateReleased: Date
  /// 是否允许 Mod 分发
  public let allowModDistribution: Bool?
  /// 游戏热门度排名
  public let gamePopularityRank: Int
  /// 是否可用
  public let isAvailable: Bool
  /// 点赞数
  public let thumbsUpCount: Int
  /// 截图列表
  public let screenshots: [CFScreenshot]?
  /// 社交链接
  public let socialLinks: [CFSocialLink]?
  /// 服务器联属信息
  public let serverAffiliation: CFServerAffiliation?
  /// 精选项目标签
  public let featuredProjectTag: Int?

  /// 格式化的下载次数
  public var formattedDownloadCount: String {
    let count = Double(downloadCount)
    if count < 1000 {
      return "\(downloadCount)"
    } else if count < 1_000_000 {
      return String(format: "%.1fK", count / 1000)
    } else if count < 1_000_000_000 {
      return String(format: "%.1fM", count / 1_000_000)
    } else {
      return String(format: "%.2fB", count / 1_000_000_000)
    }
  }

  /// 主要作者
  public var primaryAuthor: CFAuthor? {
    return authors.first
  }

  /// 是否为整合包
  public var isModpack: Bool {
    return classId == 4471
  }

  /// 最新发布版文件
  public var latestReleaseFile: CFFile? {
    return latestFiles.first(where: { $0.releaseType == 1 })
  }

  /// 最新测试版文件
  public var latestBetaFile: CFFile? {
    return latestFiles.first(where: { $0.releaseType == 2 })
  }

  /// 最新内测版文件
  public var latestAlphaFile: CFFile? {
    return latestFiles.first(where: { $0.releaseType == 3 })
  }

  /// 支持的游戏版本列表
  public var supportedGameVersions: [String] {
    let allVersions = latestFilesIndexes.map { $0.gameVersion }
    return Array(Set(allVersions)).sorted().reversed()
  }

  /// 是否有截图
  public var hasScreenshots: Bool {
    return screenshots?.isEmpty == false
  }

  /// 是否有社交链接
  public var hasSocialLinks: Bool {
    return socialLinks?.isEmpty == false
  }

  /// Discord 链接
  public var discordLink: String? {
    return socialLinks?.first(where: { $0.type == 2 })?.url
  }

  /// 官网链接
  public var websiteLink: String? {
    return socialLinks?.first(where: { $0.type == 3 })?.url
  }
}
