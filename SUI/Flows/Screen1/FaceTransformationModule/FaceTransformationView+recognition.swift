//
//  FaceTransformationView+recognition.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 24.09.2025.
//

import SwiftUI
import Vision

extension FaceTransformationView {
    func recognizeImage(cgImage: CGImage) {
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try requestHandler.perform([createDetectFaceRequest()])
        } catch {
            print(error)
        }
    }

    func createDetectFaceRequest() -> VNDetectFaceLandmarksRequest {
        let request = VNDetectFaceLandmarksRequest { request, error in
            let inputImage = getImage()

            if let error = error {
                print("Ошибка распознавания: \(error)")
                return
            }

            guard let results = request.results as? [VNFaceObservation] else {
                print("Лица не найдены")
                return
            }

            if let faceObservation = results.first {
                isRecognized = true
                saveFaceLandmarks(faceObservation, imageSize: inputImage.size)
            } else {
                isRecognized = false
            }
        }

        return request
    }

    func saveFaceLandmarks(_ face: VNFaceObservation, imageSize: CGSize) {
        let rect = VNImageRectForNormalizedRect(face.boundingBox,Int(imageSize.width), Int(imageSize.height))
        if let lips = face.landmarks?.outerLips {
            lipsPoints = convertNormalizedPoints(lips.normalizedPoints, to: rect)
        }

        if let leftEye = face.landmarks?.leftEye {
            leftEyePoints = convertNormalizedPoints(leftEye.normalizedPoints, to: rect)
        }

        if let rightEye = face.landmarks?.rightEye {
            rightEyePoints = convertNormalizedPoints(rightEye.normalizedPoints, to: rect)
        }

        if let nose = face.landmarks?.nose {
            nosePoints = convertNormalizedPoints(nose.normalizedPoints, to: rect)
        }
    }

    func convertNormalizedPoints(_ points: [CGPoint], to rect: CGRect) -> [CGPoint] {
        return points.map { point in
            CGPoint(
                x: rect.origin.x + CGFloat(point.x) * rect.width,
                y: rect.origin.y + CGFloat(point.y) * rect.height
            )
        }
    }
}
