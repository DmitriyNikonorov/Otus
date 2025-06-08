//
//  Screen4ViewModel.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 07.06.2025.
//

import Foundation
import Combine

final class Screen4ViewModel: ViewModel, ObservableObject {

    enum Link {
        case details(DetailsViewModel)
    }

    enum Action {
        case openDetails(String)
    }

    private var cancellables = Set<AnyCancellable>()

    @Published var link: Link? {
        didSet {
            isLinkActive = link != nil
        }
    }
    @Published var isLinkActive = false
    @Published var isLoading = false
    var action = PassthroughSubject<Action, Never>()

    override init() {
        super.init()
        bind()
    }

    func startTimer() {
        Just(())
            .delay(for: .seconds(3), scheduler: RunLoop.main)
            .sink { [weak self] in
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }
}

private extension Screen4ViewModel {
    func bind() {
        action
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                guard let self else { return }

                switch action {
                case .openDetails(let text):
                    self.link = .details(DefaultAssembler.shared.resolve(text: text))
                }
            }
            .store(in: &cancellables)
    }
}
