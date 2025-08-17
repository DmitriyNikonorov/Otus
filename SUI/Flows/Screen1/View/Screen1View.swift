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
    @State private var isShowSeet = false

    var body: some View {
        ZStack {
            VStack {
                Button("Show Actors sheet") { isShowSeet = true }
            }
        }
        .sheet(isPresented: $isShowSeet) { SheetView(viewModel: viewModel) }
    }
}
