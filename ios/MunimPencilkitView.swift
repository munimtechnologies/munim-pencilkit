import ExpoModulesCore
import PencilKit
import UIKit

@available(iOS 13.0, *)
extension PKStroke {
  func toDictionary() -> [String: Any] {
    var strokeDict: [String: Any] = [:]
    
    strokeDict["renderBounds"] = [
      "x": renderBounds.origin.x,
      "y": renderBounds.origin.y,
      "width": renderBounds.size.width,
      "height": renderBounds.size.height
    ]
    
    strokeDict["path"] = path.toDictionary()
    strokeDict["ink"] = ink.toDictionary()
    strokeDict["transform"] = [
      "a": transform.a,
      "b": transform.b,
      "c": transform.c,
      "d": transform.d,
      "tx": transform.tx,
      "ty": transform.ty
    ]
    
    // Add stroke identifier based on stroke properties
    let identifier = "\(renderBounds.origin.x)_\(renderBounds.origin.y)_\(path.creationDate.timeIntervalSince1970)"
    strokeDict["identifier"] = identifier
    
    return strokeDict
  }
}

@available(iOS 13.0, *)
extension PKStrokePath {
  func toDictionary() -> [String: Any] {
    var pathDict: [String: Any] = [:]
    
    pathDict["count"] = count
    pathDict["creationDate"] = creationDate.timeIntervalSince1970
    
    // Get all points
    var points: [[String: Any]] = []
    for i in 0..<count {
      let point = self[i]
      points.append(point.toDictionary())
    }
    pathDict["points"] = points
    
    // Get interpolated points for smoother representation
    if count > 1 {
      var interpolatedPoints: [[String: Any]] = []
      let step: Float = 1.0 / Float(Swift.max(count * 2, 10))
      var t: Float = 0.0
      while t <= 1.0 {
        let interpolatedPoint = self.interpolatedLocation(at: CGFloat(t))
        interpolatedPoints.append([
          "location": ["x": interpolatedPoint.x, "y": interpolatedPoint.y],
          "timeOffset": 0.0,
          "size": ["width": 1.0, "height": 1.0],
          "opacity": 1.0,
          "force": 1.0,
          "azimuth": 0.0,
          "altitude": 0.0
        ])
        t += step
      }
      pathDict["interpolatedPoints"] = interpolatedPoints
    }
    
    return pathDict
  }
}

@available(iOS 13.0, *)
extension PKStrokePoint {
  func toDictionary() -> [String: Any] {
    var pointDict: [String: Any] = [:]
    
    pointDict["location"] = ["x": location.x, "y": location.y]
    pointDict["timeOffset"] = timeOffset
    pointDict["size"] = ["width": size.width, "height": size.height]
    pointDict["opacity"] = opacity
    pointDict["force"] = force
    pointDict["azimuth"] = azimuth
    pointDict["altitude"] = altitude
    
    return pointDict
  }
}

@available(iOS 13.0, *)
extension PKInk {
  func toDictionary() -> [String: Any] {
    var inkDict: [String: Any] = [:]
    
    switch inkType {
    case .pen:
      inkDict["type"] = "pen"
    case .pencil:
      inkDict["type"] = "pencil"
    case .marker:
      inkDict["type"] = "marker"
    @unknown default:
      inkDict["type"] = "unknown"
    }
    
    inkDict["color"] = color.hexString
    
    // Add version-specific properties
    if #available(iOS 17.0, *) {
      inkDict["requiredContentVersion"] = requiredContentVersion.rawValue
    }
    
    return inkDict
  }
}

// This view will be used as a native component. Make sure to inherit from `ExpoView`
// to apply the proper styling (e.g. border radius and shadows).
class MunimPencilkitView: ExpoView {
  let canvasView = PKCanvasView()
  var toolPicker: PKToolPicker?
  
  // Cached serialization to reflect content right after stroke ends
  private var _lastDrawingData: Data?
  private var _lastStrokeCount: Int = 0
  private var _lastBounds: CGRect = .zero
  
  // Fallback stroke data for when PKDrawing serialization fails
  private var _fallbackStrokeData: Data?
  
  // Event dispatchers for various PencilKit events
  let onDrawingChanged = EventDispatcher()
  let onToolChanged = EventDispatcher()
  let onDrawingStarted = EventDispatcher()
  let onDrawingEnded = EventDispatcher()
  
  // Configuration properties
  private var _showToolPicker: Bool = true
  private var _allowsFingerDrawing: Bool = true
  private var _isRulerActive: Bool = false
  private var _drawingPolicy: String = "default"
  
  // Tool configuration properties
  var _currentToolType: String = "pen"
  var _currentToolColor: String = "#000000"
  var _currentToolWidth: CGFloat = 10.0
  
  // Ink behavior control properties
  private var _enableInkSmoothing: Bool = true
  private var _enableStrokeRefinement: Bool = true
  private var _enableHandwritingRecognition: Bool = true
  private var _naturalDrawingMode: Bool = false

  required init(appContext: AppContext? = nil) {
    super.init(appContext: appContext)
    setupCanvasView()
    setupToolPicker()
    applyToolConfiguration() // Apply default tool configuration
  }
  
  private func setupCanvasView() {
    canvasView.delegate = self
    canvasView.drawingPolicy = .default
    canvasView.allowsFingerDrawing = _allowsFingerDrawing
    canvasView.isRulerActive = _isRulerActive
    canvasView.backgroundColor = UIColor.clear
    addSubview(canvasView)
  }
  
  private func setupToolPicker() {
    if #available(iOS 14.0, *) {
      toolPicker = PKToolPicker()
      toolPicker?.setVisible(_showToolPicker, forFirstResponder: canvasView)
      toolPicker?.addObserver(canvasView)
      canvasView.becomeFirstResponder()
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    canvasView.frame = bounds
  }
  
  // MARK: - Public methods for JavaScript interface
  
  func setShowToolPicker(_ show: Bool) {
    _showToolPicker = show
    if #available(iOS 14.0, *) {
      toolPicker?.setVisible(show, forFirstResponder: canvasView)
    }
  }
  
  func setAllowsFingerDrawing(_ allows: Bool) {
    _allowsFingerDrawing = allows
    canvasView.allowsFingerDrawing = allows
  }
  
  func setIsRulerActive(_ active: Bool) {
    _isRulerActive = active
    if #available(iOS 14.0, *) {
      canvasView.isRulerActive = active
    }
  }
  
  func setDrawingPolicy(_ policy: String) {
    _drawingPolicy = policy
    switch policy {
    case "pencilOnly":
      if #available(iOS 14.0, *) {
        canvasView.drawingPolicy = .pencilOnly
      }
    case "anyInput":
      if #available(iOS 14.0, *) {
        canvasView.drawingPolicy = .anyInput
      }
    default:
      canvasView.drawingPolicy = .default
    }
  }
  
  // MARK: - Ink Behavior Controls
  
  func setEnableInkSmoothing(_ enable: Bool) {
    _enableInkSmoothing = enable
    applyToolConfiguration()
  }
  
  func setEnableStrokeRefinement(_ enable: Bool) {
    _enableStrokeRefinement = enable
    applyToolConfiguration()
  }
  
  func setEnableHandwritingRecognition(_ enable: Bool) {
    _enableHandwritingRecognition = enable
    configureHandwritingRecognition()
  }
  
  func setNaturalDrawingMode(_ natural: Bool) {
    _naturalDrawingMode = natural
    if natural {
      // Natural drawing mode disables most processing
      _enableInkSmoothing = false
      _enableStrokeRefinement = false
      _enableHandwritingRecognition = false
    }
    applyToolConfiguration()
    configureHandwritingRecognition()
  }
  
  private func configureHandwritingRecognition() {
    // Configure Scribble interaction based on handwriting recognition setting
    if #available(iOS 14.0, *) {
      if _enableHandwritingRecognition {
        configureScribbleInteraction(enabled: true)
      } else {
        configureScribbleInteraction(enabled: false)
      }
    }
  }
  
  func clearDrawing() {
    canvasView.drawing = PKDrawing()
    onDrawingChanged(["hasContent": false, "strokeCount": 0, "bounds": [
      "x": 0,
      "y": 0,
      "width": 0,
      "height": 0
    ]])
  }
  
  func undo() {
    canvasView.undoManager?.undo()
  }
  
  func redo() {
    canvasView.undoManager?.redo()
  }
  
  func getDrawingData() -> Data? {
    // Try immediate serialization first
    var result: Data?
    if Thread.isMainThread {
      result = canvasView.drawing.dataRepresentation()
    } else {
      DispatchQueue.main.sync {
        result = self.canvasView.drawing.dataRepresentation()
      }
    }
    
    // Debug logging
    print("[PencilKit] getDrawingData() - immediate attempt: \(result?.count ?? 0) bytes, cached: \(_lastDrawingData?.count ?? 0) bytes, strokeCount: \(_lastStrokeCount)")
    
    // If immediate serialization succeeded, return it
    if let data = result, !data.isEmpty {
      print("[PencilKit] getDrawingData() - returning immediate data: \(data.count) bytes")
      return data
    }
    
    // If we have strokes but serialization failed, try with a delay
    if !canvasView.drawing.strokes.isEmpty {
      print("[PencilKit] getDrawingData() - immediate serialization failed, trying with delay...")
      var delayedResult: Data?
      let semaphore = DispatchSemaphore(value: 0)
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        delayedResult = self.canvasView.drawing.dataRepresentation()
        semaphore.signal()
      }
      
      // Wait up to 0.5 seconds for delayed serialization
      let timeout = DispatchTime.now() + 0.5
      if semaphore.wait(timeout: timeout) == .success {
        if let data = delayedResult, !data.isEmpty {
          print("[PencilKit] getDrawingData() - returning delayed data: \(data.count) bytes")
          // Update cache with successful delayed result
          self._lastDrawingData = data
          return data
        }
      }
    }
    
    // If current data is empty but we have cached strokes, use cached data
    if _lastStrokeCount > 0, let cachedData = _lastDrawingData, !cachedData.isEmpty {
      print("[PencilKit] getDrawingData() - using cached data: \(cachedData.count) bytes")
      return cachedData
    }
    
    // Last resort: create fallback data if we have strokes but no serialized data
    if !canvasView.drawing.strokes.isEmpty {
      print("[PencilKit] getDrawingData() - creating fallback stroke data as last resort")
      if let fallbackData = createFallbackStrokeData() {
        self._fallbackStrokeData = fallbackData
        print("[PencilKit] getDrawingData() - returning fallback data: \(fallbackData.count) bytes")
        return fallbackData
      }
    }
    
    // Return cached fallback data if available
    if let fallbackData = _fallbackStrokeData {
      print("[PencilKit] getDrawingData() - returning cached fallback data: \(fallbackData.count) bytes")
      return fallbackData
    }
    
    print("[PencilKit] getDrawingData() - all methods failed, returning nil")
    return nil
  }

  // MARK: - Simple State Accessors
  func hasContent() -> Bool {
    var has = false
    if Thread.isMainThread {
      has = !canvasView.drawing.strokes.isEmpty
    } else {
      DispatchQueue.main.sync {
        has = !self.canvasView.drawing.strokes.isEmpty
      }
    }
    // Always prioritize cached state if it indicates content, as PencilKit may temporarily clear strokes during processing
    let result = has || _lastStrokeCount > 0
    print("[PencilKit] hasContent() - current: \(has), cached: \(_lastStrokeCount > 0), result: \(result)")
    return result
  }
  
  func getStrokeCount() -> Int {
    var count = 0
    if Thread.isMainThread {
      count = canvasView.drawing.strokes.count
    } else {
      DispatchQueue.main.sync {
        count = self.canvasView.drawing.strokes.count
      }
    }
    // Always return the maximum of current and cached count to handle race conditions
    let result = max(count, _lastStrokeCount)
    print("[PencilKit] getStrokeCount() - current: \(count), cached: \(_lastStrokeCount), result: \(result)")
    return result
  }
  
  func getDrawingBoundsStruct() -> [String: CGFloat] {
    var bounds = CGRect.zero
    if Thread.isMainThread {
      bounds = canvasView.drawing.bounds
    } else {
      DispatchQueue.main.sync {
        bounds = self.canvasView.drawing.bounds
      }
    }
    // Use cached bounds if current bounds are empty but we have cached strokes
    if bounds.isEmpty && _lastStrokeCount > 0 { bounds = _lastBounds }
    return [
      "x": bounds.origin.x,
      "y": bounds.origin.y,
      "width": bounds.size.width,
      "height": bounds.size.height
    ]
  }
  
  func loadDrawingData(_ data: Data) {
    do {
      let drawing = try PKDrawing(data: data)
      canvasView.drawing = drawing
      onDrawingChanged(["hasContent": !drawing.strokes.isEmpty])
    } catch {
      print("Failed to load drawing data: \(error)")
    }
  }
  
  func exportDrawingAsImage(scale: CGFloat = 1.0) -> UIImage? {
    // Prefer drawing bounds; if empty, return nil to allow higher-level fallbacks
    guard !canvasView.drawing.bounds.isEmpty else { return nil }
    let bounds = canvasView.drawing.bounds
    return canvasView.drawing.image(from: bounds, scale: scale)
  }
  
  func setBackgroundColor(_ color: UIColor) {
    canvasView.backgroundColor = color
  }
  
  // MARK: - Fallback Serialization
  
  private func createFallbackStrokeData() -> Data? {
    do {
      let strokes = canvasView.drawing.strokes.map { $0.toDictionary() }
      let fallbackData: [String: Any] = [
        "type": "fallbackStrokes",
        "version": 1,
        "strokeCount": strokes.count,
        "bounds": [
          "x": canvasView.drawing.bounds.origin.x,
          "y": canvasView.drawing.bounds.origin.y,
          "width": canvasView.drawing.bounds.size.width,
          "height": canvasView.drawing.bounds.size.height
        ],
        "strokes": strokes,
        "timestamp": Date().timeIntervalSince1970
      ]
      
      return try JSONSerialization.data(withJSONObject: fallbackData, options: [])
    } catch {
      print("[PencilKit] Failed to create fallback stroke data: \(error)")
      return nil
    }
  }
  
  // MARK: - Advanced Stroke Inspection
  
  @available(iOS 13.0, *)
  func getAllStrokes() -> [[String: Any]] {
    var currentStrokes: [PKStroke] = []
    var result: [[String: Any]] = []
    
    let work = {
      currentStrokes = self.canvasView.drawing.strokes
      result = currentStrokes.map { $0.toDictionary() }
    }
    
    if Thread.isMainThread {
      work()
    } else {
      DispatchQueue.main.sync(execute: work)
    }
    
    // Debug logging to track the issue
    print("[PencilKit] getAllStrokes() - current: \(currentStrokes.count), cached: \(_lastStrokeCount), hasCachedData: \(_lastDrawingData != nil)")
    
    // If current strokes are empty but we have cached strokes, use cached data
    if currentStrokes.isEmpty && _lastStrokeCount > 0 {
      if let data = self._lastDrawingData, !data.isEmpty {
        do {
          let drawing = try PKDrawing(data: data)
          let cachedResult = drawing.strokes.map { $0.toDictionary() }
          print("[PencilKit] getAllStrokes() - using cached data: \(cachedResult.count) strokes")
          return cachedResult
        } catch {
          print("[PencilKit] getAllStrokes() - failed to parse cached data: \(error)")
        }
      }
    }
    
    print("[PencilKit] getAllStrokes() - returning current result: \(result.count) strokes")
    return result
  }
  
  @available(iOS 13.0, *)
  func getStroke(at index: Int) -> [String: Any]? {
    var strokes = canvasView.drawing.strokes
    
    // If current strokes are empty but we have cached strokes, use cached data
    if strokes.isEmpty && _lastStrokeCount > 0 {
      if let data = self._lastDrawingData, !data.isEmpty {
        do {
          let drawing = try PKDrawing(data: data)
          strokes = drawing.strokes
        } catch {
          print("[PencilKit] getStroke() - failed to parse cached data: \(error)")
        }
      }
    }
    
    guard index >= 0 && index < strokes.count else { return nil }
    return strokes[index].toDictionary()
  }
  
  @available(iOS 13.0, *)
  func getStrokesInRegion(_ region: CGRect) -> [[String: Any]] {
    var strokes = canvasView.drawing.strokes
    
    // If current strokes are empty but we have cached strokes, use cached data
    if strokes.isEmpty && _lastStrokeCount > 0 {
      if let data = self._lastDrawingData, !data.isEmpty {
        do {
          let drawing = try PKDrawing(data: data)
          strokes = drawing.strokes
        } catch {
          print("[PencilKit] getStrokesInRegion() - failed to parse cached data: \(error)")
        }
      }
    }
    
    return strokes.filter { stroke in
      stroke.renderBounds.intersects(region)
    }.map { $0.toDictionary() }
  }
  
  @available(iOS 13.0, *)
  func analyzeDrawing() -> [String: Any] {
    var strokes = canvasView.drawing.strokes
    
    // If current strokes are empty but we have cached strokes, use cached data
    if strokes.isEmpty && _lastStrokeCount > 0 {
      if let data = self._lastDrawingData, !data.isEmpty {
        do {
          let drawing = try PKDrawing(data: data)
          strokes = drawing.strokes
        } catch {
          print("[PencilKit] analyzeDrawing() - failed to parse cached data: \(error)")
        }
      }
    }
    var analysis: [String: Any] = [:]
    
    analysis["strokeCount"] = strokes.count
    analysis["totalPoints"] = strokes.reduce(0) { $0 + $1.path.count }
    
    // Analyze ink types
    var inkTypes: [String: Int] = [:]
    var averageForce: Double = 0
    var totalForcePoints = 0
    
    for stroke in strokes {
      let inkType: String
      switch stroke.ink.inkType {
      case .pen: inkType = "pen"
      case .pencil: inkType = "pencil"
      case .marker: inkType = "marker"
      @unknown default: inkType = "unknown"
      }
      
      inkTypes[inkType, default: 0] += 1
      
      // Calculate average force
      for i in 0..<stroke.path.count {
        let point = stroke.path[i]
        averageForce += Double(point.force)
        totalForcePoints += 1
      }
    }
    
    analysis["inkTypes"] = inkTypes
    analysis["averageForce"] = totalForcePoints > 0 ? averageForce / Double(totalForcePoints) : 0
    analysis["bounds"] = [
      "x": canvasView.drawing.bounds.origin.x,
      "y": canvasView.drawing.bounds.origin.y,
      "width": canvasView.drawing.bounds.size.width,
      "height": canvasView.drawing.bounds.size.height
    ]
    
    return analysis
  }
  
  @available(iOS 13.0, *)
  func findStrokesNear(point: CGPoint, threshold: CGFloat) -> [[String: Any]] {
    let strokes = canvasView.drawing.strokes
    var nearbyStrokes: [[String: Any]] = []
    
    for stroke in strokes {
      for i in 0..<stroke.path.count {
        let strokePoint = stroke.path[i]
        let distance = sqrt(pow(strokePoint.location.x - point.x, 2) + pow(strokePoint.location.y - point.y, 2))
        if distance <= threshold {
          nearbyStrokes.append(stroke.toDictionary())
          break // Don't add the same stroke multiple times
        }
      }
    }
    
    return nearbyStrokes
  }
  
  // MARK: - Backward Compatibility & Content Versions
  
  @available(iOS 17.0, *)
  func getContentVersion() -> Int {
    if #available(iOS 17.0, *) {
      return canvasView.drawing.requiredContentVersion.rawValue
    }
    return 1 // Default to version 1 for older iOS versions
  }
  
  @available(iOS 17.0, *)
  func setContentVersion(_ version: Int) {
    if #available(iOS 17.0, *) {
      // This would typically be set when creating new drawings
      // The content version affects which features are available
    }
  }
  
  func getSupportedContentVersions() -> [Int] {
    var versions = [1] // iOS 13.0 baseline
    
    if #available(iOS 14.0, *) {
      versions.append(2) // iOS 14 additions
    }
    
    if #available(iOS 16.0, *) {
      versions.append(3) // iOS 16 additions
    }
    
    if #available(iOS 17.0, *) {
      versions.append(4) // iOS 17 additions
    }
    
    return versions
  }
  
  // MARK: - Advanced Tool Picker Visibility
  
  @available(iOS 14.0, *)
  func setToolPickerVisibility(_ visibility: String, animated: Bool = true) {
    guard let toolPicker = self.toolPicker else { return }
    
    switch visibility {
    case "visible":
      toolPicker.setVisible(true, forFirstResponder: canvasView)
      if animated {
        UIView.animate(withDuration: 0.3) {
          let _ = toolPicker.frameObscured(in: self)
        }
      }
    case "hidden":
      toolPicker.setVisible(false, forFirstResponder: canvasView)
    default:
      // Auto visibility based on responder status
      let shouldShow = canvasView.isFirstResponder
      toolPicker.setVisible(shouldShow, forFirstResponder: canvasView)
    }
  }
  
  @available(iOS 14.0, *)
  func getToolPickerVisibility() -> String {
    guard let toolPicker = self.toolPicker else { return "hidden" }
    
    if toolPicker.isVisible {
      return "visible"
    } else {
      return "hidden"  
    }
  }
  
  // MARK: - Scribble Support
  
  @available(iOS 14.0, *)
  func configureScribbleInteraction(enabled: Bool) {
    if #available(iOS 14.0, *) {
      // Always keep drawing interactions enabled; only add/remove Scribble interaction
      if canvasView.isUserInteractionEnabled == false {
        canvasView.isUserInteractionEnabled = true
      }
      
      // Configure for text input if needed
      if enabled {
        // Avoid adding duplicate interactions
        let hasScribble = canvasView.interactions.contains { $0 is UIScribbleInteraction }
        if !hasScribble {
          let interaction = UIScribbleInteraction(delegate: self)
          canvasView.addInteraction(interaction)
        }
      } else {
        // Remove existing scribble interactions
        canvasView.interactions.forEach { interaction in
          if interaction is UIScribbleInteraction {
            canvasView.removeInteraction(interaction)
          }
        }
      }
    }
  }
  
  @available(iOS 14.0, *)
  func isScribbleAvailable() -> Bool {
    if #available(iOS 14.0, *) {
      // Check if device supports scribble - iPads typically do
      return UIDevice.current.userInterfaceIdiom == .pad
    }
    return false
  }
  
  // MARK: - Advanced Responder State Management
  
  @available(iOS 13.0, *)
  func configureResponderState() -> [String: Any] {
    var state: [String: Any] = [:]
    
    state["isFirstResponder"] = canvasView.isFirstResponder
    state["canBecomeFirstResponder"] = canvasView.canBecomeFirstResponder
    state["canResignFirstResponder"] = canvasView.canResignFirstResponder
    
    // Add PencilKit-specific responder information
    if #available(iOS 14.0, *) {
      if let toolPicker = self.toolPicker {
        state["toolPickerVisible"] = toolPicker.isVisible
        state["toolPickerFrameObscured"] = !toolPicker.frameObscured(in: self).isEmpty
      }
    }
    
    // Touch and pencil input states
    state["allowsFingerDrawing"] = canvasView.allowsFingerDrawing
    state["isRulerActive"] = canvasView.isRulerActive
    
    switch canvasView.drawingPolicy {
    case .default:
      state["drawingPolicy"] = "default"
    case .anyInput:
      state["drawingPolicy"] = "anyInput"
    case .pencilOnly:
      state["drawingPolicy"] = "pencilOnly"
    @unknown default:
      state["drawingPolicy"] = "unknown"
    }
    
    return state
  }
  
  @available(iOS 13.0, *)
  func handleAdvancedTouchEvents(_ enabled: Bool) {
    // Configure advanced touch event handling
    canvasView.isMultipleTouchEnabled = enabled
    
    if enabled {
      // Add gesture recognizers for advanced interactions
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleAdvancedTap(_:)))
      tapGesture.numberOfTapsRequired = 2 // Double tap
      canvasView.addGestureRecognizer(tapGesture)
      
      let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleAdvancedLongPress(_:)))
      canvasView.addGestureRecognizer(longPressGesture)
    }
  }
  
  @objc private func handleAdvancedTap(_ gesture: UITapGestureRecognizer) {
    let location = gesture.location(in: canvasView)
    
    // Dispatch advanced tap event
    onDrawingChanged([
      "type": "advancedTap",
      "location": ["x": location.x, "y": location.y],
      "timestamp": Date().timeIntervalSince1970
    ])
  }
  
  @objc private func handleAdvancedLongPress(_ gesture: UILongPressGestureRecognizer) {
    if gesture.state == .began {
      let location = gesture.location(in: canvasView)
      
      // Find strokes near the long press location
      let nearbyStrokes = findStrokesNear(point: location, threshold: 20.0)
      
      // Dispatch advanced long press event
      onDrawingChanged([
        "type": "advancedLongPress",
        "location": ["x": location.x, "y": location.y],
        "nearbyStrokes": nearbyStrokes,
        "timestamp": Date().timeIntervalSince1970
      ])
    }
  }
  
  // MARK: - Tool management
  
  func applyToolConfiguration() {
    let color = UIColor(hex: _currentToolColor)
    setTool(_currentToolType, color: color, width: _currentToolWidth)
  }
  
  func setTool(_ toolType: String, color: UIColor?, width: CGFloat?) {
    var tool: PKTool
    
    // Adjust tool selection based on ink behavior settings
    var adjustedToolType = toolType
    if _naturalDrawingMode || !_enableInkSmoothing {
      // For natural drawing, prefer marker which has less smoothing
      if toolType == "pen" || toolType == "pencil" {
        adjustedToolType = "marker"
      }
    }
    
    switch adjustedToolType {
    case "pen":
      let inkType: PKInk.InkType = .pen
      let defaultColor = color ?? UIColor.black
      // Adjust width based on refinement settings
      let adjustedWidth = _enableStrokeRefinement ? (width ?? 10.0) : max(width ?? 10.0, 6.0)
      tool = PKInkingTool(inkType, color: defaultColor, width: adjustedWidth)
      
    case "pencil":
      let inkType: PKInk.InkType = .pencil
      let defaultColor = color ?? UIColor.black
      // Pencil with natural settings uses slightly thicker strokes
      let adjustedWidth = _enableStrokeRefinement ? (width ?? 8.0) : max(width ?? 8.0, 8.0)
      tool = PKInkingTool(inkType, color: defaultColor, width: adjustedWidth)
      
    case "marker":
      let inkType: PKInk.InkType = .marker
      let defaultColor = color ?? UIColor.black // Changed from yellow to respect color choice
      // Marker naturally has less smoothing, good for natural drawing
      let adjustedWidth = width ?? 12.0
      tool = PKInkingTool(inkType, color: defaultColor, width: adjustedWidth)
      
    case "eraser":
      if #available(iOS 16.4, *) {
        tool = PKEraserTool(.vector)
      } else {
        tool = PKEraserTool(.bitmap)
      }
      
    case "lasso":
      tool = PKLassoTool()
      
    default:
      tool = PKInkingTool(.pen, color: UIColor.black, width: 10.0)
    }
    
    if #available(iOS 14.0, *) {
      toolPicker?.selectedTool = tool
    }
    canvasView.tool = tool
    
    onToolChanged([
      "toolType": toolType,
      "color": color?.hexString ?? "#000000",
      "width": width ?? 10.0
    ])
  }
}

// MARK: - PKCanvasViewDelegate

extension MunimPencilkitView: PKCanvasViewDelegate {
  func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
    // Ensure event is dispatched on main thread with fresh values
    let drawing = canvasView.drawing
    let hasContent = !drawing.strokes.isEmpty
    let strokeCount = drawing.strokes.count
    let bounds = drawing.bounds
    
    // Debug logging to track state changes
    print("[PencilKit] Drawing changed - current: hasContent=\(hasContent), strokeCount=\(strokeCount), cached: _lastStrokeCount=\(_lastStrokeCount)")
    
    // Update cached state immediately
    self._lastStrokeCount = strokeCount
    self._lastBounds = bounds
    
    // Try immediate serialization
    let immediateData = drawing.dataRepresentation()
    if !immediateData.isEmpty {
      self._lastDrawingData = immediateData
      print("[PencilKit] Drawing changed - immediate serialization successful: \(immediateData.count) bytes")
    } else if strokeCount > 0 {
      print("[PencilKit] Drawing changed - immediate serialization failed, scheduling delayed attempt")
      
      // Schedule delayed serialization attempt
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
        guard let self = self else { return }
        let delayedData = self.canvasView.drawing.dataRepresentation()
        if !delayedData.isEmpty {
          self._lastDrawingData = delayedData
          print("[PencilKit] Drawing changed - delayed serialization successful: \(delayedData.count) bytes")
        } else {
          print("[PencilKit] Drawing changed - delayed serialization also failed, creating fallback data")
          // Create fallback data when both immediate and delayed serialization fail
          if let fallbackData = self.createFallbackStrokeData() {
            self._fallbackStrokeData = fallbackData
            print("[PencilKit] Drawing changed - fallback data created: \(fallbackData.count) bytes")
          }
        }
      }
    }
    
    onDrawingChanged([
      "hasContent": hasContent,
      "strokeCount": strokeCount,
      "bounds": [
        "x": bounds.origin.x,
        "y": bounds.origin.y,
        "width": bounds.size.width,
        "height": bounds.size.height
      ]
    ])
  }
  
  func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
    onDrawingStarted([:])
  }
  
  func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
    onDrawingEnded([:])
  }
  
  func canvasViewDidFinishRendering(_ canvasView: PKCanvasView) {
    // Drawing rendering completed
  }
}

// MARK: - UIColor extension for hex conversion

// MARK: - UIScribbleInteractionDelegate

@available(iOS 14.0, *)
extension MunimPencilkitView: UIScribbleInteractionDelegate {
  func scribbleInteraction(_ interaction: UIScribbleInteraction, shouldBeginAt location: CGPoint) -> Bool {
    // Allow scribble interaction to begin
    return true
  }
  
  func scribbleInteraction(_ interaction: UIScribbleInteraction, shouldDelayFocus: Bool) -> Bool {
    // Don't delay focus for drawing canvas
    return false
  }
  
  func scribbleInteractionWillBeginWriting(_ interaction: UIScribbleInteraction) {
    // Notify that scribble writing is about to begin
    onDrawingChanged([
      "type": "scribbleWillBegin",
      "timestamp": Date().timeIntervalSince1970
    ])
  }
  
  func scribbleInteractionDidFinishWriting(_ interaction: UIScribbleInteraction) {
    // Notify that scribble writing has finished
    onDrawingChanged([
      "type": "scribbleDidFinish", 
      "timestamp": Date().timeIntervalSince1970
    ])
  }
}

// MARK: - UIColor extension for hex conversion

extension UIColor {
  var hexString: String {
    let components = self.cgColor.components
    let r: CGFloat = components?[0] ?? 0.0
    let g: CGFloat = components?[1] ?? 0.0
    let b: CGFloat = components?[2] ?? 0.0
    
    let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
    return hexString
  }
  
  convenience init?(hex: String) {
    let r, g, b, a: CGFloat
    
    if hex.hasPrefix("#") {
      let start = hex.index(hex.startIndex, offsetBy: 1)
      let hexColor = String(hex[start...])
      
      if hexColor.count == 6 {
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        
        if scanner.scanHexInt64(&hexNumber) {
          r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
          g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
          b = CGFloat(hexNumber & 0x0000ff) / 255
          a = 1.0
          
          self.init(red: r, green: g, blue: b, alpha: a)
          return
        }
      }
    }
    
    return nil
  }
}
