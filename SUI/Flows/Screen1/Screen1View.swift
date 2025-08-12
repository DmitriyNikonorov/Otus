//
//  Screen1View.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 07.06.2025.
//

import SwiftUI
import Foundation

struct Screen1View: View {
    @EnvironmentObject var tabBarState: TabBarState
    @ObservedObject var viewModel: Screen1ViewModel

//    @State private var worker = Worker(name: "Worker 1")
    @State private var workers = [Worker]()
    @State private var total = 0

//    init() {
//
//    }

    var body: some View {
        ZStack {
            VStack {
                List {
                    Section {
                        ForEach(workers) { worker in
                            WorkerView(worker: worker)
                        }
                    } header: {
                        Text("Заказы")
                    }
                }
                .listStyle(.plain)
                Button("Добавить заказ в очередь") {
                    Task {
                        workers.append(Worker(name: "Worker \(workers.count + 1)"))
                        await workers.last?.work()
                    }
                }
                .buttonStyle(.automatic)
                .padding(.vertical, 12.0)
            }
        }
    }
}

struct WorkerView: View {
    @State var worker: Worker

    var body: some View {
        VStack {
            HStack {
                ScrollView(.horizontal) {
                    HStack(spacing: 8.0) {
                        switch worker.state {
                        case .noWork,.inQueue, .cooking, .inDelivery:
                            Text("\(worker.state.description)")
                            ProgressView()

                        case .delivered:
                            Text(worker.state.description)
                        }
                    }
                }
                .scrollIndicators(.never)
            }
        }
    }
}

enum WorkState: Int {
    case noWork, inQueue, cooking, inDelivery, delivered

    var description: String {
        switch self {
        case .noWork:
            return "Очередь пуста"

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

@Observable
final class Worker: Identifiable {
    let name: String
    let id: UUID

    init(name: String) {
        self.name = name
        id = UUID()
    }

    var state: WorkState = .noWork
    var progress = 0
    var inProgress = false

    private func reset() {
        progress = 0
        state = .noWork
        inProgress = false
    }

    func work() async -> WorkState {
        reset()
        inProgress = true

        for _ in 0..<4 {
            progress += doWork()
            state = WorkState(rawValue: progress) ?? .noWork
            logProgress()
        }

        inProgress = false
        return state
    }

    private func doWork() -> Int  {
        var a: Double = 10
        for i in 0...5000000 {
            a = pow(Double(a),Double(i))
        }
        return 1
    }

    private func logProgress() {
        print("Name \(name), progress \(state.description)")
    }
}
