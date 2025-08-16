//
//  SheetView.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 15.08.2025.
//

import SwiftUI
import Foundation

struct SheetView: View {
    @State private var worker = Worker(name: "First worker")
    @State private var jobs = [Job]()
//    @State private var totalJobsDone = 0

    @State private var jobsAdded = 0

    @State private var totalSteps: Int = 0

    var body: some View {
        VStack {
            Text("Всего задач выполнено :\(worker.totalJobsDone)")
            List {
                Section {
                    Text("Приготовлено заказов: \(worker.totalJobsDone)")
                    ForEach(jobs) { job in
                        WorkerView(job: job)
                    }
                } header: {
                    Text("Доставка")
                }
            }
            .listStyle(.plain)
            Button("Добавить заказ в очередь") {
                Task {
                    jobsAdded += 1
                    let newJob = Job(worker: worker, name: "Job \(jobsAdded)")
                    jobs.append(newJob)
                    let workResult = await worker.enqueueJob(newJob)
                }

            }
            .buttonStyle(.automatic)
            .padding(.vertical, 12.0)
        }
    }
}
