//
//  Screen3View.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 07.06.2025.
//

import SwiftUI

struct Screen3View: View {
    @ObservedObject var viewModel: Screen3ViewModel

    var body: some View {
        ZStack {
            VStack {
                Button("Open Details Modal") {
                    viewModel.action.send(.openDetails)
                }
            }
            .navigationTitle("Third Screen")
            .sheet(isPresented: $viewModel.isShowingModal) {
                DetailsView(viewModel: DefaultAssembler.shared.resolve(text: "Modal Screen"))
            }
        }
    }
}
