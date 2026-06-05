//
//  ContentView.swift
//  MayotyWatch Watch App
//
//  Created by sun on 5/31/26.
//

import SwiftUI

struct ContentView: View {
    @State private var model: WatchViewModel?
    @State private var manager: WatchCentralManager?
    
    var body: some View {
        VStack{
            Button("Reconnect"){
                manager?.scan()
            }
            
            HStack{
                Button("죽이기"){
                    manager?.sendSaveOrKill(.kill)
                }
                Button("살리기"){
                    manager?.sendSaveOrKill(.save)
                }
            }
        }
    }
}

//#Preview {
//    ContentView()
//}
