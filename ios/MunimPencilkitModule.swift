import ExpoModulesCore
import PencilKit
import UIKit

public class MunimPencilkitModule: Module {
  public func definition() -> ModuleDefinition {
    Name("MunimPencilkit")

    // Defines event names that the module can send to JavaScript.
    Events("onDrawingChanged", "onToolChanged", "onDrawingStarted", "onDrawingEnded")

    // MARK: - Drawing Management Functions
    
    AsyncFunction("exportDrawingAsImage") { (scale: Double) -> String? in
      // This will be handled by the view's method
      return nil
    }
    
    AsyncFunction("exportDrawingAsData") -> Data? {
      // This will be handled by the view's method
      return nil
    }
    
    AsyncFunction("exportDrawingAsPDF") { (scale: Double) -> Data? in
      // This will be handled by the view's method  
      return nil
    }

    // MARK: - Tool Management Functions
    
    Function("getAvailableTools") {
      return [
        "pen": [
          "type": "pen",
          "name": "Pen",
          "supportsColor": true,
          "supportsWidth": true,
          "minWidth": 1.0,
          "maxWidth": 100.0
        ],
        "pencil": [
          "type": "pencil", 
          "name": "Pencil",
          "supportsColor": true,
          "supportsWidth": true,
          "minWidth": 1.0,
          "maxWidth": 50.0
        ],
        "marker": [
          "type": "marker",
          "name": "Marker", 
          "supportsColor": true,
          "supportsWidth": true,
          "minWidth": 5.0,
          "maxWidth": 100.0
        ],
        "eraser": [
          "type": "eraser",
          "name": "Eraser",
          "supportsColor": false,
          "supportsWidth": true,
          "minWidth": 5.0,
          "maxWidth": 200.0
        ],
        "lasso": [
          "type": "lasso",
          "name": "Lasso Tool",
          "supportsColor": false,
          "supportsWidth": false
        ]
      ]
    }
    
    Function("getInkTypes") {
      return [
        "pen": "Creates crisp, precise lines that are ideal for writing and detailed drawings",
        "pencil": "Creates soft, textured lines that simulate a real pencil",
        "marker": "Creates broad, semi-transparent lines ideal for highlighting"
      ]
    }

    // MARK: - View Configuration
    
    View(MunimPencilkitView.self) {
      // Canvas configuration props
      Prop("showToolPicker") { (view: MunimPencilkitView, show: Bool) in
        view.setShowToolPicker(show)
      }
      
      Prop("allowsFingerDrawing") { (view: MunimPencilkitView, allows: Bool) in
        view.setAllowsFingerDrawing(allows)
      }
      
      Prop("isRulerActive") { (view: MunimPencilkitView, active: Bool) in
        view.setIsRulerActive(active)
      }
      
      Prop("drawingPolicy") { (view: MunimPencilkitView, policy: String) in
        view.setDrawingPolicy(policy)
      }
      
      Prop("backgroundColor") { (view: MunimPencilkitView, color: String) in
        if let uiColor = UIColor(hex: color) {
          view.setBackgroundColor(uiColor)
        }
      }
      
      // Tool configuration props
      Prop("toolType") { (view: MunimPencilkitView, toolType: String, color: String?, width: Double?) in
        let uiColor = color.flatMap { UIColor(hex: $0) }
        let cgWidth = width.map { CGFloat($0) }
        view.setTool(toolType, color: uiColor, width: cgWidth)
      }
      
      // Drawing data props
      Prop("drawingData") { (view: MunimPencilkitView, data: Data) in
        view.loadDrawingData(data)
      }

      // MARK: - View Methods
      
      AsyncFunction("clearDrawing") { (view: MunimPencilkitView) in
        view.clearDrawing()
      }
      
      AsyncFunction("undo") { (view: MunimPencilkitView) in
        view.undo()
      }
      
      AsyncFunction("redo") { (view: MunimPencilkitView) in  
        view.redo()
      }
      
      AsyncFunction("getDrawingData") { (view: MunimPencilkitView) -> Data? in
        return view.getDrawingData()
      }
      
      AsyncFunction("exportAsImage") { (view: MunimPencilkitView, scale: Double) -> String? in
        guard let image = view.exportDrawingAsImage(scale: CGFloat(scale)),
              let imageData = image.pngData() else {
          return nil
        }
        return imageData.base64EncodedString()
      }
      
      AsyncFunction("exportAsPDF") { (view: MunimPencilkitView, scale: Double) -> Data? in
        guard let image = view.exportDrawingAsImage(scale: CGFloat(scale)) else {
          return nil
        }
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, CGRect.zero, nil)
        UIGraphicsBeginPDFPage()
        
        if let context = UIGraphicsGetCurrentContext() {
          image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        }
        
        UIGraphicsEndPDFContext()
        return pdfData as Data
      }
      
      AsyncFunction("setTool") { (view: MunimPencilkitView, toolType: String, color: String?, width: Double?) in
        let uiColor = color.flatMap { UIColor(hex: $0) }
        let cgWidth = width.map { CGFloat($0) }
        view.setTool(toolType, color: uiColor, width: cgWidth)
      }
      
      // MARK: - Advanced Stroke Inspection
      
      AsyncFunction("getAllStrokes") { (view: MunimPencilkitView) -> [[String: Any]] in
        return view.getAllStrokes()
      }
      
      AsyncFunction("getStroke") { (view: MunimPencilkitView, index: Int) -> [String: Any]? in
        return view.getStroke(at: index)
      }
      
      AsyncFunction("getStrokesInRegion") { (view: MunimPencilkitView, x: Double, y: Double, width: Double, height: Double) -> [[String: Any]] in
        let region = CGRect(x: x, y: y, width: width, height: height)
        return view.getStrokesInRegion(region)
      }
      
      AsyncFunction("analyzeDrawing") { (view: MunimPencilkitView) -> [String: Any] in
        return view.analyzeDrawing()
      }
      
      AsyncFunction("findStrokesNear") { (view: MunimPencilkitView, x: Double, y: Double, threshold: Double) -> [[String: Any]] in
        let point = CGPoint(x: x, y: y)
        return view.findStrokesNear(point: point, threshold: CGFloat(threshold))
      }
      
      // MARK: - Backward Compatibility & Content Versions
      
      AsyncFunction("getContentVersion") { (view: MunimPencilkitView) -> Int in
        if #available(iOS 17.0, *) {
          return view.getContentVersion()
        }
        return 1
      }
      
      AsyncFunction("getSupportedContentVersions") { (view: MunimPencilkitView) -> [Int] in
        return view.getSupportedContentVersions()
      }
      
      AsyncFunction("setContentVersion") { (view: MunimPencilkitView, version: Int) in
        if #available(iOS 17.0, *) {
          view.setContentVersion(version)
        }
      }
      
      // MARK: - Advanced Tool Picker Visibility
      
      AsyncFunction("setToolPickerVisibility") { (view: MunimPencilkitView, visibility: String, animated: Bool) in
        if #available(iOS 14.0, *) {
          view.setToolPickerVisibility(visibility, animated: animated)
        }
      }
      
      AsyncFunction("getToolPickerVisibility") { (view: MunimPencilkitView) -> String in
        if #available(iOS 14.0, *) {
          return view.getToolPickerVisibility()
        }
        return "hidden"
      }
      
      // MARK: - Scribble Support
      
      AsyncFunction("configureScribbleInteraction") { (view: MunimPencilkitView, enabled: Bool) in
        if #available(iOS 14.0, *) {
          view.configureScribbleInteraction(enabled: enabled)
        }
      }
      
      AsyncFunction("isScribbleAvailable") { (view: MunimPencilkitView) -> Bool in
        if #available(iOS 14.0, *) {
          return view.isScribbleAvailable()
        }
        return false
      }
      
      // MARK: - Advanced Responder State Management
      
      AsyncFunction("getResponderState") { (view: MunimPencilkitView) -> [String: Any] in
        return view.configureResponderState()
      }
      
      AsyncFunction("handleAdvancedTouchEvents") { (view: MunimPencilkitView, enabled: Bool) in
        view.handleAdvancedTouchEvents(enabled)
      }
      
      // MARK: - Advanced Drawing Features
      
      AsyncFunction("createStrokeFromPoints") { (view: MunimPencilkitView, points: [[String: Any]], inkType: String, color: String, width: Double) -> Bool in
        // This would create a custom stroke from point data
        // Implementation would require converting the points array back to PKStrokePoints
        return true
      }
      
      AsyncFunction("replaceStroke") { (view: MunimPencilkitView, index: Int, newStrokeData: [String: Any]) -> Bool in
        // This would replace a stroke at the given index
        // Implementation would require advanced PKDrawing manipulation
        return true
      }
      
      AsyncFunction("getDrawingStatistics") { (view: MunimPencilkitView) -> [String: Any] in
        let analysis = view.analyzeDrawing()
        var stats = analysis
        
        // Add additional statistics
        stats["timestamp"] = Date().timeIntervalSince1970
        stats["canvasSize"] = [
          "width": view.canvasView.bounds.width,
          "height": view.canvasView.bounds.height
        ]
        
        return stats
      }
      
      // MARK: - Events
      
      Events(
        "onDrawingChanged",
        "onToolChanged", 
        "onDrawingStarted",
        "onDrawingEnded",
        "onAdvancedTap",
        "onAdvancedLongPress",
        "onScribbleWillBegin",
        "onScribbleDidFinish"
      )
    }
  }
}
