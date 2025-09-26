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
      
      // MARK: - Events
      
      Events(
        "onDrawingChanged",
        "onToolChanged", 
        "onDrawingStarted",
        "onDrawingEnded"
      )
    }
  }
}
