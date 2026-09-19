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
  /// The view's resolved light/dark style, for `appearance: 'view'` exports.
  let userInterfaceStyle: UIUserInterfaceStyle
}

/// Drawing state captured on the main thread so it can be serialized off it.
struct PencilKitDrawingCapture {
  let drawing: PKDrawing?
  let rasterImage: UIImage?
  let canvasSize: CGSize
  let includeStrokes: Bool
}

struct PencilMotionState {
  var location: CGPoint = .zero
  var timestamp: TimeInterval = 0
  var velocity: Double = 0
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
        if oldId != id {
          // A new id after destroyPencilKitView (e.g. a React remount that
          // reuses this native view) restores what tearDown() stopped.
          updateMotionTracking()
          updateToolPickerVisibility()
        }
      }
    }
  }

  @objc var enableApplePencilData: Bool = false
  @objc var enableToolPicker: Bool = true {
    didSet {
      // Config updates re-send this prop; only a real change should reset an
      // explicit setToolPickerVisible() override or touch the picker.
      guard oldValue != enableToolPicker else { return }
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
  @objc var onPencilKitToolPickerItemChange: RCTDirectEventBlock?
  @objc var onPencilKitToolPickerAccessoryPress: RCTDirectEventBlock?
  @objc var onPencilKitDidFinishRendering: RCTDirectEventBlock?

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
  /// Whether the picker was shown on the last visibility pass. Focus is only
  /// taken when the picker goes from hidden to shown, never on every pass.
  private var isToolPickerShown = false
  private var autoFocusToolPicker = true
  private var toolItemsConfig: [[String: Any]]?
  private var toolItemsSignature: String?
  private var accessoryItemConfig: [String: Any]?
  private var maximumContentVersion: PKContentVersion?
  private var lastToolPickerPayload: NSDictionary?
  private var lastSelectedToolItemIdentifier: String?
  private var includeStrokesInDrawing = false

  /// Kinematics of the last *real* pencil sample, for velocity/acceleration.
  private var motionState = PencilMotionState()
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
    // Let the surrounding React Native layout own one-finger scrolling. PKCanvasView is a
    // UIScrollView subclass: if its scroll stays enabled, finger pans never reach a parent
    // ScrollView even when drawingPolicy is .pencilOnly. `config.scrollEnabled` restores it.
    canvasView.isScrollEnabled = false
    canvasView.bounces = false
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

  /// Shows or hides the tool picker.
  ///
  /// PKToolPicker only appears while its responder (the canvas) is first
  /// responder, so showing it means taking focus. That used to happen on every
  /// pass (every didMoveToWindow and config update), which stole focus from
  /// text inputs. Focus is now taken only when the picker goes from hidden to
  /// shown, never from a focused text input unless `explicit` (an app call to
  /// setToolPickerVisible(true)), and never when `autoFocusToolPicker` is off.
  private func updateToolPickerVisibility(explicit: Bool = false) {
    guard desiredToolPickerVisibility() else {
      toolPicker?.setVisible(false, forFirstResponder: canvasView)
      isToolPickerShown = false
      emitToolPickerChange()
      return
    }
    guard let window else { return }
    guard let picker = ensureToolPicker(for: window) else { return }
    picker.setVisible(true, forFirstResponder: canvasView)
    let becameVisible = !isToolPickerShown
    isToolPickerShown = true
    if explicit || (becameVisible && autoFocusToolPicker) {
      focusCanvasForToolPicker(overridingTextInput: explicit)
    }
    emitToolPickerChange()
  }

  private func ensureToolPicker(for window: UIWindow) -> PKToolPicker? {
    if let toolPicker { return toolPicker }
    let picker: PKToolPicker
    if #available(iOS 18.0, *) {
      // iOS 18+ supports per-view tool picker instances, optionally with a
      // custom item set.
      if let items = makeToolPickerItems(), !items.isEmpty {
        picker = PKToolPicker(toolItems: items)
      } else {
        picker = PKToolPicker()
      }
      picker.accessoryItem = makeAccessoryItem()
    } else {
      guard let shared = PKToolPicker.shared(for: window) else { return nil }
      picker = shared
    }
    if let maximumContentVersion {
      picker.maximumSupportedContentVersion = maximumContentVersion
    }
    picker.addObserver(canvasView)
    picker.addObserver(self)
    toolPicker = picker
    if #available(iOS 18.0, *) {
      lastSelectedToolItemIdentifier = picker.selectedToolItem.identifier
    }
    return picker
  }

  /// Drops the current picker so the next visibility pass builds a fresh one
  /// (tool items and the accessory item can only be set at creation).
  private func rebuildToolPicker() {
    guard let picker = toolPicker else { return }
    picker.setVisible(false, forFirstResponder: canvasView)
    picker.removeObserver(self)
    picker.removeObserver(canvasView)
    toolPicker = nil
    isToolPickerShown = false
    lastToolPickerPayload = nil
    updateToolPickerVisibility()
  }

  private func focusCanvasForToolPicker(overridingTextInput: Bool) {
    guard !canvasView.isFirstResponder else { return }
    if !overridingTextInput, Self.isTextInputFocused(in: window) { return }
    canvasView.becomeFirstResponder()
  }

  private static weak var capturedFirstResponder: UIResponder?

  /// True when a text field / text view (anything adopting UITextInput) is
  /// first responder, i.e. the keyboard belongs to someone else.
  /// Only counts a text input in `window`: nil-targeted actions go to the key
  /// window, which under the UIScene lifecycle can belong to another scene.
  private static func isTextInputFocused(in window: UIWindow?) -> Bool {
    capturedFirstResponder = nil
    UIApplication.shared.sendAction(
      #selector(UIResponder.munimPencilKitCaptureFirstResponder(_:)),
      to: nil,
      from: nil,
      for: nil
    )
    defer { capturedFirstResponder = nil }
    guard let responder = capturedFirstResponder, responder is UITextInput else { return false }
    if let view = responder as? UIView, let window {
      return view.window === window
    }
    return true
  }

  static func recordFirstResponder(_ responder: UIResponder) {
    capturedFirstResponder = responder
  }

  func setToolPickerVisible(_ visible: Bool) {
    toolPickerVisibleOverride = visible
    updateToolPickerVisibility(explicit: visible)
  }

  private func emitToolPickerChange() {
    guard viewId.intValue > 0 else { return }
    let payload: [String: Any] = [
      "viewId": viewId.intValue,
      "visible": desiredToolPickerVisibility() && toolPicker != nil,
      "selectedTool": currentToolStatePayload(),
    ]
    // iOS 18 reports a tool change through both the deprecated and the
    // tool-item observer callbacks; send each distinct state once.
    let dictionary = payload as NSDictionary
    if let lastToolPickerPayload, lastToolPickerPayload.isEqual(dictionary) { return }
    lastToolPickerPayload = dictionary
    onPencilKitToolPickerChange?(payload)
  }

  func toolPickerSelectedToolDidChange(_ toolPicker: PKToolPicker) {
    emitToolPickerChange()
  }

  @available(iOS 18.0, *)
  func toolPickerSelectedToolItemDidChange(_ toolPicker: PKToolPicker) {
    emitToolPickerChange()
    emitToolPickerItemChange(toolPicker.selectedToolItem)
  }

  func toolPickerVisibilityDidChange(_ toolPicker: PKToolPicker) {
    emitToolPickerChange()
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()
    if window == nil {
      // Coming back to a window counts as showing the picker again.
      isToolPickerShown = false
      return
    }
    updateToolPickerVisibility()
  }

  // MARK: iOS 18 tool items

  @available(iOS 18.0, *)
  private func makeToolPickerItems() -> [PKToolPickerItem]? {
    guard let toolItemsConfig else { return nil }
    var items: [PKToolPickerItem] = []
    for (index, config) in toolItemsConfig.enumerated() {
      if let item = Self.makeToolPickerItem(config) {
        items.append(item)
      } else {
        NSLog("[munim-pencilkit] ignoring invalid toolItems[%d]", index)
      }
    }
    return items
  }

  @available(iOS 18.0, *)
  private static func makeToolPickerItem(_ config: [String: Any]) -> PKToolPickerItem? {
    guard let type = config["type"] as? String else { return nil }
    let identifier = config["identifier"] as? String
    let width = (config["width"] as? NSNumber).map { CGFloat($0.doubleValue) }
    let validWidth = width.flatMap { $0.isFinite && $0 > 0 && $0 <= 512 ? $0 : nil }
    switch type {
    case "ink":
      guard
        let rawInkType = config["inkType"] as? String,
        let parsedInkType = Self.inkType(fromString: rawInkType)
      else { return nil }
      let color = (config["color"] as? String).flatMap(UIColor.pencilKitCSSColor)
      let item = PKToolPickerInkingItem(
        type: parsedInkType,
        color: color,
        width: validWidth,
        identifier: identifier
      )
      if let allowsColorSelection = config["allowsColorSelection"] as? Bool {
        item.allowsColorSelection = allowsColorSelection
      }
      return item
    case "eraser":
      let eraserType: PKEraserTool.EraserType =
        (config["eraserType"] as? String) == "vector" ? .vector : .bitmap
      if let validWidth {
        return PKToolPickerEraserItem(type: eraserType, width: validWidth)
      }
      return PKToolPickerEraserItem(type: eraserType)
    case "lasso":
      return PKToolPickerLassoItem()
    #if !os(visionOS)
      case "ruler":
        return PKToolPickerRulerItem()
      case "scribble":
        return PKToolPickerScribbleItem()
    #endif
    case "custom":
      guard
        let identifier, !identifier.isEmpty,
        let name = config["name"] as? String, !name.isEmpty
      else { return nil }
      var configuration = PKToolPickerCustomItem.Configuration(identifier: identifier, name: name)
      let systemImage = config["systemImage"] as? String ?? "pencil.tip"
      configuration.imageProvider = { item in
        let image = UIImage(systemName: systemImage)
          ?? UIImage(systemName: "questionmark.square.dashed")
          ?? UIImage()
        return image.withTintColor(item.color, renderingMode: .alwaysOriginal)
      }
      if let color = (config["defaultColor"] as? String).flatMap(UIColor.pencilKitCSSColor) {
        configuration.defaultColor = color
      }
      if let defaultWidth = (config["defaultWidth"] as? NSNumber)?.doubleValue,
        defaultWidth.isFinite, defaultWidth > 0
      {
        configuration.defaultWidth = CGFloat(defaultWidth)
      }
      if let allowsColorSelection = config["allowsColorSelection"] as? Bool {
        configuration.allowsColorSelection = allowsColorSelection
      }
      if let controls = config["controls"] as? [String] {
        var options: PKToolPickerCustomItem.ControlOptions = []
        if controls.contains("width") { options.insert(.width) }
        if controls.contains("opacity") { options.insert(.opacity) }
        configuration.toolAttributeControls = options
      }
      return PKToolPickerCustomItem(configuration: configuration)
    default:
      return nil
    }
  }

  @available(iOS 18.0, *)
  private func makeAccessoryItem() -> UIBarButtonItem? {
    guard let accessoryItemConfig else { return nil }
    let identifier = accessoryItemConfig["identifier"] as? String ?? "accessory"
    let action = UIAction { [weak self] _ in
      guard let self, self.viewId.intValue > 0 else { return }
      self.onPencilKitToolPickerAccessoryPress?([
        "viewId": self.viewId.intValue,
        "identifier": identifier,
      ])
    }
    let item: UIBarButtonItem
    if let systemImage = accessoryItemConfig["systemImage"] as? String,
      let image = UIImage(systemName: systemImage)
    {
      item = UIBarButtonItem(image: image, primaryAction: action)
    } else {
      item = UIBarButtonItem(primaryAction: action)
      item.title = accessoryItemConfig["title"] as? String ?? "More"
    }
    if let title = accessoryItemConfig["title"] as? String {
      item.accessibilityLabel = title
    }
    return item
  }

  @available(iOS 18.0, *)
  private func emitToolPickerItemChange(_ item: PKToolPickerItem) {
    guard viewId.intValue > 0 else { return }
    let previous = lastSelectedToolItemIdentifier
    lastSelectedToolItemIdentifier = item.identifier
    var payload: [String: Any] = [
      "viewId": viewId.intValue,
      "identifier": item.identifier,
      "itemType": Self.toolItemType(item),
      "reselected": previous == item.identifier,
    ]
    if let customItem = item as? PKToolPickerCustomItem {
      payload["color"] = customItem.color.pencilKitHexRGBA
      payload["width"] = Double(customItem.width)
    } else {
      payload["selectedTool"] = currentToolStatePayload()
    }
    onPencilKitToolPickerItemChange?(payload)
  }

  @available(iOS 18.0, *)
  private static func toolItemType(_ item: PKToolPickerItem) -> String {
    switch item {
    case is PKToolPickerInkingItem: return "ink"
    case is PKToolPickerEraserItem: return "eraser"
    case is PKToolPickerLassoItem: return "lasso"
    case is PKToolPickerCustomItem: return "custom"
    default:
      #if !os(visionOS)
        if item is PKToolPickerRulerItem { return "ruler" }
        if item is PKToolPickerScribbleItem { return "scribble" }
      #endif
      return "unknown"
    }
  }

  /// Points the picker at `tool` so it doesn't override a programmatic
  /// `canvasView.tool` change the next time it's used.
  private func syncToolPickerSelection(to tool: PKTool, itemIdentifier: String?) {
    guard let picker = toolPicker else { return }
    if #available(iOS 18.0, *) {
      let items = picker.toolItems
      let match = itemIdentifier.flatMap { id in items.first { $0.identifier == id } }
        ?? Self.toolItem(matching: tool, in: items)
      if let match, picker.selectedToolItem.identifier != match.identifier {
        picker.selectedToolItem = match
      }
    }
    // Carries color/width over to the matching item; the canvas observes the
    // picker, so this also keeps the two in step.
    picker.selectedTool = tool
  }

  @available(iOS 18.0, *)
  private static func toolItem(matching tool: PKTool, in items: [PKToolPickerItem]) -> PKToolPickerItem? {
    if let inkingTool = tool as? PKInkingTool {
      return items.first {
        ($0 as? PKToolPickerInkingItem)?.inkingTool.inkType == inkingTool.inkType
      }
    }
    if let eraserTool = tool as? PKEraserTool {
      return items.first {
        ($0 as? PKToolPickerEraserItem)?.eraserTool.eraserType == eraserTool.eraserType
      } ?? items.first { $0 is PKToolPickerEraserItem }
    }
    if tool is PKLassoTool {
      return items.first { $0 is PKToolPickerLassoItem }
    }
    return nil
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
    if let scrollEnabled = config["scrollEnabled"] as? Bool {
      canvasView.isScrollEnabled = scrollEnabled
      canvasView.bounces = scrollEnabled
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
    if let includeStrokes = config["includeStrokesInDrawing"] as? Bool {
      includeStrokesInDrawing = includeStrokes
    }
    if let autoFocus = config["autoFocusToolPicker"] as? Bool {
      autoFocusToolPicker = autoFocus
    }
    if let limit = config["customStylusHistoryLimit"] as? NSNumber {
      stylusView.historyEntryLimit = min(max(limit.intValue, 0), 200)
    }
    if let megabytes = config["customStylusHistoryMemoryMB"] as? NSNumber,
      megabytes.doubleValue.isFinite
    {
      let bytes = min(max(megabytes.doubleValue, 0), 2048) * 1024 * 1024
      stylusView.historyMemoryBudgetBytes = Int(bytes)
    }
    if config.keys.contains("maximumSupportedContentVersion") {
      applyMaximumContentVersion(config["maximumSupportedContentVersion"])
    }
    if config.keys.contains("toolItems") || config.keys.contains("toolPickerAccessoryItem") {
      applyToolItemsConfig(config)
    }
  }

  private func applyMaximumContentVersion(_ raw: Any?) {
    let version: PKContentVersion
    if raw == nil || raw is NSNull {
      version = .latest
    } else {
      do {
        guard let parsed = try PKContentVersion.pencilKitParse(raw) else { return }
        version = parsed
      } catch {
        NSLog("[munim-pencilkit] %@", error.localizedDescription)
        return
      }
    }
    maximumContentVersion = raw == nil || raw is NSNull ? nil : version
    canvasView.maximumSupportedContentVersion = version
    toolPicker?.maximumSupportedContentVersion = version
  }

  private func applyToolItemsConfig(_ config: [String: Any]) {
    let items = config.keys.contains("toolItems")
      ? config["toolItems"] as? [[String: Any]]
      : toolItemsConfig
    let accessory = config.keys.contains("toolPickerAccessoryItem")
      ? config["toolPickerAccessoryItem"] as? [String: Any]
      : accessoryItemConfig
    let signatureObject: [Any] = [items ?? NSNull(), accessory ?? NSNull()]
    let signature = (try? JSONSerialization.data(withJSONObject: signatureObject, options: [.sortedKeys]))
      .flatMap { String(data: $0, encoding: .utf8) }
    guard signature != toolItemsSignature else { return }
    toolItemsSignature = signature
    toolItemsConfig = items
    accessoryItemConfig = accessory
    if #available(iOS 18.0, *) {
      // Tool items and the accessory item are fixed at PKToolPicker creation.
      rebuildToolPicker()
    }
  }

  /// Must be called on the main thread.
  func captureDrawing(includeStrokes: Bool? = nil) -> PencilKitDrawingCapture {
    if useCustomStylusView {
      return PencilKitDrawingCapture(
        drawing: nil,
        rasterImage: stylusView.snapshotImage(),
        canvasSize: bounds.size,
        includeStrokes: false
      )
    }
    return PencilKitDrawingCapture(
      drawing: canvasView.drawing,
      rasterImage: nil,
      canvasSize: bounds.size,
      includeStrokes: includeStrokes ?? includeStrokesInDrawing
    )
  }

  /// Builds the `PencilKitDrawingData` payload. Safe to call off the main thread.
  static func drawingPayload(from capture: PencilKitDrawingCapture) -> [String: Any] {
    guard let drawing = capture.drawing else {
      let imageBase64 = capture.rasterImage?.pngData()?.base64EncodedString()
      return [
        "strokes": [],
        "bounds": [
          "x": 0,
          "y": 0,
          "width": capture.canvasSize.width,
          "height": capture.canvasSize.height,
        ],
        "imageBase64": imageBase64 as Any,
      ]
    }

    let drawingBounds = drawing.bounds.isNull || drawing.bounds.isInfinite ? .zero : drawing.bounds
    return [
      // Strokes are opt-in (includeStrokesInDrawing / getDrawing({ includeStrokes }))
      // because they can be many times larger than the archive.
      "strokes": capture.includeStrokes ? PencilKitStrokeCodec.encode(drawing.strokes) : [],
      "bounds": [
        "x": drawingBounds.origin.x,
        "y": drawingBounds.origin.y,
        "width": drawingBounds.width,
        "height": drawingBounds.height,
      ],
      "dataBase64": drawing.dataRepresentation().base64EncodedString(),
      "requiredContentVersion": drawing.requiredContentVersion.rawValue,
    ]
  }

  func getDrawingData(includeStrokes: Bool? = nil) -> [String: Any] {
    return Self.drawingPayload(from: captureDrawing(includeStrokes: includeStrokes))
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
        // Without an archive, fall back to building the drawing from strokes.
        if let strokes = drawing["strokes"] as? [Any], !strokes.isEmpty {
          return .pencilKit(PKDrawing(strokes: try PencilKitStrokeCodec.decodeStrokes(from: drawing)))
        }
        throw PencilKitHybridError.invalidDrawing("dataBase64 or a non-empty strokes array is required")
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

  /// The live PencilKit drawing. Throws in custom-stylus mode, which has no strokes.
  func pencilKitDrawing() throws -> PKDrawing {
    guard !useCustomStylusView else {
      throw PencilKitHybridError.invalidOptions(
        "stroke access requires the PencilKit engine; disable useCustomStylusView"
      )
    }
    return canvasView.drawing
  }

  /// Replaces the drawing's strokes with `transform(strokes)` as one undoable step.
  func mutateStrokes(
    actionName: String,
    _ transform: ([PKStroke]) throws -> [PKStroke]
  ) throws {
    var drawing = try pencilKitDrawing()
    drawing.strokes = try transform(drawing.strokes)
    replaceDrawingUndoably(drawing, actionName: actionName)
  }

  private func replaceDrawingUndoably(_ drawing: PKDrawing, actionName: String) {
    let previous = canvasView.drawing
    if let undoManager = canvasView.undoManager {
      undoManager.registerUndo(withTarget: self) { target in
        // Registering from inside an undo lands on the redo stack.
        target.replaceDrawingUndoably(previous, actionName: actionName)
      }
      undoManager.setActionName(actionName)
    }
    importedImageView.image = nil
    canvasView.drawing = drawing
  }

  /// Releases native state for destroyPencilKitView. The view stays in the
  /// hierarchy (React owns it) and works again if it gets a new viewId.
  func tearDown() {
    snapshotWorkItem?.cancel()
    snapshotWorkItem = nil
    isApplePencilCaptureActive = false
    stopMotionTracking()
    canvasView.undoManager?.removeAllActions(withTarget: self)
    if let picker = toolPicker {
      picker.setVisible(false, forFirstResponder: canvasView)
      picker.removeObserver(self)
      picker.removeObserver(canvasView)
      toolPicker = nil
    }
    isToolPickerShown = false
    lastToolPickerPayload = nil
    if canvasView.isFirstResponder {
      canvasView.resignFirstResponder()
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
        drawingBounds: CGRect(origin: .zero, size: bounds.size),
        userInterfaceStyle: traitCollection.userInterfaceStyle
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
      drawingBounds: drawingBounds,
      userInterfaceStyle: traitCollection.userInterfaceStyle
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

    let newTool: PKTool
    switch type {
    case "ink":
      guard
        let rawInkType = object["inkType"] as? String,
        let inkType = Self.inkType(fromString: rawInkType)
      else {
        throw PencilKitHybridError.invalidOptions(
          "inkType must be one of \(Self.availableInkTypeNames().joined(separator: ", "))"
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
      newTool = PKInkingTool(inkType, color: color, width: width)
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
        newTool = PKEraserTool(eraserType, width: width)
      } else {
        newTool = PKEraserTool(eraserType)
      }
    case "lasso":
      newTool = PKLassoTool()
    default:
      throw PencilKitHybridError.invalidOptions("tool type must be ink, eraser, or lasso")
    }
    // Update the picker first: the canvas observes it, and a picker left on
    // the old tool would put it back the next time it's shown or tapped.
    syncToolPickerSelection(to: newTool, itemIdentifier: object["itemIdentifier"] as? String)
    canvasView.tool = newTool
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
    case "reed":
      if #available(iOS 26.0, *) { return .reed }
      return nil
    default: return nil
    }
  }

  /// Ink names the running OS can render, in the order the tool picker shows them.
  static func availableInkTypeNames() -> [String] {
    var names = ["pen", "pencil", "marker", "monoline", "fountainPen", "watercolor", "crayon"]
    if #available(iOS 26.0, *) { names.append("reed") }
    return names
  }

  static func inkTypeString(_ inkType: PKInkingTool.InkType) -> String {
    if #available(iOS 26.0, *), inkType == .reed { return "reed" }
    switch inkType {
    case .pen: return "pen"
    case .pencil: return "pencil"
    case .marker: return "marker"
    case .monoline: return "monoline"
    case .fountainPen: return "fountainPen"
    case .watercolor: return "watercolor"
    case .crayon: return "crayon"
    // A plain default: InkType is a frozen Swift enum, so `@unknown default`
    // does not cover `.reed` (handled above) and the switch warns as
    // non-exhaustive (an error in Swift 6 mode).
    default: return "pen"
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
    // Drawing brings the picker back once focus has left the canvas (e.g. a
    // text input was focused and then dismissed). A text input that is still
    // focused keeps its keyboard.
    if desiredToolPickerVisibility(), toolPicker != nil {
      focusCanvasForToolPicker(overridingTextInput: false)
    }
    emitDrawingPhase("began")
  }

  func canvasViewDidFinishRendering(_ canvasView: PKCanvasView) {
    guard viewId.intValue > 0 else { return }
    onPencilKitDidFinishRendering?([
      "viewId": viewId.intValue,
      "revision": revision,
      "timestamp": ProcessInfo.processInfo.systemUptime,
      "timestampClock": "systemUptime",
    ])
  }

  func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
    isDrawing = false
    emitDrawingPhase("ended")
  }

  func handleTouches(_ touches: Set<UITouch>, phase: UITouch.Phase, event: UIEvent?) {
    guard enableApplePencilData, isApplePencilCaptureActive else { return }

    for touch in touches where touch.type == .pencil {
      // Coalesced samples lead up to `touch`, so chain their kinematics from
      // the state before it; predicted samples extrapolate past it. Only the
      // real touch advances the stored velocity state.
      let stateBeforeTouch = motionState
      let data = convertTouchToDictionary(touch: touch, phase: phase, state: &motionState)
      onApplePencilData?(data)

      if let coalesced = event?.coalescedTouches(for: touch), !coalesced.isEmpty {
        var coalescedState = stateBeforeTouch
        let touchesData = coalesced.map {
          convertTouchToDictionary(touch: $0, phase: phase, state: &coalescedState)
        }
        onApplePencilCoalescedTouches?([
          "viewId": viewId.intValue,
          "touches": touchesData,
          "timestamp": touch.timestamp,
        ])
      }

      if let predicted = event?.predictedTouches(for: touch), !predicted.isEmpty {
        var predictedState = motionState
        let touchesData = predicted.map {
          convertTouchToDictionary(touch: $0, phase: .moved, state: &predictedState)
        }
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
      // Estimated-property updates revise an earlier sample; they must not
      // move the velocity state forward.
      var scratchState = motionState
      let updated = estimatePropertyNames(mask: touch.estimatedProperties)
      if updated.isEmpty { continue }
      onApplePencilEstimatedProperties?([
        "viewId": viewId.intValue,
        "touchId": touch.hash,
        "updatedProperties": updated,
        "newData": convertTouchToDictionary(touch: touch, phase: touch.phase, state: &scratchState),
        "timestamp": touch.timestamp,
      ])
    }
  }

  private func convertTouchToDictionary(
    touch: UITouch,
    phase: UITouch.Phase,
    state: inout PencilMotionState
  ) -> [String: Any] {
    let location = touch.location(in: self)
    let previousLocation = touch.previousLocation(in: self)
    let preciseLocation = touch.preciseLocation(in: self)
    let pressure: Double = touch.maximumPossibleForce > 0
      ? Double(touch.force / touch.maximumPossibleForce)
      : 0
    let curvedPressure = pow(min(max(pressure, 0), 1), 0.7)
    let nowVelocity: Double
    let acceleration: Double
    if state.timestamp > 0, phase != .began {
      let dt = touch.timestamp - state.timestamp
      if dt > 0 {
        let dx = Double(location.x - state.location.x)
        let dy = Double(location.y - state.location.y)
        nowVelocity = sqrt((dx * dx) + (dy * dy)) / dt
        acceleration = (nowVelocity - state.velocity) / dt
      } else {
        nowVelocity = state.velocity
        acceleration = 0
      }
    } else {
      nowVelocity = 0
      acceleration = 0
    }
    state = PencilMotionState(location: location, timestamp: touch.timestamp, velocity: nowVelocity)

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
    guard enableHoverSupport else { return }
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
      "phase": Self.hoverPhase(recognizer.state),
      "location": ["x": location.x, "y": location.y],
      "altitude": altitude,
      "azimuth": azimuth,
      "azimuthUnitVector": ["x": azimuthUnitVector.dx, "y": azimuthUnitVector.dy],
      "zOffset": zOffset,
      "rollAngle": rollAngle,
      "timestamp": ProcessInfo.processInfo.systemUptime,
    ])
  }

  static func hoverPhase(_ state: UIGestureRecognizer.State) -> String {
    switch state {
    case .began: return "began"
    case .changed: return "changed"
    case .ended: return "ended"
    default: return "cancelled"
    }
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

    // In custom-stylus mode the coalesced samples are the real input.
    let touchesData = pencilTouches.map {
      convertTouchToDictionary(touch: $0, phase: .moved, state: &motionState)
    }
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
    rollAngle: CGFloat,
    phase: String
  ) {
    guard enableHoverSupport else { return }
    onApplePencilHover?([
      "viewId": viewId.intValue,
      "phase": phase,
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

extension UIResponder {
  /// Target of a nil-targeted action used to find the current first responder.
  @objc func munimPencilKitCaptureFirstResponder(_ sender: Any?) {
    PencilKitNativeView.recordFirstResponder(self)
  }
}
