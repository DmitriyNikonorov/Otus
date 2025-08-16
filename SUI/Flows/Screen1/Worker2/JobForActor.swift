//
//  JobForActor.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 15.08.2025.
//

import Foundation

@Observable
final class JobForActor: Identifiable {
    let name: String
    let id: UUID
    let workActor: WorkActor

    var progress = 0
    var inProgress = false

    init(name: String, workActor: WorkActor) {
        self.name = name
        id = UUID()
        self.workActor = workActor
    }

    @MainActor
    func jobAsync(count: Int) async {
        for _ in 0..<count {
            self.progress += 1
            await workActor.addOneWork()
        }
        log()
    }

    private func log() {
        print("Job with name \(name) is done")
    }
}
