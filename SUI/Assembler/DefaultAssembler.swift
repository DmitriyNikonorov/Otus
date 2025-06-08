//
//  DefaultAssembler.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 07.06.2025.
//

import Foundation

protocol Assembler:
    Screen1Assembler,
    Screen2Assembler,
    Screen3Assembler,
    Screen4Assembler,
    DetailsViewAssembler,
    TabBarAssembler {
}

final class DefaultAssembler: Assembler, ObservableObject {
    static let shared = DefaultAssembler()
}
