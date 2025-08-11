//
//  DetailsView.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 07.06.2025.
//

import SwiftUI

struct DetailsView: View {
    @StateObject var viewModel: DetailsViewModel

    var body: some View {
        Text(viewModel.text)
            .navigationTitle(Localization.detailsView)
    }
}
