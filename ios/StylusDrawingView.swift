//
//  StylusDrawingView.swift
//  munim-pencilkit
//
//  A custom UIKit drawing view that handles Apple Pencil (stylus) input
//  without using PencilKit. It renders incrementally into a bitmap for
//  performance and uses coalesced touches for smoother strokes.
//

import UIKit

@objc protocol StylusDrawingViewDelegate: AnyObject {
    func stylusViewDidToggleEraser(_ view: StylusDrawingView, isOn: Bool)
    func stylusViewDidStartDrawing(_ view: StylusDrawingView)
    func stylusViewDidEndDrawing(_ view: StylusDrawingView)
}

@objc class StylusDrawingView: UIView, UIPencilInteractionDelegate {
    // Public configuration
    @objc var allowsFingerDrawing: Bool = false
    @objc var strokeColor: UIColor = .label
    @objc var baseLineWidth: CGFloat = 4.0
    @objc var showHoverPreview: Bool = true

    // Backing store for incremental rendering
    private let renderImageView = UIImageView()

    // State per active stroke
    private var lastPointByTouch: [UITouch: CGPoint] = [:]
    private var strokePaths: [UITouch: UIBezierPath] = [:]
    private var strokePoints: [UITouch: [CGPoint]] = [:]
    private var strokePressures: [UITouch: [CGFloat]] = [:]

    // Hover preview
    private let hoverPreviewLayer = CAShapeLayer()
    private var hoverGesture: UIHoverGestureRecognizer?

    // Tool state
    private var isEraserEnabled: Bool = false
    @objc weak var delegate: StylusDrawingViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        isMultipleTouchEnabled = true
        backgroundColor = .systemBackground
        renderImageView.contentMode = .center
        renderImageView.isOpaque = true
        addSubview(renderImageView)

        // Hover preview layer
        hoverPreviewLayer.fillColor = UIColor.clear.cgColor
        hoverPreviewLayer.strokeColor = UIColor.systemBlue.withAlphaComponent(0.6).cgColor
        hoverPreviewLayer.lineWidth = 1.0
        hoverPreviewLayer.isHidden = true
        layer.addSublayer(hoverPreviewLayer)

        // Hover support (available on iPad with Pencil hover)
        let hg = UIHoverGestureRecognizer(target: self, action: #selector(handleHover(_:)))
        addGestureRecognizer(hg)
        hoverGesture = hg

        // Pencil interaction (tap)
        let pencil = UIPencilInteraction()
        pencil.delegate = self
        addInteraction(pencil)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        renderImageView.frame = bounds
        // Initialize image if needed
        if renderImageView.image == nil && bounds.width > 0 && bounds.height > 0 {
            renderImageView.image = emptyImage(size: bounds.size)
        }
    }

    @objc func clearCanvas() {
        renderImageView.image = emptyImage(size: bounds.size)
        strokePaths.removeAll()
        strokePoints.removeAll()
        strokePressures.removeAll()
        lastPointByTouch.removeAll()
        setNeedsDisplay()
    }

    @objc func setCanvasImage(_ image: UIImage?) {
        if let image = image {
            // Ensure the image is set with proper scaling to match the view bounds
            if bounds.size != .zero && bounds.size != image.size {
                // Create a properly sized image that matches the view bounds
                let format = UIGraphicsImageRendererFormat.default()
                format.scale = UIScreen.main.scale
                format.opaque = true
                let renderer = UIGraphicsImageRenderer(size: bounds.size, format: format)
                let scaledImage = renderer.image { _ in
                    image.draw(in: CGRect(origin: .zero, size: bounds.size))
                }
                renderImageView.image = scaledImage
            } else {
                renderImageView.image = image
            }
        } else if bounds.size != .zero {
            renderImageView.image = emptyImage(size: bounds.size)
        }
        setNeedsDisplay()
    }

    @objc func snapshotImage() -> UIImage? {
        return renderImageView.image
    }

    @objc func setEraserEnabled(_ enabled: Bool) {
        isEraserEnabled = enabled
        if isEraserEnabled {
            hoverPreviewLayer.strokeColor = UIColor.systemRed.withAlphaComponent(0.7).cgColor
        } else {
            hoverPreviewLayer.strokeColor = UIColor.systemBlue.withAlphaComponent(0.6).cgColor
        }
    }

    private func emptyImage(size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = UIScreen.main.scale
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { ctx in
            (backgroundColor ?? .white).setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let image = renderImageView.image else { return }
        for touch in touches {
            if shouldAccept(touch: touch) == false { continue }
            let point = touch.preciseLocation(in: self)
            lastPointByTouch[touch] = point
            
            // Initialize stroke path and points
            let path = UIBezierPath()
            path.move(to: point)
            strokePaths[touch] = path
            strokePoints[touch] = [point]
            strokePressures[touch] = [normalizedForce(for: touch)]
            
            // Notify delegate that drawing started
            delegate?.stylusViewDidStartDrawing(self)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let image = renderImageView.image else { return }
        for touch in touches {
            if shouldAccept(touch: touch) == false { continue }

            // Use coalesced touches for smoother strokes
            let samples = (event?.coalescedTouches(for: touch) ?? [touch])
            for sample in samples {
                let current = sample.preciseLocation(in: self)
                
                // Add point to stroke path
                if var path = strokePaths[touch], var points = strokePoints[touch], var pressures = strokePressures[touch] {
                    path.addLine(to: current)
                    points.append(current)
                    pressures.append(normalizedForce(for: sample))
                    strokePaths[touch] = path
                    strokePoints[touch] = points
                    strokePressures[touch] = pressures
                }
                
                lastPointByTouch[touch] = current
            }
            
            // Render the entire stroke with pressure-sensitive segments
            renderStrokeWithPressure(for: touch, on: image)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        endTouches(touches)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        endTouches(touches)
    }

    private func endTouches(_ touches: Set<UITouch>) {
        for touch in touches {
            lastPointByTouch.removeValue(forKey: touch)
            strokePaths.removeValue(forKey: touch)
            strokePoints.removeValue(forKey: touch)
            strokePressures.removeValue(forKey: touch)
        }
        // Notify delegate that drawing ended
        delegate?.stylusViewDidEndDrawing(self)
    }

    private func shouldAccept(touch: UITouch) -> Bool {
        if allowsFingerDrawing { return true }
        if #available(iOS 12.1, *) {
            return touch.type == .stylus
        } else {
            return true
        }
    }

    // MARK: - Rendering

    private func renderStrokeWithPressure(for touch: UITouch, on image: UIImage) {
        guard bounds.width > 0, bounds.height > 0 else { return }
        guard let points = strokePoints[touch], let pressures = strokePressures[touch], points.count > 1 else { return }

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = UIScreen.main.scale
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: bounds.size, format: format)

        let color = isEraserEnabled ? backgroundColor ?? .white : strokeColor

        let updated = renderer.image { ctx in
            image.draw(at: .zero)

            // Draw the stroke with pressure-sensitive segments
            for i in 1..<points.count {
                let from = points[i-1]
                let to = points[i]
                
                // Use the pressure stored for this point
                let force = pressures[i]
                let tiltFactor = tiltWidthFactor(for: touch)
                let width = max(2.0, baseLineWidth * (0.5 + force) * tiltFactor)
                
                let path = UIBezierPath()
                path.move(to: from)
                path.addLine(to: to)
                path.lineCapStyle = .round
                path.lineJoinStyle = .round
                path.lineWidth = width

                color.setStroke()
                path.stroke()
            }
        }

        renderImageView.image = updated
    }

    private func normalizedForce(for touch: UITouch) -> CGFloat {
        guard touch.maximumPossibleForce > 0 else { return 1.0 }
        let value = touch.force / touch.maximumPossibleForce
        return min(max(value, 0.0), 1.0)
    }

    private func tiltWidthFactor(for touch: UITouch) -> CGFloat {
        // Increase width when the pencil is tilted (lower altitude)
        // altitudeAngle ranges roughly 0 (parallel) to ~pi/2 (perpendicular)
        let altitude = touch.altitudeAngle
        let perpendicularity = max(0.0, min(1.0, altitude / (.pi / 2.0)))
        // When perpendicularity is low (tilted), allow up to 1.8x width
        return 1.0 + (1.8 - 1.0) * (1.0 - perpendicularity)
    }
}

// MARK: - Hover Handling

extension StylusDrawingView {
    @objc private func handleHover(_ recognizer: UIHoverGestureRecognizer) {
        let location = recognizer.location(in: self)
        switch recognizer.state {
        case .began, .changed:
            updateHoverPreview(at: location)
            hoverPreviewLayer.isHidden = !showHoverPreview
        case .ended, .cancelled, .failed:
            hoverPreviewLayer.isHidden = true
        default:
            break
        }
    }

    private func updateHoverPreview(at location: CGPoint) {
        guard showHoverPreview else { return }
        // Use base width as preview size; could incorporate tilt/force when available via hover pose in future
        let previewDiameter = max(4.0, baseLineWidth * 2.0)
        let rect = CGRect(x: location.x - previewDiameter * 0.5,
                          y: location.y - previewDiameter * 0.5,
                          width: previewDiameter,
                          height: previewDiameter)
        let path = UIBezierPath(ovalIn: rect)
        hoverPreviewLayer.path = path.cgPath
    }
}

// MARK: - UIPencilInteractionDelegate

extension StylusDrawingView {
    func pencilInteractionDidTap(_ interaction: UIPencilInteraction) {
        // Toggle eraser on pencil tap
        isEraserEnabled.toggle()
        setEraserEnabled(isEraserEnabled)
        delegate?.stylusViewDidToggleEraser(self, isOn: isEraserEnabled)
    }
}
