//
//  ListView.swift
//  Mayoty
//
//  Created by jeegarden on 6/7/26.
//
import SwiftUI

struct ListView<Header: View, Item: Identifiable, Cell: View>: View {
    let header: Header
    let leadingTitle: String
    let trailingTitle: String
    let items: [Item]
    let cell: (Item) -> Cell

    init(
        leadingTitle: String,
        trailingTitle: String,
        items: [Item],
        @ViewBuilder header: () -> Header,
        @ViewBuilder cell: @escaping (Item) -> Cell
    ) {
        self.leadingTitle = leadingTitle
        self.trailingTitle = trailingTitle
        self.items = items
        self.header = header()
        self.cell = cell
    }

    var body: some View {
        List {
            Section(header: header.textCase(nil)) {}
                .padding(.top, 20)

            Section(header:
                HStack {
                    Text(leadingTitle)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.primary)
                
                    Spacer()
                
                    Text(trailingTitle)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.primary)
                }
                .padding(.top, 160)
                .padding(.bottom,6)
                .textCase(nil)
            ) {
                ForEach(items) { item in
                    cell(item)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(
                            top: 4, leading: 16, bottom: 4, trailing: 16
                        ))
                }
            }
        }
        .listStyle(.plain)
        .background(Color(UIColor.systemGroupedBackground))
    }
}
