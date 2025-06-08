//
//  DetailsViewModel.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 07.06.2025.
//

import Foundation

final class DetailsViewModel: ViewModel, ObservableObject {
    @Published var text: String

    init(text: String) {
        _text = Published(wrappedValue: text)
    }
}
