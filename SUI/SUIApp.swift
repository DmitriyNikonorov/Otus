//
//  SUIApp.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 02.06.2025.
//

import SwiftUI
import Combine

@main
struct SUIApp: App {

//    private let tabBarViewModel = TabBarViewModel()
    private let tabBarViewModel: TabBarViewModel = DefaultAssembler.shared.resolve()

    @StateObject private var tabBarState = TabBarState()

//    let screen1ViewModel: Screen1ViewModel = DefaultAssembler.shared.resolve()
//    let screen2ViewModel: Screen2ViewModel = DefaultAssembler.shared.resolve()
//    let screen3ViewModel: Screen3ViewModel = DefaultAssembler.shared.resolve()
//    let screen4ViewModel: Screen4ViewModel = DefaultAssembler.shared.resolve()

    init() {

    }

    var body: some Scene {
        WindowGroup {
            TabBarView(
//                screen1ViewModel: DefaultAssembler.shared.resolve(),
//                screen2ViewModel: DefaultAssembler.shared.resolve(),
//                screen3ViewModel: DefaultAssembler.shared.resolve(),
//                screen4ViewModel: DefaultAssembler.shared.resolve()
                screen1ViewModel: tabBarViewModel.screen1ViewModel,
                screen2ViewModel: tabBarViewModel.screen2ViewModel,
                screen3ViewModel: tabBarViewModel.screen3ViewModel,
                screen4ViewModel: tabBarViewModel.screen4ViewModel
            )
            .environmentObject(tabBarState)

        }
    }
}
