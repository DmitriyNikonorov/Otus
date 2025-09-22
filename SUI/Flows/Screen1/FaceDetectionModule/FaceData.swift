//
//  FaceData.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 21.09.2025.
//

import Foundation
import ARKit
import Combine

final class FaceData: ObservableObject {
    @Published var headYPosition: Float = 0
    @Published var headXPosition: Float = 0
    @Published var smileValue: Float = 0
    @Published var eyeBlinkValue: Float = 0
    @Published var isFaceDetected: Bool = false

    @Published var faceType: String = "Не определен"
    @Published var eyeShape: String = "Не определен"
    @Published var noseType: String = "Не определен"
    @Published var lipShape: String = "Не определен"
    @Published var eyebrowShape: String = "Не определен"

    @Published var faceOvalScale: Float = 1.0
    @Published var eyeScale: Float = 0.02
    @Published var noseScale: Float = 1.0
    @Published var lipScale: Float = 1.0
    @Published var eyebrowScale: Float = 1.0

    func update(with faceAnchor: ARFaceAnchor?) {
        DispatchQueue.main.async {
            guard let anchor = faceAnchor else {
                self.isFaceDetected = false
                return
            }

            self.isFaceDetected = true
            self.headYPosition = anchor.transform.columns.3.y
            self.headXPosition = anchor.transform.columns.3.x
            let blendShapes = anchor.blendShapes
            self.smileValue = blendShapes[.mouthSmileLeft]?.floatValue ?? 0
            self.eyeBlinkValue = blendShapes[.eyeBlinkLeft]?.floatValue ?? 0
            self.analyzeFacialFeatures(blendShapes: blendShapes, geometry: anchor.geometry)

        }
    }

    private func analyzeFacialFeatures(blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber], geometry: ARFaceGeometry) {
        // Анализ типа лица
        analyzeFaceType(geometry: geometry)

        // Анализ формы глаз
        analyzeEyeShape(blendShapes: blendShapes)

        // Анализ типа носа
        analyzeNoseType(geometry: geometry)

        // Анализ формы губ
        analyzeLipShape(blendShapes: blendShapes)

        // Анализ формы бровей
        analyzeEyebrowShape(blendShapes: blendShapes)
    }

    private func analyzeFaceType(geometry: ARFaceGeometry) {
        guard let faceWidthMax = geometry.vertices.max(by: { $0.x < $1.x })?.x else { return }


        let faceWidth = (geometry.vertices.max(by: { $0.x < $1.x })?.x ?? 0) - (geometry.vertices.min(by: { $0.x < $1.x })?.x ?? 0)
        let faceHeight = (geometry.vertices.max(by: { $0.y < $1.y })?.y ?? 0) - (geometry.vertices.min(by: { $0.y < $1.y })?.y ?? 0)

        let ratio = faceWidth / faceHeight

        if ratio > 0.85 {
            faceType = "Круглое"
            faceOvalScale = 0.95
        } else if ratio > 0.75 {
            faceType = "Овальное"
            faceOvalScale = 1.0
        } else if ratio > 0.65 {
            faceType = "Квадратное"
            faceOvalScale = 1.05
        } else {
            faceType = "Продолговатое"
            faceOvalScale = 0.9
        }
    }

    private func analyzeEyeShape(blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber]) {
        let eyeOpenLeft = blendShapes[.eyeBlinkLeft]?.floatValue ?? 0
        let eyeOpenRight = blendShapes[.eyeBlinkRight]?.floatValue ?? 0
        let eyeAverage = (eyeOpenLeft + eyeOpenRight) / 2

        if eyeAverage < 0.1 {
            eyeShape = "Широко открытые"
            eyeScale = 1.1
        } else if eyeAverage < 0.3 {
            eyeShape = "Миндалевидные"
            eyeScale = 1.0
        } else {
            eyeShape = "Узкие"
            eyeScale = 0.9
        }
    }

    private func analyzeNoseType(geometry: ARFaceGeometry) {
        let noseWidth = abs(geometry.vertices[10].x - geometry.vertices[11].x)

        if noseWidth > 0.03 {
            noseType = "Широкий"
            noseScale = 0.9
        } else if noseWidth > 0.02 {
            noseType = "Средний"
            noseScale = 1.0
        } else {
            noseType = "Узкий"
            noseScale = 1.1
        }
    }

    private func analyzeLipShape(blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber]) {
        let smileLeft = blendShapes[.mouthSmileLeft]?.floatValue ?? 0
        let smileRight = blendShapes[.mouthSmileRight]?.floatValue ?? 0
        let smileAverage = (smileLeft + smileRight) / 2

        if smileAverage > 0.5 {
            lipShape = "Пухлые"
            lipScale = 1.2
        } else if smileAverage > 0.2 {
            lipShape = "Средние"
            lipScale = 1.0
        } else {
            lipShape = "Тонкие"
            lipScale = 0.8
        }
    }

    private func analyzeEyebrowShape(blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber]) {
        let browInnerUp = blendShapes[.browInnerUp]?.floatValue ?? 0
        let browOuterUp = blendShapes[.browOuterUpLeft]?.floatValue ?? 0

        if browInnerUp > 0.3 {
            eyebrowShape = "Приподнятые"
            eyebrowScale = 1.1
        } else if browOuterUp > 0.2 {
            eyebrowShape = "Изогнутые"
            eyebrowScale = 1.0
        } else {
            eyebrowShape = "Прямые"
            eyebrowScale = 0.9
        }
    }
}
