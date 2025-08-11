//
//  Screen1ViewModel.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 07.06.2025.
//

import Foundation
import Combine

final class Screen1ViewModel: ViewModel, ObservableObject {

    enum Action {
        case openDetail
    }

    var isLinkActive = PassthroughSubject<Bool, Never>()

    var action = PassthroughSubject<Action, Never>()
    var output = PassthroughSubject<Void, Never>()

    var delegate: Screen1ViewModelOutput?

    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        bind()
    }
}

private extension Screen1ViewModel {
    func bind() {
        action
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                guard let self else { return }
                
                switch action {
                case .openDetail:
                    output.send()
                }
            }
            .store(in: &cancellables)
    }
}
