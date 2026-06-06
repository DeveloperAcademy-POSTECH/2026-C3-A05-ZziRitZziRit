//
//  ConnectionOk.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI

struct ConnectionOk: View {
    var body: some View {
        MafiaLogoView {
            VStack(spacing: 5) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size:40))
                Text("연결 완료")
                    .font(.system(size:30))
            }
        }
    }
}

#Preview {
    ConnectionOk()
}
