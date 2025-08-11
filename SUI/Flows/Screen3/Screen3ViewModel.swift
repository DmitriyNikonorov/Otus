//
//  Screen3ViewModel.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 07.06.2025.
//

import Foundation
import Combine

final class Screen3ViewModel: ViewModel, ObservableObject {

    enum Action {
        case openDetails
    }

    private var cancellables = Set<AnyCancellable>()

    @Published var isShowingModal = false
    var action = PassthroughSubject<Action, Never>()

    override init() {
        super.init()
        bind()
    }
}

private extension Screen3ViewModel {
    func bind() {
        action
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                guard let self else { return }

                switch action {
                case .openDetails:
                    self.isShowingModal = true
                }
            }
            .store(in: &cancellables)
    }
}

