# Mojang API Documentation

Complete reference for Mojang Minecraft API integration.

## Table of Contents

- [Version API](#version-api)
  - [Fetch Version Manifest](#fetch-version-manifest)
  - [Fetch Version Details](#fetch-version-details)
  - [Filter Versions](#filter-versions)
- [Player Profile API](#player-profile-api)
  - [Query by Username](#query-by-username)
  - [Query by UUID](#query-by-uuid)
- [Texture API](#texture-api)
  - [Get Skin and Cape URLs](#get-skin-and-cape-urls)
  - [Download Skin and Cape](#download-skin-and-cape)
- [Data Models](#data-models)
- [Convenience Extensions](#convenience-extensions)

## Version API

### Fetch Version Manifest

```swift
// Use v2 API (recommended, includes SHA1 and compliance level)
let manifest = try await client.fetchVersionManifest()

// Explicitly specify API version
let manifestV1 = try await client.fetchVersionManifest(useV2: false)
let manifestV2 = try await client.fetchVersionManifest(useV2: true)
```

**v1 vs v2 Differences:**
- v1: Basic version info (id, type, url, time, releaseTime)
- v2: All v1 fields + `sha1` + `complianceLevel`

### Fetch Version Details

```swift
// By version ID
let details = try await client.fetchVersionDetails(byId: "1.21.4")

// By VersionInfo object
let versionInfo = try await client.findVersion(byId: "1.21.4")
if let info = versionInfo {
    let details = try await client.fetchVersionDetails(for: info)
}
```

### Filter Versions

```swift
let manifest = try await client.fetchVersionManifest()

// Get all releases
let releases = manifest.versions.filter { $0.type == .release }

// Get all snapshots
let snapshots = manifest.versions.filter { $0.type == .snapshot }

// Use convenience methods
let releaseVersions = try await client.fetchVersions(ofType: .release)
```

## Player Profile API

### Query by Username

```swift
let profile = try await client.fetchPlayerProfile(byName: "Notch")
print("UUID: \(profile.id)")
print("Username: \(profile.name)")
```

### Query by UUID

```swift
// Get full profile (including skin information)
let profile = try await client.fetchPlayerProfile(byUUID: "069a79f4-44e9-4726-a5be-fca90e38aaf5")

// Get texture information
let textures = try profile.getTexturesPayload()
if let skin = textures.textures.SKIN {
    print("Skin URL: \(skin.url)")
    print("Skin Model: \(skin.skinModel.displayName)")
}
```

## Texture API

### Get Skin and Cape URLs

```swift
// Get skin URL
if let skinURL = try await client.fetchSkinURL(byName: "Notch") {
    print("Skin URL: \(skinURL)")
}

// Get cape URL
if let capeURL = try await client.fetchCapeURL(byName: "Notch") {
    print("Cape URL: \(capeURL)")
}
```

### Download Skin and Cape

```swift
// Download skin data
let skinData = try await client.downloadSkin(byName: "Notch")

#if canImport(UIKit)
let image = UIImage(data: skinData)
#elseif canImport(AppKit)
let image = NSImage(data: skinData)
#endif

// Download cape data
if let capeData = try? await client.downloadCape(byName: "Notch") {
    // Process cape image
}
```

## Data Models

### VersionInfo

```swift
public struct VersionInfo: Codable {
    public let id: String              // Version ID (e.g., "1.21.4")
    public let type: VersionType       // Version type
    public let url: String             // Details URL
    public let time: Date              // Update time
    public let releaseTime: Date       // Release time
    public let sha1: String?           // SHA1 (v2 only)
    public let complianceLevel: Int?   // Compliance level (v2 only)
}
```

### VersionDetails

```swift
public struct VersionDetails: Codable {
    public let arguments: Arguments?
    public let minecraftArguments: String?
    public let id: String
    public let type: VersionType
    public let mainClass: String
    public let javaVersion: JavaVersion
    public let downloads: Downloads
    public let libraries: [Library]
    public let logging: Logging?
    // ... more fields
}
```

### PlayerProfile

```swift
public struct PlayerProfile: Codable {
    public let id: String                 // UUID
    public let name: String               // Username
    public let properties: [ProfileProperty]? // Signed properties (textures etc.)
    public let profileActions: [String]?  // Optional action flags from Mojang
}
```

## Convenience Extensions

### VersionInfo Extensions

```swift
// Check API version
version.isFromV2API          // Is from v2 API
version.hasSHA1              // Has SHA1
version.hasComplianceLevel   // Has compliance level

// Version comparison
version.isLatestRelease(in: manifest)
version.isLatestSnapshot(in: manifest)

// Formatting
version.formattedReleaseDate  // Formatted release date
```

### VersionDetails Extensions

```swift
// Download information
details.clientDownloadURL     // Client download URL
details.serverDownloadURL     // Server download URL
details.totalDownloadSize     // Total download size (bytes)
details.formattedDownloadSize // Formatted size

// OS support
details.supportsOS("osx")     // Check macOS support
details.libraries(for: "osx") // Get macOS libraries

// Arguments
details.gameArgumentStrings   // All game arguments
details.jvmArgumentStrings    // All JVM arguments

// Java version
details.javaVersion.isJava8
details.javaVersion.isJava17Plus
details.javaVersion.isJava21Plus
```

### PlayerProfile Extensions

```swift
profile.hasCustomSkin         // Has custom skin
profile.isSigned              // Has signature

// Get information
let textures = try profile.getTexturesPayload()
let skinURL = profile.getSkinURL()
let capeURL = profile.getCapeURL()
```

## Error Handling

```swift
do {
    let profile = try await client.fetchPlayerProfile(byName: "NonExistentPlayer")
} catch MinecraftAPIError.playerNotFound(let name) {
    print("Player '\(name)' not found")
} catch MinecraftAPIError.networkError(let error) {
    print("Network error: \(error.localizedDescription)")
} catch {
    print("Unknown error: \(error)")
}
```

## API Compatibility

This library supports both v1 and v2 version manifest APIs:

- **v1 API**: `https://launchermeta.mojang.com/mc/game/version_manifest.json`
- **v2 API**: `https://piston-meta.mojang.com/mc/game/version_manifest_v2.json`

Both APIs return identical content, but v2 includes additional fields (SHA1 hash and compliance level) for better validation and security.
