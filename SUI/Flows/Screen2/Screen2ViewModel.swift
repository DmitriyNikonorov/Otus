//
//  Screen2ViewModel.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 07.06.2025.
//

import Foundation
import Combine

protocol Screen1ViewModelOutput {
    func openDetails(with text: String)
}

extension Screen2ViewModel: Screen1ViewModelOutput {
    func openDetails(with text: String) {
        self.link = .details(DefaultAssembler.shared.resolve(text: text))
    }
}

final class Screen2ViewModel: ViewModel, ObservableObject {

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
    @Published var items: [String] = (0...25).map { "Item \($0)" }

    var action = PassthroughSubject<Action, Never>()

    override init() {
        super.init()
        bind()
    }
}

private extension Screen2ViewModel {
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
