import CoreMotion
import Foundation
import ImageIO
import PencilKit
import UIKit

import React

enum PencilKitDrawingImportMode: Equatable {
  case customImage
  case pencilKit
}

enum PreparedPencilKitDrawing {
  case customImage(UIImage)
  case pencilKit(PKDrawing)

  var mode: PencilKitDrawingImportMode {
    switch self {
    case .customImage:
      return .customImage
    case .pencilKit:
      return .pencilKit
    }
  }
}

struct PencilKitExportSource {
  let drawing: PKDrawing?
  let rasterImage: UIImage?
  let canvasSize: CGSize
  let drawingBounds: CGRect
}

enum PreparedPencilKitDocumentImport {
  case archive(PKDrawing)
  case raster(UIImage)
}

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

@objc final class PencilKitNativeView: UIView, PKCanvasViewDelegate, PKToolPickerObserver,
  StylusDrawingViewDelegate, UIPencilInteractionDelegate
{
  @objc var viewId: NSNumber = 0 {
    didSet {
      let oldId = oldValue.intValue
      if oldId > 0, oldId != viewId.intValue {
        PencilKitRegistry.shared.unregister(id: oldId, view: self)
      }
      let id = viewId.intValue
      if id > 0 {
        PencilKitRegistry.shared.register(view: self, id: id)
      }
    }
  }

  @objc var enableApplePencilData: Bool = false
  @objc var enableToolPicker: Bool = true {
    didSet {
      toolPickerVisibleOverride = nil
      updateToolPickerVisibility()
    }
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
  @objc var onPencilKitDrawingSnapshot: RCTDirectEventBlock?
  @objc var onPencilKitDrawingPhase: RCTDirectEventBlock?
  @objc var onPencilKitHistoryChange: RCTDirectEventBlock?
  @objc var onPencilKitToolPickerChange: RCTDirectEventBlock?

  private let importedImageView = UIImageView()
  private let canvasView = TouchForwardingCanvasView()
  private let stylusView = StylusDrawingView()
  private var toolPicker: PKToolPicker?
  private var hoverRecognizer: UIHoverGestureRecognizer?
  private var pencilInteraction: UIPencilInteraction?
  private let motionManager = CMMotionManager()

  private var isApplePencilCaptureActive = false
  private var useCustomStylusView = false
  private var showHoverPreview = true
  private var squeezeEraserBehavior = "alwaysOn"
  private var toolPickerVisibleOverride: Bool?

  private var lastTouchLocation: CGPoint = .zero
  private var lastTouchTimestamp: TimeInterval = 0
  private var lastVelocity: Double = 0
  private var revision = 0
  private var isDirty = false
  private var isDrawing = false
  private var snapshotDebounceMilliseconds = 0
  private var snapshotWorkItem: DispatchWorkItem?

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }

  deinit {
    snapshotWorkItem?.cancel()
    toolPicker?.removeObserver(self)
    toolPicker?.removeObserver(canvasView)
    if viewId.intValue > 0 {
      PencilKitRegistry.shared.unregister(id: viewId.intValue, view: self)
    }
    stopMotionTracking()
  }

  private func setup() {
    backgroundColor = .clear
    setupImportedImageView()
    setupCanvasView()
    setupStylusView()
    setupPencilInteraction()
    updateViewVisibility()
  }

  private func setupImportedImageView() {
    importedImageView.translatesAutoresizingMaskIntoConstraints = false
    importedImageView.contentMode = .scaleToFill
    importedImageView.backgroundColor = .clear
    addSubview(importedImageView)
    NSLayoutConstraint.activate([
      importedImageView.topAnchor.constraint(equalTo: topAnchor),
      importedImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
      importedImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
      importedImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }

  private func setupCanvasView() {
    canvasView.owner = self
    canvasView.delegate = self
    canvasView.translatesAutoresizingMaskIntoConstraints = false
    canvasView.isMultipleTouchEnabled = true
    // Transparent canvas so paper templates behind the view stay visible.
    canvasView.backgroundColor = .clear
    canvasView.isOpaque = false
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
    stylusView.backgroundColor = .clear
    stylusView.isHidden = true
    addSubview(stylusView)

    NSLayoutConstraint.activate([
      stylusView.topAnchor.constraint(equalTo: topAnchor),
      stylusView.leadingAnchor.constraint(equalTo: leadingAnchor),
      stylusView.trailingAnchor.constraint(equalTo: trailingAnchor),
      stylusView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }

  private func desiredToolPickerVisibility() -> Bool {
    guard !useCustomStylusView else { return false }
    return toolPickerVisibleOverride ?? enableToolPicker
  }

  private func updateToolPickerVisibility() {
    guard desiredToolPickerVisibility() else {
      toolPicker?.setVisible(false, forFirstResponder: canvasView)
      emitToolPickerChange()
      return
    }
    guard let window else { return }
    toolPicker?.removeObserver(self)
    toolPicker?.removeObserver(canvasView)
    let picker: PKToolPicker
    if #available(iOS 18.0, *) {
      // iOS 18+ supports per-view tool picker instances.
      picker = toolPicker ?? PKToolPicker()
    } else {
      guard let shared = PKToolPicker.shared(for: window) else { return }
      picker = shared
    }
    picker.addObserver(canvasView)
    picker.addObserver(self)
    picker.setVisible(true, forFirstResponder: canvasView)
    toolPicker = picker
    canvasView.becomeFirstResponder()
    emitToolPickerChange()
  }

  func setToolPickerVisible(_ visible: Bool) {
    toolPickerVisibleOverride = visible
    updateToolPickerVisibility()
  }

  private func emitToolPickerChange() {
    guard viewId.intValue > 0 else { return }
    onPencilKitToolPickerChange?([
      "viewId": viewId.intValue,
      "visible": desiredToolPickerVisibility() && toolPicker != nil,
      "selectedTool": currentToolStatePayload(),
    ])
  }

  func toolPickerSelectedToolDidChange(_ toolPicker: PKToolPicker) {
    emitToolPickerChange()
  }

  func toolPickerVisibilityDidChange(_ toolPicker: PKToolPicker) {
    emitToolPickerChange()
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()
    updateToolPickerVisibility()
  }

  func applyConfig(_ config: [String: Any]) {
    if let flag = config["useCustomStylusView"] as? Bool {
      useCustomStylusView = flag
      updateViewVisibility()
      updateToolPickerVisibility()
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
      if baseLineWidth.isFinite {
        stylusView.baseLineWidth = CGFloat(min(max(baseLineWidth, 0.1), 100))
      }
    }
    if let strokeColorRaw = config["strokeColor"] as? String {
      stylusView.strokeColor = UIColor.pencilKitCSSColor(strokeColorRaw) ?? .label
    }
    if let customStylusRenderMode = config["customStylusRenderMode"] as? String {
      stylusView.renderMode = customStylusRenderMode
    }
    if let customStylusEraserMode = config["customStylusEraserMode"] as? String {
      stylusView.eraserMode = customStylusEraserMode
    }
    if let customStylusOpaqueCanvas = config["customStylusOpaqueCanvas"] as? Bool {
      stylusView.opaqueCanvas = customStylusOpaqueCanvas
    }
    if let customStylusSurfaceColorRaw = config["customStylusSurfaceColor"] as? String {
      stylusView.surfaceColor = UIColor.pencilKitCSSColor(customStylusSurfaceColorRaw) ?? .systemBackground
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
    if let behavior = config["squeezeEraserBehavior"] as? String {
      squeezeEraserBehavior = behavior
    }
    if let debounce = config["snapshotDebounceMs"] as? NSNumber {
      snapshotDebounceMilliseconds = min(max(debounce.intValue, 0), 60_000)
      if snapshotDebounceMilliseconds == 0 {
        snapshotWorkItem?.cancel()
        snapshotWorkItem = nil
      }
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

  var drawingImportMode: PencilKitDrawingImportMode {
    return useCustomStylusView ? .customImage : .pencilKit
  }

  static func prepareDrawingData(
    _ drawing: [String: Any],
    for mode: PencilKitDrawingImportMode
  ) throws -> PreparedPencilKitDrawing {
    switch mode {
    case .customImage:
      guard let base64 = drawing["imageBase64"] as? String else {
        throw PencilKitHybridError.invalidImage("imageBase64 is required")
      }
      let data = try PencilKitDataValidator.decodeBase64(base64, fieldName: "imageBase64")
      let image = try PencilKitDataValidator.image(from: data)
      return .customImage(image)
    case .pencilKit:
      guard let base64 = drawing["dataBase64"] as? String else {
        throw PencilKitHybridError.invalidDrawing("dataBase64 is required")
      }
      let data = try PencilKitDataValidator.decodeBase64(base64, fieldName: "dataBase64")
      guard data.count <= PencilKitImportLimits.maxBase64DecodedBytes else {
        throw PencilKitHybridError.decodedDataTooLarge(
          "dataBase64",
          PencilKitImportLimits.maxBase64DecodedBytes
        )
      }
      do {
        return .pencilKit(try PKDrawing(data: data))
      } catch {
        throw PencilKitHybridError.invalidDrawing("dataBase64 is not a PKDrawing archive")
      }
    }
  }

  func setDrawingData(_ preparedDrawing: PreparedPencilKitDrawing) throws {
    guard Thread.isMainThread else {
      throw PencilKitHybridError.invalidDrawing("drawing mutation must run on the main thread")
    }
    guard preparedDrawing.mode == drawingImportMode else {
      throw PencilKitHybridError.drawingModeChanged
    }

    switch preparedDrawing {
    case .customImage(let image):
      importedImageView.image = nil
      stylusView.setCanvasImage(image)
      markDrawingChanged()
    case .pencilKit(let drawing):
      importedImageView.image = nil
      canvasView.drawing = drawing
    }
  }

  func clearDrawing() {
    if useCustomStylusView {
      stylusView.clearCanvas()
      importedImageView.image = nil
      markDrawingChanged()
    } else {
      importedImageView.image = nil
      canvasView.drawing = PKDrawing()
    }
  }

  func undo() -> Bool {
    if useCustomStylusView {
      let changed = stylusView.undoDrawing()
      if changed { markDrawingChanged() }
      return changed
    }
    if canvasView.undoManager?.canUndo == true {
      canvasView.undoManager?.undo()
      return true
    }
    return false
  }

  func redo() -> Bool {
    if useCustomStylusView {
      let changed = stylusView.redoDrawing()
      if changed { markDrawingChanged() }
      return changed
    }
    if canvasView.undoManager?.canRedo == true {
      canvasView.undoManager?.redo()
      return true
    }
    return false
  }

  func canUndo() -> Bool {
    if useCustomStylusView { return stylusView.canUndoDrawing }
    return canvasView.undoManager?.canUndo == true
  }

  func canRedo() -> Bool {
    if useCustomStylusView { return stylusView.canRedoDrawing }
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

  func exportSource() -> PencilKitExportSource {
    if useCustomStylusView {
      return PencilKitExportSource(
        drawing: nil,
        rasterImage: stylusView.snapshotImage(),
        canvasSize: bounds.size,
        drawingBounds: CGRect(origin: .zero, size: bounds.size)
      )
    }
    let drawing = canvasView.drawing
    let drawingBounds = drawing.bounds.isNull || drawing.bounds.isInfinite
      ? .zero
      : drawing.bounds
    return PencilKitExportSource(
      drawing: drawing,
      rasterImage: nil,
      canvasSize: canvasView.bounds.size,
      drawingBounds: drawingBounds
    )
  }

  func applyDocumentImport(_ prepared: PreparedPencilKitDocumentImport) throws {
    switch prepared {
    case .archive(let drawing):
      guard !useCustomStylusView else {
        throw PencilKitHybridError.invalidOptions(
          "archive import requires the PencilKit engine; disable useCustomStylusView"
        )
      }
      importedImageView.image = nil
      canvasView.drawing = drawing
    case .raster(let image):
      guard useCustomStylusView else {
        throw PencilKitHybridError.invalidOptions(
          "png/jpeg import is only supported with useCustomStylusView, where the image "
            + "becomes the raster canvas base; PKCanvasView cannot convert images into strokes"
        )
      }
      importedImageView.image = nil
      stylusView.setCanvasImage(image)
      markDrawingChanged()
    }
  }

  func applyToolState(_ object: [String: Any]) throws {
    guard !useCustomStylusView else {
      throw PencilKitHybridError.invalidOptions(
        "setPencilKitTool requires the PencilKit engine; disable useCustomStylusView"
      )
    }
    guard let type = object["type"] as? String else {
      throw PencilKitHybridError.invalidOptions("tool type must be ink, eraser, or lasso")
    }

    switch type {
    case "ink":
      guard
        let rawInkType = object["inkType"] as? String,
        let inkType = Self.inkType(fromString: rawInkType)
      else {
        throw PencilKitHybridError.invalidOptions(
          "inkType must be pen, pencil, marker, monoline, fountainPen, watercolor, or crayon"
        )
      }
      guard
        let rawColor = object["color"] as? String,
        let color = UIColor.pencilKitCSSColor(rawColor)
      else {
        throw PencilKitHybridError.invalidOptions("ink color must be #RRGGBB or #RRGGBBAA")
      }
      let width = CGFloat(
        (object["width"] as? NSNumber)?.doubleValue ?? Double(inkType.defaultWidth)
      )
      guard width.isFinite, width > 0, width <= 512 else {
        throw PencilKitHybridError.invalidOptions("ink width must be finite and between 0 and 512")
      }
      canvasView.tool = PKInkingTool(inkType, color: color, width: width)
    case "eraser":
      let rawEraserType = object["eraserType"] as? String ?? "bitmap"
      let eraserType: PKEraserTool.EraserType
      switch rawEraserType {
      case "bitmap":
        eraserType = .bitmap
      case "vector":
        eraserType = .vector
      default:
        throw PencilKitHybridError.invalidOptions("eraserType must be bitmap or vector")
      }
      if let widthNumber = object["width"] as? NSNumber {
        let width = CGFloat(widthNumber.doubleValue)
        guard width.isFinite, width > 0, width <= 512 else {
          throw PencilKitHybridError.invalidOptions(
            "eraser width must be finite and between 0 and 512"
          )
        }
        canvasView.tool = PKEraserTool(eraserType, width: width)
      } else {
        canvasView.tool = PKEraserTool(eraserType)
      }
    case "lasso":
      canvasView.tool = PKLassoTool()
    default:
      throw PencilKitHybridError.invalidOptions("tool type must be ink, eraser, or lasso")
    }
    emitToolPickerChange()
  }

  func currentToolStatePayload() -> [String: Any] {
    let tool = canvasView.tool
    if let inkingTool = tool as? PKInkingTool {
      return [
        "type": "ink",
        "inkType": Self.inkTypeString(inkingTool.inkType),
        "color": inkingTool.color.pencilKitHexRGBA,
        "width": Double(inkingTool.width),
      ]
    }
    if let eraserTool = tool as? PKEraserTool {
      return [
        "type": "eraser",
        "eraserType": eraserTool.eraserType == .vector ? "vector" : "bitmap",
        "width": Double(eraserTool.width),
      ]
    }
    return ["type": "lasso"]
  }

  static func inkType(fromString value: String) -> PKInkingTool.InkType? {
    switch value {
    case "pen": return .pen
    case "pencil": return .pencil
    case "marker": return .marker
    case "monoline": return .monoline
    case "fountainPen": return .fountainPen
    case "watercolor": return .watercolor
    case "crayon": return .crayon
    default: return nil
    }
  }

  static func inkTypeString(_ inkType: PKInkingTool.InkType) -> String {
    switch inkType {
    case .pen: return "pen"
    case .pencil: return "pencil"
    case .marker: return "marker"
    case .monoline: return "monoline"
    case .fountainPen: return "fountainPen"
    case .watercolor: return "watercolor"
    case .crayon: return "crayon"
    @unknown default: return "pen"
    }
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
        // CMDeviceMotion timestamps share the systemUptime clock used by UITouch.
        "timestamp": motion.timestamp,
        "source": "deviceMotion",
        "timestampClock": "systemUptime",
      ])
    }
  }

  private func stopMotionTracking() {
    if motionManager.isDeviceMotionActive {
      motionManager.stopDeviceMotionUpdates()
    }
  }

  private func markDrawingChanged() {
    revision += 1
    isDirty = true
    emitDrawingChange()
    emitHistoryChange()
    scheduleSnapshotEmit()
  }

  private func currentDrawingBounds() -> CGRect {
    let rect: CGRect
    if useCustomStylusView {
      rect = CGRect(origin: .zero, size: bounds.size)
    } else {
      rect = canvasView.drawing.bounds
    }
    if rect.isNull || rect.isInfinite {
      return .zero
    }
    return rect
  }

  private func emitDrawingChange() {
    guard viewId.intValue > 0 else { return }
    let drawingBounds = currentDrawingBounds()
    onPencilKitDrawingChange?([
      "viewId": viewId.intValue,
      "revision": revision,
      "canUndo": canUndo(),
      "canRedo": canRedo(),
      "dirty": isDirty,
      "bounds": [
        "x": drawingBounds.origin.x,
        "y": drawingBounds.origin.y,
        "width": drawingBounds.width,
        "height": drawingBounds.height,
      ],
    ])
  }

  private func emitHistoryChange() {
    guard viewId.intValue > 0 else { return }
    onPencilKitHistoryChange?([
      "viewId": viewId.intValue,
      "revision": revision,
      "canUndo": canUndo(),
      "canRedo": canRedo(),
    ])
  }

  private func emitDrawingPhase(_ phase: String) {
    guard viewId.intValue > 0 else { return }
    onPencilKitDrawingPhase?([
      "viewId": viewId.intValue,
      "revision": revision,
      "canUndo": canUndo(),
      "canRedo": canRedo(),
      "phase": phase,
      "timestamp": ProcessInfo.processInfo.systemUptime,
      "timestampClock": "systemUptime",
    ])
  }

  private func scheduleSnapshotEmit() {
    snapshotWorkItem?.cancel()
    snapshotWorkItem = nil
    // Per the TS contract, an omitted or zero debounce disables automatic
    // full-drawing serialization.
    guard snapshotDebounceMilliseconds > 0, onPencilKitDrawingSnapshot != nil else { return }
    let expectedRevision = revision
    let workItem = DispatchWorkItem { [weak self] in
      guard let self, self.revision == expectedRevision else { return }
      self.emitDrawingSnapshot()
    }
    snapshotWorkItem = workItem
    DispatchQueue.main.asyncAfter(
      deadline: .now() + .milliseconds(snapshotDebounceMilliseconds),
      execute: workItem
    )
  }

  private func emitDrawingSnapshot() {
    guard viewId.intValue > 0 else { return }
    onPencilKitDrawingSnapshot?([
      "viewId": viewId.intValue,
      "revision": revision,
      "drawing": getDrawingData(),
    ])
  }

  func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
    markDrawingChanged()
  }

  func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
    isDrawing = true
    emitDrawingPhase("began")
  }

  func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
    isDrawing = false
    emitDrawingPhase("ended")
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
      "timestamp": ProcessInfo.processInfo.systemUptime,
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

  private func mapPencilInteractionPhase(_ phase: UIPencilInteraction.Phase) -> String {
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
      "timestamp": ProcessInfo.processInfo.systemUptime,
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
    if useCustomStylusView, squeeze.phase == .ended {
      switch squeezeEraserBehavior {
      case "none":
        break
      case "toggle":
        stylusView.toggleEraserEnabled()
      case "switchEraserOnly":
        if preferredAction == "switchEraser" {
          stylusView.setEraserEnabled(true)
        }
      case "alwaysOn":
        stylusView.setEraserEnabled(true)
      default:
        break
      }
    }
    onApplePencilPreferredSqueezeAction?([
      "viewId": viewId.intValue,
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
      "timestamp": ProcessInfo.processInfo.systemUptime,
      "timestampClock": "systemUptime",
    ])
  }

  func stylusViewDidStartDrawing(_ view: StylusDrawingView) {
    isDrawing = true
    onApplePencilData?([
      "viewId": viewId.intValue,
      "action": "drawingStarted",
      "timestamp": ProcessInfo.processInfo.systemUptime,
      "timestampClock": "systemUptime",
    ])
    emitDrawingPhase("began")
  }

  func stylusViewDidEndDrawing(_ view: StylusDrawingView) {
    isDrawing = false
    onApplePencilData?([
      "viewId": viewId.intValue,
      "action": "drawingEnded",
      "timestamp": ProcessInfo.processInfo.systemUptime,
      "timestampClock": "systemUptime",
    ])
    emitDrawingPhase("ended")
    markDrawingChanged()
  }

  func stylusView(
    _ view: StylusDrawingView,
    didCollectCoalescedTouches touches: [UITouch],
    timestamp: TimeInterval
  ) {
    guard enableApplePencilData, isApplePencilCaptureActive else { return }
    let pencilTouches = touches.filter { $0.type == .pencil }
    if pencilTouches.isEmpty { return }

    let touchesData = pencilTouches.map { convertTouchToDictionary(touch: $0, phase: .moved) }
    onApplePencilCoalescedTouches?([
      "viewId": viewId.intValue,
      "touches": touchesData,
      "timestamp": timestamp,
    ])
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
      "timestamp": ProcessInfo.processInfo.systemUptime,
    ])
  }
}
