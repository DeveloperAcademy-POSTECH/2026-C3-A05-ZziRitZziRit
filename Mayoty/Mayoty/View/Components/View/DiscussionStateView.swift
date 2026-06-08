//
//  DiscussionStateView.swift
//  Mayoty
//
//  Created by jeegarden on 6/7/26.
//
import SwiftUI

struct DiscussionStateView: View {
    
    let devices: [Device] = [
        Device(name: "핑크",isAlive: true),
        Device(name: "보라",isAlive: true),
        Device(name: "노랑",isAlive: true),
        Device(name: "민트",isAlive: true),
        Device(name: "주황",isAlive: false),
    ]
    let state: String = "DiscussionState"
    
    let remainingTime: Int = 0

    var body: some View {
        ListView(
            leadingTitle: "연결된 기기",
            trailingTitle: "\(devices.count)/5",
            items: devices
        ) {
            StateView(state: state, remainingTime: remainingTime)
        } cell: { device in
            ListCell {
                HStack (spacing: 30){
                    Text(device.name)
                        .font(.default)
                    
                    Text(device.isAlive ? "생존" : "사망")
                        .font(.default)
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    DiscussionStateView()
}



