//
//  TabBarView.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 07.06.2025.
//

import SwiftUI
import Combine

struct TabBarView: View {
    @EnvironmentObject var tabBarState: TabBarState
    @ObservedObject var screen1ViewModel: Screen1ViewModel
    @ObservedObject var screen2ViewModel: Screen2ViewModel
    @ObservedObject var screen3ViewModel: Screen3ViewModel
    @ObservedObject var screen4ViewModel: Screen4ViewModel

    var body: some View {
        ZStack {
            tabBar
        }
    }

    var tabBar: some View {
        var handler: Binding<TabBarItem> {
            Binding(
                get: {
                    tabBarState.selectedTab
                },
                set: { newValue in
                    if newValue != tabBarState.selectedTab {
                        tabBarState.selectedTab = newValue
                    }
                }
            )
        }

        return TabView(selectionTab: handler, items: tabBarState.tabs) { tab in
            ZStack {
                switch tab {
                case .screen1:
                    NavigationView {
                        Screen1View(viewModel: screen1ViewModel)
                            .navigationBarTitleDisplayMode(.inline)
                    }
                    .tabBar()
                    .tint(.blue)

                case .screen2:
                    NavigationView {
                        Screen2View(viewModel: screen2ViewModel)
                            .navigationBarTitleDisplayMode(.inline)
                    }
                    .tabBar()
                    .tint(.blue)

                case .screen3:
                    NavigationView {
                        Screen3View(viewModel: screen3ViewModel)
                            .navigationBarTitleDisplayMode(.inline)

                    }
                    .tabBar()
                    .tint(.blue)

                case .screen4:
                    NavigationView {
                        Screen4View(viewModel: screen4ViewModel)
                            .navigationBarTitleDisplayMode(.inline)
                            .tabBar()
                    }
                    .tint(.blue)
                }

            }
            .background(.white)
            .environmentObject(tabBarState)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
        }
    }
}
