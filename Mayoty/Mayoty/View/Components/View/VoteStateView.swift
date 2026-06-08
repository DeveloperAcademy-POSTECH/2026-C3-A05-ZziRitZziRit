//
//  VoteStateView.swift
//  Mayoty
//
//  Created by jeegarden on 6/7/26.
//
import SwiftUI

struct VoteStateView: View {
    let device: [Device] = [
        Device(name: "핑크", isAlive: true),   // 최후 변론자
        Device(name: "보라", isAlive: true),
        Device(name: "오렌지", isAlive: true),
        Device(name: "노랑", isAlive: true),
        Device(name: "민트", isAlive: false),
    ]
    
    let state: String = "VoteState"
    
    let remainingTime: Int = 0


    
    var body: some View {
        ListView(
            leadingTitle: "연결된 기기",
            trailingTitle: "\(device.count)/5",
            items: device
        ) {
            StateView(state: state, remainingTime: remainingTime)
        } cell: { device in
            ListCell {
                HStack(spacing: 30) {
                    Text("\(device.name)")
                        .font(.default)
                    Text(device.isAlive ? "생존" : "사망")
                        .font(.default)
                    Spacer()
                    
                    //투표 옵션
                }
            }
        }
    }
}
#Preview {
    VoteStateView()
}
