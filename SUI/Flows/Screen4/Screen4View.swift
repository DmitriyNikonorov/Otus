//
//  Screen4View.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 07.06.2025.
//

import SwiftUI

struct Screen4View: View {
    @ObservedObject var viewModel: Screen4ViewModel

    var body: some View {
        ZStack {
            Color.yellow.ignoresSafeArea()
            NavigationLink("", isActive: $viewModel.isLinkActive) {
                switch viewModel.link {
                case let .details(viewModel):
                    DetailsView(viewModel: viewModel)

                default:
                    EmptyView()
                }
            }

            VStack {
                if viewModel.isLoading {
                    ActivityIndicator(isAnimating: $viewModel.isLoading, style: .large)
                } else {
                    Button("Open detail") {
                        viewModel.action.send(.openDetails("details"))
                    }
                }
            }
            .navigationTitle("Fourth screen")
            .onAppear() {
                if !viewModel.isLoading {
                    viewModel.isLoading = true
                    viewModel.startTimer()
                }
            }
        }
    }
}



