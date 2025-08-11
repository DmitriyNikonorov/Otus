//
//  Screen4View.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 07.06.2025.
//

import SwiftUI

struct Screen4View: View {
    @ObservedObject var viewModel: Screen4ViewModel

    @State private var value: Double = 0
    private let minValue = 0.0
    private let maxValue = 1000.0
    @State private var showInParrots = false


    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            NavigationLink("", isActive: $viewModel.isLinkActive) {
                switch viewModel.link {
                case let .details(viewModel):
                    DetailsView(viewModel: viewModel)

                default:
                    EmptyView()
                }
            }

            VStack {
                HStack {
                    if viewModel.isLoading {
                        ActivityIndicator(isAnimating: $viewModel.isLoading, style: .large)
                    } else {
                        Button(Localization.openDetail) {
                            viewModel.action.send(.openDetails(Localization.detailsView))
                        }
                    }
                }
                .frame(height: 50.0)
                Text(
                    showInParrots
                    ? viewModel.formattedDistanceInParrots(Int(value))
                    : viewModel.formattedDistance(Int(value))
                )
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(
                        value < 500
                        ? .green
                        : value < 900
                        ? .yellow
                        : .red
                    )
                Slider(value: $value, in: minValue...maxValue, step: 1) {
                    Text("")
                } minimumValueLabel: {
                    Text("0")
                } maximumValueLabel: {
                    Text("1000")
                }
                .padding(.horizontal, 50.0)
                .accentColor(.purple)

                Button(showInParrots ? Localization.showInMeters : Localization.showInParrots) {
                    showInParrots.toggle()
                }

            }
            .navigationTitle(Localization.fourthScreen)
            .onAppear() {
                if !viewModel.isLoading {
                    viewModel.isLoading = true
                    viewModel.startTimer()
                }
            }
        }
    }
}



