//
//  FeatureSliderView.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 25.09.2025.
//

import SwiftUI

struct FeatureSliderView: View {
    @Binding var type: TransformationType?
    @ObservedObject var featureData: FeatureModifyData
    var applyCompletion: (TransformationType?) -> Void
    let textRecognitionWorkQueue = DispatchQueue(label: "TextRecognitionQueue", qos: .userInteractive, attributes: [], autoreleaseFrequency: .workItem)

    var body: some View {
        if let type {
            VStack(spacing: 8) {
                Text("Размер \(type.title.lowercased())")
                    .font(.headline)
                    .foregroundColor(.white)

                Slider(value: bindingForFeature(type), in: -2.0...2.0, step: 0.1)
                    .accentColor(.blue)
                    .padding(.horizontal)
                    .onChange(of: bindingForFeature(type).wrappedValue) { _ in
                        textRecognitionWorkQueue.async {
                            applyCompletion(type)
                        }
                    }

                Text("\(bindingForFeature(type).wrappedValue, specifier: "%.1f")x")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.black.opacity(0.7))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }

    private func bindingForFeature(_ type: TransformationType) -> Binding<Double> {
        switch type {
        case .lips:
            return Binding(
                get: { featureData.lipsTransformValue },
                set: { featureData.lipsTransformValue = CGFloat($0) }
            )

        case .nose:
            return Binding(
                get: { featureData.noseTransformValue },
                set: { featureData.noseTransformValue = CGFloat($0) }
            )
        case .leftEye:
            return Binding(
                get: { featureData.leftEyeTransformValue },
                set: { featureData.leftEyeTransformValue = CGFloat($0) }
            )

        case .rightEye:
            return Binding(
                get: { featureData.rightEyeTransformValue },
                set: { featureData.rightEyeTransformValue = CGFloat($0) }
            )
        }
    }
}
