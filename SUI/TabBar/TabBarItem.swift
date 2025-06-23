//
//  TabBarItem.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 07.06.2025.
//

import SwiftUI

enum TabBarItem: Int {
    case screen1, screen2, screen3, screen4

//    enum LocalizedString {
//        case screen(count: Int)
//
//        var key: String {
//            switch self {
//            case .screen:
//                return "screen %lld"
//            }
//        }
//
//        var arguments: [CVarArg] {
//            switch self {
//            case let .screen(count):
//                return [count]
//            }
//        }
//
//        var localized: String {
//            let format = NSLocalizedString(key, comment: "")
//            return String(format: format, arguments: arguments)
//        }
//    }

    var image: Image {
        switch self {
        case .screen1:
            return Image(systemName: "1.square")

        case .screen2:
            return Image(systemName: "2.square")

        case .screen3:
            return Image(systemName: "3.square")

        case .screen4:
            return Image(systemName: "4.square")
        }
    }

    var title: String {
        switch self {
        case .screen1:
            Localization.screen(1)

        case .screen2:
//            LocalizedString.screen(count: 2).localized
            Localization.screen(2)

        case .screen3:
//            LocalizedString.screen(count: 3).localized
            Localization.screen(3)

        case .screen4:
//            LocalizedString.screen(count: 4).localized
            Localization.screen(4)
        }
    }
}
