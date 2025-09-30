//
//  ARCameraView.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 21.09.2025.
//

import SwiftUI
import ARKit
import RealityKit

struct ARCameraView: View {
    @State private var isFaceDetected = false
    @State private var faceAnchor: ARFaceAnchor?
    @State private var showDetails = false
    @StateObject private var faceData = FaceData()

    enum FaceFeature: String, CaseIterable {
        case eyes = "Глаза"
        case nose = "Нос"
        case lips = "Губы"
        case eyebrows = "Брови"
    }

    var body: some View {
        ZStack {
            ARFaceDetectionView(
                isFaceDetected: $isFaceDetected,
                faceAnchor: $faceAnchor,
                faceData: faceData
            )
            .edgesIgnoringSafeArea(.all)

            // Интерфейс поверх AR
            VStack {
                HeaderView(isFaceDetected: isFaceDetected)

                if isFaceDetected {
                    FaceDetailsView(
                        faceData: faceData,
                        isExpanded: $showDetails
                    )
                } else {
                    NoFaceDetectedView()
                }

                Spacer()
            }
            .padding()
        }
    }
}

struct ARFaceDetectionView: UIViewRepresentable {
    @Binding var isFaceDetected: Bool
    @Binding var faceAnchor: ARFaceAnchor?
    var faceData: FaceData

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        arView.session.delegate = context.coordinator
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.updateFaceFrame(isDetected: isFaceDetected, in: uiView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

// MARK: - Coordinator

final class Coordinator: NSObject, ARSessionDelegate {
    var parent: ARFaceDetectionView
    private var faceFrame: Entity?
    private var faceData: FaceData { parent.faceData }
    private var faceEntities: [String: Entity] = [:]

    init(_ parent: ARFaceDetectionView) {
        self.parent = parent
    }

    // MARK: - ARSessionDelegate

    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.first as? ARFaceAnchor else { return }
        parent.faceAnchor = faceAnchor
        faceData.update(with: faceAnchor)
        parent.isFaceDetected = true
    }

    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.first as? ARFaceAnchor else { return }
        parent.faceAnchor = faceAnchor
        faceData.update(with: faceAnchor)
        parent.isFaceDetected = true

        DispatchQueue.main.async {
            self.faceData.headYPosition = faceAnchor.transform.columns.3.y
            self.faceData.headXPosition = faceAnchor.transform.columns.3.x
            let blendShapes = faceAnchor.blendShapes
            self.faceData.smileValue = blendShapes[.mouthSmileLeft]?.floatValue ?? 0
            self.faceData.eyeBlinkValue = blendShapes[.eyeBlinkLeft]?.floatValue ?? 0
        }
    }

    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        if anchors.contains(where: { $0 is ARFaceAnchor }) {
            parent.isFaceDetected = false
            parent.faceAnchor = nil
        }
    }

    // MARK: - Face Frame Management

    func updateFaceFrame(isDetected: Bool, in arView: ARView) {
        if isDetected {
            addFaceFrame(to: arView)
        } else {
            removeFaceFrame(from: arView)
        }
    }

    private func addFaceFrame(to arView: ARView) {
        removeFaceFrame(from: arView)
        let frameEntity = createFaceFrame()

        let faceAnchor = AnchorEntity(.face)
        faceAnchor.addChild(frameEntity)

        arView.scene.addAnchor(faceAnchor)
        self.faceFrame = frameEntity
    }

    private func removeFaceFrame(from arView: ARView) {
        guard let faceFrame = faceFrame else {
            return
        }

        if let anchor = faceFrame.anchor {
            arView.scene.removeAnchor(anchor)
        }

        self.faceFrame = nil
    }

    private func createFaceFrame() -> Entity {
        let parentEntity = Entity()

        // Глаза
        let leftEye = createEye(position: SIMD3<Float>(x: -0.033, y: 0.02, z: 0.03))
        let rightEye = createEye(position: SIMD3<Float>(x: 0.033, y: 0.02, z: 0.03))
        parentEntity.addChild(leftEye)
        parentEntity.addChild(rightEye)
        faceEntities["leftEye"] = leftEye
        faceEntities["rightEye"] = rightEye

        // Нос
        let nose = createNose()
        parentEntity.addChild(nose)
        faceEntities["nose"] = nose

        // Губы
        let lips = createLips()
        parentEntity.addChild(lips)
        faceEntities["lips"] = lips

        // Брови
        let leftEyebrow = createEyebrow(position: SIMD3<Float>(x: -0.03, y: 0.045, z: 0.05))
        let rightEyebrow = createEyebrow(position: SIMD3<Float>(x: 0.03, y: 0.045, z: 0.05))
        parentEntity.addChild(leftEyebrow)
        parentEntity.addChild(rightEyebrow)
        faceEntities["leftEyebrow"] = leftEyebrow
        faceEntities["rightEyebrow"] = rightEyebrow

        return parentEntity
    }
}

private extension Coordinator {
    func createEye(position: SIMD3<Float>) -> ModelEntity {
        let material = SimpleMaterial(color: .blue, roughness: 0.1, isMetallic: false)
        let mesh = MeshResource.generateSphere(radius: 0.02)
        let eye = ModelEntity(mesh: mesh, materials: [material])
        eye.position = position
        return eye
    }

    func createNose() -> ModelEntity {
        let material = SimpleMaterial(color: .orange, roughness: 0.2, isMetallic: false)
        let mesh = MeshResource.generateCone(height: 0.05, radius: 0.03)
        let nose = ModelEntity(mesh: mesh, materials: [material])
        nose.position = SIMD3<Float>(x: 0, y: 0.01, z: 0.06)
        return nose
    }

    func createLips() -> ModelEntity {
        let material = SimpleMaterial(color: .red, roughness: 0.1, isMetallic: false)
        let mesh = MeshResource.generateBox(size: [0.04, 0.010, 0.010], cornerRadius: 0.002)
        let lips = ModelEntity(mesh: mesh, materials: [material])
        lips.position = SIMD3<Float>(x: 0, y: -0.035, z: 0.06)
        return lips
    }

    func createEyebrow(position: SIMD3<Float>) -> ModelEntity {
        let material = SimpleMaterial(color: .black, roughness: 0.1, isMetallic: true)
        let mesh = MeshResource.generateBox(size: [0.04, 0.010, 0.010], cornerRadius: 0.001)
        let eyebrow = ModelEntity(mesh: mesh, materials: [material])
        eyebrow.position = position
        return eyebrow
    }
}

// MARK: - Для теста
private extension Coordinator {
    func createFaceFrameWall() -> Entity {
        let material = SimpleMaterial(
            color: .green,
            roughness: 0.1,
            isMetallic: false
        )
        let mesh = MeshResource.generateBox(
            size: [0.15, 0.2, 0.01],
            cornerRadius: 0.500
        )
        let frameEntity = ModelEntity(
            mesh: mesh,
            materials: [material]
        )
        frameEntity.position = SIMD3<Float>(x: 0, y: 0, z: 0.1)
        frameEntity.model?.materials = [createTranslucentMaterial()]
        return frameEntity
    }

    func createTranslucentMaterial() -> SimpleMaterial {
        var material = SimpleMaterial()
        material.color = .init(
            tint: .green.withAlphaComponent(0.3),
            texture: nil
        )
        material.roughness = 0.1
        material.metallic = 0.0
        return material
    }
}
