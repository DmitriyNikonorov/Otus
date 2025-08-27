//
//  Screen1ViewModel+Actor.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 27.08.2025.
//

import Foundation

extension Screen1ViewModel {
    func cancelOrder(at orderID: UUID) async {
        cancelledTasks.insert(orderID)
        await updateState(orderId: orderID, state: .cancelled)
    }

    func stopAll() async {
        processingTasks.forEach {
            $0.value.cancel()
        }
        cancellables.removeAll()
        await MainActor.run {
            ordersList.removeAll()
            totalOrderDone = 0
            totalOrderAdded = 0
        }
        await chefActor.removeAllOrders()
        await deliveryActor.removeAllOrders()
    }

    @MainActor
    func addOrder() async {
        totalOrderAdded += 1
        let order = Order(number: totalOrderAdded, state: .inQueue)
        ordersList.append(order)
        await chefActor.appendToQueue(order: order)

        let task = Task {
            await startCookingProcess()
        }

        processingTasks[order.id] = task
    }
}

private extension Screen1ViewModel {


    private func startCookingProcess() async {
        guard
            await !chefActor.orderQueue.isEmpty,
            await !chefActor.isProcess
        else {
            return
        }
        await chefActor.setProcessing(isOn: true)
        var order = await chefActor.removeFirstFromQueue()

        if !cancelledTasks.contains(order.id) {
            await switchState(for: &order)
            await chefActor.cookOrder(order: order)
            await switchState(for: &order)

            Task {
                await deliveryActor.appendToQueue(order: order)
                await startDeliveringProcess()
            }
        }

        await chefActor.setProcessing(isOn: false)
        if await chefActor.orderQueue.isEmpty {
            return
        }

        await startCookingProcess()
    }

    private func switchState(for order: inout Order) async {
        if cancelledTasks.contains(order.id) {
            order.state = .cancelled
        } else {
            let state = order.state
            let newState = OrderState(rawValue: state.rawValue + 1) ?? .inQueue
            order.state = newState
        }

        await updateState(orderId: order.id, state: order.state)
    }

    private func startDeliveringProcess() async {
        guard
            await !deliveryActor.orderQueue.isEmpty,
            await !deliveryActor.isProcess
        else {
            return
        }

        await deliveryActor.setProcessing(isOn: true)
        var order = await deliveryActor.removeFirstFromQueue()

        if !cancelledTasks.contains(order.id) {
            await switchState(for: &order)
            await deliveryActor.deliveryOrder(order: order)
            await switchState(for: &order)

            await MainActor.run {
                totalOrderDone += 1
            }
        }

        await deliveryActor.setProcessing(isOn: false)
        processingTasks.removeValue(forKey: order.id)

        if await deliveryActor.orderQueue.isEmpty {
            return
        }
        await startDeliveringProcess()
    }

    private func updateState(orderId: UUID, state: OrderState) async {
        await MainActor.run {
            if let index = ordersList.firstIndex(where: { $0.id == orderId }) {
                ordersList[index].state = state
            }
        }
    }
}
