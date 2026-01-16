//
//  VersionDetailsExample.swift
//  CraftKit
//
//  Example demonstrating how to fetch and use version details
//

import Foundation

#if DEBUG
  /// Example usage of version details API
  func versionDetailsExample() async {
    let client = MinecraftAPIClient()

    do {
      // Example 1: Fetch details for a specific version
      print("Fetching details for version 1.21.4...")
      let details = try await client.fetchVersionDetails(byId: "1.21.4")

      print("Version: \(details.id)")
      print("Type: \(details.type)")
      print("Main Class: \(details.mainClass)")
      print("Java Version: \(details.javaVersion.majorVersion)")
      print("Release Time: \(details.releaseTime)")
      print("Total Download Size: \(details.formattedDownloadSize)")
      print("Number of Libraries: \(details.libraries.count)")

      // Example 2: Get download URLs
      if let clientURL = details.clientDownloadURL {
        print("\nClient Download URL: \(clientURL)")
        print(
          "Client Size: \(ByteCountFormatter.string(fromByteCount: Int64(details.downloads.client.size), countStyle: .file))"
        )
      }

      if let serverURL = details.serverDownloadURL {
        print("Server Download URL: \(serverURL)")
      }

      // Example 3: Check OS compatibility
      print("\nSupports macOS: \(details.supportsOS("osx"))")
      print("Supports Windows: \(details.supportsOS("windows"))")
      print("Supports Linux: \(details.supportsOS("linux"))")

      // Example 4: Get libraries for specific OS
      let macLibraries = details.libraries(for: "osx")
      print("\nLibraries for macOS: \(macLibraries.count)")

      // Example 5: List some game arguments
      print("\nFirst 5 game arguments:")
      for arg in details.gameArgumentStrings.prefix(5) {
        print("  - \(arg)")
      }

      // Example 6: Fetch latest snapshot details
      print("\n\nFetching latest snapshot...")
      let manifest = try await client.fetchVersionManifest()
      let latestSnapshot = manifest.latest.snapshot

      let snapshotDetails = try await client.fetchVersionDetails(byId: latestSnapshot)
      print("Latest Snapshot: \(snapshotDetails.id)")
      print("Java Version Required: \(snapshotDetails.javaVersion.majorVersion)")
      print("Is Java 17+: \(snapshotDetails.javaVersion.isJava17Plus)")
      print("Is Java 21+: \(snapshotDetails.javaVersion.isJava21Plus)")

      // Example 7: Get library information
      print("\nFirst 5 libraries:")
      for library in snapshotDetails.libraries.prefix(5) {
        print("  - \(library.name)")
        if let version = library.version {
          print("    Version: \(version)")
        }
        if let artifact = library.downloads.artifact {
          print(
            "    Size: \(ByteCountFormatter.string(fromByteCount: Int64(artifact.size), countStyle: .file))"
          )
        } else {
          print("    Type: Native library (platform-specific)")
        }
      }

    } catch {
      print("Error: \(error.localizedDescription)")
    }
  }
#endif
