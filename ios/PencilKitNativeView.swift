import CoreMotion
import Foundation
import PencilKit
import UIKit

import React

final class TouchForwardingCanvasView: PKCanvasView {
  weak var owner: PencilKitNativeView?

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    owner?.handleTouches(touches, phase: .began, event: event)
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesMoved(touches, with: event)
    owner?.handleTouches(touches, phase: .moved, event: event)
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    owner?.handleTouches(touches, phase: .ended, event: event)
  }

  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    owner?.handleTouches(touches, phase: .cancelled, event: event)
  }

  override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
    super.touchesEstimatedPropertiesUpdated(touches)
    owner?.handleEstimatedPropertiesUpdated(touches)
  }
}

@objc final class PencilKitNativeView: UIView, PKCanvasViewDelegate, StylusDrawingViewDelegate,
  UIPencilInteractionDelegate
{
  @objc var viewId: NSNumber = 0 {
    didSet {
      let id = viewId.intValue
      if id > 0 {
        PencilKitRegistry.shared.register(view: self, id: id)
      }
    }
  }

  @objc var enableApplePencilData: Bool = false
  @objc var enableToolPicker: Bool = true {
    didSet { updateToolPickerVisibility() }
  }
  @objc var enableHapticFeedback: Bool = false
  @objc var enableMotionTracking: Bool = false {
    didSet { updateMotionTracking() }
  }
  @objc var enableSqueezeInteraction: Bool = true
  @objc var enableDoubleTapInteraction: Bool = true
  @objc var enableHoverSupport: Bool = true

  @objc var onApplePencilData: RCTDirectEventBlock?
  @objc var onPencilKitDrawingChange: RCTDirectEventBlock?
  @objc var onApplePencilCoalescedTouches: RCTDirectEventBlock?
  @objc var onApplePencilPredictedTouches: RCTDirectEventBlock?
  @objc var onApplePencilEstimatedProperties: RCTDirectEventBlock?
  @objc var onApplePencilMotion: RCTDirectEventBlock?
  @objc var onApplePencilHover: RCTDirectEventBlock?
  @objc var onApplePencilSqueeze: RCTDirectEventBlock?
  @objc var onApplePencilDoubleTap: RCTDirectEventBlock?
  @objc var onApplePencilPreferredSqueezeAction: RCTDirectEventBlock?

  private let canvasView = TouchForwardingCanvasView()
  private let stylusView = StylusDrawingView()
  private var toolPicker: PKToolPicker?
  private var hoverRecognizer: UIHoverGestureRecognizer?
  private var pencilInteraction: UIPencilInteraction?
  private let motionManager = CMMotionManager()

  private var isApplePencilCaptureActive = false
  private var useCustomStylusView = false
  private var showHoverPreview = true

  private var lastTouchLocation: CGPoint = .zero
  private var lastTouchTimestamp: TimeInterval = 0
  private var lastVelocity: Double = 0

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }

  deinit {
    if viewId.intValue > 0 {
      PencilKitRegistry.shared.unregister(id: viewId.intValue)
    }
    stopMotionTracking()
  }

  private func setup() {
    backgroundColor = .systemBackground
    setupCanvasView()
    setupStylusView()
    setupPencilInteraction()
    updateViewVisibility()
  }

  private func setupCanvasView() {
    canvasView.owner = self
    canvasView.delegate = self
    canvasView.translatesAutoresizingMaskIntoConstraints = false
    canvasView.multipleTouchEnabled = true
    addSubview(canvasView)

    NSLayoutConstraint.activate([
      canvasView.topAnchor.constraint(equalTo: topAnchor),
      canvasView.leadingAnchor.constraint(equalTo: leadingAnchor),
      canvasView.trailingAnchor.constraint(equalTo: trailingAnchor),
      canvasView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])

    if #available(iOS 14.0, *) {
      canvasView.drawingPolicy = .anyInput
    } else {
      canvasView.allowsFingerDrawing = true
    }

    if #available(iOS 13.0, *) {
      let hover = UIHoverGestureRecognizer(target: self, action: #selector(handleHover(_:)))
      hover.allowedTouchTypes = [NSNumber(value: UITouch.TouchType.pencil.rawValue)]
      canvasView.addGestureRecognizer(hover)
      hoverRecognizer = hover
    }
  }

  private func setupPencilInteraction() {
    if #available(iOS 12.1, *) {
      let interaction = UIPencilInteraction()
      interaction.delegate = self
      addInteraction(interaction)
      pencilInteraction = interaction
    }
  }

  private func setupStylusView() {
    stylusView.translatesAutoresizingMaskIntoConstraints = false
    stylusView.delegate = self
    stylusView.isHidden = true
    addSubview(stylusView)

    NSLayoutConstraint.activate([
      stylusView.topAnchor.constraint(equalTo: topAnchor),
      stylusView.leadingAnchor.constraint(equalTo: leadingAnchor),
      stylusView.trailingAnchor.constraint(equalTo: trailingAnchor),
      stylusView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }

  private func updateToolPickerVisibility() {
    guard enableToolPicker else {
      toolPicker?.setVisible(false, forFirstResponder: canvasView)
      return
    }
    guard let window else { return }
    if #available(iOS 14.0, *) {
      let picker = PKToolPicker.shared(for: window)
      picker?.addObserver(canvasView)
      picker?.setVisible(true, forFirstResponder: canvasView)
      toolPicker = picker
    } else {
      let picker = PKToolPicker()
      picker.addObserver(canvasView)
      picker.setVisible(true, forFirstResponder: canvasView)
      toolPicker = picker
    }
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()
    updateToolPickerVisibility()
  }

  func applyConfig(_ config: [String: Any]) {
    if let flag = config["useCustomStylusView"] as? Bool {
      useCustomStylusView = flag
      updateViewVisibility()
    }
    if let allowsFingerDrawing = config["allowsFingerDrawing"] as? Bool {
      stylusView.allowsFingerDrawing = allowsFingerDrawing
      if #available(iOS 14.0, *) {
        canvasView.drawingPolicy = allowsFingerDrawing ? .anyInput : .pencilOnly
      } else {
        canvasView.allowsFingerDrawing = allowsFingerDrawing
      }
    }
    if let policy = config["drawingPolicy"] as? String, #available(iOS 14.0, *) {
      switch policy {
      case "anyInput":
        canvasView.drawingPolicy = .anyInput
      case "pencilOnly":
        canvasView.drawingPolicy = .pencilOnly
      default:
        canvasView.drawingPolicy = .default
      }
    }
    if let isRulerActive = config["isRulerActive"] as? Bool {
      canvasView.isRulerActive = isRulerActive
    }
    if let showHover = config["showHoverPreview"] as? Bool {
      showHoverPreview = showHover
      stylusView.showHoverPreview = showHover
    }
    if let baseLineWidth = config["baseLineWidth"] as? Double {
      stylusView.baseLineWidth = CGFloat(baseLineWidth)
    }
    if let strokeColorRaw = config["strokeColor"] as? String {
      stylusView.strokeColor = UIColor.fromCssColor(strokeColorRaw) ?? .label
    }
    if let enableCapture = config["enableApplePencilData"] as? Bool {
      enableApplePencilData = enableCapture
    }
    if let toolPicker = config["enableToolPicker"] as? Bool {
      enableToolPicker = toolPicker
    }
    if let haptics = config["enableHapticFeedback"] as? Bool {
      enableHapticFeedback = haptics
    }
    if let motion = config["enableMotionTracking"] as? Bool {
      enableMotionTracking = motion
    }
    if let squeeze = config["enableSqueezeInteraction"] as? Bool {
      enableSqueezeInteraction = squeeze
    }
    if let tap = config["enableDoubleTapInteraction"] as? Bool {
      enableDoubleTapInteraction = tap
    }
    if let hover = config["enableHoverSupport"] as? Bool {
      enableHoverSupport = hover
    }
  }

  func getDrawingData() -> [String: Any] {
    if useCustomStylusView {
      let imageBase64 = stylusView.snapshotImage()?.pngData()?.base64EncodedString()
      return [
        "strokes": [],
        "bounds": [
          "x": 0,
          "y": 0,
          "width": bounds.width,
          "height": bounds.height,
        ],
        "imageBase64": imageBase64 as Any,
      ]
    }

    let data = canvasView.drawing.dataRepresentation().base64EncodedString()
    return [
      "strokes": [],
      "bounds": [
        "x": canvasView.drawing.bounds.origin.x,
        "y": canvasView.drawing.bounds.origin.y,
        "width": canvasView.drawing.bounds.width,
        "height": canvasView.drawing.bounds.height,
      ],
      "dataBase64": data,
    ]
  }

  func setDrawingData(_ drawing: [String: Any]) {
    if useCustomStylusView {
      if let base64 = drawing["imageBase64"] as? String,
        let data = Data(base64Encoded: base64),
        let image = UIImage(data: data)
      {
        stylusView.setCanvasImage(image)
      }
      return
    }

    guard let base64 = drawing["dataBase64"] as? String,
      let data = Data(base64Encoded: base64)
    else {
      canvasView.drawing = PKDrawing()
      return
    }
    if let drawing = try? PKDrawing(data: data) {
      canvasView.drawing = drawing
    } else {
      canvasView.drawing = PKDrawing()
    }
  }

  func clearDrawing() {
    if useCustomStylusView {
      stylusView.clearCanvas()
    } else {
      canvasView.drawing = PKDrawing()
    }
  }

  func undo() -> Bool {
    if canvasView.undoManager?.canUndo == true {
      canvasView.undoManager?.undo()
      return true
    }
    return false
  }

  func redo() -> Bool {
    if canvasView.undoManager?.canRedo == true {
      canvasView.undoManager?.redo()
      return true
    }
    return false
  }

  func canUndo() -> Bool {
    return canvasView.undoManager?.canUndo == true
  }

  func canRedo() -> Bool {
    return canvasView.undoManager?.canRedo == true
  }

  func startApplePencilCapture() {
    isApplePencilCaptureActive = true
  }

  func stopApplePencilCapture() {
    isApplePencilCaptureActive = false
  }

  func isCaptureActive() -> Bool {
    return isApplePencilCaptureActive
  }

  private func updateViewVisibility() {
    canvasView.isHidden = useCustomStylusView
    stylusView.isHidden = !useCustomStylusView
  }

  private func updateMotionTracking() {
    if enableMotionTracking {
      startMotionTracking()
    } else {
      stopMotionTracking()
    }
  }

  private func startMotionTracking() {
    guard motionManager.isDeviceMotionAvailable else { return }
    motionManager.deviceMotionUpdateInterval = 0.1
    motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
      guard let self, let motion else { return }
      self.onApplePencilMotion?([
        "viewId": self.viewId.intValue,
        "rollAngle": motion.attitude.roll,
        "pitchAngle": motion.attitude.pitch,
        "yawAngle": motion.attitude.yaw,
        "timestamp": Date().timeIntervalSince1970,
      ])
    }
  }

  private func stopMotionTracking() {
    if motionManager.isDeviceMotionActive {
      motionManager.stopDeviceMotionUpdates()
    }
  }

  func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
    onPencilKitDrawingChange?(getDrawingData())
  }

  func handleTouches(_ touches: Set<UITouch>, phase: UITouch.Phase, event: UIEvent?) {
    guard enableApplePencilData, isApplePencilCaptureActive else { return }

    for touch in touches where touch.type == .pencil {
      let data = convertTouchToDictionary(touch: touch, phase: phase)
      onApplePencilData?(data)

      if let coalesced = event?.coalescedTouches(for: touch), !coalesced.isEmpty {
        let touchesData = coalesced.map { convertTouchToDictionary(touch: $0, phase: phase) }
        onApplePencilCoalescedTouches?([
          "viewId": viewId.intValue,
          "touches": touchesData,
          "timestamp": touch.timestamp,
        ])
      }

      if let predicted = event?.predictedTouches(for: touch), !predicted.isEmpty {
        let touchesData = predicted.map { convertTouchToDictionary(touch: $0, phase: phase) }
        onApplePencilPredictedTouches?([
          "viewId": viewId.intValue,
          "touches": touchesData,
          "timestamp": touch.timestamp,
        ])
      }
    }
  }

  func handleEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
    guard enableApplePencilData, isApplePencilCaptureActive else { return }
    for touch in touches where touch.type == .pencil {
      let updated = estimatePropertyNames(mask: touch.estimatedProperties)
      if updated.isEmpty { continue }
      onApplePencilEstimatedProperties?([
        "viewId": viewId.intValue,
        "touchId": touch.hash,
        "updatedProperties": updated,
        "newData": convertTouchToDictionary(touch: touch, phase: touch.phase),
        "timestamp": touch.timestamp,
      ])
    }
  }

  private func convertTouchToDictionary(touch: UITouch, phase: UITouch.Phase) -> [String: Any] {
    let location = touch.location(in: self)
    let previousLocation = touch.previousLocation(in: self)
    let preciseLocation = touch.preciseLocation(in: self)
    let pressure: Double = touch.maximumPossibleForce > 0
      ? Double(touch.force / touch.maximumPossibleForce)
      : 0
    let curvedPressure = pow(min(max(pressure, 0), 1), 0.7)
    let nowVelocity: Double
    let acceleration: Double
    if lastTouchTimestamp > 0, phase != .began {
      let dt = touch.timestamp - lastTouchTimestamp
      if dt > 0 {
        let dx = Double(location.x - lastTouchLocation.x)
        let dy = Double(location.y - lastTouchLocation.y)
        nowVelocity = sqrt((dx * dx) + (dy * dy)) / dt
        acceleration = (nowVelocity - lastVelocity) / dt
      } else {
        nowVelocity = 0
        acceleration = 0
      }
    } else {
      nowVelocity = 0
      acceleration = 0
    }
    lastTouchLocation = location
    lastTouchTimestamp = touch.timestamp
    lastVelocity = nowVelocity

    let azimuthVector = touch.azimuthUnitVector(in: self)
    let rollAngle: CGFloat
    if #available(iOS 17.5, *) {
      rollAngle = touch.rollAngle
    } else {
      rollAngle = 0
    }
    return [
      "viewId": viewId.intValue,
      "type": "pencil",
      "isApplePencil": true,
      "pressure": curvedPressure,
      "force": touch.force,
      "maximumPossibleForce": touch.maximumPossibleForce,
      "perpendicularForce": touch.force * cos(touch.altitudeAngle),
      "rollAngle": rollAngle,
      "altitude": touch.altitudeAngle,
      "azimuth": touch.azimuthAngle(in: self),
      "azimuthUnitVector": ["x": azimuthVector.dx, "y": azimuthVector.dy],
      "timestamp": touch.timestamp,
      "location": ["x": location.x, "y": location.y],
      "previousLocation": ["x": previousLocation.x, "y": previousLocation.y],
      "preciseLocation": ["x": preciseLocation.x, "y": preciseLocation.y],
      "phase": phaseString(phase),
      "hasPreciseLocation": true,
      "estimatedProperties": estimatePropertyNames(mask: touch.estimatedProperties),
      "estimatedPropertiesExpectingUpdates": estimatePropertyNames(mask: touch.estimatedPropertiesExpectingUpdates),
      "velocity": nowVelocity,
      "acceleration": acceleration,
    ]
  }

  private func estimatePropertyNames(mask: UITouch.Properties) -> [String] {
    var values: [String] = []
    if mask.contains(.force) { values.append("force") }
    if mask.contains(.azimuth) { values.append("azimuth") }
    if mask.contains(.altitude) { values.append("altitude") }
    if mask.contains(.location) { values.append("location") }
    return values
  }

  private func phaseString(_ phase: UITouch.Phase) -> String {
    switch phase {
    case .began: return "began"
    case .moved: return "moved"
    case .ended: return "ended"
    case .cancelled: return "cancelled"
    default: return "began"
    }
  }

  @objc private func handleHover(_ recognizer: UIHoverGestureRecognizer) {
    guard showHoverPreview, enableHoverSupport else { return }
    let location = recognizer.location(in: self)
    let altitude: CGFloat
    let azimuth: CGFloat
    let azimuthUnitVector: CGVector
    let zOffset: CGFloat
    let rollAngle: CGFloat
    if #available(iOS 16.4, *) {
      altitude = recognizer.altitudeAngle
      azimuth = recognizer.azimuthAngle(in: self)
      azimuthUnitVector = recognizer.azimuthUnitVector(in: self)
    } else {
      altitude = 0
      azimuth = 0
      azimuthUnitVector = CGVector(dx: 0, dy: 0)
    }
    if #available(iOS 16.1, *) {
      zOffset = recognizer.zOffset
    } else {
      zOffset = 0
    }
    if #available(iOS 17.5, *) {
      rollAngle = recognizer.rollAngle
    } else {
      rollAngle = 0
    }
    onApplePencilHover?([
      "viewId": viewId.intValue,
      "location": ["x": location.x, "y": location.y],
      "altitude": altitude,
      "azimuth": azimuth,
      "azimuthUnitVector": ["x": azimuthUnitVector.dx, "y": azimuthUnitVector.dy],
      "zOffset": zOffset,
      "rollAngle": rollAngle,
      "timestamp": Date().timeIntervalSince1970,
    ])
  }

  private func triggerHapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
    guard enableHapticFeedback else { return }
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.prepare()
    generator.impactOccurred()
  }

  private func mapPreferredAction(_ action: UIPencilPreferredAction) -> String {
    switch action {
    case .ignore:
      return "ignore"
    case .switchEraser:
      return "switchEraser"
    case .switchPrevious:
      return "switchPrevious"
    case .showColorPalette:
      return "showColorPalette"
    case .showInkAttributes:
      return "showInkAttributes"
    case .showContextualPalette:
      return "showContextualPalette"
    case .runSystemShortcut:
      return "runSystemShortcut"
    @unknown default:
      return "ignore"
    }
  }

  private func mapPencilInteractionPhase(_ phase: UIPencilInteractionPhase) -> String {
    switch phase {
    case .began:
      return "began"
    case .changed:
      return "changed"
    case .ended:
      return "ended"
    case .cancelled:
      return "cancelled"
    @unknown default:
      return "ended"
    }
  }

  @available(iOS 17.5, *)
  private func buildHoverPosePayload(_ hoverPose: UIPencilHoverPose?) -> [String: Any]? {
    guard let hoverPose else { return nil }
    return [
      "location": [
        "x": hoverPose.location.x,
        "y": hoverPose.location.y,
      ],
      "zOffset": hoverPose.zOffset,
      "azimuth": hoverPose.azimuthAngle,
      "azimuthUnitVector": [
        "x": hoverPose.azimuthUnitVector.dx,
        "y": hoverPose.azimuthUnitVector.dy,
      ],
      "altitude": hoverPose.altitudeAngle,
      "rollAngle": hoverPose.rollAngle,
    ]
  }

  func pencilInteractionDidTap(_ interaction: UIPencilInteraction) {
    guard enableDoubleTapInteraction else { return }
    let preferredAction = mapPreferredAction(UIPencilInteraction.preferredTapAction)
    onApplePencilDoubleTap?([
      "viewId": viewId.intValue,
      "phase": "ended",
      "preferredAction": preferredAction,
      "timestamp": Date().timeIntervalSince1970,
    ])
    triggerHapticFeedback(.light)
  }

  @available(iOS 17.5, *)
  func pencilInteraction(
    _ interaction: UIPencilInteraction,
    didReceiveTap tap: UIPencilInteraction.Tap
  ) {
    guard enableDoubleTapInteraction else { return }
    let preferredAction = mapPreferredAction(UIPencilInteraction.preferredTapAction)
    var payload: [String: Any] = [
      "viewId": viewId.intValue,
      "phase": "ended",
      "preferredAction": preferredAction,
      "timestamp": tap.timestamp,
    ]
    if let hoverPose = buildHoverPosePayload(tap.hoverPose) {
      payload["hoverPose"] = hoverPose
    }
    onApplePencilDoubleTap?(payload)
    triggerHapticFeedback(.light)
  }

  @available(iOS 17.5, *)
  func pencilInteraction(
    _ interaction: UIPencilInteraction,
    didReceiveSqueeze squeeze: UIPencilInteraction.Squeeze
  ) {
    guard enableSqueezeInteraction else { return }
    let preferredAction = mapPreferredAction(UIPencilInteraction.preferredSqueezeAction)
    onApplePencilPreferredSqueezeAction?([
      "preferredAction": preferredAction,
    ])
    var payload: [String: Any] = [
      "viewId": viewId.intValue,
      "phase": mapPencilInteractionPhase(squeeze.phase),
      "preferredAction": preferredAction,
      "timestamp": squeeze.timestamp,
    ]
    if let hoverPose = buildHoverPosePayload(squeeze.hoverPose) {
      payload["hoverPose"] = hoverPose
    }
    onApplePencilSqueeze?(payload)
    if squeeze.phase == .ended {
      triggerHapticFeedback(.medium)
    }
  }

  func stylusViewDidToggleEraser(_ view: StylusDrawingView, isOn: Bool) {
    onApplePencilData?([
      "viewId": viewId.intValue,
      "isEraserOn": isOn,
      "timestamp": Date().timeIntervalSince1970,
    ])
  }

  func stylusViewDidStartDrawing(_ view: StylusDrawingView) {
    onApplePencilData?([
      "viewId": viewId.intValue,
      "action": "drawingStarted",
      "timestamp": Date().timeIntervalSince1970,
    ])
  }

  func stylusViewDidEndDrawing(_ view: StylusDrawingView) {
    onApplePencilData?([
      "viewId": viewId.intValue,
      "action": "drawingEnded",
      "timestamp": Date().timeIntervalSince1970,
    ])
    onPencilKitDrawingChange?(getDrawingData())
  }

  func stylusViewDidHover(
    _ view: StylusDrawingView,
    location: CGPoint,
    altitude: CGFloat,
    azimuth: CGFloat,
    azimuthUnitVector: CGVector,
    zOffset: CGFloat,
    rollAngle: CGFloat
  ) {
    onApplePencilHover?([
      "viewId": viewId.intValue,
      "location": ["x": location.x, "y": location.y],
      "altitude": altitude,
      "azimuth": azimuth,
      "azimuthUnitVector": ["x": azimuthUnitVector.dx, "y": azimuthUnitVector.dy],
      "zOffset": zOffset,
      "rollAngle": rollAngle,
      "timestamp": Date().timeIntervalSince1970,
    ])
  }
}

private extension UIColor {
  static func fromCssColor(_ value: String) -> UIColor? {
    if value.hasPrefix("#") {
      let hex = String(value.dropFirst())
      let scanner = Scanner(string: hex)
      var intValue: UInt64 = 0
      guard scanner.scanHexInt64(&intValue) else { return nil }
      switch hex.count {
      case 6:
        let r = CGFloat((intValue & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((intValue & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(intValue & 0x0000FF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: 1)
      case 8:
        let r = CGFloat((intValue & 0xFF000000) >> 24) / 255.0
        let g = CGFloat((intValue & 0x00FF0000) >> 16) / 255.0
        let b = CGFloat((intValue & 0x0000FF00) >> 8) / 255.0
        let a = CGFloat(intValue & 0x000000FF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: a)
      default:
        return nil
      }
    }
    return nil
  }
}
