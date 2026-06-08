//
//  ListCell.swift
//  Mayoty
//
//  Created by jeegarden on 6/7/26.
//
import SwiftUI

struct ListCell<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(.horizontal, 16)
            .foregroundStyle(Color.black)
            .frame(maxWidth: .infinity, minHeight: 64)
            .background {
                RoundedRectangle(cornerRadius: 30)
                    .foregroundStyle(Color.white)
            }
    }
}
