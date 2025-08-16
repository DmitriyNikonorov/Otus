//
//  WorkerView.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 15.08.2025.
//

import SwiftUI

struct WorkerView: View {
    @State var job: Job

    var body: some View {
        VStack {
                ScrollView(.horizontal) {
                    HStack(spacing: 8.0) {
                        switch job.state {
                        case .inQueue, .cooking, .inDelivery:
                            Text("\(job.state.description)")
                            ProgressView()

                        case .delivered:
                            Text(job.state.description)
                        }
                    }
                }
                .scrollIndicators(.never)
        }
    }
}
