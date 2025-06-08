//
//  Screen2View.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 07.06.2025.
//

import SwiftUI

struct Screen2View: View {
    @ObservedObject var viewModel: Screen2ViewModel

    var body: some View {
        ZStack {
            NavigationLink("", isActive: $viewModel.isLinkActive) {
                switch viewModel.link {
                case .details(let viewModel):
                    DetailsView(viewModel: viewModel)

                default:
                    EmptyView()
                }
            }


            List {
                ForEach(viewModel.items, id: \.self) { item in
                    Text(item)
                        .listRowSeparator(.visible)
                        .listRowInsets(.init())
                        .clipShape(Rectangle())
                        .padding(.horizontal, 16.0)
                        .padding(.vertical, 4.0)
                        .onTapGesture {
                            viewModel.action.send(.openDetails(item))
                        }
                }
            }
            .onChange(of: viewModel.isLinkActive) { isActive in
                if !isActive {
                    viewModel.link = nil
                }
            }
            .navigationTitle("Second Screen")
            .listStyle(.plain)
        }
    }
}
