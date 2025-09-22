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
    @State private var isShowSheet = false
    @State private var isShowMlSheet = false
    @State private var isShowARSheet = false

    var body: some View {
        ZStack {
            VStack {
                Button("Show Actors sheet") { isShowSheet = true }
                    .padding(24.0)
                Button("Show ML sheet") { isShowMlSheet = true }
                    .padding(24.0)
                Button("ARKit") { isShowARSheet = true }
                    .padding(24.0)
            }
        }
        .sheet(isPresented: $isShowSheet) { SheetView(viewModel: viewModel) }
        .sheet(isPresented: $isShowMlSheet) { MLView() }
        .sheet(isPresented: $isShowARSheet) { ARCameraView() }
    }
}
