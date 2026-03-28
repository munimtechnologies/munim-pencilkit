import UIKit

@objc protocol StylusDrawingViewDelegate: AnyObject {
  func stylusViewDidToggleEraser(_ view: StylusDrawingView, isOn: Bool)
  func stylusViewDidStartDrawing(_ view: StylusDrawingView)
  func stylusViewDidEndDrawing(_ view: StylusDrawingView)
  func stylusView(
    _ view: StylusDrawingView,
    didCollectCoalescedTouches touches: [UITouch],
    timestamp: TimeInterval
  )
  func stylusViewDidHover(
    _ view: StylusDrawingView,
    location: CGPoint,
    altitude: CGFloat,
    azimuth: CGFloat,
    azimuthUnitVector: CGVector,
    zOffset: CGFloat,
    rollAngle: CGFloat
  )
}

@objc final class StylusDrawingView: UIView, UIPencilInteractionDelegate {
  @objc var allowsFingerDrawing: Bool = false
  @objc var strokeColor: UIColor = .label
  @objc var baseLineWidth: CGFloat = 4.0
  @objc var showHoverPreview: Bool = true
  @objc var renderMode: String = "incremental"
  @objc var eraserMode: String = "clear"
  @objc var opaqueCanvas: Bool = false {
    didSet { applyCanvasCompositingMode() }
  }
  @objc var surfaceColor: UIColor = .systemBackground {
    didSet { applyCanvasCompositingMode() }
  }
  @objc weak var delegate: StylusDrawingViewDelegate?

  private let renderImageView = UIImageView()
  private var lastPointByTouch: [UITouch: CGPoint] = [:]
  private var strokePaths: [UITouch: UIBezierPath] = [:]
  private var strokePoints: [UITouch: [CGPoint]] = [:]
  private var strokePressures: [UITouch: [CGFloat]] = [:]
  private let hoverPreviewLayer = CAShapeLayer()
  private var isEraserEnabled: Bool = false

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
    backgroundColor = surfaceColor

    renderImageView.contentMode = .center
    renderImageView.isOpaque = true
    renderImageView.backgroundColor = surfaceColor
    addSubview(renderImageView)

    hoverPreviewLayer.fillColor = UIColor.clear.cgColor
    hoverPreviewLayer.strokeColor = UIColor.systemBlue.withAlphaComponent(0.6).cgColor
    hoverPreviewLayer.lineWidth = 1.0
    hoverPreviewLayer.isHidden = true
    layer.addSublayer(hoverPreviewLayer)

    let hover = UIHoverGestureRecognizer(target: self, action: #selector(handleHover(_:)))
    hover.allowedTouchTypes = [NSNumber(value: UITouch.TouchType.pencil.rawValue)]
    addGestureRecognizer(hover)

    if #available(iOS 12.1, *) {
      let pencil = UIPencilInteraction()
      pencil.delegate = self
      addInteraction(pencil)
    }

    applyCanvasCompositingMode()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    renderImageView.frame = bounds
    if renderImageView.image == nil && bounds.width > 0 && bounds.height > 0 {
      renderImageView.image = emptyImage(size: bounds.size)
    }
  }

  @objc func clearCanvas() {
    renderImageView.image = emptyImage(size: bounds.size)
    lastPointByTouch.removeAll()
    strokePaths.removeAll()
    strokePoints.removeAll()
    strokePressures.removeAll()
  }

  @objc func setCanvasImage(_ image: UIImage?) {
    if let image {
      renderImageView.image = image
    } else if bounds.size != .zero {
      renderImageView.image = emptyImage(size: bounds.size)
    }
  }

  @objc func snapshotImage() -> UIImage? {
    return renderImageView.image
  }

  @objc func setEraserEnabled(_ enabled: Bool) {
    guard isEraserEnabled != enabled else { return }
    isEraserEnabled = enabled
    hoverPreviewLayer.strokeColor = (
      enabled ? UIColor.systemRed : UIColor.systemBlue
    ).withAlphaComponent(0.7).cgColor
    delegate?.stylusViewDidToggleEraser(self, isOn: isEraserEnabled)
  }

  @objc func toggleEraserEnabled() {
    setEraserEnabled(!isEraserEnabled)
  }

  private func emptyImage(size: CGSize) -> UIImage {
    let format = UIGraphicsImageRendererFormat.default()
    format.scale = UIScreen.main.scale
    format.opaque = opaqueCanvas
    let renderer = UIGraphicsImageRenderer(size: size, format: format)
    return renderer.image { context in
      if opaqueCanvas {
        surfaceColor.setFill()
        context.fill(CGRect(origin: .zero, size: size))
      } else {
        context.cgContext.clear(CGRect(origin: .zero, size: size))
      }
    }
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches where shouldAccept(touch: touch) {
      let point = touch.preciseLocation(in: self)
      lastPointByTouch[touch] = point
      if renderMode == "replay" {
        let path = UIBezierPath()
        path.move(to: point)
        strokePaths[touch] = path
        strokePoints[touch] = [point]
        strokePressures[touch] = [normalizedForce(for: touch)]
      }
      delegate?.stylusViewDidStartDrawing(self)
    }
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let image = renderImageView.image else { return }
    for touch in touches where shouldAccept(touch: touch) {
      let samples = event?.coalescedTouches(for: touch) ?? [touch]
      if touch.type == .pencil {
        let pencilSamples = samples.filter { $0.type == .pencil }
        if !pencilSamples.isEmpty {
          delegate?.stylusView(
            self,
            didCollectCoalescedTouches: pencilSamples,
            timestamp: touch.timestamp
          )
        }
      }
      if renderMode == "replay" {
        appendReplaySamples(for: touch, samples: samples)
        renderReplayStroke(for: touch, on: image)
      } else {
        renderSegments(for: touch, samples: samples, on: image)
      }
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
    delegate?.stylusViewDidEndDrawing(self)
  }

  private func shouldAccept(touch: UITouch) -> Bool {
    if allowsFingerDrawing {
      return true
    }
    if #available(iOS 12.1, *) {
      return touch.type == .pencil
    }
    return true
  }

  private func renderSegments(for touch: UITouch, samples: [UITouch], on image: UIImage) {
    guard !samples.isEmpty else { return }
    var previousPoint = lastPointByTouch[touch] ?? samples[0].preciseLocation(in: self)

    let format = UIGraphicsImageRendererFormat.default()
    format.scale = UIScreen.main.scale
    format.opaque = false
    let renderer = UIGraphicsImageRenderer(size: bounds.size, format: format)

    let updated = renderer.image { context in
      image.draw(at: .zero)
      for sample in samples {
        let point = sample.preciseLocation(in: self)
        if point == previousPoint { continue }
        let path = UIBezierPath()
        path.move(to: previousPoint)
        path.addLine(to: point)
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.lineWidth = max(
          2.0,
          baseLineWidth * (0.5 + normalizedForce(for: sample)) * tiltWidthFactor(for: sample)
        )
        strokePath(path, context: context)
        previousPoint = point
      }
    }
    renderImageView.image = updated
    lastPointByTouch[touch] = previousPoint
  }

  private func appendReplaySamples(for touch: UITouch, samples: [UITouch]) {
    if strokePaths[touch] == nil {
      let seed = lastPointByTouch[touch] ?? touch.preciseLocation(in: self)
      let path = UIBezierPath()
      path.move(to: seed)
      strokePaths[touch] = path
      strokePoints[touch] = [seed]
      strokePressures[touch] = [normalizedForce(for: touch)]
    }

    guard var path = strokePaths[touch],
      var points = strokePoints[touch],
      var pressures = strokePressures[touch]
    else { return }

    for sample in samples {
      let point = sample.preciseLocation(in: self)
      path.addLine(to: point)
      points.append(point)
      pressures.append(normalizedForce(for: sample))
      lastPointByTouch[touch] = point
    }

    strokePaths[touch] = path
    strokePoints[touch] = points
    strokePressures[touch] = pressures
  }

  private func renderReplayStroke(for touch: UITouch, on image: UIImage) {
    guard let points = strokePoints[touch],
      let pressures = strokePressures[touch],
      points.count > 1
    else { return }

    let format = UIGraphicsImageRendererFormat.default()
    format.scale = UIScreen.main.scale
    format.opaque = opaqueCanvas
    let renderer = UIGraphicsImageRenderer(size: bounds.size, format: format)

    let updated = renderer.image { context in
      image.draw(at: .zero)
      for index in 1..<points.count {
        let path = UIBezierPath()
        path.move(to: points[index - 1])
        path.addLine(to: points[index])
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.lineWidth = max(
          2.0,
          baseLineWidth * (0.5 + pressures[index]) * tiltWidthFactor(for: touch)
        )
        strokePath(path, context: context)
      }
    }

    renderImageView.image = updated
  }

  private func strokePath(_ path: UIBezierPath, context: UIGraphicsImageRendererContext) {
    if isEraserEnabled {
      if eraserMode == "paint" {
        surfaceColor.setStroke()
        path.stroke()
      } else {
        context.cgContext.setBlendMode(.clear)
        UIColor.clear.setStroke()
        path.stroke(with: .clear, alpha: 1.0)
        context.cgContext.setBlendMode(.normal)
      }
      return
    }

    strokeColor.setStroke()
    path.stroke()
  }

  private func normalizedForce(for touch: UITouch) -> CGFloat {
    guard touch.maximumPossibleForce > 0 else { return 1.0 }
    return min(max(touch.force / touch.maximumPossibleForce, 0.0), 1.0)
  }

  private func tiltWidthFactor(for touch: UITouch) -> CGFloat {
    let perpendicularity = max(0.0, min(1.0, touch.altitudeAngle / (.pi / 2.0)))
    return 1.0 + (1.8 - 1.0) * (1.0 - perpendicularity)
  }

  private func applyCanvasCompositingMode() {
    backgroundColor = opaqueCanvas ? surfaceColor : .clear
    isOpaque = opaqueCanvas
    renderImageView.isOpaque = opaqueCanvas
    renderImageView.backgroundColor = opaqueCanvas ? surfaceColor : .clear
  }

  @objc private func handleHover(_ recognizer: UIHoverGestureRecognizer) {
    let location = recognizer.location(in: self)
    switch recognizer.state {
    case .began, .changed:
      updateHoverPreview(at: location)
      hoverPreviewLayer.isHidden = !showHoverPreview
      var altitude: CGFloat = 0
      var azimuth: CGFloat = 0
      var azimuthUnitVector = CGVector(dx: 0, dy: 0)
      var zOffset: CGFloat = 0
      var rollAngle: CGFloat = 0
      if #available(iOS 16.1, *) {
        zOffset = recognizer.zOffset
      }
      if #available(iOS 16.4, *) {
        altitude = recognizer.altitudeAngle
        azimuth = recognizer.azimuthAngle(in: self)
        azimuthUnitVector = recognizer.azimuthUnitVector(in: self)
      }
      if #available(iOS 17.5, *) {
        rollAngle = recognizer.rollAngle
      }
      delegate?.stylusViewDidHover(
        self,
        location: location,
        altitude: altitude,
        azimuth: azimuth,
        azimuthUnitVector: azimuthUnitVector,
        zOffset: zOffset,
        rollAngle: rollAngle
      )
    default:
      hoverPreviewLayer.isHidden = true
    }
  }

  private func updateHoverPreview(at location: CGPoint) {
    guard showHoverPreview else { return }
    let diameter = max(4.0, baseLineWidth * 2.0)
    let rect = CGRect(
      x: location.x - (diameter * 0.5),
      y: location.y - (diameter * 0.5),
      width: diameter,
      height: diameter
    )
    hoverPreviewLayer.path = UIBezierPath(ovalIn: rect).cgPath
  }

  func pencilInteractionDidTap(_ interaction: UIPencilInteraction) {
    toggleEraserEnabled()
  }
}
