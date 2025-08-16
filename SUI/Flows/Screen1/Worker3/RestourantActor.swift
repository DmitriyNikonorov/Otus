//
//  RestourantActor.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 15.08.2025.
//

import Foundation

enum OrderState: Int {
    case inQueue, cooking, inDelivery, delivered

    var description: String {
        switch self {
        case .inQueue:
            return "В очереди"

        case .cooking:
            return "Готовится"

        case .inDelivery:
            return "Доставляется"

        case .delivered:
            return "Доставлено"
        }
    }
}

actor ChefActor {
    func cookOrder(order: Order) async -> Order {
        let cookingTime = 3 //Int.random(in: 3...7)
        try? await Task.sleep(nanoseconds: UInt64(cookingTime * 1_000_000_000))

        var cookedOrder = order
        cookedOrder.state = .inDelivery
        return cookedOrder
    }
}

actor DeliveryBoyActor {
    func deliveryOrder(order: Order) async -> Order {
        let deliveryTime = 3 //Int.random(in: 2...5)
        try? await Task.sleep(nanoseconds: UInt64(deliveryTime * 1_000_000_000))

        var deliveredOrder = order
        deliveredOrder.state = .delivered
        return deliveredOrder
    }
}


enum TaskState: Int {
    case inQueue, cooking, cooked, inDelivery, delivered, unowned

    var description: String {
        switch self {
        case .inQueue:
            return "В очереди"

        case .cooking:
            return "Готовится"

        case .cooked:
            return "Отдано в доставку"

        case .inDelivery:
            return "Доставляется"

        case .delivered:
            return "Доставлено"

        case .unowned:
            return "Заказ потерялся"
        }
    }
}

protocol WorkActorProtocol: Actor {
    func addNewTask(task: any TaskProtocol) async -> (any TaskProtocol)?
    func addDoneTask()
}

actor DeliveryActor: WorkActorProtocol {
    var totalTaskDone = 0
    var totalTaskAdded = 0

    private var queueOfTask: [any TaskProtocol] = []
    private var inProgress = false

    func addNewTask(task: any TaskProtocol) async -> (any TaskProtocol)? {
//        var t = task

        totalTaskAdded += 1
//        t.name = "\(totalTaskAdded)"
        print("✅ \(task.name)")
        queueOfTask.append(task)
        return await executeAllTask()
    }

    private func executeAllTask() async -> (any TaskProtocol)? {
        guard
            !inProgress,
            !queueOfTask.isEmpty
        else {
            return nil
        }

        inProgress = true
        let task = queueOfTask.removeFirst()
        await task.taskAsync()
        addDoneTask()
        inProgress = false

        if queueOfTask.isEmpty {
            return task
        }

        return await executeAllTask()
    }

    func addDoneTask() {
        totalTaskDone += 1
    }
    

}

actor RestourantActor: WorkActorProtocol {
    var totalTaskDone = 0
    var totalTaskAdded = 0

    private var queueOfTask: [any TaskProtocol] = []
    private var inProgress = false

    func addNewTask(task: any TaskProtocol) async -> (any TaskProtocol)? {
        var t = task

        totalTaskAdded += 1
        t.name = "\(totalTaskAdded)"
        queueOfTask.append(t)
        return await executeAllTask()
    }

    private func executeAllTask() async -> (any TaskProtocol)? {
        guard
            !inProgress,
            !queueOfTask.isEmpty
        else {
            return nil
        }

        inProgress = true
        let task = queueOfTask.removeFirst()
        await task.taskAsync()
        addDoneTask()
        inProgress = false

        if queueOfTask.isEmpty {
            return task
        }

        return await executeAllTask()
    }

    func addDoneTask() {
        totalTaskDone += 1
    }
}
