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
    @State private var isShowSeet2 = false
    @State private var isShowSeet3 = false

    var body: some View {
        ZStack {
            VStack {
                Button("Show sheet") { isShowSeet = true }
                Button("Show sheet2") { isShowSeet2 = true }
                Button("Show sheet3") { isShowSeet3 = true }
            }
        }
        .sheet(isPresented: $isShowSeet) { SheetView() }
        .sheet(isPresented: $isShowSeet2) { SheetView2() }
        .sheet(isPresented: $isShowSeet3) { SheetView3(viewModel: viewModel) }
    }
}
