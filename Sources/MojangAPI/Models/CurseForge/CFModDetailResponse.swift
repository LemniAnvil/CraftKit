import Foundation

/// CurseForge API 单个 Mod/整合包详情响应
///
/// 端点: `GET https://api.curseforge.com/v1/mods/{modId}`
///
/// 返回单个 mod 或整合包的完整详细信息，包括所有版本文件、截图等。
public struct CFModDetailResponse: Codable, Equatable {
  /// Mod/整合包的完整数据
  public let data: CFMod

  public init(data: CFMod) {
    self.data = data
  }
}
