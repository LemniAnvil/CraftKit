//
//  SkinVariant.swift
//  MojangAPI
//

import Foundation

/// Minecraft 皮肤模型类型
public enum SkinVariant: String, Codable {
  /// Steve 模型（宽臂，经典模型）
  case classic = "classic"
  /// Alex 模型（细臂，苗条模型）
  case slim = "slim"
}
