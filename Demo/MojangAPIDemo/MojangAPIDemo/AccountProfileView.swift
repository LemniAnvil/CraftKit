//
//  AccountProfileView.swift
//  MojangAPIDemo
//
//  账户档案展示视图 - 显示所有皮肤和披风信息
//

import AppKit
import CraftKit
import SwiftUI

struct AccountProfileView: View {
  @State private var bearerToken = ""
  @State private var profile: AccountProfile?
  @State private var isLoading = false
  @State private var errorMessage: String?

  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        // 认证区域
        VStack(alignment: .leading, spacing: 12) {
          Text("认证信息")
            .font(.headline)

          VStack(spacing: 12) {
            SecureField("Bearer Token", text: $bearerToken)
              .textFieldStyle(.roundedBorder)
              .autocorrectionDisabled()

            Text("Token 仅用于当前会话，不会保存")
              .font(.caption)
              .foregroundStyle(.secondary)

            Button(action: loadProfile) {
              HStack {
                if isLoading {
                  ProgressView()
                    .controlSize(.small)
                } else {
                  Image(systemName: "person.circle.fill")
                }
                Text(isLoading ? "加载中..." : "获取档案")
              }
              .frame(maxWidth: .infinity)
              .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .disabled(trimmedToken.isEmpty || isLoading)
          }
          .padding()
          .background(Color(nsColor: .controlBackgroundColor))
          .clipShape(RoundedRectangle(cornerRadius: 12))
        }

        // 错误信息
        if let error = errorMessage {
          HStack {
            Image(systemName: "exclamationmark.triangle.fill")
              .foregroundStyle(.red)
            Text(error)
              .foregroundStyle(.red)
          }
          .padding()
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(Color.red.opacity(0.1))
          .clipShape(RoundedRectangle(cornerRadius: 12))
        }

        // 档案信息
        if let profile = profile {
          // 玩家信息卡片
          VStack(alignment: .leading, spacing: 16) {
            HStack {
              Image(systemName: "person.crop.circle.fill")
                .font(.title)
                .foregroundStyle(.blue)

              VStack(alignment: .leading, spacing: 4) {
                Text(profile.name)
                  .font(.title2)
                  .fontWeight(.bold)

                Text(profile.id)
                  .font(.system(.caption, design: .monospaced))
                  .foregroundStyle(.secondary)
                  .textSelection(.enabled)
              }

              Spacer()
            }

            Divider()

            HStack(spacing: 32) {
              VStack(spacing: 4) {
                Text("\(profile.skins.count)")
                  .font(.title2)
                  .fontWeight(.semibold)
                  .foregroundStyle(.blue)
                Text("皮肤")
                  .font(.caption)
                  .foregroundStyle(.secondary)
              }

              VStack(spacing: 4) {
                Text("\(profile.capes.count)")
                  .font(.title2)
                  .fontWeight(.semibold)
                  .foregroundStyle(.purple)
                Text("披风")
                  .font(.caption)
                  .foregroundStyle(.secondary)
              }
            }
            .frame(maxWidth: .infinity)
          }
          .padding(20)
          .background(Color(nsColor: .controlBackgroundColor))
          .clipShape(RoundedRectangle(cornerRadius: 12))

          // 当前状态
          VStack(alignment: .leading, spacing: 12) {
            Text("当前装备")
              .font(.headline)

            HStack(spacing: 16) {
              // 皮肤状态
              VStack(alignment: .leading, spacing: 8) {
                HStack {
                  Image(systemName: "paintbrush.fill")
                    .foregroundStyle(.blue)
                  Text("皮肤")
                    .font(.subheadline)
                    .fontWeight(.medium)
                }

                if let activeSkin = profile.activeSkin {
                  VStack(alignment: .leading, spacing: 4) {
                    Text(activeSkin.alias ?? "未命名")
                      .font(.body)

                    Text(activeSkin.variant.rawValue)
                      .font(.caption)
                      .padding(.horizontal, 8)
                      .padding(.vertical, 3)
                      .background(.blue.opacity(0.15))
                      .foregroundStyle(.blue)
                      .clipShape(Capsule())
                  }
                } else {
                  Text("默认皮肤")
                    .font(.body)
                    .foregroundStyle(.secondary)
                }
              }
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding()
              .background(Color(nsColor: .controlBackgroundColor))
              .clipShape(RoundedRectangle(cornerRadius: 10))

              // 披风状态
              VStack(alignment: .leading, spacing: 8) {
                HStack {
                  Image(systemName: "flag.fill")
                    .foregroundStyle(.purple)
                  Text("披风")
                    .font(.subheadline)
                    .fontWeight(.medium)
                }

                if let activeCape = profile.activeCape {
                  Text(activeCape.alias)
                    .font(.body)
                } else {
                  Text("未装备")
                    .font(.body)
                    .foregroundStyle(.secondary)
                }
              }
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding()
              .background(Color(nsColor: .controlBackgroundColor))
              .clipShape(RoundedRectangle(cornerRadius: 10))
            }
          }

          // 皮肤列表
          VStack(alignment: .leading, spacing: 12) {
            HStack {
              Image(systemName: "paintbrush.fill")
                .foregroundStyle(.blue)
              Text("所有皮肤")
                .font(.headline)
              Text("(\(profile.skins.count))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            if profile.skins.isEmpty {
              Text("暂无皮肤")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(40)
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
              VStack(spacing: 12) {
                ForEach(profile.skins) { skin in
                  SkinCardView(skin: skin)
                }
              }
            }
          }

          // 披风列表
          VStack(alignment: .leading, spacing: 12) {
            HStack {
              Image(systemName: "flag.fill")
                .foregroundStyle(.purple)
              Text("所有披风")
                .font(.headline)
              Text("(\(profile.capes.count))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            if profile.capes.isEmpty {
              Text("暂无披风")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(40)
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
              // 使用网格布局展示披风
              LazyVGrid(
                columns: [
                  GridItem(.adaptive(minimum: 140, maximum: 180), spacing: 16)
                ], spacing: 16
              ) {
                ForEach(profile.capes) { cape in
                  CapeCardView(cape: cape)
                }
              }
            }
          }
        }
      }
      .padding(20)
    }
    .navigationTitle("账户档案")
    .frame(minWidth: 600, minHeight: 400)
  }

  private var trimmedToken: String {
    bearerToken.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private func loadProfile() {
    isLoading = true
    errorMessage = nil
    profile = nil

    Task {
      do {
        let client = MinecraftAuthenticatedClient(bearerToken: trimmedToken)
        profile = try await client.getProfile()
      } catch MinecraftAPIError.invalidBearerToken {
        errorMessage = "Bearer Token 无效或已过期"
      } catch {
        errorMessage = error.localizedDescription
      }

      isLoading = false
    }
  }
}

// MARK: - 皮肤卡片视图
struct SkinCardView: View {
  let skin: AccountSkin
  @State private var skinImage: NSImage?
  @State private var isLoadingImage = false

  var body: some View {
    HStack(spacing: 16) {
      // 皮肤预览
      Group {
        if let image = skinImage {
          Image(nsImage: image)
            .resizable()
            .interpolation(.none)
            .aspectRatio(contentMode: .fit)
        } else if isLoadingImage {
          ProgressView()
            .controlSize(.small)
        } else {
          Image(systemName: "photo")
            .font(.title2)
            .foregroundStyle(.secondary)
        }
      }
      .frame(width: 80, height: 80)
      .background(Color(nsColor: .windowBackgroundColor))
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .overlay(
        RoundedRectangle(cornerRadius: 10)
          .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
      )

      // 皮肤信息
      VStack(alignment: .leading, spacing: 8) {
        HStack {
          Text(skin.alias ?? "未命名皮肤")
            .font(.title3)
            .fontWeight(.semibold)

          if skin.isActive {
            Text("激活")
              .font(.caption)
              .fontWeight(.semibold)
              .padding(.horizontal, 8)
              .padding(.vertical, 3)
              .background(.green)
              .foregroundStyle(.white)
              .clipShape(Capsule())
          }
        }

        HStack(spacing: 8) {
          Text(skin.variant.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(.blue.opacity(0.15))
            .foregroundStyle(.blue)
            .clipShape(Capsule())

          Text(skin.state.displayName)
            .font(.caption)
            .foregroundStyle(.secondary)
        }

        Text("ID: \(skin.id)")
          .font(.caption2)
          .foregroundStyle(.tertiary)
          .lineLimit(1)
          .textSelection(.enabled)
      }

      Spacer()

      // 操作菜单
      Menu {
        Button {
          if let url = skin.urlObject {
            NSWorkspace.shared.open(url)
          }
        } label: {
          Label("在浏览器中打开", systemImage: "safari")
        }

        Button {
          NSPasteboard.general.clearContents()
          NSPasteboard.general.setString(skin.url, forType: .string)
        } label: {
          Label("复制 URL", systemImage: "doc.on.doc")
        }

        Button {
          NSPasteboard.general.clearContents()
          NSPasteboard.general.setString(skin.textureKey, forType: .string)
        } label: {
          Label("复制纹理键", systemImage: "key")
        }
      } label: {
        Image(systemName: "ellipsis.circle.fill")
          .font(.title3)
          .foregroundStyle(.secondary)
      }
      .menuStyle(.borderlessButton)
      .frame(width: 32, height: 32)
    }
    .padding(16)
    .background(Color(nsColor: .controlBackgroundColor))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .task {
      await loadSkinImage()
    }
  }

  private func loadSkinImage() async {
    guard var url = skin.urlObject else { return }

    // 将 http:// 转换为 https://
    url = convertToHTTPS(url)

    isLoadingImage = true
    defer { isLoadingImage = false }

    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      if let image = NSImage(data: data) {
        await MainActor.run {
          skinImage = image
        }
      }
    } catch {
      print("加载皮肤图片失败: \(error)")
    }
  }

  private func convertToHTTPS(_ url: URL) -> URL {
    if url.scheme == "http" {
      var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
      components?.scheme = "https"
      return components?.url ?? url
    }
    return url
  }
}

// MARK: - 披风卡片视图
struct CapeCardView: View {
  let cape: AccountCape
  @State private var capeFrontImage: NSImage?
  @State private var isLoadingImage = false

  var body: some View {
    VStack(spacing: 0) {
      // 披风正面预览
      Group {
        if let image = capeFrontImage {
          Image(nsImage: image)
            .resizable()
            .interpolation(.none)
            .aspectRatio(contentMode: .fill)
        } else if isLoadingImage {
          ProgressView()
            .controlSize(.small)
        } else {
          Image(systemName: "photo")
            .font(.title)
            .foregroundStyle(.secondary)
        }
      }
      .frame(maxWidth: .infinity)
      .frame(height: 160)
      .background(Color(nsColor: .windowBackgroundColor))
      .clipShape(RoundedRectangle(cornerRadius: 8))
      .overlay(alignment: .topTrailing) {
        if cape.isActive {
          Text("激活")
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(.green)
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .padding(6)
        }
      }
      .padding(12)

      // 披风信息区域
      VStack(spacing: 6) {
        // 披风名称
        Text(cape.alias)
          .font(.subheadline)
          .fontWeight(.semibold)
          .lineLimit(1)
          .frame(maxWidth: .infinity)

        // 披风 ID
        Text(cape.id)
          .font(.caption2)
          .foregroundStyle(.tertiary)
          .lineLimit(1)
          .frame(maxWidth: .infinity)
          .textSelection(.enabled)

        // 操作按钮
        Menu {
          Button {
            if let url = cape.urlObject {
              NSWorkspace.shared.open(url)
            }
          } label: {
            Label("查看完整材质", systemImage: "safari")
          }

          Button {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(cape.url, forType: .string)
          } label: {
            Label("复制 URL", systemImage: "doc.on.doc")
          }

          Button {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(cape.id, forType: .string)
          } label: {
            Label("复制 ID", systemImage: "number")
          }
        } label: {
          Image(systemName: "ellipsis.circle")
            .foregroundStyle(.secondary)
        }
        .menuStyle(.borderlessButton)
        .frame(height: 20)
      }
      .padding(.horizontal, 12)
      .padding(.bottom, 12)
    }
    .background(Color(nsColor: .controlBackgroundColor))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .task {
      await loadCapeFrontImage()
    }
  }

  private func loadCapeFrontImage() async {
    guard var url = cape.urlObject else { return }

    // 将 http:// 转换为 https://
    url = convertToHTTPS(url)

    isLoadingImage = true
    defer { isLoadingImage = false }

    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      if let fullImage = NSImage(data: data) {
        // 截取披风正面部分
        if let frontImage = extractCapeFront(from: fullImage) {
          await MainActor.run {
            capeFrontImage = frontImage
          }
        }
      }
    } catch {
      print("加载披风图片失败: \(error)")
    }
  }

  /// 从完整披风材质中截取正面部分
  /// 披风材质尺寸: 64x32
  /// 正面区域: x=1, y=1, width=10, height=16
  private func extractCapeFront(from image: NSImage) -> NSImage? {
    guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
      return nil
    }

    let width = cgImage.width
    let height = cgImage.height

    // 披风材质标准尺寸是 64x32
    // 正面部分在 (1, 1) 位置，大小 10x16
    let scaleX = CGFloat(width) / 64.0
    let scaleY = CGFloat(height) / 32.0

    let frontRect = CGRect(
      x: 1 * scaleX,
      y: 1 * scaleY,
      width: 10 * scaleX,
      height: 16 * scaleY
    )

    guard let croppedCGImage = cgImage.cropping(to: frontRect) else {
      return nil
    }

    let croppedImage = NSImage(cgImage: croppedCGImage, size: NSSize(width: 10, height: 16))
    return croppedImage
  }

  private func convertToHTTPS(_ url: URL) -> URL {
    if url.scheme == "http" {
      var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
      components?.scheme = "https"
      return components?.url ?? url
    }
    return url
  }
}

#Preview {
  NavigationStack {
    AccountProfileView()
  }
}
