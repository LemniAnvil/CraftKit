//
//  CFSearchParameters.swift
//  MojangAPI
//

import Foundation

/// CurseForge 排序字段
public enum CFSortField: Int {
  /// 精选
  case featured = 1
  /// 流行度
  case popularity = 2
  /// 最后更新
  case lastUpdated = 3
  /// 名称
  case name = 4
  /// 作者
  case author = 5
  /// 总下载量
  case totalDownloads = 6
  /// 分类
  case category = 7
  /// 游戏版本
  case gameVersion = 8

  public var displayName: String {
    switch self {
    case .featured: return "精选"
    case .popularity: return "流行度"
    case .lastUpdated: return "最后更新"
    case .name: return "名称"
    case .author: return "作者"
    case .totalDownloads: return "总下载量"
    case .category: return "分类"
    case .gameVersion: return "游戏版本"
    }
  }
}

/// CurseForge 排序顺序
public enum CFSortOrder: String {
  /// 升序
  case asc = "asc"
  /// 降序
  case desc = "desc"

  public var displayName: String {
    switch self {
    case .asc: return "升序"
    case .desc: return "降序"
    }
  }
}

/// CurseForge 游戏 ID
public enum CFGameID: Int {
  /// Minecraft
  case minecraft = 432

  public var displayName: String {
    switch self {
    case .minecraft: return "Minecraft"
    }
  }
}

/// CurseForge 类别 ID
public enum CFClassID: Int {
  /// Mod
  case mod = 6
  /// 整合包
  case modpack = 4471
  /// 资源包
  case resourcePack = 12
  /// 世界
  case world = 17

  public var displayName: String {
    switch self {
    case .mod: return "Mod"
    case .modpack: return "整合包"
    case .resourcePack: return "资源包"
    case .world: return "世界"
    }
  }
}

/// CurseForge Mod 加载器
public enum CFModLoader: Int {
  /// Forge
  case forge = 1
  /// Cauldron (已停用)
  case cauldron = 2
  /// LiteLoader (已停用)
  case liteLoader = 3
  /// Fabric
  case fabric = 4
  /// Quilt
  case quilt = 5
  /// NeoForge
  case neoForge = 6

  public var displayName: String {
    switch self {
    case .forge: return "Forge"
    case .cauldron: return "Cauldron"
    case .liteLoader: return "LiteLoader"
    case .fabric: return "Fabric"
    case .quilt: return "Quilt"
    case .neoForge: return "NeoForge"
    }
  }
}
