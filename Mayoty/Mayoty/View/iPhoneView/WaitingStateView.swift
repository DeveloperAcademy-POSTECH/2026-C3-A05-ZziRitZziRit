//
//  WaitingStateView.swift
//  Mayoty
//
//  Created by jeegarden on 6/7/26.
//
import SwiftUI

struct WaitingStateView: View {
    let devices: [Device] = [
        Device(name: "블루투스 식별자 1"),
        Device(name: "블루투스 식별자 2"),
        Device(name: "블루투스 식별자 3"),
    ]
    let state: String = "WaitingState"
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
                HStack {
                    Text(device.name)
                        .font(.default)
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    WaitingStateView()
}

