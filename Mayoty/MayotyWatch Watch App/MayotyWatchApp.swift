//
//  MayotyWatchApp.swift
//  MayotyWatch Watch App
//
//  Created by sun on 5/31/26.
//

import SwiftUI

@main
struct MayotyWatch_Watch_AppApp: App {

    @State private var viewModel = WatchViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView(
                    viewModel: viewModel
                )
            }
        }
    }
}
