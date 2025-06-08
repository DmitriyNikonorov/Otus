//
//  Assemblers.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 07.06.2025.
//

protocol TabBarAssembler {
    func resolve() -> TabBarViewModel
}

extension TabBarAssembler where Self: DefaultAssembler {
    func resolve() -> TabBarViewModel {
        return TabBarViewModel(
            screen1ViewModel: resolve(),
            screen2ViewModel: resolve(),
            screen3ViewModel: resolve(),
            screen4ViewModel: resolve()
        )
    }
}

protocol Screen1Assembler {
    func resolve() -> Screen1ViewModel
}

extension Screen1Assembler {
    func resolve() -> Screen1ViewModel {
        return Screen1ViewModel()
    }
}

protocol Screen2Assembler {
    func resolve() -> Screen2ViewModel
}

extension Screen2Assembler {
    func resolve() -> Screen2ViewModel {
        return Screen2ViewModel()
    }
}

protocol Screen3Assembler {
    func resolve() -> Screen3ViewModel
}

extension Screen3Assembler {
    func resolve() -> Screen3ViewModel {
        return Screen3ViewModel()
    }
}

protocol Screen4Assembler {
    func resolve() -> Screen4ViewModel
}

extension Screen4Assembler {
    func resolve() -> Screen4ViewModel {
        return Screen4ViewModel()
    }
}

protocol DetailsViewAssembler {
    func resolve(text: String) -> DetailsViewModel
}

extension DetailsViewAssembler {
    func resolve(text: String) -> DetailsViewModel {
        return DetailsViewModel(text: text)
    }
}
