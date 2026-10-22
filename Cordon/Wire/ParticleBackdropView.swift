import RealityKit
import SwiftUI
import UIKit

/// RealityKit particle field. Only the home hero uses it.
struct ParticleBackdropView: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let view = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        view.cameraMode = .nonAR
        view.automaticallyConfigureSession = false
        view.environment.background = .color(UIColor(CanopyColor.background))
        view.isUserInteractionEnabled = false
        let anchor = AnchorEntity(world: SIMD3<Float>(0, 0, 0))
        let host = Entity()
        host.position = SIMD3<Float>(0, 0, 0)
        if #available(iOS 18.0, *) {
            var particles = ParticleEmitterComponent.Presets.sparks
            particles.emitterShape = .box
            particles.emitterShapeSize = SIMD3<Float>(0.42, 0.7, 0.04)
            particles.speed = 0.015
            particles.mainEmitter.birthRate = 10
            particles.mainEmitter.size = 0.004
            particles.mainEmitter.lifeSpan = 3.2
            particles.isEmitting = true
            particles.simulationState = .play
            host.components.set(particles)
        } else {
            let mesh = MeshResource.generateSphere(radius: 0.008)
            let material = SimpleMaterial(color: UIColor(CanopyColor.accent), isMetallic: false)
            for index in 0..<12 {
                let dot = ModelEntity(mesh: mesh, materials: [material])
                let column = Float(index % 4) - 1.5
                let row = Float(index / 4) - 1
                dot.position = SIMD3<Float>(column * 0.08, row * 0.12, 0)
                host.addChild(dot)
            }
        }
        anchor.addChild(host)
        view.scene.addAnchor(anchor)
        return view
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}
