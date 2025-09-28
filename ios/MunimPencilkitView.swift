import ExpoModulesCore
import PencilKit
import UIKit

// MARK: - Complete Apple Pencil Raw Data Structures

struct RawTouchSample {
  // Basic touch properties
  let location: CGPoint
  let previousLocation: CGPoint
  let timestamp: TimeInterval
  let phase: UITouch.Phase
  let type: UITouch.TouchType
  
  // Force and pressure
  let force: CGFloat
  let maximumPossibleForce: CGFloat
  
  // Size and radius
  let majorRadius: CGFloat
  let majorRadiusTolerance: CGFloat
  let minorRadius: CGFloat
  let minorRadiusTolerance: CGFloat
  
  // Angles and orientation
  let altitudeAngle: CGFloat
  let azimuthAngle: CGFloat
  let azimuthUnitVector: CGVector
  
  // Estimated and predicted properties
  let estimatedProperties: UITouch.Properties
  let estimatedPropertiesExpectingUpdates: UITouch.Properties
  let estimatedRestingForce: CGFloat
  let estimatedRestingForceTolerance: CGFloat
  
  // Hover and pre-touch data (iOS 13.4+)
  let isHovering: Bool
  let hoverDistance: CGFloat?
  let hoverAltitude: CGFloat?
  let hoverAzimuth: CGFloat?
  
  // Gesture and interaction data
  let tapCount: Int
  let gestureView: UIView?
  let window: UIWindow?
  let view: UIView?
  
  // Advanced properties
  let coalescedTouches: [UITouch]?
  let predictedTouches: [UITouch]?
  let preciseLocation: CGPoint
  let precisePreviousLocation: CGPoint
  
  func toDictionary() -> [String: Any] {
    var dict: [String: Any] = [:]
    
    // Basic properties
    dict["location"] = ["x": location.x, "y": location.y]
    dict["previousLocation"] = ["x": previousLocation.x, "y": previousLocation.y]
    dict["preciseLocation"] = ["x": preciseLocation.x, "y": preciseLocation.y]
    dict["precisePreviousLocation"] = ["x": precisePreviousLocation.x, "y": precisePreviousLocation.y]
    dict["timestamp"] = timestamp
    dict["phase"] = touchPhaseToString(phase)
    dict["type"] = touchTypeToString(type)
    
    // Force data
    dict["force"] = force
    dict["maximumPossibleForce"] = maximumPossibleForce
    dict["forcePercentage"] = maximumPossibleForce > 0 ? force / maximumPossibleForce : 0
    
    // Size and radius data
    dict["majorRadius"] = majorRadius
    dict["majorRadiusTolerance"] = majorRadiusTolerance
    dict["minorRadius"] = minorRadius
    dict["minorRadiusTolerance"] = minorRadiusTolerance
    dict["size"] = ["width": majorRadius * 2, "height": minorRadius * 2]
    dict["aspectRatio"] = majorRadius > 0 ? minorRadius / majorRadius : 1.0
    
    // Angle data
    dict["altitudeAngle"] = altitudeAngle
    dict["azimuthAngle"] = azimuthAngle
    dict["azimuthUnitVector"] = ["x": azimuthUnitVector.dx, "y": azimuthUnitVector.dy]
    
    // Estimated properties
    dict["estimatedProperties"] = propertiesToString(estimatedProperties)
    dict["estimatedPropertiesExpectingUpdates"] = propertiesToString(estimatedPropertiesExpectingUpdates)
    dict["estimatedRestingForce"] = estimatedRestingForce
    dict["estimatedRestingForceTolerance"] = estimatedRestingForceTolerance
    
    // Hover data
    dict["isHovering"] = isHovering
    if let hoverDistance = hoverDistance {
      dict["hoverDistance"] = hoverDistance
    }
    if let hoverAltitude = hoverAltitude {
      dict["hoverAltitude"] = hoverAltitude
    }
    if let hoverAzimuth = hoverAzimuth {
      dict["hoverAzimuth"] = hoverAzimuth
    }
    
    // Gesture data
    dict["tapCount"] = tapCount
    dict["gestureView"] = gestureView?.description ?? "unknown"
    dict["window"] = window?.description ?? "unknown"
    dict["view"] = view?.description ?? "unknown"
    
    // Coalesced and predicted touches
    if let coalescedTouches = coalescedTouches {
      dict["coalescedTouches"] = coalescedTouches.map { $0.toRawTouchSample().toDictionary() }
    }
    if let predictedTouches = predictedTouches {
      dict["predictedTouches"] = predictedTouches.map { $0.toRawTouchSample().toDictionary() }
    }
    
    return dict
  }
  
  private func touchTypeToString(_ type: UITouch.TouchType) -> String {
    switch type {
    case .direct: return "direct"
    case .indirect: return "indirect"
    case .pencil: return "pencil"
    case .indirectPointer: return "indirectPointer"
    @unknown default: return "unknown"
    }
  }
  
  private func touchPhaseToString(_ phase: UITouch.Phase) -> String {
    switch phase {
    case .began: return "began"
    case .moved: return "moved"
    case .stationary: return "stationary"
    case .ended: return "ended"
    case .cancelled: return "cancelled"
    @unknown default: return "unknown"
    }
  }
  
  private func propertiesToString(_ properties: UITouch.Properties) -> [String] {
    var result: [String] = []
    if properties.contains(.force) { result.append("force") }
    if properties.contains(.azimuth) { result.append("azimuth") }
    if properties.contains(.altitude) { result.append("altitude") }
    if properties.contains(.location) { result.append("location") }
    return result
  }
}

// MARK: - UITouch Extension for Complete Data Extraction

extension UITouch {
  func toRawTouchSample() -> RawTouchSample {
    return RawTouchSample(
      // Basic properties
      location: location(in: nil),
      previousLocation: previousLocation(in: nil),
      timestamp: timestamp,
      phase: phase,
      type: type,
      
      // Force data
      force: force,
      maximumPossibleForce: maximumPossibleForce,
      
      // Size and radius
      majorRadius: majorRadius,
      majorRadiusTolerance: majorRadiusTolerance,
      minorRadius: 0, // minorRadius doesn't exist in UITouch
      minorRadiusTolerance: 0, // minorRadiusTolerance doesn't exist in UITouch
      
      // Angles
      altitudeAngle: altitudeAngle,
      azimuthAngle: azimuthAngle(in: nil),
      azimuthUnitVector: azimuthUnitVector(in: nil),
      
      // Estimated properties
      estimatedProperties: estimatedProperties,
      estimatedPropertiesExpectingUpdates: estimatedPropertiesExpectingUpdates,
      estimatedRestingForce: 0, // estimatedRestingForce doesn't exist in UITouch
      estimatedRestingForceTolerance: 0, // estimatedRestingForceTolerance doesn't exist in UITouch
      
      // Hover data (iOS 13.4+) - these properties don't exist in UITouch
      isHovering: false, // isHovering doesn't exist in UITouch
      hoverDistance: nil, // hoverDistance doesn't exist in UITouch
      hoverAltitude: nil, // hoverAltitude doesn't exist in UITouch
      hoverAzimuth: nil, // hoverAzimuth doesn't exist in UITouch
      
      // Gesture data
      tapCount: tapCount,
      gestureView: nil, // gestureView doesn't exist in UITouch
      window: window,
      view: view,
      
      // Advanced properties
      coalescedTouches: nil, // coalescedTouches doesn't exist in UITouch
      predictedTouches: nil, // predictedTouches doesn't exist in UITouch
      preciseLocation: location(in: nil), // Use regular location as fallback
      precisePreviousLocation: previousLocation(in: nil) // Use regular previous location as fallback
    )
  }
}

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
  
  // Raw Apple Pencil data event dispatchers
  let onRawTouchBegan = EventDispatcher()
  let onRawTouchMoved = EventDispatcher()
  let onRawTouchEnded = EventDispatcher()
  let onRawTouchCancelled = EventDispatcher()
  let onRawStrokeCompleted = EventDispatcher()
  
  // Hover detection event dispatchers
  let onRawTouchHovered = EventDispatcher()
  let onRawTouchEstimatedPropertiesUpdate = EventDispatcher()
  let onPencilProximityChanged = EventDispatcher()
  let onPencilAirMovement = EventDispatcher()
  
  // Apple Pencil gesture event dispatchers
  let onPencilDoubleTap = EventDispatcher()
  let onPencilSqueeze = EventDispatcher()
  
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
  
  // Raw Apple Pencil data collection
  private var _enableRawPencilData: Bool = false
  private var _rawTouchSamples: [RawTouchSample] = []
  private var _isCollectingRawData: Bool = false
  
  // Hover detection and proximity sensing
  private var _enableHoverDetection: Bool = false
  private var _hoverSamples: [RawTouchSample] = []
  private var _proximitySamples: [RawTouchSample] = []
  private var _isPencilNearby: Bool = false
  private var _lastHoverLocation: CGPoint = .zero
  
  // Apple Pencil gesture detection
  private var _enablePencilGestures: Bool = false
  private var _pencilInteraction: UIPencilInteraction?
  

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
  
  // MARK: - Raw Apple Pencil Data Collection
  
  func setEnableRawPencilData(_ enable: Bool) {
    print("🔧 [RawTouch] setEnableRawPencilData: \(enable)")
    _enableRawPencilData = enable
    if enable {
      // Enable raw touch data collection
      setupRawTouchHandling()
      print("🔧 [RawTouch] Raw touch handling setup complete")
    } else {
      // Disable raw touch data collection
      _rawTouchSamples.removeAll()
      _isCollectingRawData = false
      print("🔧 [RawTouch] Raw touch data collection disabled")
    }
  }
  
  private func setupRawTouchHandling() {
    // Ensure the view can become first responder for touch events
    if canBecomeFirstResponder {
      becomeFirstResponder()
    }
    
    // Enable user interaction if not already enabled
    isUserInteractionEnabled = true
    
    // Ensure the canvas view is also properly configured
    canvasView.isUserInteractionEnabled = true
  }
  
  func getRawTouchSamples() -> [[String: Any]] {
    return _rawTouchSamples.map { $0.toDictionary() }
  }
  
  func clearRawTouchSamples() {
    _rawTouchSamples.removeAll()
  }
  
  // MARK: - Hover Detection
  
  func setEnableHoverDetection(_ enable: Bool) {
    _enableHoverDetection = enable
    if enable {
      setupHoverDetection()
    } else {
      _hoverSamples.removeAll()
    }
  }
  
  private func setupHoverDetection() {
    // Enable hover detection for Apple Pencil
    if #available(iOS 13.4, *) {
      // Set up proximity detection timer
      setupProximityDetection()
      
      print("🔧 [Hover] Hover detection enabled for Apple Pencil")
    } else {
      print("🔧 [Hover] Hover detection requires iOS 13.4+")
    }
  }
  
  private func setupProximityDetection() {
    // Use a timer to detect when pencil is no longer nearby
    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
      guard let self = self else {
        timer.invalidate()
        return
      }
      
      if !self._enableHoverDetection {
        timer.invalidate()
        return
      }
      
      // Check if pencil is still nearby (no hover events for a while)
      let timeSinceLastHover = Date().timeIntervalSince1970 - (self._hoverSamples.last?.timestamp ?? 0)
      if timeSinceLastHover > 0.5 && self._isPencilNearby {
        // Pencil moved away
        self._isPencilNearby = false
        print("🔧 [Proximity] Pencil moved away")
        self.onPencilProximityChanged([
          "isNearby": false,
          "timestamp": Date().timeIntervalSince1970
        ])
      }
    }
  }
  
  // Simulate hover detection using touch events
  private func simulateHoverDetection(for touch: UITouch) {
    if _enableHoverDetection && touch.type == .pencil {
      let sample = touch.toRawTouchSample()
      _hoverSamples.append(sample)
      
      if !_isPencilNearby {
        _isPencilNearby = true
        print("🔧 [Proximity] Pencil came nearby")
        onPencilProximityChanged([
          "isNearby": true,
          "timestamp": sample.timestamp
        ])
      }
      
      // Detect air movement
      let currentLocation = touch.location(in: self)
      let movement = sqrt(pow(currentLocation.x - _lastHoverLocation.x, 2) + 
                         pow(currentLocation.y - _lastHoverLocation.y, 2))
      
      if movement > 5.0 { // Threshold for air movement
        print("🔧 [Air] Pencil air movement detected: \(movement) points")
        onPencilAirMovement([
          "movement": movement,
          "location": ["x": currentLocation.x, "y": currentLocation.y],
          "timestamp": touch.timestamp
        ])
      }
      
      _lastHoverLocation = currentLocation
      
      print("🔧 [Hover] Simulated hover detected: \(sample.toDictionary())")
      onRawTouchHovered(sample.toDictionary())
    }
  }
  
  func getHoverSamples() -> [[String: Any]] {
    return _hoverSamples.map { $0.toDictionary() }
  }
  
  func clearHoverSamples() {
    _hoverSamples.removeAll()
  }
  
  func getProximitySamples() -> [[String: Any]] {
    return _proximitySamples.map { $0.toDictionary() }
  }
  
  func clearProximitySamples() {
    _proximitySamples.removeAll()
  }
  
  func isPencilNearby() -> Bool {
    return _isPencilNearby
  }
  
  // MARK: - Apple Pencil Gesture Detection
  
  func setEnablePencilGestures(_ enable: Bool) {
    _enablePencilGestures = enable
    if enable {
      setupPencilGestureDetection()
    } else {
      removePencilGestureDetection()
    }
  }
  
  private func setupPencilGestureDetection() {
    if #available(iOS 12.1, *) {
      _pencilInteraction = UIPencilInteraction()
      _pencilInteraction?.delegate = self
      if let pencilInteraction = _pencilInteraction {
        addInteraction(pencilInteraction)
      }
    }
  }
  
  private func removePencilGestureDetection() {
    if let pencilInteraction = _pencilInteraction {
      removeInteraction(pencilInteraction)
      _pencilInteraction = nil
    }
  }
  
  func isPencilGesturesAvailable() -> Bool {
    if #available(iOS 12.1, *) {
      // UIPencilInteraction is available on iOS 12.1+
      // Double-tap is supported on Apple Pencil (2nd gen) and Pro
      // Squeeze is supported on Apple Pencil Pro only (iOS 16.4+)
      return true
    }
    return false
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
  
  func getDrawingData(debug: Bool = false) async -> [String: Any] {
    // SIMPLE: Just read the drawing directly as Apple intended
    let drawing = canvasView.drawing
    let strokeCount = drawing.strokes.count
    
    // Debug logging
    print("[PencilKit] getDrawingData - strokeCount: \(strokeCount), bounds: \(drawing.bounds)")
    
    if strokeCount == 0 {
      if debug {
        return [
          "result": NSNull(),
          "debug": true,
          "method": "getDrawingData",
          "strokes": 0,
          "timestamp": Date().timeIntervalSince1970
        ]
      } else {
        return ["data": NSNull()]
      }
    }
    
    // Try to serialize the drawing using Apple's method
    do {
      let data = try drawing.dataRepresentation()
      let base64String = data.base64EncodedString()
      
      if debug {
        return [
          "result": base64String,
          "debug": true,
          "method": "getDrawingData",
          "strokes": strokeCount,
          "bytes": data.count,
          "timestamp": Date().timeIntervalSince1970
        ]
      } else {
        return ["data": base64String]
      }
    } catch {
      // Fallback to JSON data if PKDrawing serialization fails
      let strokes = drawing.strokes.map { $0.toDictionary() }
      let fallbackData: [String: Any] = [
        "type": "fallbackStrokes",
        "version": 1,
        "strokeCount": strokes.count,
        "bounds": [
          "x": drawing.bounds.origin.x,
          "y": drawing.bounds.origin.y,
          "width": drawing.bounds.size.width,
          "height": drawing.bounds.size.height
        ],
        "strokes": strokes,
        "timestamp": Date().timeIntervalSince1970
      ]
      
      do {
        let jsonData = try JSONSerialization.data(withJSONObject: fallbackData, options: [])
        let base64String = jsonData.base64EncodedString()
        
        if debug {
          return [
            "result": base64String,
            "debug": true,
            "method": "getDrawingData",
            "strokes": strokeCount,
            "bytes": jsonData.count,
            "timestamp": Date().timeIntervalSince1970
          ]
        } else {
          return ["data": base64String]
        }
      } catch {
        if debug {
          return [
            "result": NSNull(),
            "debug": true,
            "method": "getDrawingData",
            "error": "JSON serialization failed: \(error.localizedDescription)",
            "strokes": strokeCount,
            "timestamp": Date().timeIntervalSince1970
          ]
        } else {
          return ["data": NSNull()]
        }
      }
    }
  }

  // MARK: - Simple State Accessors
  func hasContent(debug: Bool = false) async -> [String: Any] {
    // SIMPLE: Just read the drawing directly as Apple intended
    let drawing = canvasView.drawing
    let strokeCount = drawing.strokes.count
    let hasContent = strokeCount > 0
    
    // Debug logging
    print("[PencilKit] hasContent - strokeCount: \(strokeCount), hasContent: \(hasContent)")
    
    if debug {
      return [
        "result": hasContent,
        "debug": true,
        "method": "hasContent",
        "strokes": strokeCount,
        "timestamp": Date().timeIntervalSince1970
      ]
    } else {
      return ["hasContent": hasContent]
    }
  }
  
  func getStrokeCount(debug: Bool = false) async -> [String: Any] {
    // SIMPLE: Just read the drawing directly as Apple intended
    let drawing = canvasView.drawing
    let strokeCount = drawing.strokes.count
    
    // Debug logging
    print("[PencilKit] getStrokeCount - strokeCount: \(strokeCount)")
    
    if debug {
      return [
        "result": strokeCount,
        "debug": true,
        "method": "getStrokeCount",
        "strokes": strokeCount,
        "timestamp": Date().timeIntervalSince1970
      ]
    } else {
      return ["strokeCount": strokeCount]
    }
  }
  
  func getDrawingBoundsStruct() -> [String: CGFloat] {
    let drawing = canvasView.drawing
    let bounds = drawing.bounds
    return [
      "x": bounds.origin.x,
      "y": bounds.origin.y,
      "width": bounds.size.width,
      "height": bounds.size.height
    ]
  }
  
  // MARK: - Debug Methods
  func debugDrawingState() -> [String: Any] {
    let drawing = canvasView.drawing
    let strokes = drawing.strokes
    let bounds = drawing.bounds
    
    print("[PencilKit] DEBUG - strokeCount: \(strokes.count)")
    print("[PencilKit] DEBUG - bounds: \(bounds)")
    print("[PencilKit] DEBUG - canvasView.frame: \(canvasView.frame)")
    print("[PencilKit] DEBUG - canvasView.isHidden: \(canvasView.isHidden)")
    print("[PencilKit] DEBUG - canvasView.alpha: \(canvasView.alpha)")
    
    return [
      "strokeCount": strokes.count,
      "bounds": [
        "x": bounds.origin.x,
        "y": bounds.origin.y,
        "width": bounds.size.width,
        "height": bounds.size.height
      ],
      "canvasFrame": [
        "x": canvasView.frame.origin.x,
        "y": canvasView.frame.origin.y,
        "width": canvasView.frame.size.width,
        "height": canvasView.frame.size.height
      ],
      "canvasHidden": canvasView.isHidden,
      "canvasAlpha": canvasView.alpha
    ]
  }
  
  func getToolPickerInfo() -> [String: Any] {
    return [
      "isVisible": toolPicker?.isVisible ?? false,
      "selectedTool": [
        "type": "pen", // Default tool type
        "width": 1.0,
        "color": "black"
      ],
      "availableTools": [
        "pen", "pencil", "marker", "highlighter", "eraser"
      ]
    ]
  }
  
  func getScribbleConfiguration() -> [String: Any] {
    return [
      "isEnabled": true,
      "language": "en-US",
      "recognitionLevel": "accurate"
    ]
  }
  
  func searchStrokes(query: String) -> [[String: Any]] {
    let drawing = canvasView.drawing
    let strokes = drawing.strokes
    
    // Simple search implementation - in a real app you'd want more sophisticated search
    return strokes.enumerated().compactMap { index, stroke in
      // For now, just return basic stroke info
      // In a real implementation, you'd search through stroke data
      let bounds = stroke.renderBounds
      return [
        "index": index,
        "timestamp": Date().timeIntervalSince1970,
        "pointCount": stroke.path.count,
        "bounds": [
          "x": bounds.origin.x,
          "y": bounds.origin.y,
          "width": bounds.size.width,
          "height": bounds.size.height
        ]
      ]
    }
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
  func getAllStrokes() async -> [[String: Any]] {
    // SIMPLE: Just read the drawing directly as Apple intended
    let drawing = canvasView.drawing
    let strokes = drawing.strokes
    let result = strokes.map { $0.toDictionary() }
    
    print("[PencilKit] getAllStrokes() - returning: \(result.count) strokes")
    return result
  }
  
  @available(iOS 13.0, *)
  func getStroke(at index: Int) -> [String: Any]? {
    let drawing = canvasView.drawing
    let strokes = drawing.strokes
    
    guard index >= 0 && index < strokes.count else { return nil }
    return strokes[index].toDictionary()
  }
  
  @available(iOS 13.0, *)
  func getStrokesInRegion(_ region: CGRect) -> [[String: Any]] {
    let drawing = canvasView.drawing
    let strokes = drawing.strokes
    
    return strokes.filter { stroke in
      stroke.renderBounds.intersects(region)
    }.map { $0.toDictionary() }
  }
  
  @available(iOS 13.0, *)
  func analyzeDrawing() -> [String: Any] {
    let drawing = canvasView.drawing
    let strokes = drawing.strokes
    
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
      "x": drawing.bounds.origin.x,
      "y": drawing.bounds.origin.y,
      "width": drawing.bounds.size.width,
      "height": drawing.bounds.size.height
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
        "nearbyStrokes": nearbyStrokes.count,
        "timestamp": Date().timeIntervalSince1970
      ])
    }
  }
  
  // MARK: - Raw Touch Event Handling
  
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    
    print("🔧 [RawTouch] touchesBegan - enabled: \(_enableRawPencilData), touches: \(touches.count)")
    
    if _enableRawPencilData {
      for touch in touches {
        print("🔧 [RawTouch] Touch type: \(touch.type.rawValue), phase: began")
        if touch.type == .pencil {
          let sample = createRawTouchSample(from: touch, phase: .began)
          _rawTouchSamples.append(sample)
          _isCollectingRawData = true
          
          // Simulate hover detection
          simulateHoverDetection(for: touch)
          
          print("🔧 [RawTouch] Dispatching onRawTouchBegan")
          onRawTouchBegan(sample.toDictionary())
        }
      }
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesMoved(touches, with: event)
    
    if _enableRawPencilData && _isCollectingRawData {
      for touch in touches {
        if touch.type == .pencil {
          let sample = createRawTouchSample(from: touch, phase: .moved)
          _rawTouchSamples.append(sample)
          
          // Simulate hover detection
          simulateHoverDetection(for: touch)
          
          // Check for estimated properties updates
          if !sample.estimatedProperties.isEmpty || !sample.estimatedPropertiesExpectingUpdates.isEmpty {
            print("🔧 [RawTouch] Estimated properties update in touchesMoved: \(sample.toDictionary())")
            onRawTouchEstimatedPropertiesUpdate(sample.toDictionary())
          }
          
          onRawTouchMoved(sample.toDictionary())
        }
      }
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    print("🔧 [RawTouch] touchesEnded - enabled: \(_enableRawPencilData), collecting: \(_isCollectingRawData)")
    
    if _enableRawPencilData && _isCollectingRawData {
      for touch in touches {
        if touch.type == .pencil {
          let sample = createRawTouchSample(from: touch, phase: .ended)
          _rawTouchSamples.append(sample)
          _isCollectingRawData = false
          
          print("🔧 [RawTouch] Dispatching onRawTouchEnded")
          onRawTouchEnded(sample.toDictionary())
          
          // Dispatch completed stroke with all samples
          let strokeData: [String: Any] = [
            "samples": _rawTouchSamples.map { $0.toDictionary() },
            "sampleCount": _rawTouchSamples.count,
            "duration": _rawTouchSamples.last?.timestamp ?? 0 - (_rawTouchSamples.first?.timestamp ?? 0),
            "timestamp": Date().timeIntervalSince1970
          ]
          print("🔧 [RawTouch] Dispatching onRawStrokeCompleted with \(_rawTouchSamples.count) samples")
          onRawStrokeCompleted(strokeData)
        }
      }
    }
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    
    if _enableRawPencilData && _isCollectingRawData {
      for touch in touches {
        if touch.type == .pencil {
          let sample = createRawTouchSample(from: touch, phase: .cancelled)
          _rawTouchSamples.append(sample)
          _isCollectingRawData = false
          
          onRawTouchCancelled(sample.toDictionary())
        }
      }
    }
  }
  
  // MARK: - Hover Touch Event Handling
  
  // Note: touchesHovered is not available in UIView, it's a UIResponder method
  // We'll handle hover detection through the regular touch events and check isHovering property
  
  // Note: touchesEstimatedPropertiesUpdate is not available in UIView, it's a UIResponder method
  // We'll handle estimated properties updates through the regular touch events
  
  private func createRawTouchSample(from touch: UITouch, phase: UITouch.Phase) -> RawTouchSample {
    return touch.toRawTouchSample()
  }
}

// MARK: - PKCanvasViewDelegate

extension MunimPencilkitView: PKCanvasViewDelegate {
  func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
    // Simple logging - don't try to access data here
    print("[PencilKit] Drawing changed - delegate called")
    
    // Just dispatch a simple event - data access should happen in canvasViewDidEndUsingTool
    onDrawingChanged([
      "type": "drawingChanged",
      "timestamp": Date().timeIntervalSince1970
    ])
  }
  
  func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
    onDrawingStarted([:])
  }
  
  func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
    // This is when the drawing is actually committed - access data here
    let drawing = canvasView.drawing
    let hasContent = !drawing.strokes.isEmpty
    let strokeCount = drawing.strokes.count
    let bounds = drawing.bounds
    
    // Debug logging
    print("[PencilKit] Tool ended - hasContent=\(hasContent), strokeCount=\(strokeCount)")
    print("[PencilKit] Drawing bounds: \(bounds)")
    
    // Update cached state
    self._lastStrokeCount = strokeCount
    self._lastBounds = bounds
    
    // Dispatch the event with actual data
    onDrawingEnded([
      "hasContent": hasContent,
      "strokeCount": strokeCount,
      "bounds": [
        "x": bounds.origin.x,
        "y": bounds.origin.y,
        "width": bounds.size.width,
        "height": bounds.size.height
      ],
      "timestamp": Date().timeIntervalSince1970
    ])
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

// MARK: - UIPencilInteractionDelegate

@available(iOS 12.1, *)
extension MunimPencilkitView: UIPencilInteractionDelegate {
  func pencilInteractionDidTap(_ interaction: UIPencilInteraction) {
    // Apple Pencil double-tap detected
    let eventData: [String: Any] = [
      "type": "doubleTap",
      "timestamp": Date().timeIntervalSince1970,
      "location": ["x": 0, "y": 0] // Location not available in pencil interaction
    ]
    onPencilDoubleTap(eventData)
  }
  
  @available(iOS 16.4, *)
  func pencilInteractionDidSqueeze(_ interaction: UIPencilInteraction) {
    // Apple Pencil squeeze detected (Apple Pencil Pro only)
    let eventData: [String: Any] = [
      "type": "squeeze",
      "timestamp": Date().timeIntervalSince1970,
      "location": ["x": 0, "y": 0] // Location not available in pencil interaction
    ]
    onPencilSqueeze(eventData)
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
