//
//  ContentView.swift
//  MojangAPIDemo
//

import AppKit
import MojangAPI
import SwiftUI
import UniformTypeIdentifiers

struct MojangAPITestsView: View {
  var body: some View {
    List {
      Section("Mojang API") {
        NavigationLink(destination: PlayerSearchView()) {
          Label("玩家搜索", systemImage: "person.circle")
        }

        NavigationLink(destination: VersionDetailsView()) {
          Label("版本信息", systemImage: "cube")
        }

        NavigationLink(destination: AccountProfileView()) {
          Label("账户档案", systemImage: "person.text.rectangle")
        }

        NavigationLink(destination: SkinUploadView()) {
          Label("皮肤上传测试", systemImage: "square.and.arrow.up")
        }
      }
      Section("高级测试") {
        NavigationLink(destination: VersionManifestView()) {
          Label("版本清单对比", systemImage: "list.bullet.rectangle")
        }

        NavigationLink(destination: BatchUUIDLookupView()) {
          Label("批量 UUID 查询", systemImage: "number")
        }

        NavigationLink(destination: PlayerUUIDLookupView()) {
          Label("轻量 UUID 查询", systemImage: "person.text.rectangle")
        }

        NavigationLink(destination: ProfileByUUIDView()) {
          Label("UUID 档案查看", systemImage: "person.badge.shield.checkmark")
        }

        NavigationLink(destination: BlockedServersView()) {
          Label("封禁服务器列表", systemImage: "exclamationmark.triangle")
        }
      }
    }
    .listStyle(.sidebar)
  }
}

struct PlayerSearchView: View {
  @State private var playerName = "1ris_W"
  @State private var profile: PlayerProfile?
  @State private var textures: TexturesPayload?
  @State private var skinImage: Image?
  @State private var isLoading = false
  @State private var errorMessage: String?

  private let client = MinecraftAPIClient()

  var body: some View {
    Form {
      // 搜索区域
      Section("搜索玩家") {
        TextField("玩家名称", text: $playerName)
          .autocorrectionDisabled()

        Button(action: search) {
          if isLoading {
            ProgressView()
              .frame(maxWidth: .infinity)
          } else {
            Text("搜索")
              .frame(maxWidth: .infinity)
          }
        }
        .disabled(playerName.isEmpty || isLoading)
      }

      // 错误信息
      if let error = errorMessage {
        Section {
          Text(error)
            .foregroundStyle(.red)
        }
      }

      // 基本信息
      if let profile = profile {
        Section("基本信息") {
          LabeledContent("玩家名", value: profile.name)
          LabeledContent("UUID", value: profile.id)
          LabeledContent("有签名", value: profile.isSigned ? "✓" : "✗")
        }
      }

      // 皮肤预览
      if let skinImage = skinImage {
        Section("皮肤预览") {
          skinImage
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .frame(height: 200)
            .frame(maxWidth: .infinity)
        }
      }

      // 纹理信息
      if let textures = textures {
        Section("纹理信息") {
          LabeledContent("时间戳", value: textures.formattedTimestamp)

          if let skin = textures.textures.SKIN {
            LabeledContent("皮肤模型", value: skin.skinModel.displayName)
            LabeledContent("皮肤ID", value: String(skin.textureId.prefix(16)) + "...")
          }

          if let cape = textures.textures.CAPE {
            LabeledContent("披风ID", value: String(cape.textureId.prefix(16)) + "...")
          } else {
            LabeledContent("披风", value: "无")
          }
        }

        // 皮肤 URL
        if let skin = textures.textures.SKIN {
          Section("皮肤 URL") {
            Text(skin.url.absoluteString)
              .font(.caption)
              .textSelection(.enabled)
          }
        }
      }
    }
    .navigationTitle("玩家搜索")
  }

  private func search() {
    isLoading = true
    errorMessage = nil
    profile = nil
    textures = nil
    skinImage = nil

    Task {
      do {
        // 1. 获取基本档案
        let basicProfile = try await client.fetchPlayerProfile(byName: playerName)

        // 2. 获取完整档案（含纹理）
        let fullProfile = try await client.fetchPlayerProfile(byUUID: basicProfile.id)
        profile = fullProfile

        // 3. 解码纹理信息
        textures = try fullProfile.getTexturesPayload()

        // 4. 下载皮肤图片
        if fullProfile.hasCustomSkin {
          let skinData = try await client.downloadSkin(byUUID: fullProfile.id)
          #if canImport(UIKit)
            if let uiImage = UIImage(data: skinData) {
              skinImage = Image(uiImage: uiImage)
            }
          #elseif canImport(AppKit)
            if let nsImage = NSImage(data: skinData) {
              skinImage = Image(nsImage: nsImage)
            }
          #endif
        }

      } catch {
        errorMessage = error.localizedDescription
      }

      isLoading = false
    }
  }
}

struct SkinUploadView: View {
  @State private var bearerToken = ""
  @State private var variant: SkinVariant = .classic
  @State private var skinData: Data?
  @State private var selectedFileName: String?
  @State private var skinImage: Image?
  @State private var skinDimensionsDescription: String?
  @State private var statusMessage: String?
  @State private var errorMessage: String?
  @State private var isUploading = false
  @State private var isFileImporterPresented = false

  private let maxSkinSize = 24_576

  var body: some View {
    Form {
      Section("认证信息") {
        TextField("Bearer Token", text: $bearerToken)
          .autocorrectionDisabled()

        Text("Token 仅会用于当前会话，不会持久化保存。")
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      Section("皮肤参数") {
        Picker("皮肤模型", selection: $variant) {
          Text("Steve (classic)").tag(SkinVariant.classic)
          Text("Alex (slim)").tag(SkinVariant.slim)
        }
        .pickerStyle(.segmented)
      }

      Section("皮肤文件") {
        Button {
          isFileImporterPresented = true
        } label: {
          Label("选择 PNG 文件", systemImage: "folder")
            .frame(maxWidth: .infinity, alignment: .leading)
        }

        if let name = selectedFileName {
          LabeledContent("文件名", value: name)
        }

        if let data = skinData {
          LabeledContent(
            "文件大小",
            value: ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file)
          )
        }

        if let dimensions = skinDimensionsDescription {
          LabeledContent("尺寸", value: dimensions)
        }

        if let image = skinImage {
          VStack(alignment: .leading) {
            Text("预览")
              .font(.subheadline)
              .foregroundStyle(.secondary)

            image
              .interpolation(.none)
              .resizable()
              .scaledToFit()
              .frame(height: 200)
              .frame(maxWidth: .infinity)
          }
          .padding(.top, 4)
        }
      }

      if let status = statusMessage {
        Section("结果") {
          Label(status, systemImage: "checkmark.circle")
            .foregroundStyle(.green)
        }
      }

      if let error = errorMessage {
        Section("错误") {
          Text(error)
            .foregroundStyle(.red)
        }
      }

      Section {
        Button(action: uploadSkin) {
          if isUploading {
            ProgressView()
              .frame(maxWidth: .infinity)
          } else {
            Text("上传皮肤")
              .frame(maxWidth: .infinity)
          }
        }
        .disabled(!canUpload)
      }

      Section("使用说明") {
        Text(
          "1. 在浏览器中获取 Authorization Bearer Token；2. 选择 64x32 或 64x64 的 PNG 皮肤文件（≤ 24 KB）；3. 点击上传即可在几分钟内在游戏中看到效果。"
        )
        .font(.caption)
        .foregroundStyle(.secondary)
      }
    }
    .navigationTitle("皮肤上传测试")
    .fileImporter(isPresented: $isFileImporterPresented, allowedContentTypes: [.png]) { result in
      switch result {
      case .success(let url):
        handleFileSelection(url: url)
      case .failure(let error):
        errorMessage = error.localizedDescription
      }
    }
  }

  private var canUpload: Bool {
    !trimmedToken.isEmpty && skinData != nil && !isUploading
  }

  private var trimmedToken: String {
    bearerToken.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private func handleFileSelection(url: URL) {
    let needsAccess = url.startAccessingSecurityScopedResource()
    defer {
      if needsAccess {
        url.stopAccessingSecurityScopedResource()
      }
    }

    do {
      let data = try Data(contentsOf: url)
      if let validationMessage = validateSkinData(data) {
        skinData = nil
        selectedFileName = nil
        skinImage = nil
        skinDimensionsDescription = nil
        errorMessage = validationMessage
        statusMessage = nil
        return
      }

      skinData = data
      selectedFileName = url.lastPathComponent
      updatePreview(with: data)
      errorMessage = nil
      statusMessage = nil
    } catch {
      errorMessage = error.localizedDescription
    }
  }

  private func validateSkinData(_ data: Data) -> String? {
    guard data.count <= maxSkinSize else {
      return "皮肤文件过大，最大只能为 24 KB。"
    }

    guard Self.isValidSkinImage(data) else {
      return "皮肤尺寸必须是 64x32 或 64x64 像素。"
    }

    return nil
  }

  private func updatePreview(with data: Data) {
    skinImage = Self.makeImage(from: data)
    if let size = Self.imagePixelSize(from: data) {
      skinDimensionsDescription = "\(size.width) x \(size.height)"
    } else {
      skinDimensionsDescription = nil
    }
  }

  private func uploadSkin() {
    guard let skinData else {
      return
    }

    isUploading = true
    statusMessage = nil
    errorMessage = nil

    Task {
      do {
        let client = MinecraftAuthenticatedClient(bearerToken: trimmedToken)
        try await client.uploadSkin(imageData: skinData, variant: variant)

        await MainActor.run {
          statusMessage = "皮肤上传成功，可能需要几分钟才会在游戏中生效。"
        }
      } catch MinecraftAPIError.skinTooLarge {
        await MainActor.run {
          errorMessage = "服务器拒绝了请求：皮肤文件超过 24 KB。"
        }
      } catch MinecraftAPIError.invalidBearerToken {
        await MainActor.run {
          errorMessage = "Bearer Token 无效或已过期，请重新获取后再试。"
        }
      } catch {
        await MainActor.run {
          errorMessage = error.localizedDescription
        }
      }

      await MainActor.run {
        isUploading = false
      }
    }
  }

  private static func isValidSkinImage(_ data: Data) -> Bool {
    guard let size = imagePixelSize(from: data) else {
      return false
    }
    return size.width == 64 && (size.height == 32 || size.height == 64)
  }

  private static func imagePixelSize(from data: Data) -> (width: Int, height: Int)? {
    #if canImport(UIKit)
      guard let image = UIImage(data: data) else { return nil }
      let width = Int(image.size.width * image.scale)
      let height = Int(image.size.height * image.scale)
      return (width, height)
    #elseif canImport(AppKit)
      guard let image = NSImage(data: data) else { return nil }
      let width = Int(image.size.width)
      let height = Int(image.size.height)
      return (width, height)
    #else
      return nil
    #endif
  }

  private static func makeImage(from data: Data) -> Image? {
    #if canImport(UIKit)
      guard let uiImage = UIImage(data: data) else { return nil }
      return Image(uiImage: uiImage)
    #elseif canImport(AppKit)
      guard let nsImage = NSImage(data: data) else { return nil }
      return Image(nsImage: nsImage)
    #else
      return nil
    #endif
  }
}

struct CurseForgeAPITestsView: View {
  var body: some View {
    List {
      Section("CurseForge API") {
        NavigationLink(destination: ModpacksView()) {
          Label("整合包浏览", systemImage: "square.stack.3d.up")
        }
      }
    }
    .listStyle(.sidebar)
  }
}

struct VersionManifestView: View {
  @State private var useV2 = true
  @State private var manifest: VersionManifest?
  @State private var isLoading = false
  @State private var errorMessage: String?
  @State private var versionLimit = 12

  private let client = MinecraftAPIClient()

  private var recentVersions: [VersionInfo] {
    guard let manifest else { return [] }
    return Array(manifest.versions.prefix(versionLimit))
  }

  var body: some View {
    Form {
      Section("请求配置") {
        Toggle("使用 version_manifest_v2.json", isOn: $useV2)

        Stepper("展示最近 \(versionLimit) 个版本", value: $versionLimit, in: 5...30, step: 5)

        Button(action: loadManifest) {
          Label(isLoading ? "请求中..." : "获取版本清单", systemImage: "arrow.clockwise.circle")
            .frame(maxWidth: .infinity)
        }
        .disabled(isLoading)
      }

      if isLoading {
        Section {
          ProgressView("请求中…")
            .frame(maxWidth: .infinity)
        }
      }

      if let error = errorMessage {
        Section {
          Text(error)
            .foregroundStyle(.red)
        }
      }

      if let manifest = manifest {
        Section("最新版本") {
          DataCard {
            KeyValueRow(title: "最新正式版", value: manifest.latest.release)
            KeyValueRow(title: "最新快照", value: manifest.latest.snapshot)
            KeyValueRow(
              title: "具备 v2 元数据",
              value: "\(manifest.versions.filter { $0.isFromV2API }.count)",
              monospaced: true
            )
          }
        }

        Section("最近版本（\(recentVersions.count)）") {
          ForEach(recentVersions) { version in
            DataCard {
              HStack {
                Text(version.id)
                  .font(.headline)
                Spacer()
                Text(version.type.rawValue)
                  .font(.caption)
                  .padding(.horizontal, 6)
                  .padding(.vertical, 3)
                  .background(.thinMaterial)
                  .clipShape(Capsule())
              }

              Text(version.releaseTime.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundStyle(.secondary)

              if version.isFromV2API {
                Divider()
                KeyValueRow(title: "SHA1", value: version.sha1 ?? "N/A", monospaced: true)
                KeyValueRow(
                  title: "Compliance",
                  value: version.complianceLevel.map(String.init) ?? "-",
                  monospaced: true
                )
              } else {
                Text("来自 v1 API，无 SHA1/Compliance")
                  .font(.caption)
                  .foregroundStyle(.secondary)
              }
            }
          }
        }
      }
    }
    .navigationTitle("版本清单测试")
  }

  private func loadManifest() {
    isLoading = true
    errorMessage = nil

    Task {
      do {
        manifest = try await client.fetchVersionManifest(useV2: useV2)
      } catch {
        errorMessage = error.localizedDescription
        manifest = nil
      }
      isLoading = false
    }
  }
}

struct BatchUUIDLookupView: View {
  @State private var inputNames = "Notch\njeb_\nDinnerbone"
  @State private var results: [String: String] = [:]
  @State private var isLoading = false
  @State private var errorMessage: String?

  private let client = MinecraftAPIClient()

  private var parsedNames: [String] {
    inputNames
      .split(whereSeparator: { $0 == "\n" || $0 == "," })
      .map { $0.trimmingCharacters(in: .whitespaces) }
      .filter { !$0.isEmpty }
  }

  var body: some View {
    Form {
      Section("输入玩家名称（换行或逗号分隔）") {
        TextEditor(text: $inputNames)
          .frame(minHeight: 140)
          .autocorrectionDisabled()
          .font(.system(.body, design: .monospaced))

        LabeledContent("有效名称", value: "\(parsedNames.count)")

        Button(action: lookup) {
          Label("批量查询", systemImage: "arrow.triangle.2.circlepath")
            .frame(maxWidth: .infinity)
        }
        .disabled(parsedNames.isEmpty || isLoading)
      }

      if isLoading {
        Section {
          ProgressView("请求中…").frame(maxWidth: .infinity)
        }
      }

      if let error = errorMessage {
        Section {
          Text(error)
            .foregroundStyle(.red)
        }
      }

      if !results.isEmpty {
        Section("结果（\(results.count)）") {
          ForEach(
            results.sorted(by: { $0.key.lowercased() < $1.key.lowercased() }),
            id: \.key
          ) { name, uuid in
            DataCard {
              Text(name)
                .font(.headline)
              Text(uuid)
                .font(.system(.footnote, design: .monospaced))
                .textSelection(.enabled)
            }
          }
        }
      }
    }
    .navigationTitle("批量 UUID 查询")
  }

  private func lookup() {
    isLoading = true
    errorMessage = nil
    results = [:]

    let names = parsedNames
    Task {
      do {
        results = try await client.fetchUUIDs(names: names)
      } catch {
        errorMessage = error.localizedDescription
      }
      isLoading = false
    }
  }
}

struct PlayerUUIDLookupView: View {
  @State private var playerName = "Notch"
  @State private var result: PlayerUUID?
  @State private var isLoading = false
  @State private var errorMessage: String?

  private let client = MinecraftAPIClient()

  var body: some View {
    Form {
      Section("玩家名称") {
        TextField("玩家名称", text: $playerName)
          .autocorrectionDisabled()

        Button("查询 UUID", action: lookup)
          .frame(maxWidth: .infinity)
          .disabled(playerName.isEmpty || isLoading)
      }

      if isLoading {
        Section {
          ProgressView("请求中…").frame(maxWidth: .infinity)
        }
      }

      if let error = errorMessage {
        Section {
          Text(error)
            .foregroundStyle(.red)
        }
      }

      if let result = result {
        Section("结果") {
          DataCard {
            KeyValueRow(title: "玩家", value: result.name)
            KeyValueRow(title: "UUID (32)", value: result.id, monospaced: true)
            KeyValueRow(title: "UUID (带横杠)", value: result.formattedUUID, monospaced: true)
          }
        }
      }
    }
    .navigationTitle("轻量 UUID 查询")
  }

  private func lookup() {
    isLoading = true
    errorMessage = nil
    result = nil

    Task {
      do {
        result = try await client.fetchPlayerUUID(byName: playerName)
      } catch {
        errorMessage = error.localizedDescription
      }
      isLoading = false
    }
  }
}

struct ProfileByUUIDView: View {
  @State private var uuid = "069a79f4-44e9-4726-a5be-fca90e38aaf5"
  @State private var unsigned = false
  @State private var profile: PlayerProfile?
  @State private var isLoading = false
  @State private var errorMessage: String?

  private let client = MinecraftAPIClient()

  var body: some View {
    Form {
      Section("输入 UUID") {
        TextField("069a79f4-...", text: $uuid)
          .autocorrectionDisabled()

        Toggle("请求未签名档案 (unsigned)", isOn: $unsigned)

        Button("查询档案", action: lookup)
          .frame(maxWidth: .infinity)
          .disabled(uuid.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
      }

      if isLoading {
        Section {
          ProgressView("请求中…").frame(maxWidth: .infinity)
        }
      }

      if let error = errorMessage {
        Section {
          Text(error)
            .foregroundStyle(.red)
        }
      }

      if let profile = profile {
        Section("基本信息") {
          DataCard {
            KeyValueRow(title: "玩家名", value: profile.name)
            KeyValueRow(title: "UUID", value: profile.id, monospaced: true)
            KeyValueRow(title: "有自定义皮肤", value: profile.hasCustomSkin ? "是" : "否")
            KeyValueRow(title: "有披风", value: profile.hasCape ? "是" : "否")
          }
        }

        if let actions = profile.profileActions, !actions.isEmpty {
          Section("profileActions") {
            DataCard {
              VStack(alignment: .leading, spacing: 4) {
                ForEach(actions, id: \.self) { action in
                  Text(action)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                }
              }
            }
          }
        }

        if let textures = try? profile.getTexturesPayload() {
          Section("纹理") {
            DataCard {
              if let skin = textures.textures.SKIN {
                KeyValueRow(
                  title: "皮肤 URL",
                  value: skin.url.absoluteString,
                  monospaced: true
                )
              }
              if let cape = textures.textures.CAPE {
                KeyValueRow(
                  title: "披风 URL",
                  value: cape.url.absoluteString,
                  monospaced: true
                )
              }
            }
          }
        }
      }
    }
    .navigationTitle("UUID 档案查看")
  }

  private func lookup() {
    isLoading = true
    errorMessage = nil
    profile = nil

    Task {
      do {
        profile = try await client.fetchPlayerProfile(byUUID: uuid, unsigned: unsigned)
      } catch {
        errorMessage = error.localizedDescription
      }
      isLoading = false
    }
  }
}

struct BlockedServersView: View {
  @State private var blockedServers: [String] = []
  @State private var searchText = ""
  @State private var isLoading = false
  @State private var errorMessage: String?

  private let client = MinecraftAPIClient()

  private var filteredServers: [String] {
    guard !searchText.isEmpty else { return blockedServers }
    return blockedServers.filter { $0.localizedCaseInsensitiveContains(searchText) }
  }

  var body: some View {
    List {
      Section("操作") {
        Button(action: fetchBlockedServers) {
          Label(isLoading ? "同步中..." : "刷新列表", systemImage: "arrow.clockwise.circle")
            .frame(maxWidth: .infinity)
        }
        .disabled(isLoading)

        TextField("搜索哈希", text: $searchText)
          .autocorrectionDisabled()
      }

      if isLoading {
        Section {
          ProgressView("同步中…")
            .frame(maxWidth: .infinity)
        }
      }

      if let error = errorMessage {
        Section {
          Text(error)
            .foregroundStyle(.red)
        }
      }

      if !blockedServers.isEmpty {
        Section("哈希（总 \(blockedServers.count) 条，当前 \(filteredServers.count) 条）") {
          ForEach(filteredServers, id: \.self) { hash in
            DataCard {
              Text(hash)
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
            }
          }
        }
      }
    }
    .navigationTitle("封禁服务器列表")
  }

  private func fetchBlockedServers() {
    isLoading = true
    errorMessage = nil

    Task {
      do {
        blockedServers = try await client.fetchBlockedServers()
      } catch {
        errorMessage = error.localizedDescription
        blockedServers = []
      }
      isLoading = false
    }
  }
}

#Preview("Mojang API Tests") {
  NavigationStack {
    MojangAPITestsView()
      .navigationTitle("Mojang API Demo")
  }
}

#Preview("CurseForge API Tests") {
  NavigationStack {
    CurseForgeAPITestsView()
      .navigationTitle("CurseForge API Demo")
  }
}

struct DataCard<Content: View>: View {
  @ViewBuilder var content: Content

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      content
    }
    .padding()
    .background(.ultraThinMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
  }
}

struct KeyValueRow: View {
  var title: String
  var value: String
  var monospaced = false

  var body: some View {
    HStack(alignment: .firstTextBaseline) {
      Text(title)
        .font(.caption)
        .foregroundStyle(.secondary)
      Spacer()
      Text(value)
        .font(monospaced ? .system(.body, design: .monospaced) : .body)
        .textSelection(.enabled)
    }
  }
}

#Preview("Mojang API Tests") {
  MojangAPITestsView()
}

#Preview("CurseForge API Tests") {
  CurseForgeAPITestsView()
}
