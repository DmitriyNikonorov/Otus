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
    private let chef = ChefActor()
    private let deliveryBoy = DeliveryBoyActor()
    private var processingTasks: [UUID: Task<Void, Never>] = [:]

    enum Action {
        case openDetail
    }

    var isLinkActive = PassthroughSubject<Bool, Never>()

    var action = PassthroughSubject<Action, Never>()
    var output = PassthroughSubject<Void, Never>()

    var delegate: Screen1ViewModelOutput?

    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        bind()
    }

//    func addNewTask(task: any TaskProtocol) async -> (any TaskProtocol)? {
//        totalTaskAdded += 1
//        print("✅ \(task.name)")
//        queueOfTask.append(task)
//        return await executeAllTask()
//    }

    @MainActor
    func addOrder(number: Int) {
        let order = Order(number: number, state: .inQueue)
        ordersList.append(order)

        let task = Task {
            await processeOrder(order)
        }

        processingTasks[order.id] = task
    }

    private func processeOrder(_ order: Order) async {
        var order = order
        await updateState(orderId: order.id, state: .cooking)

        let cookedOrder = await chef.cookOrder(order: order)
        await updateState(orderId: cookedOrder.id, state: .inDelivery)

        let deliveredOrder = await deliveryBoy.deliveryOrder(order: cookedOrder)
        await updateState(orderId: deliveredOrder.id, state: .delivered)

        processingTasks.removeValue(forKey: order.id)
    }

    private func updateState(orderId: UUID, state: OrderState) async {
        await MainActor.run {
            if let index = ordersList.firstIndex(where: { $0.id == orderId }) {
                ordersList[index].state = state
            }
        }
    }

    func cancelOrder(_ orderID: UUID) {
        processingTasks[orderID]?.cancel()
        processingTasks.removeValue(forKey: orderID)
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
