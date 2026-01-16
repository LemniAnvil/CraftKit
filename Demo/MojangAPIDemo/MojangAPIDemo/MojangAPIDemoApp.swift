//
//  CraftKitDemoApp.swift
//  CraftKitDemo
//

import SwiftUI

@main
struct MojangAPIDemoApp: App {
  @State private var mojangPath = NavigationPath()
  @State private var curseForgePath = NavigationPath()

  var body: some Scene {
    WindowGroup {
      TabView {
        NavigationStack(path: $mojangPath) {
          MojangAPITestsView()
            .navigationTitle("Mojang API Demo")
        }
        .tabItem {
          Label("Mojang", systemImage: "gamecontroller.fill")
        }

        NavigationStack(path: $curseForgePath) {
          CurseForgeAPITestsView()
            .navigationTitle("CurseForge API Demo")
        }
        .tabItem {
          Label("CurseForge", systemImage: "square.stack.3d.up.fill")
        }
      }
    }
  }
}
