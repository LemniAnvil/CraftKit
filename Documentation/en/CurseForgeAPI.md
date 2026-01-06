# CurseForge API Documentation

Complete reference for CurseForge Minecraft modpack/mod API integration.

## Table of Contents

- [Getting Started](#getting-started)
- [Search API](#search-api)
  - [Search Modpacks](#search-modpacks)
  - [Search Mods](#search-mods)
  - [Search Parameters](#search-parameters)
- [Mod Detail API](#mod-detail-api)
  - [Fetch Mod Details](#fetch-mod-details)
- [Data Models](#data-models)
- [Pagination](#pagination)
- [Error Handling](#error-handling)

## Getting Started

### Configuration

```swift
import MojangAPI

// Read API key from environment variable (recommended)
let apiKey = ProcessInfo.processInfo.environment["CURSEFORGE_API_KEY"] ?? "YOUR_API_KEY"
let config = CurseForgeAPIConfiguration(apiKey: apiKey)
let client = CurseForgeAPIClient(configuration: config)
```

### API Key

You need a CurseForge API key to use this API. Get one from:
- [CurseForge for Studios](https://console.curseforge.com/?#/api-keys)

**Security Note**: Never hardcode API keys in your source code. Use environment variables or secure configuration files.

## Search API

### Search Modpacks

```swift
// Basic search
let response = try await client.searchModpacks()

// Search with keyword
let response = try await client.searchModpacks(
    searchFilter: "sky",
    sortField: .totalDownloads,
    sortOrder: .desc,
    pageSize: 20
)

// Filter by game version
let response = try await client.searchModpacks(
    gameVersion: "1.20.1",
    pageSize: 10
)

// Filter by categories
let response = try await client.searchModpacks(
    categoryIds: [4475, 4483], // Adventure and RPG, Combat / PvP
    pageSize: 15
)
```

### Search Mods

```swift
let response = try await client.searchMods(
    gameId: .minecraft,
    classId: .mod,
    searchFilter: "optifine",
    sortField: .totalDownloads,
    sortOrder: .desc,
    index: 0,
    pageSize: 25,
    gameVersion: "1.20.1",
    modLoaderType: .forge
)
```

### Search Parameters

**Sort Fields:**
- `.featured` - Featured mods
- `.popularity` - Popularity
- `.lastUpdated` - Last updated
- `.name` - Name (alphabetical)
- `.author` - Author name
- `.totalDownloads` - Total downloads
- `.category` - Category
- `.gameVersion` - Game version

**Sort Order:**
- `.asc` - Ascending
- `.desc` - Descending

**Mod Loaders:**
- `.any` - Any loader
- `.forge` - Forge
- `.cauldron` - Cauldron
- `.liteLoader` - LiteLoader
- `.fabric` - Fabric
- `.quilt` - Quilt
- `.neoForge` - NeoForge

## Mod Detail API

### Fetch Mod Details

```swift
// Fetch by mod ID
let response = try await client.fetchModDetails(modId: 285109)
let mod = response.data

print("Name: \(mod.name)")
print("Downloads: \(mod.formattedDownloadCount)")
print("Author: \(mod.primaryAuthor?.name ?? "Unknown")")
print("Summary: \(mod.summary)")

// Access categories
for category in mod.categories {
    print("Category: \(category.name)")
}

// Access latest files
if let latestRelease = mod.latestReleaseFile {
    print("Latest Release: \(latestRelease.displayName)")
    print("File Size: \(latestRelease.formattedFileSize)")
    print("Game Versions: \(latestRelease.gameVersions.joined(separator: ", "))")
}

// Access links
print("Website: \(mod.links.websiteUrl)")
if let wiki = mod.links.wikiUrl {
    print("Wiki: \(wiki)")
}

// Access social links
if let socialLinks = mod.socialLinks {
    for link in socialLinks {
        print("\(link.typeName): \(link.url)")
    }
}
```

## Data Models

### CFMod

Main model for mods and modpacks:

```swift
public struct CFMod: Codable {
    public let id: Int                      // Mod ID
    public let name: String                 // Mod name
    public let slug: String                 // URL-friendly name
    public let summary: String              // Short description
    public let downloadCount: Int           // Total downloads
    public let categories: [CFCategory]     // Categories
    public let authors: [CFAuthor]          // Authors
    public let logo: CFLogo                 // Logo/icon
    public let latestFiles: [CFFile]        // Latest files
    public let links: CFLinks               // External links
    public let socialLinks: [CFSocialLink]? // Social media links
    public let screenshots: [CFScreenshot]? // Screenshots
    // ... more fields
}
```

### CFFile

File information:

```swift
public struct CFFile: Codable {
    public let id: Int                   // File ID
    public let fileName: String          // File name
    public let displayName: String       // Display name
    public let downloadUrl: String?      // Download URL
    public let fileLength: Int           // File size in bytes
    public let downloadCount: Int        // Download count
    public let releaseType: Int          // 1=Release, 2=Beta, 3=Alpha
    public let gameVersions: [String]    // Supported game versions
    public let hashes: [CFFileHash]      // SHA1/MD5 hashes
    public let fileDate: Date            // Upload date
    public let isServerPack: Bool        // Whether it is a server pack
    public let dependencies: [CFFileDependency] // Dependencies
    // ... more fields
}
```

### CFModsSearchResponse

Search response with pagination:

```swift
public struct CFModsSearchResponse: Codable {
    public let data: [CFMod]           // Search results
    public let pagination: CFPagination // Pagination info
}
```

## Pagination

### Working with Pagination

```swift
let pageSize = 20
var currentIndex = 0

// First page
let page1 = try await client.searchModpacks(
    index: currentIndex,
    pageSize: pageSize
)

print("Page \(page1.pagination.currentPage) of \(page1.pagination.totalPages)")
print("Total results: \(page1.pagination.totalCount)")

// Next page
if page1.pagination.hasNextPage {
    currentIndex = page1.pagination.nextIndex!
    let page2 = try await client.searchModpacks(
        index: currentIndex,
        pageSize: pageSize
    )
}

// Previous page
if page1.pagination.hasPreviousPage {
    currentIndex = page1.pagination.previousIndex!
    let page0 = try await client.searchModpacks(
        index: currentIndex,
        pageSize: pageSize
    )
}
```

### Pagination Helper Methods

```swift
let pagination: CFPagination

pagination.hasNextPage      // Has next page
pagination.hasPreviousPage  // Has previous page
pagination.nextIndex        // Next page index
pagination.previousIndex    // Previous page index
pagination.currentPage      // Current page number (1-based)
pagination.totalPages       // Total number of pages
```

## Convenience Extensions

### CFMod Extensions

```swift
mod.isModpack                    // Is this a modpack?
mod.formattedDownloadCount       // "27.8M" format
mod.primaryAuthor                // First author
mod.latestReleaseFile            // Latest release version
mod.latestBetaFile               // Latest beta version
mod.latestAlphaFile              // Latest alpha version
mod.supportedGameVersions        // All supported versions
mod.hasScreenshots               // Has screenshots
mod.hasSocialLinks               // Has social links
mod.discordLink                  // Discord invite URL
mod.websiteLink                  // Official website
```

### CFFile Extensions

```swift
file.formattedFileSize      // "49.0 MB" format
file.releaseTypeName        // "Release", "Beta", "Alpha"
file.sha1Hash               // SHA1 hash value
file.md5Hash                // MD5 hash value

let hash: CFFileHash
hash.isSHA1                  // Available on CFFileHash
hash.isMD5
```

## Error Handling

```swift
do {
    let response = try await client.searchModpacks()
} catch CurseForgeAPIError.unauthorized {
    print("Invalid API key")
} catch CurseForgeAPIError.rateLimitExceeded {
    print("Rate limit exceeded, please wait")
} catch CurseForgeAPIError.serverError(let statusCode) {
    print("Server error: \(statusCode)")
} catch CurseForgeAPIError.networkError(let error) {
    print("Network error: \(error.localizedDescription)")
} catch {
    print("Unknown error: \(error)")
}
```

## Common Use Cases

### Display Modpack List

```swift
let response = try await client.searchModpacks(
    sortField: .totalDownloads,
    sortOrder: .desc,
    pageSize: 20
)

for modpack in response.data {
    print("\(modpack.name)")
    print("  Author: \(modpack.primaryAuthor?.name ?? "Unknown")")
    print("  Downloads: \(modpack.formattedDownloadCount)")
    print("  Summary: \(modpack.summary)")
    print("  Logo: \(modpack.logo.thumbnailUrl)")
    print()
}
```

### Find Version-Specific Modpacks

```swift
let response = try await client.searchModpacks(
    gameVersion: "1.20.1",
    sortField: .totalDownloads,
    sortOrder: .desc,
    pageSize: 10
)

for modpack in response.data {
    let versions = modpack.supportedGameVersions
    print("\(modpack.name) supports: \(versions.joined(separator: ", "))")
}
```

### Get Complete Mod Information

```swift
// First, search for the mod
let searchResponse = try await client.searchModpacks(
    searchFilter: "RLCraft",
    pageSize: 1
)

if let mod = searchResponse.data.first {
    // Then, fetch full details
    let detailResponse = try await client.fetchModDetails(modId: mod.id)
    let fullMod = detailResponse.data
    
    print("Full information for \(fullMod.name):")
    print("  Categories: \(fullMod.categories.map { $0.name }.joined(separator: ", "))")
    print("  Files: \(fullMod.latestFiles.count)")
    print("  Screenshots: \(fullMod.screenshots?.count ?? 0)")
}
```

## API Limits

- **Rate Limiting**: CurseForge API has rate limits. Respect them to avoid being blocked.
- **Page Size**: Maximum page size is typically 50.
- **API Version**: This library uses CurseForge API v1.

## Related Resources

- [CurseForge API Documentation](https://docs.curseforge.com/)
- [CurseForge for Studios Console](https://console.curseforge.com/)
