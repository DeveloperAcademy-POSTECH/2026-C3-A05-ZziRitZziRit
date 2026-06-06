//
//  ContentView.swift
//  MayotyWatch Watch App
//
//  Created by sun on 5/31/26.
//

import SwiftUI

struct ContentView: View {
    @State private var model: WatchViewModel?
    @State private var manager: WatchBLEManager?
    
    var body: some View {
        VStack{
            Button("Reconnect"){
                manager?.scan()
            }
        }
    }
}

//#Preview {
//    ContentView()
//}
