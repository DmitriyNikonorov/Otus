//
//  Worker.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 15.08.2025.
//

import Foundation

enum WorkState: Int {
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


protocol WorkerProtocol: Actor {
    func work(_ step: Int) -> WorkState
    func enqueueJob(_ job: Job) async -> Bool
}

actor Worker: WorkerProtocol, Identifiable {
    private let name: String
    let id: UUID

    init(name: String) {
        self.name = name
        id = UUID()
        print("init Worker \(name) ")
    }

    deinit {
        print("deinit Worker \(name) ")
    }

    var state: WorkState = .inQueue
    var totalJobsDone = 0
    var totalJobsAdded = 0

    private var taskQueue: [Job] = []
    var isProcessing = false

    func enqueueJob(_ job: Job) async -> Bool {
        taskQueue.append(job)
        return await processNextJob()
    }

    func incrementTotalJobsAdded() async {
         totalJobsAdded += 1
    }

    private func processNextJob() async -> Bool {
        guard !isProcessing, !taskQueue.isEmpty else { return false }
         isProcessing = true

        let currentJob = taskQueue.removeFirst()
         let result = await currentJob.doNeedJob()

        totalJobsDone += 1
        isProcessing = false

        if taskQueue.isEmpty {
            return result
        }
        return await processNextJob()
    }


    func work(_ step: Int) -> WorkState {
        var counter = 0
        for _ in 0..<10000_000 {
            counter += 1
        }
        state = WorkState(rawValue: step) ?? .inQueue
        return state
    }

    private func logProgress() {
        print("Name \(name), progress \(state.description)")
    }
}
