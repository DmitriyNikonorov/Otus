//
//  FaceTransformationView+transformation.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 24.09.2025.
//

import SwiftUI
import Vision

extension FaceTransformationView {
    func applyLipsTransformation(_ type: TransformationType?) {
        guard
            let type,
            let originalImage = originalImage,
            let ciImage = CIImage(image: originalImage)
        else {
            return
        }

        var resultImage = ciImage

        for (savedType, factor) in previousTransformation {
            if savedType != type {
                switch savedType {
                case .lips:
                    resultImage = applyBumpDistortion(from: type, to: resultImage, points: lipsPoints, factor: factor)

                case .leftEye:
                    resultImage = applyBumpDistortion(from: type, to: resultImage, points: leftEyePoints, factor: factor)

                case .rightEye:
                    resultImage = applyBumpDistortion(from: type, to: resultImage, points: rightEyePoints, factor: factor)

                case .nose:
                    resultImage = applyBumpDistortion(from: type, to: resultImage, points: nosePoints, factor: factor)
                }
            }
        }

        switch type {
        case .lips:
            resultImage = applyBumpDistortion(from: type, to: resultImage, points: lipsPoints, factor: featureData.lipsTransformValue)
            previousTransformation[type] = featureData.lipsTransformValue

        case .leftEye:
            resultImage = applyBumpDistortion(from: type, to: resultImage, points: leftEyePoints, factor: featureData.leftEyeTransformValue)
            previousTransformation[type] = featureData.leftEyeTransformValue

        case .rightEye:
            resultImage = applyBumpDistortion(from: type, to: resultImage, points: rightEyePoints, factor: featureData.rightEyeTransformValue)
            previousTransformation[type] = featureData.rightEyeTransformValue


        case .nose:
            resultImage = applyBumpDistortion(from: type, to: resultImage, points: nosePoints, factor: featureData.noseTransformValue)
            previousTransformation[type] = featureData.noseTransformValue
        }



        let context = CIContext()
        if let cgImage = context.createCGImage(resultImage, from: resultImage.extent) {
            processedImage = UIImage(cgImage: cgImage)
        }
    }

    func applyBumpDistortion(from type: TransformationType, to image: CIImage, points: [CGPoint], factor: CGFloat) -> CIImage {
        guard points.count >= 2 else { return image }

        let centerX = points.map { $0.x }.reduce(0, +) / CGFloat(points.count)
        let centerY = points.map { $0.y }.reduce(0, +) / CGFloat(points.count)
        let center = CGPoint(x: centerX, y: centerY)

        let width = calculateWidth(points)
        let radius = width * 0.6

        guard let filter = CIFilter(name: "CIBumpDistortion") else {
            return image
        }

        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
        filter.setValue(radius, forKey: kCIInputRadiusKey)
        filter.setValue(factor * 0.5, forKey: kCIInputScaleKey)

        return filter.outputImage ?? image
    }

    func calculateWidth(_ points: [CGPoint]) -> CGFloat {
        guard !points.isEmpty else {
            return 50.0
        }

        let minX = points.min(by: { $0.x < $1.x })?.x ?? 0
        let maxX = points.max(by: { $0.x < $1.x })?.x ?? 0
        return maxX - minX
    }
}
