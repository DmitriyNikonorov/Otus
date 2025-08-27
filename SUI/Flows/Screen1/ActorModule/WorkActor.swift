//
//  WorkActor.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 15.08.2025.
//

import Foundation

protocol WorkActor {

}

actor ChefActor {
    var orderQueue: [Order] = []
    var isProcess = false

    func appendToQueue(order: Order) async {
        orderQueue.append(order)
    }

    func removeFirstFromQueue() -> Order {
        orderQueue.removeFirst()
    }

    func removeFromQueue(at orderID: UUID) async -> Bool {
        guard let index = orderQueue.firstIndex(where: { $0.id == orderID }) else { return false }
        orderQueue.remove(at: index)
        return true
    }

    func setProcessing(isOn: Bool) async {
        isProcess = isOn
    }

    func cookOrder(order: Order) async {
        let cookingTime = Int.random(in: 3...7)
        try? await Task.sleep(nanoseconds: UInt64(cookingTime * 1_000_000_000))
    }

    func removeAllOrders() async {
        orderQueue.removeAll()
    }
}

actor DeliveryActor {

    var orderQueue: [Order] = []

    func appendToQueue(order: Order) {
        orderQueue.append(order)
    }

    func removeFirstFromQueue() -> Order {
        orderQueue.removeFirst()
    }

    func removeFromQueue(at id: UUID) async  -> Bool {
        guard let index = orderQueue.firstIndex(where: { $0.id == id }) else { return false }
        orderQueue.remove(at: index)
        return true
    }

    var isProcess = false
    
    func setProcessing(isOn: Bool) async {
        isProcess = isOn
    }

    func deliveryOrder(order: Order) async {
        let deliveryTime = Int.random(in: 2...5)
        try? await Task.sleep(nanoseconds: UInt64(deliveryTime * 1_000_000_000))
    }

    func removeAllOrders() async {
        orderQueue.removeAll()
    }
}
