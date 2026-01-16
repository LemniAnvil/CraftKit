# CraftKit – Swift Minecraft API Client

A modern, type-safe Swift package for Mojang's Minecraft services plus CurseForge search APIs. The package exposes async/await friendly networking, first-class models, and a demo app to showcase every major feature.

> 需要中文说明？请查看 [`Documentation/zh-CN/README.md`](./Documentation/zh-CN/README.md)。

## Features

### Mojang API
- **Microsoft OAuth 2.0 Authentication** - Complete login flow without UI dependencies
- Version manifest + details (v1 + v2)
- Player profiles by name or UUID
- Skin and cape download helpers
- Authenticated client for uploading/changing skins

### CurseForge API
- Modpack and mod search with filters
- Complete result details and pagination helpers
- Sorting (downloads, updated time, name, etc.)
- Filter by game version and loader

### Technical goodies
- Pure Swift, type-safe models
- Async/Await friendly APIs with rich error surfaces
- Shared networking stack with ISO8601 decoding helpers
- Bilingual docs (English + Chinese)
- Demo SwiftUI app showcasing Mojang + CurseForge flows

## Installation (Swift Package Manager)

```swift
dependencies: [
    .package(url: "https://github.com/LemniAnvil/CraftKit.git", branch: "main")
]
```

## Quick Start

```swift
import CraftKit

let client = MinecraftAPIClient()

// Fetch the manifest
let manifest = try await client.fetchVersionManifest()
print("Latest release: \(manifest.latest.release)")
print("Latest snapshot: \(manifest.latest.snapshot)")

// Version details
let details = try await client.fetchVersionDetails(byId: "1.21.4")
print("Java version: \(details.javaVersion.majorVersion)")
print("Download size: \(details.formattedDownloadSize)")
```

### Player profiles and skins

```swift
let profile = try await client.fetchPlayerProfile(byName: "Notch")
print(profile.id)

let skinData = try await client.downloadSkin(byUUID: profile.id)
// render skinData in UIImage/NSImage
```

### Authenticated skin management

```swift
let auth = MinecraftAuthenticatedClient(bearerToken: "Bearer …")

// Get account profile with all skins and capes
let profile = try await auth.getProfile()
print("Active skin: \(profile.activeSkin?.variant.rawValue ?? "default")")

// Upload a new skin
let pngData = try Data(contentsOf: URL(fileURLWithPath: "skin.png"))
try await auth.uploadSkin(imageData: pngData, variant: .classic)

// Change skin variant without re-uploading
try await auth.changeSkinVariant(.slim)

// Copy another player's skin
try await auth.copySkin(from: "Notch")
```

### Microsoft OAuth 2.0 Authentication

Complete authentication flow without UI dependencies:

```swift
let authClient = MicrosoftAuthClient(
  clientID: "your-microsoft-client-id",
  redirectURI: "your-app://auth"
)

// Step 1: Generate login URL
let loginData = try authClient.generateLoginURL()
// Open loginData.url in browser (your app handles this)

// Step 2: Parse callback URL (after user authorizes)
let authCode = try authClient.parseCallback(
  url: callbackURL,
  expectedState: loginData.state
)

// Step 3: Complete login
let response = try await authClient.completeLogin(
  authCode: authCode,
  codeVerifier: loginData.codeVerifier
)

print("Logged in as: \(response.name)")
print("Access token: \(response.accessToken)")

// Step 4: Refresh token when expired
let refreshed = try await authClient.refreshLogin(
  refreshToken: response.refreshToken
)
```

See [Microsoft Authentication Guide](./Documentation/MicrosoftAuthenticationGuide.md) for complete implementation details.

## API Documentation

- Mojang API: [English](./Documentation/en/MojangAPI.md) · [中文](./Documentation/zh-CN/MojangAPI.md)
- CurseForge API: [English](./Documentation/en/CurseForgeAPI.md) · [中文](./Documentation/zh-CN/CurseForgeAPI.md)

Full project README in Chinese now lives at [`Documentation/zh-CN/README.md`](./Documentation/zh-CN/README.md).

## Demo App

A SwiftUI demo highlights both API clients:

- Player lookup + skin preview
- Version browsing + details
- CurseForge modpack browsing and pagination
- Skin upload testing screen for authenticated flows

Run it with:
```bash
cd Demo/MojangAPIDemo
open MojangAPIDemo.xcodeproj
```
Or open the workspace to code the app and package side-by-side:
```bash
open Demo/MojangAPIWorkspace.xcworkspace
```

## Requirements

- iOS 15 / macOS 12
- Swift 5.9+
- Xcode 15+

## License

MIT

## Contributing

Issues and PRs are welcome! See `Documentation/zh-CN/README.md` for the Chinese overview.

## Helpful Links

- [Mojang API Wiki (archived)](https://web.archive.org/web/20241129181309/https://wiki.vg/Mojang_API)
- [Minecraft Wiki](https://minecraft.wiki/)
