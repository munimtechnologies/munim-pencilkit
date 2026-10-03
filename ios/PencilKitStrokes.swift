import Foundation
import PencilKit
import UIKit

/// Limits for stroke payloads. Stroke JSON is far more entry-dense than the
/// rest of the API (every control point is a small object), so it gets its own
/// collection budget instead of the 10k default.
enum PencilKitStrokeLimits {
  static let maxJSONCollectionEntries = 4_000_000
  static let maxStrokes = 50_000
  static let maxPointsPerStroke = 100_000
  static let maxTotalPoints = 500_000
  static let maxMaskPathLength = 1_000_000
}

/// Converts between `PKStroke` and the JSON shape exposed as `PencilKitStroke`.
///
/// The JSON shape is a superset of the legacy `PencilKitStroke` type
/// (`points[].location/pressure/azimuth/altitude/timestamp`, `tool`, `color`,
/// `width`), so older consumers keep reading the fields they know about.
/// `points` are the stroke path's *control points* in stroke space: apply
/// `transform` to map them into canvas space. `renderBounds` is already in
/// canvas space.
enum PencilKitStrokeCodec {
  // MARK: Encoding

  static func encode(_ strokes: [PKStroke], includeBezierPaths: Bool = false) -> [[String: Any]] {
    return strokes.map { encode($0, includeBezierPaths: includeBezierPaths) }
  }

  static func encode(_ stroke: PKStroke, includeBezierPaths: Bool = false) -> [String: Any] {
    let inkType = PencilKitNativeView.inkTypeString(stroke.ink.inkType)
    let color = stroke.ink.color.pencilKitHexRGBA
    var points: [[String: Any]] = []
    points.reserveCapacity(stroke.path.count)
    var widthSum: CGFloat = 0
    for point in stroke.path {
      widthSum += point.size.width
      var encoded: [String: Any] = [
        "location": ["x": point.location.x, "y": point.location.y],
        "timeOffset": point.timeOffset,
        "size": ["width": point.size.width, "height": point.size.height],
        "opacity": point.opacity,
        "force": point.force,
        "azimuth": point.azimuth,
        "altitude": point.altitude,
        "secondaryScale": point.secondaryScale,
        // Legacy PencilKitPoint fields.
        "pressure": point.force,
        "timestamp": point.timeOffset,
      ]
      #if compiler(>=6.2)
      if #available(iOS 26.0, *) {
        encoded["threshold"] = point.threshold
      }
      #endif
      #if compiler(>=6.4)
      if #available(iOS 27.0, *) {
        encoded["lateralJitter"] = point.lateralJitter
      }
      #endif
      points.append(encoded)
    }
    let width = points.isEmpty ? 0 : Double(widthSum / CGFloat(points.count))
    let transform = stroke.transform
    let bounds = stroke.renderBounds.isNull || stroke.renderBounds.isInfinite
      ? CGRect.zero
      : stroke.renderBounds

    var result: [String: Any] = [
      "points": points,
      "ink": ["inkType": inkType, "color": color],
      "tool": ["type": legacyToolType(inkType), "width": width, "color": color],
      "color": color,
      "width": width,
      "transform": [
        "a": transform.a,
        "b": transform.b,
        "c": transform.c,
        "d": transform.d,
        "tx": transform.tx,
        "ty": transform.ty,
      ],
      "randomSeed": Int(stroke.randomSeed),
      "creationDate": stroke.path.creationDate.timeIntervalSince1970 * 1000,
      "renderBounds": [
        "x": bounds.origin.x,
        "y": bounds.origin.y,
        "width": bounds.width,
        "height": bounds.height,
      ],
      "requiredContentVersion": stroke.requiredContentVersion.rawValue,
    ]
    if let mask = stroke.mask {
      result["mask"] = PencilKitPathCodec.encode(mask.cgPath)
    }
    #if compiler(>=6.4)
    if #available(iOS 27.0, *) {
      result["id"] = stroke.id.uuidString
      result["pathId"] = stroke.path.id.uuidString
      if let renderGroupID = stroke.renderGroupID {
        result["renderGroupId"] = renderGroupID.uuidString
      }
      if let renderState = stroke.renderState {
        var state: [String: Any] = [:]
        if let grainOffset = renderState.grainOffset {
          state["grainOffset"] = ["x": grainOffset.x, "y": grainOffset.y]
        }
        result["renderState"] = state
      }
      if includeBezierPaths {
        result["bezierPath"] = PencilKitPathCodec.encode(stroke.path.bezierRepresentation)
      }
    }
    #endif
    return result
  }

  /// The legacy `PencilKitTool.type` union only has pen/pencil/marker for inks.
  private static func legacyToolType(_ inkType: String) -> String {
    switch inkType {
    case "pencil", "marker": return inkType
    default: return "pen"
    }
  }

  // MARK: Decoding

  static func decodeStrokes(from object: [String: Any], key: String = "strokes") throws -> [PKStroke] {
    guard let rawStrokes = object[key] as? [Any] else {
      throw PencilKitHybridError.invalidOptions("\(key) must be an array")
    }
    guard rawStrokes.count <= PencilKitStrokeLimits.maxStrokes else {
      throw PencilKitHybridError.invalidOptions(
        "\(key) exceeds the \(PencilKitStrokeLimits.maxStrokes)-stroke limit"
      )
    }
    var totalPoints = 0
    var strokes: [PKStroke] = []
    strokes.reserveCapacity(rawStrokes.count)
    for (index, raw) in rawStrokes.enumerated() {
      guard let dictionary = raw as? [String: Any] else {
        throw PencilKitHybridError.invalidOptions("\(key)[\(index)] must be an object")
      }
      let stroke = try decode(dictionary, index: index)
      totalPoints += stroke.path.count
      guard totalPoints <= PencilKitStrokeLimits.maxTotalPoints else {
        throw PencilKitHybridError.invalidOptions(
          "strokes exceed the \(PencilKitStrokeLimits.maxTotalPoints)-point limit"
        )
      }
      strokes.append(stroke)
    }
    return strokes
  }

  static func decode(_ object: [String: Any], index: Int) throws -> PKStroke {
    let context = "strokes[\(index)]"
    let ink = object["ink"] as? [String: Any]
    let tool = object["tool"] as? [String: Any]

    let rawInkType = (ink?["inkType"] as? String)
      ?? (object["inkType"] as? String)
      ?? (tool?["type"] as? String)
      ?? "pen"
    guard let inkType = PencilKitNativeView.inkType(fromString: rawInkType) else {
      throw PencilKitHybridError.invalidOptions(
        "\(context) ink type must be one of "
          + PencilKitNativeView.availableInkTypeNames().joined(separator: ", ")
      )
    }

    let rawColor = (ink?["color"] as? String)
      ?? (object["color"] as? String)
      ?? (tool?["color"] as? String)
      ?? "#000000FF"
    guard let color = UIColor.pencilKitCSSColor(rawColor) else {
      throw PencilKitHybridError.invalidOptions("\(context) color must be #RRGGBB or #RRGGBBAA")
    }

    let fallbackWidth = try finiteNumber(object["width"], context: "\(context).width")
      ?? finiteNumber(tool?["width"], context: "\(context).tool.width")
      ?? Double(inkType.defaultWidth)
    guard fallbackWidth > 0, fallbackWidth <= 512 else {
      throw PencilKitHybridError.invalidOptions("\(context) width must be between 0 and 512")
    }

    guard let rawPoints = object["points"] as? [Any], !rawPoints.isEmpty else {
      throw PencilKitHybridError.invalidOptions("\(context).points must be a non-empty array")
    }
    guard rawPoints.count <= PencilKitStrokeLimits.maxPointsPerStroke else {
      throw PencilKitHybridError.invalidOptions(
        "\(context).points exceeds the \(PencilKitStrokeLimits.maxPointsPerStroke)-point limit"
      )
    }

    // Legacy points carry an absolute `timestamp`; convert it into an offset
    // from the first point when `timeOffset` is absent.
    let firstTimestamp = (rawPoints.first as? [String: Any]).flatMap {
      ($0["timestamp"] as? NSNumber)?.doubleValue
    }
    var points: [PKStrokePoint] = []
    points.reserveCapacity(rawPoints.count)
    for (pointIndex, rawPoint) in rawPoints.enumerated() {
      guard let point = rawPoint as? [String: Any] else {
        throw PencilKitHybridError.invalidOptions("\(context).points[\(pointIndex)] must be an object")
      }
      points.append(
        try decodePoint(
          point,
          context: "\(context).points[\(pointIndex)]",
          fallbackWidth: CGFloat(fallbackWidth),
          firstTimestamp: firstTimestamp
        )
      )
    }

    // iOS 27 identity fields. Parsed (and validated) on every OS so a bad id
    // fails the same way everywhere; older OS versions then ignore them.
    let strokeID = try uuid(object["id"], context: "\(context).id")
    let pathID = try uuid(object["pathId"], context: "\(context).pathId")
    let renderGroupID = try uuid(object["renderGroupId"], context: "\(context).renderGroupId")
    var grainOffset: CGPoint?
    var hasRenderState = false
    if let rawState = object["renderState"], !(rawState is NSNull) {
      guard let state = rawState as? [String: Any] else {
        throw PencilKitHybridError.invalidOptions("\(context).renderState must be an object")
      }
      hasRenderState = true
      if let rawOffset = state["grainOffset"], !(rawOffset is NSNull) {
        guard
          let offset = rawOffset as? [String: Any],
          let x = try finiteNumber(offset["x"], context: "\(context).renderState.grainOffset.x"),
          let y = try finiteNumber(offset["y"], context: "\(context).renderState.grainOffset.y")
        else {
          throw PencilKitHybridError.invalidOptions("\(context).renderState.grainOffset must be { x, y }")
        }
        grainOffset = CGPoint(x: x, y: y)
      }
    }

    let creationDate: Date
    if let milliseconds = try finiteNumber(object["creationDate"], context: "\(context).creationDate") {
      creationDate = Date(timeIntervalSince1970: milliseconds / 1000)
    } else {
      creationDate = Date()
    }
    let path = PKStrokePath(controlPoints: points, creationDate: creationDate)

    var transform = CGAffineTransform.identity
    if let rawTransform = object["transform"] {
      transform = try decodeTransform(rawTransform, context: "\(context).transform")
    }

    var mask: UIBezierPath?
    if let rawMask = object["mask"] as? String {
      mask = UIBezierPath(cgPath: try PencilKitPathCodec.decode(rawMask, context: "\(context).mask"))
    }

    let pkInk = PKInk(inkType, color: color)
    var randomSeed: UInt32?
    if let seedNumber = object["randomSeed"] as? NSNumber {
      let seed = seedNumber.doubleValue
      guard seed.isFinite, seed >= 0, seed <= Double(UInt32.max), seed.rounded() == seed else {
        throw PencilKitHybridError.invalidOptions("\(context).randomSeed must be a UInt32")
      }
      randomSeed = UInt32(seed)
    }

    #if compiler(>=6.4)
    if #available(iOS 27.0, *),
      strokeID != nil || pathID != nil || renderGroupID != nil || hasRenderState
    {
      let identifiedPath = pathID.map {
        PKStrokePath(controlPoints: points, creationDate: creationDate, id: $0)
      } ?? path
      return PKStroke(
        ink: pkInk,
        path: identifiedPath,
        transform: transform,
        mask: mask,
        randomSeed: randomSeed ?? UInt32.random(in: 0...UInt32.max),
        id: strokeID ?? UUID(),
        renderGroupID: renderGroupID,
        renderState: hasRenderState ? PKStroke.RenderState(grainOffset: grainOffset) : nil
      )
    }
    #else
    _ = (strokeID, pathID, renderGroupID, grainOffset, hasRenderState)
    #endif
    if let randomSeed {
      return PKStroke(ink: pkInk, path: path, transform: transform, mask: mask, randomSeed: randomSeed)
    }
    return PKStroke(ink: pkInk, path: path, transform: transform, mask: mask)
  }

  /// Returns nil when absent; throws when present but not a UUID string.
  static func uuid(_ value: Any?, context: String) throws -> UUID? {
    guard let value, !(value is NSNull) else { return nil }
    guard let string = value as? String, let uuid = UUID(uuidString: string) else {
      throw PencilKitHybridError.invalidOptions("\(context) must be a UUID string")
    }
    return uuid
  }

  /// Parses a `strokeIds` array of UUID strings.
  static func uuidSet(_ values: [String], context: String) throws -> Set<UUID> {
    guard values.count <= PencilKitStrokeLimits.maxStrokes else {
      throw PencilKitHybridError.invalidOptions(
        "\(context) exceeds the \(PencilKitStrokeLimits.maxStrokes)-id limit"
      )
    }
    var result = Set<UUID>()
    for (index, value) in values.enumerated() {
      guard let uuid = UUID(uuidString: value) else {
        throw PencilKitHybridError.invalidOptions("\(context)[\(index)] must be a UUID string")
      }
      result.insert(uuid)
    }
    return result
  }

  static func decodePoint(
    _ object: [String: Any],
    context: String,
    fallbackWidth: CGFloat,
    firstTimestamp: Double?
  ) throws -> PKStrokePoint {
    guard
      let location = object["location"] as? [String: Any],
      let x = try finiteNumber(location["x"], context: "\(context).location.x"),
      let y = try finiteNumber(location["y"], context: "\(context).location.y")
    else {
      throw PencilKitHybridError.invalidOptions("\(context).location must be { x, y }")
    }

    var timeOffset = try finiteNumber(object["timeOffset"], context: "\(context).timeOffset")
    if timeOffset == nil,
      let timestamp = try finiteNumber(object["timestamp"], context: "\(context).timestamp"),
      let firstTimestamp
    {
      timeOffset = max(0, timestamp - firstTimestamp)
    }

    var size = CGSize(width: fallbackWidth, height: fallbackWidth)
    if let rawSize = object["size"] as? [String: Any] {
      guard
        let width = try finiteNumber(rawSize["width"], context: "\(context).size.width"),
        let height = try finiteNumber(rawSize["height"], context: "\(context).size.height"),
        width >= 0, height >= 0, width <= 1024, height <= 1024
      else {
        throw PencilKitHybridError.invalidOptions("\(context).size must be { width, height } within 0...1024")
      }
      size = CGSize(width: width, height: height)
    }

    let opacity = try finiteNumber(object["opacity"], context: "\(context).opacity") ?? 1
    let force = try finiteNumber(object["force"], context: "\(context).force")
      ?? finiteNumber(object["pressure"], context: "\(context).pressure")
      ?? 1
    let azimuth = try finiteNumber(object["azimuth"], context: "\(context).azimuth") ?? 0
    let altitude = try finiteNumber(object["altitude"], context: "\(context).altitude") ?? (.pi / 2)
    let secondaryScale = try finiteNumber(object["secondaryScale"], context: "\(context).secondaryScale") ?? 1

    #if compiler(>=6.4)
    if #available(iOS 27.0, *),
      let lateralJitter = try finiteNumber(object["lateralJitter"], context: "\(context).lateralJitter")
    {
      let threshold = try finiteNumber(object["threshold"], context: "\(context).threshold") ?? 0
      return PKStrokePoint(
        location: CGPoint(x: x, y: y),
        timeOffset: timeOffset ?? 0,
        size: size,
        opacity: CGFloat(opacity),
        force: CGFloat(force),
        azimuth: CGFloat(azimuth),
        altitude: CGFloat(altitude),
        secondaryScale: CGFloat(secondaryScale),
        threshold: CGFloat(threshold),
        lateralJitter: CGFloat(lateralJitter)
      )
    }
    #endif
    #if compiler(>=6.2)
    if #available(iOS 26.0, *),
      let threshold = try finiteNumber(object["threshold"], context: "\(context).threshold")
    {
      return PKStrokePoint(
        location: CGPoint(x: x, y: y),
        timeOffset: timeOffset ?? 0,
        size: size,
        opacity: CGFloat(opacity),
        force: CGFloat(force),
        azimuth: CGFloat(azimuth),
        altitude: CGFloat(altitude),
        secondaryScale: CGFloat(secondaryScale),
        threshold: CGFloat(threshold)
      )
    }
    #endif
    return PKStrokePoint(
      location: CGPoint(x: x, y: y),
      timeOffset: timeOffset ?? 0,
      size: size,
      opacity: CGFloat(opacity),
      force: CGFloat(force),
      azimuth: CGFloat(azimuth),
      altitude: CGFloat(altitude),
      secondaryScale: CGFloat(secondaryScale)
    )
  }

  static func decodeTransform(_ raw: Any, context: String) throws -> CGAffineTransform {
    guard let object = raw as? [String: Any] else {
      throw PencilKitHybridError.invalidOptions("\(context) must be { a, b, c, d, tx, ty }")
    }
    func component(_ key: String, _ fallback: Double) throws -> CGFloat {
      return CGFloat(try finiteNumber(object[key], context: "\(context).\(key)") ?? fallback)
    }
    return CGAffineTransform(
      a: try component("a", 1),
      b: try component("b", 0),
      c: try component("c", 0),
      d: try component("d", 1),
      tx: try component("tx", 0),
      ty: try component("ty", 0)
    )
  }

  /// Returns nil when the value is absent; throws when it is present but not a finite number.
  static func finiteNumber(_ value: Any?, context: String) throws -> Double? {
    guard let value, !(value is NSNull) else { return nil }
    guard let number = value as? NSNumber, !number.pencilKitIsBoolean else {
      throw PencilKitHybridError.invalidOptions("\(context) must be a number")
    }
    let double = number.doubleValue
    guard double.isFinite else {
      throw PencilKitHybridError.invalidOptions("\(context) must be finite")
    }
    return double
  }
}

/// Serializes `CGPath`s as SVG path data using absolute M/L/Q/C/Z commands.
enum PencilKitPathCodec {
  static func encode(_ path: CGPath) -> String {
    var parts: [String] = []
    func format(_ point: CGPoint) -> String {
      return "\(Double(point.x)) \(Double(point.y))"
    }
    path.applyWithBlock { elementPointer in
      let element = elementPointer.pointee
      switch element.type {
      case .moveToPoint:
        parts.append("M \(format(element.points[0]))")
      case .addLineToPoint:
        parts.append("L \(format(element.points[0]))")
      case .addQuadCurveToPoint:
        parts.append("Q \(format(element.points[0])) \(format(element.points[1]))")
      case .addCurveToPoint:
        parts.append(
          "C \(format(element.points[0])) \(format(element.points[1])) \(format(element.points[2]))"
        )
      case .closeSubpath:
        parts.append("Z")
      @unknown default:
        break
      }
    }
    return parts.joined(separator: " ")
  }

  static func decode(_ string: String, context: String) throws -> CGPath {
    guard string.utf8.count <= PencilKitStrokeLimits.maxMaskPathLength else {
      throw PencilKitHybridError.invalidOptions("\(context) is too long")
    }
    let tokens = tokenize(string)
    let path = CGMutablePath()
    var index = 0
    var command: Character?

    func number() throws -> CGFloat {
      guard index < tokens.count, let value = Double(tokens[index]), value.isFinite else {
        throw PencilKitHybridError.invalidOptions("\(context) is not valid SVG path data")
      }
      index += 1
      return CGFloat(value)
    }
    func point() throws -> CGPoint {
      let x = try number()
      let y = try number()
      return CGPoint(x: x, y: y)
    }

    while index < tokens.count {
      let token = tokens[index]
      if token.count == 1, let character = token.first, "MLQCZmlqcz".contains(character) {
        command = Character(character.uppercased())
        index += 1
        if command == "Z" {
          path.closeSubpath()
          command = nil
        }
        continue
      }
      guard let current = command else {
        throw PencilKitHybridError.invalidOptions(
          "\(context) must use absolute M, L, Q, C, or Z commands"
        )
      }
      // Repeated coordinate pairs reuse the previous command (M becomes L).
      switch current {
      case "M":
        path.move(to: try point())
        command = "L"
      case "L":
        guard !path.isEmpty else {
          throw PencilKitHybridError.invalidOptions("\(context) must start with M")
        }
        path.addLine(to: try point())
      case "Q":
        guard !path.isEmpty else {
          throw PencilKitHybridError.invalidOptions("\(context) must start with M")
        }
        let control = try point()
        path.addQuadCurve(to: try point(), control: control)
      case "C":
        guard !path.isEmpty else {
          throw PencilKitHybridError.invalidOptions("\(context) must start with M")
        }
        let control1 = try point()
        let control2 = try point()
        path.addCurve(to: try point(), control1: control1, control2: control2)
      default:
        throw PencilKitHybridError.invalidOptions("\(context) is not valid SVG path data")
      }
    }
    return path
  }

  private static func tokenize(_ string: String) -> [String] {
    var tokens: [String] = []
    var current = ""
    func flush() {
      if !current.isEmpty {
        tokens.append(current)
        current = ""
      }
    }
    for character in string {
      if "MLQCZmlqcz".contains(character) {
        flush()
        tokens.append(String(character))
      } else if character == " " || character == "," || character == "\n" || character == "\t" {
        flush()
      } else if character == "-", !current.isEmpty, current.last != "e", current.last != "E" {
        flush()
        current.append(character)
      } else {
        current.append(character)
      }
    }
    flush()
    return tokens
  }
}

extension PKContentVersion {
  /// The newest content version the running OS can render.
  static var pencilKitMaximumAvailable: PKContentVersion {
    // Raw values, not .version4/.version5, so this still compiles with SDKs
    // that predate those cases (version5 needs the iOS 27 SDK).
    if #available(iOS 27.0, *), let version = PKContentVersion(rawValue: 5) { return version }
    if #available(iOS 26.0, *), let version = PKContentVersion(rawValue: 4) { return version }
    return .version3
  }

  /// Parses a JS content version (1...5 or "latest"), clamped to what the OS supports.
  static func pencilKitParse(_ raw: Any?) throws -> PKContentVersion? {
    guard let raw, !(raw is NSNull) else { return nil }
    if let string = raw as? String {
      guard string == "latest" else {
        throw PencilKitHybridError.invalidOptions(
          "maximumSupportedContentVersion must be 1-5 or \"latest\""
        )
      }
      return .latest
    }
    guard let number = raw as? NSNumber, !number.pencilKitIsBoolean else {
      throw PencilKitHybridError.invalidOptions(
        "maximumSupportedContentVersion must be 1-5 or \"latest\""
      )
    }
    let value = number.intValue
    guard value >= 1, Double(value) == number.doubleValue else {
      throw PencilKitHybridError.invalidOptions(
        "maximumSupportedContentVersion must be 1-5 or \"latest\""
      )
    }
    let clamped = min(value, pencilKitMaximumAvailable.rawValue)
    return PKContentVersion(rawValue: clamped) ?? pencilKitMaximumAvailable
  }
}

#if compiler(>=6.4)
@available(iOS 27.0, *)
enum PencilKitStrokeIdentity {
  /// Keeps every stroke's id unless it is already taken (by `existing` or an
  /// earlier stroke in `strokes`); those get a fresh id, so selection and
  /// recognition by id stay unambiguous.
  static func uniquified(_ strokes: [PKStroke], existing: [PKStroke] = []) -> [PKStroke] {
    var seen = Set(existing.map(\.id))
    return strokes.map { stroke in
      var stroke = stroke
      if !seen.insert(stroke.id).inserted {
        stroke.id = UUID()
        seen.insert(stroke.id)
      }
      return stroke
    }
  }
}
#endif

/// A parsed `PencilKitErasePathOptions`: an eraser stroke path in canvas space.
struct PencilKitEraseRequest {
  static let defaultWidth: Double = 20

  let path: PKStrokePath
  let mask: UIBezierPath?
  let transform: CGAffineTransform

  init(_ object: [String: Any]) throws {
    let width = try PencilKitStrokeCodec.finiteNumber(object["width"], context: "width")
      ?? Self.defaultWidth
    guard width > 0, width <= 1024 else {
      throw PencilKitHybridError.invalidOptions("width must be between 0 and 1024")
    }
    guard let rawPoints = object["points"] as? [Any], !rawPoints.isEmpty else {
      throw PencilKitHybridError.invalidOptions("points must be a non-empty array")
    }
    guard rawPoints.count <= PencilKitStrokeLimits.maxPointsPerStroke else {
      throw PencilKitHybridError.invalidOptions(
        "points exceeds the \(PencilKitStrokeLimits.maxPointsPerStroke)-point limit"
      )
    }
    var points: [PKStrokePoint] = []
    points.reserveCapacity(rawPoints.count)
    for (index, rawPoint) in rawPoints.enumerated() {
      guard var point = rawPoint as? [String: Any] else {
        throw PencilKitHybridError.invalidOptions("points[\(index)] must be an object")
      }
      // Accept bare { x, y } as well as stroke-point objects.
      if point["location"] == nil, point["x"] != nil || point["y"] != nil {
        point["location"] = ["x": point["x"] as Any, "y": point["y"] as Any]
      }
      // Space samples evenly in time unless the caller timed them.
      if point["timeOffset"] == nil, point["timestamp"] == nil {
        point["timeOffset"] = Double(index) / 120
      }
      points.append(
        try PencilKitStrokeCodec.decodePoint(
          point,
          context: "points[\(index)]",
          fallbackWidth: CGFloat(width),
          firstTimestamp: (rawPoints.first as? [String: Any]).flatMap {
            ($0["timestamp"] as? NSNumber)?.doubleValue
          }
        )
      )
    }
    path = PKStrokePath(controlPoints: points, creationDate: Date())

    if let rawMask = object["mask"] as? String {
      mask = UIBezierPath(cgPath: try PencilKitPathCodec.decode(rawMask, context: "mask"))
    } else {
      mask = nil
    }
    if let rawTransform = object["transform"], !(rawTransform is NSNull) {
      transform = try PencilKitStrokeCodec.decodeTransform(rawTransform, context: "transform")
    } else {
      transform = .identity
    }
  }

  #if compiler(>=6.4)
  @available(iOS 27.0, *)
  func apply(to drawing: PKDrawing) -> PKDrawing {
    return drawing.erasingPath(path, mask: mask, transform: transform)
  }
  #endif
}

extension NSNumber {
  /// True only for JSON `true`/`false`. `value is Bool` cannot tell them
  /// apart: Swift bridges any NSNumber holding 0 or 1 to Bool, so it would
  /// reject numeric 0 and 1.
  var pencilKitIsBoolean: Bool {
    return CFGetTypeID(self) == CFBooleanGetTypeID()
  }
}
