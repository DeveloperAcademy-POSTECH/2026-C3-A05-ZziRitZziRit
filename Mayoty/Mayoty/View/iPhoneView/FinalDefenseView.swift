//
//  FinalDefenseView.swift
//  Mayoty
//
//  Created by jeegarden on 6/7/26.
//
import SwiftUI

struct FinalDefenseView: View {
    let device: [Device] = [
        Device(name: "핑크",isFinalDefender: true, isAlive: true),   // 최후 변론자
        Device(name: "보라", isFinalDefender: false,isAlive: true),
        Device(name: "오렌지", isFinalDefender: false,isAlive: true),
        Device(name: "노랑", isFinalDefender: false,isAlive: true),
        Device(name: "민트", isFinalDefender: false,isAlive: false),
    ]
    
    let state: String = "FinalDefenseState"
    
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
                    if device.isFinalDefender {
                        Text("최후 변론자")
                    }
                }
            }
        }
    }
}
#Preview {
    FinalDefenseView()
}
