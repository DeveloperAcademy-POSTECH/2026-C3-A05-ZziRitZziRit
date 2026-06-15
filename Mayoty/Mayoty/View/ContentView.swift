//
//  ContentView.swift
//  Mayoty
//
//  Created by sun on 6/12/26.
//

import SwiftUI

struct ContentView: View {
    
    @State private var game: MafiaGame
    @State private var bleViewModel: BLEViewModel
    @State private var didAutoStartGame = false

    private let peripheralManager: iPhoneBLEPeripheralManager
    private let watchCommandManager: WatchCommandManager
    
    init() {
        let peripheralManager = iPhoneBLEPeripheralManager()

        let watchCommandManager = WatchCommandManager(
            peripheralManager: peripheralManager
        )

        let initialGame = MafiaGame(
            players: [],
            initialState: WaitingState(),
            homeKitLightManager: HomeKitLightManager(),
            watchCommandManager: watchCommandManager
        )
        
        self.peripheralManager = peripheralManager
        self.watchCommandManager = watchCommandManager

        _game = State(initialValue: initialGame)
        _bleViewModel = State(
            initialValue: BLEViewModel(
                game: initialGame,
                peripheralManager: peripheralManager
            )
        )
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Advertising: \(bleViewModel.isAdvertising ? "ON" : "OFF")")
                }
                
                Divider()
                
                Text("워치 응답")
                    .font(.headline)
                
                if bleViewModel.answers.isEmpty {
                    Text("아직 응답 없음")
                        .foregroundStyle(.secondary)
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(Array(bleViewModel.answers), id: \.key) { id, answer in
                                HStack {
                                    Text(String(id.uuidString.prefix(8)))
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing) {
                                        Text(answer.kindText)
                                            .bold()
                                        
                                        Text("value: \(answer.value)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
                
                Divider()
                
                Text("기록들")
                    .font(.headline)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(bleViewModel.logs, id: \.self) { log in
                            Text(log)
                                .font(.caption)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
            .navigationTitle("CoreBluetooth 데모")
        }
    }
}

