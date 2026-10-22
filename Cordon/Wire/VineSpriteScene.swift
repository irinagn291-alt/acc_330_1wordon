import SpriteKit
import SwiftUI
import UIKit

/// Procedural vine for the home hero. Height follows committed progress, never the tray.
final class VineSpriteScene: SKScene {
    private let stem = SKShapeNode()
    private let wireLayer = SKNode()
    private var drawnShape = VineShape(lean: 0, forks: 1, twist: 0)
    private var drawnProgress: CGFloat = -1

    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = .clear
        scaleMode = .resizeFill
        stem.lineCap = .round
        stem.lineJoin = .round
        stem.lineWidth = CanopyMetrics.vineStroke
        stem.strokeColor = UIColor(CanopyColor.accent)
        stem.fillColor = .clear
        addChild(wireLayer)
        addChild(stem)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    func render(shape: VineShape, progress: CGFloat) {
        let clamped = min(max(progress, 0), 1)
        guard size.width > 1, size.height > 1 else { return }
        if drawnProgress == clamped, drawnShape == shape, stem.path != nil { return }
        drawnProgress = clamped
        drawnShape = shape
        stem.path = vinePath(shape: shape, progress: clamped)
        redrawWires(progress: clamped)
    }

    private func redrawWires(progress: CGFloat) {
        wireLayer.removeAllChildren()
        let thresholds: [CGFloat] = [0.25, 0.5, 0.75, 1]
        for threshold in thresholds {
            let y = wireY(for: threshold)
            let path = CGMutablePath()
            path.move(to: CGPoint(x: size.width * 0.12, y: y))
            path.addLine(to: CGPoint(x: size.width * 0.88, y: y))
            let line = SKShapeNode(path: path)
            line.lineWidth = CanopyMetrics.hairline
            let lit = progress + 0.0001 >= threshold
            line.strokeColor = lit ? UIColor(CanopyColor.accent) : UIColor(CanopyColor.muted)
            wireLayer.addChild(line)
        }
    }

    private func wireY(for threshold: CGFloat) -> CGFloat {
        let top = size.height * 0.12
        let bottom = size.height * 0.9
        return bottom - (bottom - top) * threshold
    }

    private func vinePath(shape: VineShape, progress: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let grown = max(progress, 0.06)
        let base = CGPoint(x: size.width * 0.5, y: size.height * 0.9)
        let tipY = wireY(for: grown)
        let lean = CGFloat(shape.lean) * size.width * 0.16
        let control = CGPoint(
            x: base.x + lean * CGFloat(0.35 + shape.twist * 0.4),
            y: (base.y + tipY) * 0.5
        )
        let tip = CGPoint(x: base.x + lean, y: tipY)
        path.move(to: base)
        path.addQuadCurve(to: tip, control: control)
        let forks = max(shape.forks, 1)
        for index in 0..<forks {
            let t = CGFloat(index + 1) / CGFloat(forks + 1)
            let origin = quadPoint(base: base, control: control, tip: tip, t: t * grown / max(grown, 0.01))
            let direction: CGFloat = index.isMultiple(of: 2) ? 1 : -1
            let length = size.width * (0.08 + CGFloat(shape.twist) * 0.06)
            let end = CGPoint(x: origin.x + direction * length, y: origin.y + size.height * 0.03)
            path.move(to: origin)
            path.addLine(to: end)
        }
        return path
    }

    private func quadPoint(base: CGPoint, control: CGPoint, tip: CGPoint, t: CGFloat) -> CGPoint {
        let clamped = min(max(t, 0), 1)
        let one = 1 - clamped
        let x = one * one * base.x + 2 * one * clamped * control.x + clamped * clamped * tip.x
        let y = one * one * base.y + 2 * one * clamped * control.y + clamped * clamped * tip.y
        return CGPoint(x: x, y: y)
    }
}

/// SpriteKit host. Confined to the home hero with the particle field.
struct VineCanvasHost: UIViewRepresentable {
    var shape: VineShape
    var progress: Double

    func makeUIView(context: Context) -> VineSKView {
        let view = VineSKView()
        view.allowsTransparency = true
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        let scene = VineSpriteScene(size: CGSize(width: 320, height: 280))
        scene.scaleMode = .resizeFill
        view.presentScene(scene)
        view.onLayout = { size in
            guard size.width > 1, size.height > 1 else { return }
            scene.size = size
            scene.render(shape: shape, progress: CGFloat(progress))
        }
        return view
    }

    func updateUIView(_ view: VineSKView, context: Context) {
        guard let scene = view.scene as? VineSpriteScene else { return }
        if view.bounds.width > 1 {
            scene.size = view.bounds.size
        }
        scene.render(shape: shape, progress: CGFloat(progress))
        view.onLayout = { size in
            guard size.width > 1, size.height > 1 else { return }
            scene.size = size
            scene.render(shape: shape, progress: CGFloat(progress))
        }
    }
}

final class VineSKView: SKView {
    var onLayout: ((CGSize) -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()
        onLayout?(bounds.size)
    }
}
