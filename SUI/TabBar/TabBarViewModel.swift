//
//  TabBarViewModel.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 07.06.2025.
//

import Foundation
import Combine

final class TabBarViewModel: ViewModel, ObservableObject {
    private var cancellables = Set<AnyCancellable>()

    let screen1ViewModel: Screen1ViewModel
    let screen2ViewModel: Screen2ViewModel
    let screen3ViewModel: Screen3ViewModel
    let screen4ViewModel: Screen4ViewModel

    init(
        screen1ViewModel: Screen1ViewModel,
        screen2ViewModel: Screen2ViewModel,
        screen3ViewModel: Screen3ViewModel,
        screen4ViewModel: Screen4ViewModel
    ) {
        self.screen1ViewModel = screen1ViewModel
        self.screen2ViewModel = screen2ViewModel
        self.screen3ViewModel = screen3ViewModel
        self.screen4ViewModel = screen4ViewModel
        super.init()
        bind()
    }
}

private extension TabBarViewModel {
    func bind() {
        screen1ViewModel.output
            .sink { [weak self] in
                let element = self?.screen2ViewModel.items.randomElement()
                self?.screen2ViewModel.link = .details(DefaultAssembler.shared.resolve(text: element ?? ""))
            }
            .store(in: &cancellables)
    }
}
