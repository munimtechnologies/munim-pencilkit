import Foundation
import NitroModules
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
  case unsupported(String)

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
    case .unsupported(let feature):
      return "\(feature) requires iOS 27 or later and an app built with the iOS 27 SDK (Xcode 27)"
    }
  }
}

enum PencilKitJSONValidator {
  static func parseObject(
    _ json: String,
    fieldName: String,
    maxCollectionEntries: Int = PencilKitImportLimits.maxJSONCollectionEntries
  ) throws -> [String: Any] {
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
    try validateCollectionComplexity(of: object, maxEntries: maxCollectionEntries)
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

  private static func validateCollectionComplexity(
    of root: [String: Any],
    maxEntries: Int
  ) throws {
    var pending: [(value: Any, depth: Int)] = [(root, 1)]
    var entryCount = 0

    while let current = pending.popLast() {
      if let dictionary = current.value as? [String: Any] {
        guard current.depth <= PencilKitImportLimits.maxJSONNestingDepth else {
          throw PencilKitHybridError.jsonTooComplex
        }
        entryCount = try checkedEntryCount(entryCount, adding: dictionary.count, maximum: maxEntries)
        for value in dictionary.values {
          pending.append((value, current.depth + 1))
        }
      } else if let array = current.value as? [Any] {
        guard current.depth <= PencilKitImportLimits.maxJSONNestingDepth else {
          throw PencilKitHybridError.jsonTooComplex
        }
        entryCount = try checkedEntryCount(entryCount, adding: array.count, maximum: maxEntries)
        for value in array {
          pending.append((value, current.depth + 1))
        }
      }
    }
  }

  private static func checkedEntryCount(
    _ count: Int,
    adding addition: Int,
    maximum: Int
  ) throws -> Int {
    let (result, overflow) = count.addingReportingOverflow(addition)
    guard
      !overflow,
      result <= maximum
    else {
      throw PencilKitHybridError.jsonTooComplex
    }
    return result
  }
}

final class HybridMunimPencilkit: HybridMunimPencilkitSpec {
  /// Serial queue behind every Promise-returning method. Being serial keeps the
  /// async calls in call order; being off the JS thread means JS never blocks
  /// while the main thread is busy.
  private static let asyncQueue = DispatchQueue(
    label: "com.munim.pencilkit.async",
    qos: .userInitiated
  )

  /// Deprecated leftover from the Nitro template. Kept because it is public API.
  func sum(num1: Double, num2: Double) throws -> Double {
    return num1 + num2
  }

  func isPencilKitSupported() throws -> Bool {
    return Self.isPencilKitAvailable
  }

  /// PencilKit needs iOS 17.5 (the pod's deployment target) or visionOS, and the
  /// PKCanvasView class has to be present at runtime.
  static var isPencilKitAvailable: Bool {
    guard NSClassFromString("PKCanvasView") != nil else { return false }
    #if os(visionOS)
      return true
    #else
      return ProcessInfo.processInfo.isOperatingSystemAtLeast(
        OperatingSystemVersion(majorVersion: 17, minorVersion: 5, patchVersion: 0)
      )
    #endif
  }

  func getPencilKitCapabilities() throws -> String {
    // The pod's minimum deployment target is iOS 17.5, so every iOS 17 ink
    // (monoline, fountainPen, watercolor, crayon) and the iOS 17.5 pencil
    // interactions (squeeze, barrel roll) are always available at runtime.
    // The iOS 26 reed ink is reported only where the OS provides it.
    var toolItems = false
    if #available(iOS 18.0, *) { toolItems = true }
    let supported = Self.isPencilKitAvailable
    let capabilities: [String: Any] = [
      "platform": "ios",
      "supported": supported,
      "minimumIOSVersion": "17.5",
      "osVersion": UIDevice.current.systemVersion,
      "documentVersion": 1,
      "documentFormats": ["archive", "png", "jpeg", "pdf"],
      "outputKinds": ["base64", "fileUrl"],
      "importFormats": ["archive", "png", "jpeg"],
      "tools": [
        "ink": PencilKitNativeView.availableInkTypeNames(),
        "eraser": ["bitmap", "vector"],
        "lasso": true,
        "toolPicker": supported,
        "toolItems": toolItems,
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
      "strokes": true,
      "features": [
        "strokeIds": Self.isIOS27FeatureSetAvailable,
        "selection": Self.isIOS27FeatureSetAvailable,
        "selectionChangeEvents": Self.isIOS27FeatureSetAvailable,
        "erasePath": Self.isIOS27FeatureSetAvailable,
        "bezierPaths": Self.isIOS27FeatureSetAvailable,
        "handwritingRecognition": Self.isIOS27FeatureSetAvailable,
        "toolPickerHDRColors": PencilKitNativeView.isHDRToolPickerColorAvailable,
      ],
      "contentVersion": [
        "maximum": PKContentVersion.pencilKitMaximumAvailable.rawValue
      ],
      "limits": [
        "maxJSONUTF8Bytes": PencilKitImportLimits.maxJSONUTF8Bytes,
        "maxBase64EncodedBytes": PencilKitImportLimits.maxBase64EncodedBytes,
        "maxBase64DecodedBytes": PencilKitImportLimits.maxBase64DecodedBytes,
        "maxImageDimension": PencilKitImportLimits.maxImageDimension,
        "maxImagePixelCount": PencilKitImportLimits.maxImagePixelCount,
        "maxStrokes": PencilKitStrokeLimits.maxStrokes,
        "maxStrokePoints": PencilKitStrokeLimits.maxTotalPoints,
      ],
    ]
    return try Self.encodeJSONObject(capabilities, context: "capabilities")
  }

  // MARK: Export / import

  func exportPencilKitDocument(viewId: Double, optionsJson: String) throws -> String {
    return try Self.exportDocument(id: Int(viewId), optionsJson: optionsJson)
  }

  func exportPencilKitDocumentAsync(viewId: Double, optionsJson: String) throws -> Promise<String> {
    let id = Int(viewId)
    return Promise.parallel(Self.asyncQueue) {
      try Self.exportDocument(id: id, optionsJson: optionsJson)
    }
  }

  func importPencilKitDocument(viewId: Double, optionsJson: String) throws {
    try Self.importDocument(id: Int(viewId), optionsJson: optionsJson)
  }

  func importPencilKitDocumentAsync(viewId: Double, optionsJson: String) throws -> Promise<Void> {
    let id = Int(viewId)
    return Promise.parallel(Self.asyncQueue) {
      try Self.importDocument(id: id, optionsJson: optionsJson)
    }
  }

  private static func exportDocument(id: Int, optionsJson: String) throws -> String {
    let options = try Self.offMain {
      try PencilKitDocumentExportOptions(
        try PencilKitJSONValidator.parseObject(optionsJson, fieldName: "optionsJson")
      )
    }
    let source = try Self.onMain { () -> PencilKitExportSource in
      try Self.view(id).exportSource()
    }
    let rendered = try Self.offMain {
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
    if let requiredContentVersion = source.drawing?.requiredContentVersion {
      result["requiredContentVersion"] = requiredContentVersion.rawValue
    }
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
    return try Self.encodeJSONObject(result, context: "export result")
  }

  private static func importDocument(id: Int, optionsJson: String) throws {
    let prepared = try Self.offMain { () -> PreparedPencilKitDocumentImport in
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
    try Self.onMain {
      try Self.view(id).applyDocumentImport(prepared)
    }
  }

  // MARK: Tools

  func setPencilKitTool(viewId: Double, toolJson: String) throws {
    let object = try Self.offMain {
      try PencilKitJSONValidator.parseObject(toolJson, fieldName: "toolJson")
    }
    try Self.onMain {
      try Self.view(Int(viewId)).applyToolState(object)
    }
  }

  func getPencilKitTool(viewId: Double) throws -> String {
    return try Self.onMain {
      try Self.encodeJSONObject(
        Self.view(Int(viewId)).currentToolStatePayload(),
        context: "tool state"
      )
    }
  }

  func setPencilKitToolPickerVisible(viewId: Double, visible: Bool) throws {
    try Self.onMain {
      try Self.view(Int(viewId)).setToolPickerVisible(visible)
    }
  }

  // MARK: View lifecycle

  func createPencilKitView() throws -> Double {
    return try Self.onMain {
      Double(PencilKitRegistry.shared.createViewId())
    }
  }

  /// Releases the native state behind `viewId`. The UIView itself belongs to
  /// React Native, which removes it when the component unmounts, so this
  /// never detaches it from the hierarchy.
  func destroyPencilKitView(viewId: Double) throws {
    try Self.onMain {
      let id = Int(viewId)
      PencilKitRegistry.shared.view(for: id)?.tearDown()
      PencilKitRegistry.shared.unregister(id: id)
      Self.recognizers[id] = nil
    }
  }

  func setPencilKitConfig(viewId: Double, configJson: String) throws {
    let object = try Self.offMain {
      try PencilKitJSONValidator.parseObject(configJson, fieldName: "configJson")
    }

    try Self.onMain {
      let id = Int(viewId)
      if let view = PencilKitRegistry.shared.view(for: id) {
        view.applyConfig(object)
      } else {
        PencilKitRegistry.shared.setPendingConfig(id: id, config: object)
      }
    }
  }

  // MARK: Drawing

  func getPencilKitDrawing(viewId: Double) throws -> String {
    return try Self.getDrawing(id: Int(viewId), optionsJson: nil)
  }

  func getPencilKitDrawingAsync(viewId: Double, optionsJson: String) throws -> Promise<String> {
    let id = Int(viewId)
    return Promise.parallel(Self.asyncQueue) {
      try Self.getDrawing(id: id, optionsJson: optionsJson)
    }
  }

  func setPencilKitDrawing(viewId: Double, drawingJson: String) throws {
    try Self.setDrawing(id: Int(viewId), drawingJson: drawingJson)
  }

  func setPencilKitDrawingAsync(viewId: Double, drawingJson: String) throws -> Promise<Void> {
    let id = Int(viewId)
    return Promise.parallel(Self.asyncQueue) {
      try Self.setDrawing(id: id, drawingJson: drawingJson)
    }
  }

  private static func getDrawing(id: Int, optionsJson: String?) throws -> String {
    var includeStrokes: Bool?
    if let optionsJson, !optionsJson.isEmpty {
      let options = try Self.offMain {
        try PencilKitJSONValidator.parseObject(optionsJson, fieldName: "optionsJson")
      }
      includeStrokes = options["includeStrokes"] as? Bool
    }
    // Capture on main, serialize (archive, base64, strokes, PNG) off main.
    let capture = try Self.onMain { try Self.view(id).captureDrawing(includeStrokes: includeStrokes) }
    return try Self.offMain {
      try Self.encodeJSONObject(
        PencilKitNativeView.drawingPayload(from: capture),
        context: "native drawing"
      )
    }
  }

  private static func setDrawing(id: Int, drawingJson: String) throws {
    let object = try Self.offMain {
      try PencilKitJSONValidator.parseObject(
        drawingJson,
        fieldName: "drawingJson",
        maxCollectionEntries: PencilKitStrokeLimits.maxJSONCollectionEntries
      )
    }
    let target = try Self.onMain { () -> (PencilKitNativeView, PencilKitDrawingImportMode) in
      let view = try Self.view(id)
      return (view, view.drawingImportMode)
    }
    let preparedDrawing = try Self.offMain {
      try PencilKitNativeView.prepareDrawingData(object, for: target.1)
    }

    try Self.onMain {
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
    try Self.onMain { try Self.view(Int(viewId)).clearDrawing() }
  }

  func undoPencilKitDrawing(viewId: Double) throws -> Bool {
    return try Self.onMain { try Self.view(Int(viewId)).undo() }
  }

  func redoPencilKitDrawing(viewId: Double) throws -> Bool {
    return try Self.onMain { try Self.view(Int(viewId)).redo() }
  }

  func canUndoPencilKitDrawing(viewId: Double) throws -> Bool {
    return try Self.onMain { try Self.view(Int(viewId)).canUndo() }
  }

  func canRedoPencilKitDrawing(viewId: Double) throws -> Bool {
    return try Self.onMain { try Self.view(Int(viewId)).canRedo() }
  }

  // MARK: Strokes

  func getPencilKitStrokes(viewId: Double) throws -> Promise<String> {
    let id = Int(viewId)
    return Promise.parallel(Self.asyncQueue) {
      let drawing = try Self.onMain { try Self.view(id).pencilKitDrawing() }
      return try Self.offMain {
        try Self.encodeJSONObject(
          [
            "strokes": PencilKitStrokeCodec.encode(drawing.strokes),
            "requiredContentVersion": drawing.requiredContentVersion.rawValue,
          ],
          context: "strokes"
        )
      }
    }
  }

  func setPencilKitStrokes(viewId: Double, strokesJson: String) throws -> Promise<Void> {
    let id = Int(viewId)
    return Promise.parallel(Self.asyncQueue) {
      let strokes = try Self.decodeStrokes(strokesJson)
      try Self.onMain {
        try Self.view(id).mutateStrokes(actionName: "Set Strokes") { _ in
          Self.uniquifiedIDs(strokes, existing: [])
        }
      }
    }
  }

  func appendPencilKitStrokes(viewId: Double, strokesJson: String) throws -> Promise<Void> {
    let id = Int(viewId)
    return Promise.parallel(Self.asyncQueue) {
      let strokes = try Self.decodeStrokes(strokesJson)
      try Self.onMain {
        try Self.view(id).mutateStrokes(actionName: "Add Strokes") {
          $0 + Self.uniquifiedIDs(strokes, existing: $0)
        }
      }
    }
  }

  func removePencilKitStrokes(viewId: Double, indices: [Double]) throws -> Promise<Double> {
    let id = Int(viewId)
    return Promise.parallel(Self.asyncQueue) {
      try Self.onMain { () -> Double in
        var removed = 0
        try Self.view(id).mutateStrokes(actionName: "Delete Strokes") { strokes in
          let targets = try Self.validatedIndices(indices, count: strokes.count)
          removed = targets.count
          return strokes.enumerated().filter { !targets.contains($0.offset) }.map(\.element)
        }
        return Double(removed)
      }
    }
  }

  func transformPencilKitStrokes(
    viewId: Double,
    indices: [Double],
    transformJson: String
  ) throws -> Promise<Double> {
    let id = Int(viewId)
    return Promise.parallel(Self.asyncQueue) {
      let object = try PencilKitJSONValidator.parseObject(transformJson, fieldName: "transformJson")
      let transform = try PencilKitStrokeCodec.decodeTransform(object, context: "transform")
      return try Self.onMain { () -> Double in
        var changed = 0
        try Self.view(id).mutateStrokes(actionName: "Transform Strokes") { strokes in
          let targets = try Self.validatedIndices(indices, count: strokes.count)
          changed = targets.count
          var next = strokes
          for index in targets {
            // Apply `transform` in canvas space, after the stroke's own transform.
            next[index].transform = next[index].transform.concatenating(transform)
          }
          return next
        }
        return Double(changed)
      }
    }
  }

  /// iOS 27: keeps incoming stroke ids, re-identifying only duplicates.
  private static func uniquifiedIDs(_ strokes: [PKStroke], existing: [PKStroke]) -> [PKStroke] {
    #if compiler(>=6.4)
    if #available(iOS 27.0, *) {
      return PencilKitStrokeIdentity.uniquified(strokes, existing: existing)
    }
    #endif
    return strokes
  }

  private static func decodeStrokes(_ json: String) throws -> [PKStroke] {
    let object = try PencilKitJSONValidator.parseObject(
      json,
      fieldName: "strokesJson",
      maxCollectionEntries: PencilKitStrokeLimits.maxJSONCollectionEntries
    )
    return try PencilKitStrokeCodec.decodeStrokes(from: object)
  }

  private static func validatedIndices(_ indices: [Double], count: Int) throws -> Set<Int> {
    var result = Set<Int>()
    for raw in indices {
      guard raw.isFinite, raw.rounded() == raw, raw >= 0, raw < Double(count) else {
        throw PencilKitHybridError.invalidOptions(
          "stroke index \(raw) is out of range for \(count) strokes"
        )
      }
      result.insert(Int(raw))
    }
    return result
  }

  // MARK: iOS 27: stroke ids, selection, erasing, recognition

  /// PKStroke.id, canvas selection, erasePath, Bézier paths and
  /// PKStrokeRecognizer: iOS 27 at runtime, and the iOS 27 SDK at build time.
  static var isIOS27FeatureSetAvailable: Bool {
    #if compiler(>=6.4)
    if #available(iOS 27.0, *) { return true }
    #endif
    return false
  }

  /// One recognizer per view, reused while the language preference is the
  /// same so recognition stays incremental. Main thread only.
  nonisolated(unsafe) private static var recognizers: [Int: (key: String, recognizer: AnyObject)] = [:]

  func getPencilKitStrokesWithOptions(viewId: Double, optionsJson: String) throws -> Promise<String> {
    let id = Int(viewId)
    return Promise.parallel(Self.asyncQueue) {
      let options = try Self.parseOptionalObject(optionsJson, fieldName: "optionsJson")
      let includeBezierPaths = options["includeBezierPaths"] as? Bool ?? false
      let drawing = try Self.onMain { try Self.view(id).pencilKitDrawing() }
      return try Self.encodeJSONObject(
        [
          "strokes": PencilKitStrokeCodec.encode(
            drawing.strokes,
            includeBezierPaths: includeBezierPaths
          ),
          "requiredContentVersion": drawing.requiredContentVersion.rawValue,
        ],
        context: "strokes"
      )
    }
  }

  func getPencilKitSelection(viewId: Double) throws -> Promise<String> {
    let id = Int(viewId)
    return Promise.parallel(Self.asyncQueue) {
      #if compiler(>=6.4)
      if #available(iOS 27.0, *) {
        let selection = try Self.onMain { try Self.view(id).selectedStrokeIDs() }
        return try Self.encodeJSONObject(
          ["strokeIds": selection.map(\.uuidString).sorted()],
          context: "selection"
        )
      }
      #endif
      throw PencilKitHybridError.unsupported("Stroke selection")
    }
  }

  func setPencilKitSelection(viewId: Double, selectionJson: String) throws -> Promise<Void> {
    let id = Int(viewId)
    return Promise.parallel(Self.asyncQueue) {
      #if compiler(>=6.4)
      if #available(iOS 27.0, *) {
        let object = try PencilKitJSONValidator.parseObject(
          selectionJson,
          fieldName: "selectionJson",
          maxCollectionEntries: PencilKitStrokeLimits.maxStrokes + 1
        )
        guard let rawIDs = object["strokeIds"] as? [String] else {
          throw PencilKitHybridError.invalidOptions("strokeIds must be an array of UUID strings")
        }
        let ids = try PencilKitStrokeCodec.uuidSet(rawIDs, context: "strokeIds")
        try Self.onMain { try Self.view(id).setSelectedStrokeIDs(ids) }
        return
      }
      #endif
      throw PencilKitHybridError.unsupported("Stroke selection")
    }
  }

  func erasePencilKitPath(viewId: Double, eraseJson: String) throws -> Promise<String> {
    let id = Int(viewId)
    return Promise.parallel(Self.asyncQueue) {
      #if compiler(>=6.4)
      if #available(iOS 27.0, *) {
        let object = try PencilKitJSONValidator.parseObject(
          eraseJson,
          fieldName: "eraseJson",
          maxCollectionEntries: PencilKitStrokeLimits.maxJSONCollectionEntries
        )
        let request = try PencilKitEraseRequest(object)
        let original = try Self.onMain { try Self.view(id).pencilKitDrawing() }
        // Erasing is expensive, so it runs here rather than on main.
        let erased = request.apply(to: original)
        return try Self.onMain { () -> String in
          let view = try Self.view(id)
          let current = try view.pencilKitDrawing()
          // If the drawing changed meanwhile, erase the live drawing instead.
          let result = current == original ? erased : request.apply(to: current)
          let changed = result != current
          if changed {
            view.replaceDrawingUndoably(result, actionName: "Erase")
          }
          return try Self.encodeJSONObject(
            [
              "changed": changed,
              "strokeCountBefore": current.strokes.count,
              "strokeCountAfter": result.strokes.count,
            ],
            context: "erase result"
          )
        }
      }
      #endif
      throw PencilKitHybridError.unsupported("erasePath")
    }
  }

  func recognizePencilKitText(viewId: Double, optionsJson: String) throws -> Promise<String> {
    #if compiler(>=6.4)
    if #available(iOS 27.0, *) {
      let id = Int(viewId)
      return Promise.async {
        let options = try Self.parseOptionalObject(optionsJson, fieldName: "optionsJson")
        let languages = try Self.parseLanguages(options["preferredLanguages"])
        var strokeIDs: Set<UUID>?
        if let raw = options["strokeIds"], !(raw is NSNull) {
          guard let strings = raw as? [String] else {
            throw PencilKitHybridError.invalidOptions("strokeIds must be an array of UUID strings")
          }
          strokeIDs = try PencilKitStrokeCodec.uuidSet(strings, context: "strokeIds")
        }
        let includeIndexableContent = options["includeIndexableContent"] as? Bool ?? false

        let recognizer = try await Self.preparedRecognizer(id: id, languages: languages)
        let text = await recognizer.recognizedText(strokeIDs: strokeIDs)
        let recognizerLanguages = await recognizer.languages
        var result: [String: Any] = [
          "text": text ?? NSNull(),
          "languages": recognizerLanguages.map(\.minimalIdentifier),
          "recognitionVersion": PKStrokeRecognizer.recognitionVersion,
        ]
        if includeIndexableContent {
          result["indexableContent"] = await recognizer.indexableContent ?? NSNull()
        }
        return try Self.encodeJSONObject(result, context: "recognized text")
      }
    }
    #endif
    return Promise.rejected(withError: PencilKitHybridError.unsupported("Handwriting recognition"))
  }

  func searchPencilKitText(viewId: Double, query: String, optionsJson: String) throws -> Promise<String> {
    #if compiler(>=6.4)
    if #available(iOS 27.0, *) {
      let id = Int(viewId)
      return Promise.async {
        guard !query.isEmpty, query.count <= 1_000 else {
          throw PencilKitHybridError.invalidOptions("query must be 1-1000 characters")
        }
        let options = try Self.parseOptionalObject(optionsJson, fieldName: "optionsJson")
        let languages = try Self.parseLanguages(options["preferredLanguages"])
        let fullWordsOnly = options["fullWordsOnly"] as? Bool ?? false
        let caseMatchingOnly = options["caseMatchingOnly"] as? Bool ?? false

        let recognizer = try await Self.preparedRecognizer(id: id, languages: languages)
        let matches = await recognizer.search(
          query,
          fullWordsOnly: fullWordsOnly,
          caseMatchingOnly: caseMatchingOnly
        )
        let results: [[String: Any]] = matches.map { match in
          [
            "strokeIds": match.strokes.map(\.uuidString).sorted(),
            "bounds": [
              "x": match.bounds.origin.x,
              "y": match.bounds.origin.y,
              "width": match.bounds.width,
              "height": match.bounds.height,
            ],
          ]
        }
        return try Self.encodeJSONObject(["results": results], context: "search results")
      }
    }
    #endif
    return Promise.rejected(withError: PencilKitHybridError.unsupported("Handwriting search"))
  }

  func getPencilKitRecognitionInfo() throws -> Promise<String> {
    return Promise.parallel(Self.asyncQueue) {
      var info: [String: Any] = [
        "supported": false,
        "supportedLanguages": [String](),
        "recognitionVersion": NSNull(),
      ]
      #if compiler(>=6.4)
      if #available(iOS 27.0, *) {
        info = [
          "supported": true,
          "supportedLanguages": PKStrokeRecognizer.supportedLanguages.map(\.minimalIdentifier).sorted(),
          "recognitionVersion": PKStrokeRecognizer.recognitionVersion,
        ]
      }
      #endif
      return try Self.encodeJSONObject(info, context: "recognition info")
    }
  }

  #if compiler(>=6.4)
  /// The view's cached recognizer, brought up to date with its drawing.
  @available(iOS 27.0, *)
  private static func preparedRecognizer(
    id: Int,
    languages: [Locale.Language]?
  ) async throws -> PKStrokeRecognizer {
    let key = languages?.map(\.maximalIdentifier).joined(separator: ",") ?? ""
    let (recognizer, drawing) = try await MainActor.run {
      () throws -> (PKStrokeRecognizer, PKDrawing) in
      let drawing = try Self.view(id).pencilKitDrawing()
      if let cached = recognizers[id], cached.key == key,
        let recognizer = cached.recognizer as? PKStrokeRecognizer
      {
        return (recognizer, drawing)
      }
      let recognizer = PKStrokeRecognizer(preferredLanguages: languages)
      recognizers[id] = (key, recognizer)
      return (recognizer, drawing)
    }
    await recognizer.updateDrawing(drawing)
    return recognizer
  }

  /// `preferredLanguages`: BCP-47 identifiers, e.g. `["en", "fr-CA"]`.
  @available(iOS 27.0, *)
  private static func parseLanguages(_ raw: Any?) throws -> [Locale.Language]? {
    guard let raw, !(raw is NSNull) else { return nil }
    guard let identifiers = raw as? [String], identifiers.count <= 32 else {
      throw PencilKitHybridError.invalidOptions(
        "preferredLanguages must be an array of up to 32 language identifiers"
      )
    }
    return try identifiers.map { identifier in
      guard !identifier.isEmpty, identifier.count <= 64 else {
        throw PencilKitHybridError.invalidOptions("preferredLanguages contains an invalid identifier")
      }
      return Locale.Language(identifier: identifier)
    }
  }
  #endif

  /// Parses an options object; an empty string means no options.
  private static func parseOptionalObject(_ json: String, fieldName: String) throws -> [String: Any] {
    if json.isEmpty { return [:] }
    return try PencilKitJSONValidator.parseObject(json, fieldName: fieldName)
  }

  // MARK: Apple Pencil capture

  func startApplePencilDataCapture(viewId: Double) throws {
    try Self.onMain { try Self.view(Int(viewId)).startApplePencilCapture() }
  }

  func stopApplePencilDataCapture(viewId: Double) throws {
    try Self.onMain { try Self.view(Int(viewId)).stopApplePencilCapture() }
  }

  func isApplePencilDataCaptureActive(viewId: Double) throws -> Bool {
    return try Self.onMain { try Self.view(Int(viewId)).isCaptureActive() }
  }

  // MARK: Helpers

  /// Must be called on the main thread.
  private static func view(_ id: Int) throws -> PencilKitNativeView {
    guard let view = PencilKitRegistry.shared.view(for: id) else {
      throw PencilKitHybridError.viewNotFound(id)
    }
    return view
  }

  private static func encodeJSONObject(_ object: [String: Any], context: String) throws -> String {
    let data = try JSONSerialization.data(withJSONObject: object, options: [])
    guard let json = String(data: data, encoding: .utf8) else {
      throw PencilKitHybridError.invalidJSON("\(context) could not be encoded as UTF-8")
    }
    return json
  }

  /// Runs `block` on the main thread. Runs inline when already on main, so it
  /// can never `sync` onto its own queue. Called from the JS thread by the
  /// deprecated synchronous methods (the JS thread then waits for main), and
  /// from `asyncQueue` by the Promise-returning ones (only that queue waits).
  private static func onMain<T>(_ block: () throws -> T) throws -> T {
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

  private static func offMain<T>(_ block: () throws -> T) throws -> T {
    if Thread.isMainThread {
      return try DispatchQueue.global(qos: .userInitiated).sync(execute: block)
    }
    return try block()
  }
}
