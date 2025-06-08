//
//  TabBarItem.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 07.06.2025.
//

import SwiftUI

enum TabBarItem: Int {
    case screen1, screen2, screen3, screen4

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
            "Screen 1"

        case .screen2:
            "Screen 2"

        case .screen3:
            "Screen 3"

        case .screen4:
            "Screen 4"
        }
    }
}
