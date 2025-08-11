//
//  TabView.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 07.06.2025.
//

import SwiftUI

struct TabView<Content: View>: View {

    @Binding var selectionTab: TabBarItem
    let items: [TabBarItem]
    let content: (TabBarItem) -> Content

    var body: some View {
        ZStack {
            Spacer().tabBar()
            ForEach(items, id: \.self) { item in
                content(item)
                    .isHidden(item != selectionTab, isNeedRemove: true)
                    .animation(.easeInOut, value: selectionTab)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}


struct TabBarModifier: ViewModifier {
    @EnvironmentObject var tabBarState: TabBarState

    func body(content: Content) -> some View {
        VStack(spacing: 0.0) {
            content

            Divider()
            HStack {
                ForEach(tabBarState.tabs, id: \.self) { tabItem in
                    Button {
                        tabBarState.selectedTab = tabItem
                    } label: {
                        VStack(spacing: 4.0) {
                            tabItem.image
                            Text(tabItem.title)
                                .font(.system(size: 9, weight: .semibold))
                        }
                        .foregroundColor(tabItem == tabBarState.selectedTab ? Color.accentColor : .primary)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.top, 8.0)
            .padding(.bottom, 32.0)
            .background(.green)
        }
        .ignoresSafeArea(edges: .all)
    }
}

extension View {
    func tabBar() -> some View {
        self.modifier(TabBarModifier())
    }

    @ViewBuilder
    func isHidden(_ isHidden: Bool, isNeedRemove: Bool = false) -> some View {
        if isHidden {
            if !isNeedRemove {
                hidden()
            }
        } else {
            self
        }
    }
}
