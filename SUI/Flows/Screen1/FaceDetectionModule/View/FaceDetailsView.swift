//
//  FaceDetailsView.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 21.09.2025.
//

import SwiftUI

struct FaceDetailsView: View {
    @ObservedObject var faceData: FaceData
    @Binding var isExpanded: Bool

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Анализ лица")
                    .font(.headline)
                Spacer()

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
            }
            .onTapGesture {
                isExpanded.toggle()
            }

            if isExpanded {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        DetailRow(title: "Положение головы Y", value: String(format: "%.2f", faceData.headYPosition))
                        DetailRow(title: "Положение головы X", value: String(format: "%.2f", faceData.headXPosition))

                        Text("Анализ черт лица")
                            .font(.headline)
                            .padding(.top, 8)

                        DetailRow(title: "Тип лица", value: faceData.faceType)
                        DetailRow(title: "Форма глаз", value: faceData.eyeShape)
                        DetailRow(title: "Тип носа", value: faceData.noseType)
                        DetailRow(title: "Форма губ", value: faceData.lipShape)
                        DetailRow(title: "Форма бровей", value: faceData.eyebrowShape)

                        Text("Выражения лица")
                            .font(.headline)
                            .padding(.top, 8)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Улыбка: \(Int(faceData.smileValue * 100))%")
                                .font(.caption)
                            ProgressView(value: Double(faceData.smileValue))
                                .tint(.green)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Моргание: \(Int(faceData.eyeBlinkValue * 100))%")
                                .font(.caption)
                            ProgressView(value: Double(faceData.eyeBlinkValue))
                                .tint(.blue)
                        }
                    }
                }
                .frame(maxHeight: 300.0)
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
                .scrollIndicators(ScrollIndicatorVisibility.hidden)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(15.0)
    }
}
