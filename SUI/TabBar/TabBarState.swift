//
//  A.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 07.06.2025.
//

import Foundation

final class TabBarState: ObservableObject {

    @Published var selectedTab = TabBarItem.screen1
    let tabs: [TabBarItem] = [.screen1, .screen2, .screen3, .screen4]
}
