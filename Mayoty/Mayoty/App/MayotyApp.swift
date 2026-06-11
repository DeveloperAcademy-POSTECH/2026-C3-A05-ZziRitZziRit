//
//  MayotyApp.swift
//  Mayoty
//
//  Created by sun on 5/31/26.
//

import SwiftUI

@main
struct MayotyApp: App {
    @State private var dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            GameView(dependencies: dependencies)
        }
    }
}
