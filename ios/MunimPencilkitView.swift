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
    
    // Add stroke UUID if available (iOS 14+)
    if #available(iOS 14.0, *) {
      strokeDict["uuid"] = uuid.uuidString
    }
    
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
      let point = self.point(at: i)
      points.append(point.toDictionary())
    }
    pathDict["points"] = points
    
    // Get interpolated points for smoother representation
    if count > 1 {
      var interpolatedPoints: [[String: Any]] = []
      let step: Float = 1.0 / Float(max(count * 2, 10))
      var t: Float = 0.0
      while t <= 1.0 {
        let interpolatedPoint = self.interpolatedPoint(at: CGFloat(t))
        interpolatedPoints.append(interpolatedPoint.toDictionary())
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

  required init(appContext: AppContext? = nil) {
    super.init(appContext: appContext)
    setupCanvasView()
    setupToolPicker()
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
  
  func clearDrawing() {
    canvasView.drawing = PKDrawing()
    onDrawingChanged(["hasContent": false])
  }
  
  func undo() {
    canvasView.undoManager?.undo()
  }
  
  func redo() {
    canvasView.undoManager?.redo()
  }
  
  func getDrawingData() -> Data? {
    return canvasView.drawing.dataRepresentation()
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
    let bounds = canvasView.drawing.bounds.isEmpty ? canvasView.bounds : canvasView.drawing.bounds
    return canvasView.drawing.image(from: bounds, scale: scale)
  }
  
  func setBackgroundColor(_ color: UIColor) {
    canvasView.backgroundColor = color
  }
  
  // MARK: - Tool management
  
  func setTool(_ toolType: String, color: UIColor?, width: CGFloat?) {
    var tool: PKTool
    
    switch toolType {
    case "pen":
      let inkType: PKInkType = .pen
      let defaultColor = color ?? UIColor.black
      let defaultWidth = width ?? 10.0
      tool = PKInkingTool(inkType, color: defaultColor, width: defaultWidth)
      
    case "pencil":
      let inkType: PKInkType = .pencil
      let defaultColor = color ?? UIColor.black
      let defaultWidth = width ?? 10.0
      tool = PKInkingTool(inkType, color: defaultColor, width: defaultWidth)
      
    case "marker":
      let inkType: PKInkType = .marker
      let defaultColor = color ?? UIColor.yellow
      let defaultWidth = width ?? 20.0
      tool = PKInkingTool(inkType, color: defaultColor, width: defaultWidth)
      
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
    let hasContent = !canvasView.drawing.strokes.isEmpty
    let strokeCount = canvasView.drawing.strokes.count
    
    onDrawingChanged([
      "hasContent": hasContent,
      "strokeCount": strokeCount,
      "bounds": [
        "x": canvasView.drawing.bounds.origin.x,
        "y": canvasView.drawing.bounds.origin.y,
        "width": canvasView.drawing.bounds.size.width,
        "height": canvasView.drawing.bounds.size.height
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
