//
//  SheetView.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 15.08.2025.
//

import SwiftUI
import Foundation

struct SheetView: View {
    @StateObject var viewModel: Screen1ViewModel

    var body: some View {
        VStack {
            Spacer()
            Text("Всего задач добавлено : \(viewModel.totalOrderAdded)")
            Text("Всего задач выполнено : \(viewModel.totalOrderDone)")
            List {
                Section {
                    ForEach($viewModel.ordersList) { $order in
                        OrderView(order: $order)
                    }
                }
            }

            Button("Добавить заказ в очередь") {
                Task {
                    await viewModel.addOrder()
                }
            }
            .buttonStyle(.automatic)
            .padding(.vertical, 12.0)
        }
        .onDisappear {
            Task {
                await viewModel.stopAll()
            }
        }
    }
}

struct OrderView: View {
    @Binding var order: Order

    var body: some View {
        HStack() {
            Text("Order \(order.number)")
                .font(.headline)

            Text(order.state.description)
                .foregroundStyle(stateColor)
                .padding(8)
                .background(statusBackground)
                .cornerRadius(8)
        }
    }

    private var stateColor: Color {
        switch order.state {
        case .inQueue, .delivered:
                .white

        case .cooking:
                .black

        case .cooked:
                .black

        case .inDelivery:
                .white
        }
    }

    private var statusBackground: Color {
        switch order.state {
        case .inQueue:
                .gray

        case .cooking:
                .yellow

        case .cooked:
                .orange

        case .inDelivery:
                .blue


        case .delivered:
                .green
        }
    }
}
