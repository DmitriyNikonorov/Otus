//
//  Screen1View.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 07.06.2025.
//

import SwiftUI

struct Screen1View: View {
    @EnvironmentObject var tabBarState: TabBarState
    @ObservedObject var viewModel: Screen1ViewModel

    var body: some View {
        ZStack {
            VStack {
                Text("Hello, Screen1View!")
                Button("Open Second Screen") {
                    tabBarState.selectedTab = .screen2
                    viewModel.action.send(.openDetail)
                }
                .padding(.top, 120.0)
            }
        }
    }
}
