//
//  SheetView3.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 15.08.2025.
//

import SwiftUI
import Foundation

struct SheetView3: View {
    @StateObject var viewModel: Screen1ViewModel

    @State private var totalTaskDone = 0
    @State private var totalTaskAdded = 0

//    @State private var cookingTaskList: [any TaskProtocol] = []
//    @State private var deliveryTaskList: [any TaskProtocol] = []



    var body: some View {
        VStack {
            Spacer()
            Text("Всего задач добавлено : \(totalTaskAdded)")
            Text("Всего задач выполнено : \(totalTaskDone)")
            List {
                Section {
                    ForEach(viewModel.ordersList) { order in
//                        WorkView(task: task)
                        Text("Заказ \(order.number), статус \(order.state.description)")
                    }
                }
//                Section {
//                    ForEach(deliveryTaskList, id: \.id) { task in
//                        WorkView(task: task)
//                    }
//                } header: {
//                    Text("Доставка")
//                }
            }
//            .listStyle(.plain)

            Button("Добавить заказ в очередь") {
                Task {
                    totalTaskAdded += 1
                    await viewModel.addOrder(number: totalTaskAdded)
                }
            }
            .buttonStyle(.automatic)
            .padding(.vertical, 12.0)
        }
    }
}

struct WorkView: View {
    @State var task: any TaskProtocol

    var body: some View {
        VStack {
                ScrollView(.horizontal) {
                    HStack(spacing: 8.0) {
                        switch task.state {
                        case .inQueue, .cooking, .inDelivery:
                            Text("Задача: \(task.name), статус: \(task.state.description)")
                            ProgressView()

                        case .cooked, .delivered:
                            Text("Задача: \(task.name), статус: \(task.state.description)")

                        case .unowned:
                            Text("Заказ \(task.name) потерялса")
                        }
                    }
                }
                .scrollIndicators(.never)
        }
    }
}
