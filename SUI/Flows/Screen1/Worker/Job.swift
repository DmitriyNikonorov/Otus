//
//  Job.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 15.08.2025.
//

import Foundation

@Observable
final class Job: Identifiable {
    let worker: WorkerProtocol
    var state: WorkState = .inQueue
    let name: String
    private let needJobsSteps = 4

    init(worker: Worker, name: String) {
        self.worker = worker
        self.name = name
        print("init Job \(name)")
    }

    deinit {
        print("deinit Job \(name)")
    }

    @MainActor
    func doNeedJob() async -> Bool {
        for n in 0...needJobsSteps {
            state = await worker.work(n)
            logProgress()
        }

        return true
    }

    private func logProgress() {
        print("Job \(name), \(state.description)")
    }
}
