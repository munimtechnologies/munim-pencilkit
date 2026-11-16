import Foundation
import NitroModules
import UIKit

/// Packs Apple Pencil samples into the Float64 records read by
/// `decodePencilSamples` (src/samples.ts). Keep the two in sync:
///
///   header: [formatVersion, stride, count, viewId]
///   record: [kind, phase, timestamp, x, y, preciseX, preciseY, force,
///            maximumPossibleForce, altitude, azimuth, azimuthUnitX,
///            azimuthUnitY, rollAngle, estimatedMask, estimationUpdateIndex]
struct PencilSampleEncoder {
  enum Kind: Double {
    case sample = 0
    case predicted = 1
    case estimatedUpdate = 2
  }

  static let formatVersion: Double = 1
  static let headerLength = 4
  static let stride = 16

  private var values: [Double] = []
  private(set) var count = 0

  init(expectedSamples: Int = 8) {
    values.reserveCapacity(Self.headerLength + expectedSamples * Self.stride)
    values.append(contentsOf: [Self.formatVersion, Double(Self.stride), 0, 0])
  }

  var isEmpty: Bool { count == 0 }

  mutating func append(_ touch: UITouch, kind: Kind, in view: UIView) {
    let location = touch.location(in: view)
    let precise = touch.preciseLocation(in: view)
    let azimuthUnit = touch.azimuthUnitVector(in: view)
    var estimatedMask = Self.mask(touch.estimatedProperties)
    estimatedMask |= Self.mask(touch.estimatedPropertiesExpectingUpdates) << 4
    let updateIndex = touch.estimationUpdateIndex.map { $0.doubleValue } ?? -1
    let rollAngle: Double
    if #available(iOS 17.5, *) {
      rollAngle = Double(touch.rollAngle)
    } else {
      rollAngle = 0
    }
    values.append(contentsOf: [
      kind.rawValue,
      Self.phaseValue(touch.phase),
      touch.timestamp,
      Double(location.x),
      Double(location.y),
      Double(precise.x),
      Double(precise.y),
      Double(touch.force),
      Double(touch.maximumPossibleForce),
      Double(touch.altitudeAngle),
      Double(touch.azimuthAngle(in: view)),
      Double(azimuthUnit.dx),
      Double(azimuthUnit.dy),
      rollAngle,
      Double(estimatedMask),
      updateIndex,
    ])
    count += 1
  }

  /// One owning buffer, handed to JS without a further copy.
  func makeBuffer(viewId: Int) -> ArrayBuffer {
    let byteCount = values.count * MemoryLayout<Double>.size
    let buffer = ArrayBuffer.allocate(size: byteCount)
    values.withUnsafeBytes { raw in
      if let base = raw.baseAddress {
        memcpy(buffer.data, base, byteCount)
      }
    }
    let header = UnsafeMutableRawPointer(buffer.data).assumingMemoryBound(to: Double.self)
    header[2] = Double(count)
    header[3] = Double(viewId)
    return buffer
  }

  private static func mask(_ properties: UITouch.Properties) -> Int {
    var mask = 0
    if properties.contains(.force) { mask |= 1 }
    if properties.contains(.azimuth) { mask |= 2 }
    if properties.contains(.altitude) { mask |= 4 }
    if properties.contains(.location) { mask |= 8 }
    return mask
  }

  private static func phaseValue(_ phase: UITouch.Phase) -> Double {
    switch phase {
    case .began: return 0
    case .moved, .stationary: return 1
    case .ended: return 2
    case .cancelled: return 3
    default: return 1
    }
  }
}
