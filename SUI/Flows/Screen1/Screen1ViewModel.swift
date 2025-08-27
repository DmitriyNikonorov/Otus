//
//  Screen1ViewModel.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 07.06.2025.
//

import Foundation
import Combine

final class Screen1ViewModel: ViewModel, ObservableObject {
    @Published var ordersList = [Order]()
    @Published var totalOrderDone = 0
    @Published var totalOrderAdded = 0

    private let chefActor = ChefActor()
    private let deliveryActor = DeliveryActor()
    private var processingTasks: [UUID: Task<Void, Never>] = [:]

    private var cancelledTasks = Set<UUID>()
    private var cancellables = Set<AnyCancellable>()

    enum Action {
        case openDetail
    }

    var isLinkActive = PassthroughSubject<Bool, Never>()
    var action = PassthroughSubject<Action, Never>()
    var output = PassthroughSubject<Void, Never>()
    var delegate: Screen1ViewModelOutput?

    override init() {
        super.init()
        bind()
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

    func cancelOrder(at orderID: UUID) async {
        cancelledTasks.insert(orderID)
        await updateState(orderId: orderID, state: .cancelled)
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

private extension Screen1ViewModel {
    func bind() {
        action
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                guard let self else { return }
                
                switch action {
                case .openDetail:
                    output.send()
                }
            }
            .store(in: &cancellables)
    }
}
