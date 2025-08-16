//
//  TaskForActor.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 15.08.2025.
//

import Foundation

struct Order: Identifiable {
    var id: UUID = UUID()
    var number: Int
    var state: OrderState
}

protocol TaskProtocol: Identifiable {
    var actor: WorkActorProtocol { get set }
    var state: TaskState { get set }
    var name: String { get set }
    func taskAsync() async
    var id: UUID { get set }
}

@Observable
final class CookingTask: TaskProtocol {
    var name: String = ""
    var id: UUID
    var actor: WorkActorProtocol
    var state: TaskState = .inQueue

    init(workActor: RestourantActor) {
        id = UUID()
        self.actor = workActor
    }

    func taskAsync() async {
        let cookingTime = Int.random(in: 2...5)
        state = .cooking

        // Имитация работы
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(TimeInterval(cookingTime))
        while Date() < endTime {
            await Task.yield()
        }

        state = .cooked
        log()
    }

    private func log() {
        print("Job with name \(name) is done")
    }
}

@Observable
final class DeliveryTask: TaskProtocol {
    var name: String
    var id: UUID
    var actor: WorkActorProtocol
    var state: TaskState

    init(name: String, workActor: DeliveryActor, state: TaskState = .inQueue) {
        self.name = name
        id = UUID()
        self.actor = workActor
        self.state = state
    }

    func taskAsync() async {
        let cookingTime = Int.random(in: 3...7)
        state = .inDelivery

        // Имитация работы
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(TimeInterval(cookingTime))
        while Date() < endTime {
            await Task.yield()
        }

        state = .delivered
        log()
    }

    private func log() {
        print("Job with name \(name) is done")
    }
}
