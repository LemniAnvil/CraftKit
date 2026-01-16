//
//  PKCEHelper.swift
//  MojangAPI
//
//  PKCE (Proof Key for Code Exchange) 辅助工具
//  实现 RFC 7636 标准，用于 OAuth 2.0 公共客户端
//

import CryptoKit
import Foundation

/// PKCE 辅助工具
///
/// 实现 RFC 7636 标准，为 OAuth 2.0 公共客户端提供安全扩展，防止授权码拦截攻击。
///
/// 使用示例：
/// ```swift
/// let codePair = PKCEHelper.generateCodePair()
/// // 在授权 URL 中使用 codePair.challenge
/// // 在交换授权码时使用 codePair.verifier
/// ```
public struct PKCEHelper {

  // MARK: - 类型定义

  /// PKCE 代码对
  public struct CodePair {
    /// 代码验证器（43-128 个字符）
    public let verifier: String

    /// 代码挑战值（验证器的 SHA256 哈希）
    public let challenge: String

    public init(verifier: String, challenge: String) {
      self.verifier = verifier
      self.challenge = challenge
    }
  }

  // MARK: - 公共方法

  /// 生成 PKCE 代码验证器和挑战值对
  ///
  /// - Returns: 包含验证器和挑战值的代码对
  public static func generateCodePair() -> CodePair {
    let verifier = generateCodeVerifier()
    let challenge = generateCodeChallenge(from: verifier)
    return CodePair(verifier: verifier, challenge: challenge)
  }

  /// 生成随机代码验证器
  ///
  /// 生成符合 RFC 7636 规范的 43-128 字符长度的随机字符串。
  ///
  /// - Returns: URL 安全的 Base64 编码字符串
  public static func generateCodeVerifier() -> String {
    let bytes = (0..<96).map { _ in UInt8.random(in: 0...255) }
    return base64URLEncode(Data(bytes)).prefix(128).string
  }

  /// 从验证器生成代码挑战值（使用 SHA256）
  ///
  /// - Parameter verifier: 代码验证器字符串
  /// - Returns: 验证器的 SHA256 哈希值（URL 安全的 Base64 编码）
  public static func generateCodeChallenge(from verifier: String) -> String {
    let data = Data(verifier.utf8)
    let hash = SHA256.hash(data: data)
    return base64URLEncode(Data(hash))
  }

  /// 生成随机 state 参数用于 CSRF 保护
  ///
  /// - Returns: 16 字节的随机字符串（URL 安全的 Base64 编码）
  public static func generateState() -> String {
    let bytes = (0..<16).map { _ in UInt8.random(in: 0...255) }
    return base64URLEncode(Data(bytes))
  }

  // MARK: - 私有方法

  /// 将数据编码为 URL 安全的 Base64 字符串
  ///
  /// 按照 RFC 4648 Section 5 规范，将标准 Base64 转换为 URL 安全格式：
  /// - 将 '+' 替换为 '-'
  /// - 将 '/' 替换为 '_'
  /// - 移除填充字符 '='
  ///
  /// - Parameter data: 要编码的数据
  /// - Returns: URL 安全的 Base64 字符串
  private static func base64URLEncode(_ data: Data) -> String {
    return data.base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
  }
}

// MARK: - Substring Extension

extension Substring {
  /// 将 Substring 转换为 String
  fileprivate var string: String {
    return String(self)
  }
}
