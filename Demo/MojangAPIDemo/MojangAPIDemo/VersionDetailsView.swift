//
//  VersionDetailsView.swift
//  CraftKitDemo
//

import CraftKit
import SwiftUI

struct VersionDetailsView: View {
  @State private var versionId = ""
  @State private var versionDetails: VersionDetails?
  @State private var isLoading = false
  @State private var errorMessage: String?
  @State private var selectedOS = "osx"
  @State private var availableVersions: [VersionInfo] = []
  @State private var selectedVersionFromPicker: VersionInfo?
  @State private var filterType: VersionType? = nil

  private let client = MinecraftAPIClient()
  private let osOptions = ["osx", "windows", "linux"]

  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        queryPanel

        if isLoading {
          DataCard {
            HStack {
              ProgressView()
              Text("正在查询版本详情…")
            }
            .frame(maxWidth: .infinity)
          }
        }

        if let error = errorMessage {
          DataCard {
            Label(error, systemImage: "exclamationmark.triangle")
              .foregroundStyle(.red)
          }
        }

        if let details = versionDetails {
          summarySection(details)
          downloadsSection(details)
          resourcesSection(details)
          argumentsSection(details)
          technicalSection(details)
        }
      }
      .padding()
    }
    .background(Color(nsColor: .textBackgroundColor))
    .navigationTitle("版本详情")
    .task {
      await loadVersionList()
    }
  }

  private var queryPanel: some View {
    DataCard {
      VStack(alignment: .leading, spacing: 12) {
        Text("查询版本")
          .font(.headline)

        if !availableVersions.isEmpty {
          HStack {
            Text("按类型筛选")
              .font(.caption)
              .foregroundStyle(.secondary)
            Spacer()
            Picker("筛选类型", selection: $filterType) {
              Text("全部").tag(nil as VersionType?)
              Text("正式版").tag(VersionType.release as VersionType?)
              Text("快照版").tag(VersionType.snapshot as VersionType?)
              Text("旧测试版").tag(VersionType.oldBeta as VersionType?)
              Text("旧内测版").tag(VersionType.oldAlpha as VersionType?)
            }
            .labelsHidden()
            .pickerStyle(.menu)
          }

          Picker("选择版本", selection: $selectedVersionFromPicker) {
            Text("请选择…").tag(nil as VersionInfo?)
            ForEach(filteredVersions, id: \.id) { version in
              Text("\(version.id) (\(version.type.rawValue))")
                .tag(version as VersionInfo?)
            }
          }
          .onChange(of: selectedVersionFromPicker) { _, newValue in
            if let version = newValue {
              versionId = version.id
            }
          }

          Divider()
        }

        TextField("版本 ID (例如: 1.21.4)", text: $versionId)
          .textFieldStyle(.roundedBorder)
          .autocorrectionDisabled()

        Button(action: search) {
          Label(isLoading ? "查询中…" : "查询版本信息", systemImage: "magnifyingglass.circle")
            .frame(maxWidth: .infinity)
        }
        .disabled(versionId.isEmpty || isLoading)
        .buttonStyle(.borderedProminent)

        HStack {
          Button("查询最新正式版") {
            Task { await searchLatestRelease() }
          }
          .buttonStyle(.bordered)
          .disabled(isLoading)

          Button("查询最新快照") {
            Task { await searchLatestSnapshot() }
          }
          .buttonStyle(.bordered)
          .disabled(isLoading)
        }
      }
    }
  }

  private func summarySection(_ details: VersionDetails) -> some View {
    DataCard {
      VStack(alignment: .leading, spacing: 16) {
        HStack {
          VStack(alignment: .leading, spacing: 8) {
            Text(details.id)
              .font(.title2)
              .fontWeight(.bold)
            HStack(spacing: 10) {
              Text(details.type.rawValue)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(typeColor(for: details.type).opacity(0.2))
                .foregroundColor(typeColor(for: details.type))
                .clipShape(Capsule())
              Text(details.releaseTime.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundStyle(.secondary)
            }
          }
          Spacer()
        }

        Divider()

        HStack(spacing: 24) {
          MetricTile(title: "Java", value: "\(details.javaVersion.majorVersion)")
          MetricTile(title: "合规等级", value: "\(details.complianceLevel)")
          MetricTile(title: "总下载大小", value: details.formattedDownloadSize)
        }
      }
    }
  }

  private func downloadsSection(_ details: VersionDetails) -> some View {
    DataCard {
      VStack(alignment: .leading, spacing: 12) {
        Text("下载")
          .font(.headline)

        DownloadRow(
          title: "客户端",
          size: details.downloads.client.size,
          sha1: details.downloads.client.sha1
        )

        if let server = details.downloads.server {
          Divider()
          DownloadRow(title: "服务端", size: server.size, sha1: server.sha1)
        }

        if let mappings = details.downloads.clientMappings {
          Divider()
          DownloadRow(title: "客户端映射", size: mappings.size, sha1: mappings.sha1)
        }
        if let mappings = details.downloads.serverMappings {
          Divider()
          DownloadRow(title: "服务端映射", size: mappings.size, sha1: mappings.sha1)
        }
      }
    }
  }

  private func resourcesSection(_ details: VersionDetails) -> some View {
    DataCard {
      VStack(alignment: .leading, spacing: 12) {
        Text("资源与依赖")
          .font(.headline)

        KeyValueRow(title: "资源索引", value: details.assetIndex.id, monospaced: true)
        KeyValueRow(
          title: "资源总大小",
          value: ByteCountFormatter.string(
            fromByteCount: Int64(details.assetIndex.totalSize), countStyle: .file)
        )

        Divider()

        Picker("操作系统", selection: $selectedOS) {
          Text("macOS").tag("osx")
          Text("Windows").tag("windows")
          Text("Linux").tag("linux")
        }
        .pickerStyle(.segmented)

        let filteredLibraries = details.libraries(for: selectedOS)
        HStack {
          Text("依赖库")
            .font(.subheadline)
          Spacer()
          Text("\(filteredLibraries.count) / \(details.libraries.count)")
            .font(.caption)
            .foregroundStyle(.secondary)
        }

        NavigationLink {
          LibrariesListView(libraries: filteredLibraries)
        } label: {
          HStack {
            Text("查看库列表")
            Spacer()
            Image(systemName: "chevron.right")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
          .font(.subheadline)
        }
      }
    }
  }

  private func argumentsSection(_ details: VersionDetails) -> some View {
    DataCard {
      VStack(alignment: .leading, spacing: 12) {
        Text("启动参数")
          .font(.headline)

        NavigationLink {
          ArgumentsListView(title: "游戏参数", arguments: details.gameArgumentStrings)
        } label: {
          ArgumentRow(title: "游戏参数", count: details.gameArgumentStrings.count)
        }

        NavigationLink {
          ArgumentsListView(title: "JVM 参数", arguments: details.jvmArgumentStrings)
        } label: {
          ArgumentRow(title: "JVM 参数", count: details.jvmArgumentStrings.count)
        }
      }
    }
  }

  private func technicalSection(_ details: VersionDetails) -> some View {
    DataCard {
      DisclosureGroup {
        VStack(alignment: .leading, spacing: 8) {
          InfoRow(label: "主类", value: details.mainClass)
          InfoRow(label: "最低启动器版本", value: "\(details.minimumLauncherVersion)")
          InfoRow(label: "Java 组件", value: details.javaVersion.component)
          InfoRow(
            label: "客户端 SHA1",
            value: String(details.downloads.client.sha1.prefix(16)) + "…"
          )
          if let server = details.downloads.server {
            InfoRow(label: "服务端 SHA1", value: String(server.sha1.prefix(16)) + "…")
          }
        }
        .font(.caption)
      } label: {
        Text("技术详情")
          .font(.headline)
      }
    }
  }

  // 计算属性：根据筛选类型过滤版本
  private var filteredVersions: [VersionInfo] {
    if let filterType = filterType {
      return availableVersions.filter { $0.type == filterType }
    }
    return availableVersions
  }

  private func loadVersionList() async {
    do {
      let manifest = try await client.fetchVersionManifest()
      availableVersions = manifest.versions
    } catch {
      // 静默失败，用户仍然可以手动输入版本号
      print("无法加载版本列表: \(error)")
    }
  }

  private func search() {
    isLoading = true
    errorMessage = nil
    versionDetails = nil

    Task {
      do {
        let details = try await client.fetchVersionDetails(byId: versionId)
        versionDetails = details
      } catch {
        errorMessage = error.localizedDescription
      }
      isLoading = false
    }
  }

  private func searchLatestRelease() async {
    isLoading = true
    errorMessage = nil
    versionDetails = nil

    do {
      let manifest = try await client.fetchVersionManifest()
      versionId = manifest.latest.release
      let details = try await client.fetchVersionDetails(byId: versionId)
      versionDetails = details
    } catch {
      errorMessage = error.localizedDescription
    }
    isLoading = false
  }

  private func searchLatestSnapshot() async {
    isLoading = true
    errorMessage = nil
    versionDetails = nil

    do {
      let manifest = try await client.fetchVersionManifest()
      versionId = manifest.latest.snapshot
      let details = try await client.fetchVersionDetails(byId: versionId)
      versionDetails = details
    } catch {
      errorMessage = error.localizedDescription
    }
    isLoading = false
  }

  private func typeColor(for type: VersionType) -> Color {
    switch type {
    case .release:
      return .green
    case .snapshot:
      return .orange
    case .oldBeta:
      return .blue
    case .oldAlpha:
      return .purple
    }
  }
}

private struct MetricTile: View {
  var title: String
  var value: String

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(title)
        .font(.caption)
        .foregroundStyle(.secondary)
      Text(value)
        .font(.title3)
        .fontWeight(.semibold)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

private struct DownloadRow: View {
  var title: String
  var size: Int
  var sha1: String

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack {
        Text(title)
          .font(.subheadline)
        Spacer()
        Text(ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file))
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      Text("SHA1: \(sha1)")
        .font(.caption2)
        .foregroundStyle(.secondary)
        .textSelection(.enabled)
    }
  }
}

private struct ArgumentRow: View {
  var title: String
  var count: Int

  var body: some View {
    HStack {
      Text(title)
      Spacer()
      Text("\(count)")
        .font(.caption)
        .foregroundStyle(.secondary)
      Image(systemName: "chevron.right")
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .font(.subheadline)
  }
}

// MARK: - Helper Views

struct InfoRow: View {
  let label: String
  let value: String

  var body: some View {
    HStack {
      Text(label)
        .foregroundStyle(.secondary)
      Spacer()
      Text(value)
        .multilineTextAlignment(.trailing)
    }
  }
}

// MARK: - Supporting Views

struct LibrariesListView: View {
  let libraries: [Library]

  var body: some View {
    List(libraries, id: \.name) { library in
      VStack(alignment: .leading, spacing: 4) {
        Text(library.name)
          .font(.caption)

        HStack {
          if let version = library.version {
            Text("v\(version)")
              .font(.caption2)
              .foregroundStyle(.secondary)
          }

          Spacer()

          if let artifact = library.downloads.artifact {
            Text(
              ByteCountFormatter.string(
                fromByteCount: Int64(artifact.size),
                countStyle: .file
              )
            )
            .font(.caption2)
            .foregroundStyle(.secondary)
          } else {
            Text("Native")
              .font(.caption2)
              .foregroundStyle(.secondary)
          }
        }
      }
      .padding(.vertical, 2)
    }
    .navigationTitle("依赖库列表")
  }
}

struct ArgumentsListView: View {
  let title: String
  let arguments: [String]

  var body: some View {
    List(arguments.indices, id: \.self) { index in
      Text(arguments[index])
        .font(.system(.caption, design: .monospaced))
        .textSelection(.enabled)
    }
    .navigationTitle(title)
  }
}

#Preview {
  VersionDetailsView()
}
