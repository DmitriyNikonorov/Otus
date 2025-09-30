//
//  FaceTransformationView.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 23.09.2025.
//

import SwiftUI
import Vision

enum TransformationType: CaseIterable {
    case lips
    case leftEye
    case rightEye
    case nose

    var title: String {
        switch self {
        case .lips:
            return "Губы"

        case .leftEye:
            return "Левый глаз"

        case .rightEye:
            return "Правый глаз"

        case .nose:
            return "Нос"
        }
    }
}

final class FeatureModifyData: ObservableObject {
    @Published var lipsTransformValue: CGFloat = 0.0
    @Published var leftEyeTransformValue: CGFloat = 0.0
    @Published var rightEyeTransformValue: CGFloat = 0.0
    @Published var noseTransformValue: CGFloat = 0.0
}

struct FaceTransformationView: View {
    @State var originalImage: UIImage?
    @State var processedImage: UIImage?

    @State var previousTransformation: [TransformationType: CGFloat] = [:]

    @State var isRecognized = false
    @State var selectedType: TransformationType?

    @State var lipsPoints: [CGPoint] = []
    @State var leftEyePoints: [CGPoint] = []
    @State var rightEyePoints: [CGPoint] = []
    @State var nosePoints: [CGPoint] = []

    @ObservedObject var featureData = FeatureModifyData()

    var body: some View {
        VStack {
            Text("FaceTransformationView")
                .padding(.bottom, 24.0)
                .padding(.top, 16.0)
            Image(uiImage: processedImage ?? getImage())
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 300)
                .clipped()
                .padding(.bottom, 36.0)

            Button("Распознать лицо") {
                recognizeImage(cgImage: getImage().cgImage!)
            }
            if isRecognized {
                HStack(spacing: 12) {
                    ForEach(TransformationType.allCases, id: \.self) { type in
                        Button(action: {
                            selectedType = selectedType == type ? nil : type
                        }) {
                            Text(type.title)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(selectedType == type ? .white : .blue)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedType == type ? Color.blue : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.blue, lineWidth: 1)
                                )
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
                
                if let _ = selectedType {
                    FeatureSliderView(
                        type: $selectedType,
                        featureData: featureData,
                        applyCompletion: applyLipsTransformation
                    )
                }

            }
            Spacer()
        }
        .padding(.horizontal, 16.0)
        .onAppear {
            originalImage = getImage()
        }
    }

    func getImage() -> UIImage {
        if let imagePath = Bundle.main.path(forResource: "111", ofType: "jpg"),
           let image = UIImage(contentsOfFile: imagePath) {
            return image
        }

        return UIImage()
    }
}
