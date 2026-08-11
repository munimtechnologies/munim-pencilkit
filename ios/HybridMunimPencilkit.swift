import Foundation
import PencilKit
import UIKit

enum PencilKitImportLimits {
  static let maxJSONUTF8Bytes = 16 * 1024 * 1024
  static let maxBase64EncodedBytes = 12 * 1024 * 1024
  static let maxBase64DecodedBytes = 8 * 1024 * 1024
  static let maxJSONNestingDepth = 32
  static let maxJSONCollectionEntries = 10_000
  static let maxImageDimension = 8_192
  static let maxImagePixelCount = 16_777_216
}

enum PencilKitHybridError: LocalizedError {
  case viewNotFound(Int)
  case invalidJSON(String)
  case inputTooLarge(String, Int)
  case jsonTooComplex
  case invalidBase64(String)
  case decodedDataTooLarge(String, Int)
  case invalidDrawing(String)
  case invalidImage(String)
  case drawingModeChanged
  case invalidOptions(String)
  case invalidFileURL(String)
  case exportFailed(String)

  var errorDescription: String? {
    switch self {
    case .viewNotFound(let id):
      return "PencilKit view not found: \(id)"
    case .invalidJSON(let reason):
      return "Invalid JSON: \(reason)"
    case .inputTooLarge(let field, let maximum):
      return "\(field) exceeds the \(maximum)-byte limit"
    case .jsonTooComplex:
      return
        "JSON exceeds the nesting depth (\(PencilKitImportLimits.maxJSONNestingDepth)) "
        + "or collection entry (\(PencilKitImportLimits.maxJSONCollectionEntries)) limit"
    case .invalidBase64(let field):
      return "\(field) must be valid, padded Base64"
    case .decodedDataTooLarge(let field, let maximum):
      return "\(field) decodes to more than \(maximum) bytes"
    case .invalidDrawing(let reason):
      return "Invalid PencilKit drawing: \(reason)"
    case .invalidImage(let reason):
      return "Invalid drawing image: \(reason)"
    case .drawingModeChanged:
      return "The drawing engine changed while the drawing was being imported"
    case .invalidOptions(let reason):
      return "Invalid options: \(reason)"
    case .invalidFileURL(let reason):
      return "Invalid file URL: \(reason)"
    case .exportFailed(let reason):
      return "Export failed: \(reason)"
    }
  }
}

enum PencilKitJSONValidator {
  static func parseObject(_ json: String, fieldName: String) throws -> [String: Any] {
    let byteCount = json.utf8.count
    guard byteCount <= PencilKitImportLimits.maxJSONUTF8Bytes else {
      throw PencilKitHybridError.inputTooLarge(
        fieldName,
        PencilKitImportLimits.maxJSONUTF8Bytes
      )
    }

    let data = Data(json.utf8)
    try validateNesting(in: data)

    let value: Any
    do {
      value = try JSONSerialization.jsonObject(with: data, options: [])
    } catch {
      throw PencilKitHybridError.invalidJSON("\(fieldName) is malformed")
    }

    guard let object = value as? [String: Any] else {
      throw PencilKitHybridError.invalidJSON("\(fieldName) must contain an object")
    }
    try validateCollectionComplexity(of: object)
    return object
  }

  private static func validateNesting(in data: Data) throws {
    var depth = 0
    var isInsideString = false
    var isEscaped = false

    for byte in data {
      if isInsideString {
        if isEscaped {
          isEscaped = false
        } else if byte == 0x5C {
          isEscaped = true
        } else if byte == 0x22 {
          isInsideString = false
        }
        continue
      }

      switch byte {
      case 0x22:
        isInsideString = true
      case 0x7B, 0x5B:
        depth += 1
        guard depth <= PencilKitImportLimits.maxJSONNestingDepth else {
          throw PencilKitHybridError.jsonTooComplex
        }
      case 0x7D, 0x5D:
        guard depth > 0 else {
          throw PencilKitHybridError.invalidJSON("unbalanced collection delimiters")
        }
        depth -= 1
      default:
        break
      }
    }

    guard !isInsideString, depth == 0 else {
      throw PencilKitHybridError.invalidJSON("unterminated string or collection")
    }
  }

  private static func validateCollectionComplexity(of root: [String: Any]) throws {
    var pending: [(value: Any, depth: Int)] = [(root, 1)]
    var entryCount = 0

    while let current = pending.popLast() {
      if let dictionary = current.value as? [String: Any] {
        guard current.depth <= PencilKitImportLimits.maxJSONNestingDepth else {
          throw PencilKitHybridError.jsonTooComplex
        }
        entryCount = try checkedEntryCount(entryCount, adding: dictionary.count)
        for value in dictionary.values {
          pending.append((value, current.depth + 1))
        }
      } else if let array = current.value as? [Any] {
        guard current.depth <= PencilKitImportLimits.maxJSONNestingDepth else {
          throw PencilKitHybridError.jsonTooComplex
        }
        entryCount = try checkedEntryCount(entryCount, adding: array.count)
        for value in array {
          pending.append((value, current.depth + 1))
        }
      }
    }
  }

  private static func checkedEntryCount(_ count: Int, adding addition: Int) throws -> Int {
    let (result, overflow) = count.addingReportingOverflow(addition)
    guard
      !overflow,
      result <= PencilKitImportLimits.maxJSONCollectionEntries
    else {
      throw PencilKitHybridError.jsonTooComplex
    }
    return result
  }
}

final class HybridMunimPencilkit: HybridMunimPencilkitSpec {
  func sum(num1: Double, num2: Double) throws -> Double {
    return num1 + num2
  }

  func isPencilKitSupported() throws -> Bool {
    return true
  }

  func getPencilKitCapabilities() throws -> String {
    // The pod's minimum deployment target is iOS 17.5, so every iOS 17 ink
    // (monoline, fountainPen, watercolor, crayon) and the iOS 17.5 pencil
    // interactions (squeeze, barrel roll) are always available at runtime.
    let capabilities: [String: Any] = [
      "platform": "ios",
      "supported": true,
      "minimumIOSVersion": "17.5",
      "osVersion": UIDevice.current.systemVersion,
      "documentVersion": 1,
      "documentFormats": ["archive", "png", "jpeg", "pdf"],
      "outputKinds": ["base64", "fileUrl"],
      "importFormats": ["archive", "png", "jpeg"],
      "tools": [
        "ink": [
          "pen", "pencil", "marker", "monoline", "fountainPen", "watercolor", "crayon",
        ],
        "eraser": ["bitmap", "vector"],
        "lasso": true,
        "toolPicker": true,
      ],
      "telemetry": [
        "pencilTouches": true,
        "predictedTouches": true,
        "coalescedTouches": true,
        "hover": true,
        "squeeze": true,
        "barrelRoll": true,
        "pencilMotion": false,
        "deviceMotion": true,
      ],
      "limits": [
        "maxJSONUTF8Bytes": PencilKitImportLimits.maxJSONUTF8Bytes,
        "maxBase64EncodedBytes": PencilKitImportLimits.maxBase64EncodedBytes,
        "maxBase64DecodedBytes": PencilKitImportLimits.maxBase64DecodedBytes,
        "maxImageDimension": PencilKitImportLimits.maxImageDimension,
        "maxImagePixelCount": PencilKitImportLimits.maxImagePixelCount,
      ],
    ]
    return try encodeJSONObject(capabilities, context: "capabilities")
  }

  func exportPencilKitDocument(viewId: Double, optionsJson: String) throws -> String {
    let id = Int(viewId)
    let options = try offMain {
      try PencilKitDocumentExportOptions(
        try PencilKitJSONValidator.parseObject(optionsJson, fieldName: "optionsJson")
      )
    }
    let source = try onMain { () -> PencilKitExportSource in
      guard let view = PencilKitRegistry.shared.view(for: id) else {
        throw PencilKitHybridError.viewNotFound(id)
      }
      return view.exportSource()
    }
    let rendered = try offMain {
      try PencilKitDocumentRenderer.render(source: source, options: options)
    }

    var result: [String: Any] = [
      "version": 1,
      "format": options.format.rawValue,
      "output": options.output.rawValue,
      "mimeType": options.format.mimeType,
      "byteLength": rendered.data.count,
      "width": rendered.width,
      "height": rendered.height,
    ]
    switch options.output {
    case .base64:
      guard rendered.data.count <= PencilKitImportLimits.maxBase64DecodedBytes else {
        throw PencilKitHybridError.invalidOptions(
          "export exceeds the \(PencilKitImportLimits.maxBase64DecodedBytes)-byte base64 "
            + "limit; use output: fileUrl"
        )
      }
      result["dataBase64"] = rendered.data.base64EncodedString()
    case .fileUrl:
      let url = try PencilKitDocumentFileStore.write(rendered.data, format: options.format)
      result["fileUrl"] = url.absoluteString
    }
    return try encodeJSONObject(result, context: "export result")
  }

  func importPencilKitDocument(viewId: Double, optionsJson: String) throws {
    let id = Int(viewId)
    let prepared = try offMain { () -> PreparedPencilKitDocumentImport in
      let object = try PencilKitJSONValidator.parseObject(optionsJson, fieldName: "optionsJson")
      let options = try PencilKitDocumentImportOptions(object)
      switch options.format {
      case .archive:
        do {
          return .archive(try PKDrawing(data: options.data))
        } catch {
          throw PencilKitHybridError.invalidDrawing("data is not a PKDrawing archive")
        }
      case .png, .jpeg:
        return .raster(try PencilKitDataValidator.image(from: options.data))
      case .pdf:
        throw PencilKitHybridError.invalidOptions("pdf documents cannot be imported")
      }
    }
    try onMain {
      guard let view = PencilKitRegistry.shared.view(for: id) else {
        throw PencilKitHybridError.viewNotFound(id)
      }
      try view.applyDocumentImport(prepared)
    }
  }

  func setPencilKitTool(viewId: Double, toolJson: String) throws {
    let object = try offMain {
      try PencilKitJSONValidator.parseObject(toolJson, fieldName: "toolJson")
    }
    try onMain {
      let id = Int(viewId)
      guard let view = PencilKitRegistry.shared.view(for: id) else {
        throw PencilKitHybridError.viewNotFound(id)
      }
      try view.applyToolState(object)
    }
  }

  func getPencilKitTool(viewId: Double) throws -> String {
    return try onMain {
      let id = Int(viewId)
      guard let view = PencilKitRegistry.shared.view(for: id) else {
        throw PencilKitHybridError.viewNotFound(id)
      }
      return try encodeJSONObject(view.currentToolStatePayload(), context: "tool state")
    }
  }

  func setPencilKitToolPickerVisible(viewId: Double, visible: Bool) throws {
    try onMain {
      let id = Int(viewId)
      guard let view = PencilKitRegistry.shared.view(for: id) else {
        throw PencilKitHybridError.viewNotFound(id)
      }
      view.setToolPickerVisible(visible)
    }
  }

  private func encodeJSONObject(_ object: [String: Any], context: String) throws -> String {
    let data = try JSONSerialization.data(withJSONObject: object, options: [])
    guard let json = String(data: data, encoding: .utf8) else {
      throw PencilKitHybridError.invalidJSON("\(context) could not be encoded as UTF-8")
    }
    return json
  }

  func createPencilKitView() throws -> Double {
    return try onMain {
      Double(PencilKitRegistry.shared.createViewId())
    }
  }

  func destroyPencilKitView(viewId: Double) throws {
    try onMain {
      let id = Int(viewId)
      guard let view = PencilKitRegistry.shared.view(for: id) else {
        PencilKitRegistry.shared.unregister(id: id)
        return
      }
      view.removeFromSuperview()
      PencilKitRegistry.shared.unregister(id: id)
    }
  }

  func setPencilKitConfig(viewId: Double, configJson: String) throws {
    let object = try offMain {
      try PencilKitJSONValidator.parseObject(configJson, fieldName: "configJson")
    }

    try onMain {
      let id = Int(viewId)
      if let view = PencilKitRegistry.shared.view(for: id) {
        view.applyConfig(object)
      } else {
        PencilKitRegistry.shared.setPendingConfig(id: id, config: object)
      }
    }
  }

  func getPencilKitDrawing(viewId: Double) throws -> String {
    return try onMain {
      let id = Int(viewId)
      guard let view = PencilKitRegistry.shared.view(for: id) else {
        throw PencilKitHybridError.viewNotFound(id)
      }
      let drawing = view.getDrawingData()
      let data = try JSONSerialization.data(withJSONObject: drawing, options: [])
      guard let json = String(data: data, encoding: .utf8) else {
        throw PencilKitHybridError.invalidJSON("native drawing could not be encoded as UTF-8")
      }
      return json
    }
  }

  func setPencilKitDrawing(viewId: Double, drawingJson: String) throws {
    let id = Int(viewId)
    let object = try offMain {
      try PencilKitJSONValidator.parseObject(drawingJson, fieldName: "drawingJson")
    }
    let target = try onMain {
      guard let view = PencilKitRegistry.shared.view(for: id) else {
        throw PencilKitHybridError.viewNotFound(id)
      }
      return (view, view.drawingImportMode)
    }
    let preparedDrawing = try offMain {
      try PencilKitNativeView.prepareDrawingData(object, for: target.1)
    }

    try onMain {
      guard
        let registeredView = PencilKitRegistry.shared.view(for: id),
        registeredView === target.0
      else {
        throw PencilKitHybridError.viewNotFound(id)
      }
      try registeredView.setDrawingData(preparedDrawing)
    }
  }

  func clearPencilKitDrawing(viewId: Double) throws {
    try onMain {
      let id = Int(viewId)
      guard let view = PencilKitRegistry.shared.view(for: id) else {
        throw PencilKitHybridError.viewNotFound(id)
      }
      view.clearDrawing()
    }
  }

  func undoPencilKitDrawing(viewId: Double) throws -> Bool {
    return try onMain {
      let id = Int(viewId)
      guard let view = PencilKitRegistry.shared.view(for: id) else {
        throw PencilKitHybridError.viewNotFound(id)
      }
      return view.undo()
    }
  }

  func redoPencilKitDrawing(viewId: Double) throws -> Bool {
    return try onMain {
      let id = Int(viewId)
      guard let view = PencilKitRegistry.shared.view(for: id) else {
        throw PencilKitHybridError.viewNotFound(id)
      }
      return view.redo()
    }
  }

  func canUndoPencilKitDrawing(viewId: Double) throws -> Bool {
    return try onMain {
      let id = Int(viewId)
      guard let view = PencilKitRegistry.shared.view(for: id) else {
        throw PencilKitHybridError.viewNotFound(id)
      }
      return view.canUndo()
    }
  }

  func canRedoPencilKitDrawing(viewId: Double) throws -> Bool {
    return try onMain {
      let id = Int(viewId)
      guard let view = PencilKitRegistry.shared.view(for: id) else {
        throw PencilKitHybridError.viewNotFound(id)
      }
      return view.canRedo()
    }
  }

  func startApplePencilDataCapture(viewId: Double) throws {
    try onMain {
      let id = Int(viewId)
      guard let view = PencilKitRegistry.shared.view(for: id) else {
        throw PencilKitHybridError.viewNotFound(id)
      }
      view.startApplePencilCapture()
    }
  }

  func stopApplePencilDataCapture(viewId: Double) throws {
    try onMain {
      let id = Int(viewId)
      guard let view = PencilKitRegistry.shared.view(for: id) else {
        throw PencilKitHybridError.viewNotFound(id)
      }
      view.stopApplePencilCapture()
    }
  }

  func isApplePencilDataCaptureActive(viewId: Double) throws -> Bool {
    return try onMain {
      let id = Int(viewId)
      guard let view = PencilKitRegistry.shared.view(for: id) else {
        throw PencilKitHybridError.viewNotFound(id)
      }
      return view.isCaptureActive()
    }
  }

  private func onMain<T>(_ block: () throws -> T) throws -> T {
    if Thread.isMainThread {
      return try block()
    }

    var result: Result<T, Error>?
    DispatchQueue.main.sync {
      result = Result(catching: block)
    }

    guard let result else {
      throw PencilKitHybridError.invalidJSON("main-thread operation did not complete")
    }
    return try result.get()
  }

  private func offMain<T>(_ block: () throws -> T) throws -> T {
    if Thread.isMainThread {
      return try DispatchQueue.global(qos: .userInitiated).sync(execute: block)
    }
    return try block()
  }
}
