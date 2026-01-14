# Version Details API

This document describes how to use the Version Details API to fetch detailed information about Minecraft versions.

## Overview

The Version Details API allows you to retrieve comprehensive metadata about any Minecraft version, including:

- Download URLs and checksums
- Required Java version
- Dependencies (libraries)
- Launch arguments
- Asset information
- OS-specific configurations

## Basic Usage

### Fetch Version Details by ID

```swift
let client = MinecraftAPIClient()

do {
    let details = try await client.fetchVersionDetails(byId: "1.21.4")
    print("Version: \(details.id)")
    print("Java Version: \(details.javaVersion.majorVersion)")
    print("Main Class: \(details.mainClass)")
} catch {
    print("Error: \(error)")
}
```

### Fetch Latest Release Details

```swift
let client = MinecraftAPIClient()

do {
    // Get the version manifest first
    let manifest = try await client.fetchVersionManifest()
    let latestRelease = manifest.latest.release
    
    // Fetch details for the latest release
    let details = try await client.fetchVersionDetails(byId: latestRelease)
    print("Latest Release: \(details.id)")
} catch {
    print("Error: \(error)")
}
```

### Fetch Details from VersionInfo

```swift
let client = MinecraftAPIClient()

do {
    let manifest = try await client.fetchVersionManifest()
    
    // Find a specific version
    if let versionInfo = manifest.versions.first(where: { $0.id == "1.21.4" }) {
        // Fetch details using the VersionInfo object
        let details = try await client.fetchVersionDetails(for: versionInfo)
        print("Details for \(details.id)")
    }
} catch {
    print("Error: \(error)")
}
```

## Data Models

### VersionDetails

The main structure containing all version metadata:

```swift
public struct VersionDetails: Codable {
    public let arguments: Arguments?          // Structured launch arguments (1.13+)
    public let minecraftArguments: String?    // Legacy flat string args (1.12.2-)
    public let assetIndex: AssetIndex         // Asset information
    public let assets: String                 // Asset version ID
    public let complianceLevel: Int           // Compliance level
    public let downloads: Downloads           // Download URLs
    public let id: String                     // Version ID
    public let javaVersion: JavaVersion       // Required Java version
    public let libraries: [Library]           // Dependencies
    public let logging: Logging?              // Log configuration (may be absent)
    public let mainClass: String              // Main class name
    public let minimumLauncherVersion: Int    // Min launcher version
    public let releaseTime: Date              // Release timestamp
    public let time: Date                     // Update timestamp
    public let type: VersionType              // Version type
}
```

> Versions before 1.13 only provide `minecraftArguments`, while modern versions expose `arguments`. Check both to support every release.

## Useful Extensions

### Download Information

```swift
let details = try await client.fetchVersionDetails(byId: "1.21.4")

// Get download URLs
if let clientURL = details.clientDownloadURL {
    print("Client: \(clientURL)")
}

if let serverURL = details.serverDownloadURL {
    print("Server: \(serverURL)")
}

// Get total download size
print("Total size: \(details.formattedDownloadSize)")
```

### Java Version Checking

```swift
let javaVersion = details.javaVersion

print("Major Version: \(javaVersion.majorVersion)")
print("Is Java 8: \(javaVersion.isJava8)")
print("Is Java 17+: \(javaVersion.isJava17Plus)")
print("Is Java 21+: \(javaVersion.isJava21Plus)")
```

### OS-Specific Libraries

```swift
// Check OS support
print("Supports macOS: \(details.supportsOS("osx"))")
print("Supports Windows: \(details.supportsOS("windows"))")
print("Supports Linux: \(details.supportsOS("linux"))")

// Get libraries for a specific OS
let macLibraries = details.libraries(for: "osx")
print("macOS libraries: \(macLibraries.count)")

for library in macLibraries {
    print("  - \(library.name)")
    if let version = library.version {
        print("    Version: \(version)")
    }
}
```

### Launch Arguments

```swift
// Get all game arguments
let gameArgs = details.gameArgumentStrings
print("Game arguments: \(gameArgs.count)")

// Get all JVM arguments
let jvmArgs = details.jvmArgumentStrings
print("JVM arguments: \(jvmArgs.count)")
```

## Complete Example

```swift
import CraftKit

let client = MinecraftAPIClient()

do {
    // Fetch version details
    let details = try await client.fetchVersionDetails(byId: "1.21.4")
    
    print("=== Version Information ===")
    print("ID: \(details.id)")
    print("Type: \(details.type)")
    print("Released: \(details.releaseTime)")
    print("Main Class: \(details.mainClass)")
    
    print("\n=== Java Requirements ===")
    print("Component: \(details.javaVersion.component)")
    print("Version: \(details.javaVersion.majorVersion)")
    
    print("\n=== Downloads ===")
    print("Client Size: \(ByteCountFormatter.string(fromByteCount: Int64(details.downloads.client.size), countStyle: .file))")
    if let server = details.downloads.server {
        print("Server Size: \(ByteCountFormatter.string(fromByteCount: Int64(server.size), countStyle: .file))")
    }
    print("Total: \(details.formattedDownloadSize)")
    
    print("\n=== Libraries ===")
    print("Total Libraries: \(details.libraries.count)")
    
    let macLibs = details.libraries(for: "osx")
    print("macOS Libraries: \(macLibs.count)")
    
    print("\n=== Arguments ===")
    print("Game Arguments: \(details.gameArgumentStrings.count)")
    print("JVM Arguments: \(details.jvmArgumentStrings.count)")
    
    print("\n=== Assets ===")
    print("Asset Index: \(details.assetIndex.id)")
    print("Asset Size: \(ByteCountFormatter.string(fromByteCount: Int64(details.assetIndex.totalSize), countStyle: .file))")
    
} catch {
    print("Error: \(error.localizedDescription)")
}
```

## Error Handling

The API can throw the following errors:

```swift
do {
    let details = try await client.fetchVersionDetails(byId: "nonexistent")
} catch MinecraftAPIError.versionNotFound(let versionId) {
    print("Version not found: \(versionId)")
} catch MinecraftAPIError.networkError(let error) {
    print("Network error: \(error)")
} catch MinecraftAPIError.decodingError(let error) {
    print("Decoding error: \(error)")
} catch {
    print("Unknown error: \(error)")
}
```

## Data Structures Reference

### Downloads

```swift
public struct Downloads: Codable {
    public let client: DownloadInfo
    public let server: DownloadInfo?
}

public struct DownloadInfo: Codable {
    public let sha1: String
    public let size: Int
    public let url: String
}
```

### Library

```swift
public struct Library: Codable {
    public let downloads: LibraryDownloads
    public let name: String              // Maven coordinates
    public let rules: [Rule]?            // OS/feature rules
}
```

### Arguments

```swift
public struct Arguments: Codable {
    public let game: [Argument]
    public let jvm: [Argument]
}

// Arguments can be simple strings or conditional
public enum Argument: Codable {
    case string(String)
    case conditional(ConditionalArgument)
}
```

## API Endpoints

The Version Details API uses the following Mojang endpoints:

- **Version Manifest**: `https://piston-meta.mojang.com/mc/game/version_manifest_v2.json`
- **Version Details**: URLs from the version manifest (e.g., `https://piston-meta.mojang.com/v1/packages/{sha1}/{version}.json`)

## See Also

- [Player Profile API](../README.md#player-profile-api)
- [Version Manifest API](../README.md#version-api)
- [Demo App](../../Demo/MojangAPIDemo)
