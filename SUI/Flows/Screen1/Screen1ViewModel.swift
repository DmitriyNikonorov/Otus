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
        let order = await chefActor.removeFirstFromQueue().nextState()


        await updateState(orderId: order.id, state: order.state)

        let cookedOrder = await chefActor.cookOrder(order: order)
        await updateState(orderId: order.id, state: cookedOrder.state)
        await chefActor.setProcessing(isOn: false)

        Task {
            await deliveryActor.appendToQueue(order: cookedOrder)
            await startDeliveringProcess()
        }

        if await chefActor.orderQueue.isEmpty {
            return
        }

        await startCookingProcess()

    }

    private func startDeliveringProcess() async {
        guard
            await !deliveryActor.orderQueue.isEmpty,
            await !deliveryActor.isProcess
        else {
            return
        }

        await deliveryActor.setProcessing(isOn: true)
        let order = await deliveryActor.removeFirstFromQueue().nextState()

        await updateState(orderId: order.id, state: order.state)

        let deliveredOrder = await deliveryActor.deliveryOrder(order: order)
        await updateState(orderId: deliveredOrder.id, state: deliveredOrder.state)

        await deliveryActor.setProcessing(isOn: false)
        processingTasks.removeValue(forKey: order.id)
        await MainActor.run {
            totalOrderDone += 1
        }

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
