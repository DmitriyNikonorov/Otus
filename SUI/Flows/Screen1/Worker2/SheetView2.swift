//
//  SheetView2.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 15.08.2025.
//

import SwiftUI
import Foundation

struct SheetView2: View {
    @State private var work: WorkActor
//    @State private var job: JobForActor
    @State private var totalJobsDone = 0
    private let targetNumber = 1000_000

    @State private var jobsList: [JobForActor] = []

    init() {
        let theWork = WorkActor()
        _work = State(initialValue: theWork)

//        let job = JobForActor(name: "First", workActor: theWork)
//        _job = State(initialValue: job)
    }

    @State private var totalSteps: Int = 0
    @State private var totalJobsAdded = 0

    var body: some View {
        VStack {
            Spacer()
//            Text("Всего задач выполнено : \(totalJobsDone)")
            Text("Всего задач выполнено : \(totalJobsAdded)")
//            Text("Недостача : \(targetNumber - totalJobsDone)")
//                .foregroundStyle(.red)
//            Text("Недостача : \(targetNumber - totalJobsDone)")
//                .foregroundStyle(.red)
            List {
                Section {
                    ForEach(jobsList) { job in
                        Text("\(job.name), \(job.progress)")
                    }
                }
            }
            .listStyle(.plain)
            Button("Добавить заказ в очередь") {
                Task {
                    totalJobsAdded += 1
                    let job = JobForActor(name: "Job \(totalJobsAdded)", workActor: work)
                    jobsList.append(job)
                    await job.jobAsync(count: targetNumber)
                    totalJobsDone = await work.total
                }
            }
            .buttonStyle(.automatic)
            .padding(.vertical, 12.0)
        }
    }
}
