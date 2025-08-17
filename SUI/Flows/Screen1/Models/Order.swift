//
//  Order.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 15.08.2025.
//

import Foundation

enum OrderState: Int {
    case inQueue, cooking, cooked, inDelivery, delivered

    var description: String {
        switch self {

        case .inQueue:
            return "В очереди"

        case .cooking:
            return "Готовится"

        case .cooked:
            return "Ждёт доставщика"

        case .inDelivery:
            return "Доставляется"

        case .delivered:
            return "Доставлено"
        }
    }
}

struct Order: Identifiable {
    let id: UUID
    let number: Int
    var state: OrderState

    init(id: UUID = UUID(), number: Int, state: OrderState) {
        self.id = id
        self.number = number
        self.state = state
    }

    func nextState()  -> Order {
        return Order(
            id: self.id,
            number: self.number,
            state: OrderState(rawValue: self.state.rawValue + 1) ?? .inQueue
        )
    }
}
