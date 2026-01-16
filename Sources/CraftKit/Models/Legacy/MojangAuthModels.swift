//
//  MojangAuthModels.swift
//  CraftKit
//
//  旧版 Mojang 认证模型（已弃用）
//
//  注意：Mojang 认证已被弃用，并由 Microsoft 认证取代。
//  这些模型仅为向后兼容而保留。
//

import Foundation

// MARK: - Mojang 认证（旧版）

/// Mojang 认证请求
///
/// - Warning: 此认证方法已弃用。请使用 Microsoft 认证。
public struct MojangAuthRequest: Codable, Sendable {
  public let username: String
  public let password: String
  public let clientToken: String
  public let requestUser: Bool

  public init(
    username: String,
    password: String,
    clientToken: String,
    requestUser: Bool = true
  ) {
    self.username = username
    self.password = password
    self.clientToken = clientToken
    self.requestUser = requestUser
  }
}

/// Mojang 认证响应
///
/// - Warning: 此认证方法已弃用。请使用 Microsoft 认证。
public struct MojangAuthResponse: Codable, Sendable {
  public let accessToken: String
  public let clientToken: String
  public let availableProfiles: [GameProfile]
  public let selectedProfile: GameProfile
  public let user: UserInfo?

  public init(
    accessToken: String,
    clientToken: String,
    availableProfiles: [GameProfile],
    selectedProfile: GameProfile,
    user: UserInfo? = nil
  ) {
    self.accessToken = accessToken
    self.clientToken = clientToken
    self.availableProfiles = availableProfiles
    self.selectedProfile = selectedProfile
    self.user = user
  }
}

// MARK: - 支持类型

/// 游戏档案
public struct GameProfile: Codable, Sendable {
  public let id: String
  public let name: String
  public let legacy: Bool?

  public init(id: String, name: String, legacy: Bool? = nil) {
    self.id = id
    self.name = name
    self.legacy = legacy
  }
}

/// 用户信息
public struct UserInfo: Codable, Sendable {
  public let id: String
  public let properties: [UserProperty]?

  public init(id: String, properties: [UserProperty]? = nil) {
    self.id = id
    self.properties = properties
  }
}

/// 用户属性
public struct UserProperty: Codable, Sendable {
  public let name: String
  public let value: String

  public init(name: String, value: String) {
    self.name = name
    self.value = value
  }
}
