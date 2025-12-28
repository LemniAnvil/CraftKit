//
//  MojangAPIDemoApp.swift
//  MojangAPIDemo
//
//  Created by Iris on 2025-12-26.
//

import SwiftUI

@main
struct MojangAPIDemoApp: App {
  var body: some Scene {
    WindowGroup {
      TabView {
        ContentView()
          .tabItem {
            Label("玩家档案", systemImage: "person.fill")
          }

        VersionDetailsView()
          .tabItem {
            Label("版本详情", systemImage: "cube.box.fill")
          }
      }
    }
  }
}
