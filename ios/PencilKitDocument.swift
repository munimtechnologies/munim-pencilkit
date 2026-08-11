import Foundation
import ImageIO
import PencilKit
import UIKit

enum PencilKitDataValidator {
  static func decodeBase64(_ base64: String, fieldName: String) throws -> Data {
    let encodedByteCount = base64.utf8.count
    guard encodedByteCount <= PencilKitImportLimits.maxBase64EncodedBytes else {
      throw PencilKitHybridError.inputTooLarge(
        fieldName,
        PencilKitImportLimits.maxBase64EncodedBytes
      )
    }
    guard encodedByteCount.isMultiple(of: 4) else {
      throw PencilKitHybridError.invalidBase64(fieldName)
    }
    let padding = base64.hasSuffix("==") ? 2 : (base64.hasSuffix("=") ? 1 : 0)
    let (maximum, overflow) = (encodedByteCount / 4).multipliedReportingOverflow(by: 3)
    guard !overflow, maximum >= padding,
      maximum - padding <= PencilKitImportLimits.maxBase64DecodedBytes
    else {
      throw PencilKitHybridError.decodedDataTooLarge(
        fieldName,
        PencilKitImportLimits.maxBase64DecodedBytes
      )
    }
    guard
      let data = Data(base64Encoded: base64, options: []),
      data.count == maximum - padding
    else {
      throw PencilKitHybridError.invalidBase64(fieldName)
    }
    return data
  }

  static func image(from data: Data) throws -> UIImage {
    let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
    guard
      let source = CGImageSourceCreateWithData(data as CFData, sourceOptions),
      CGImageSourceGetCount(source) == 1,
      let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, sourceOptions)
        as? [CFString: Any],
      let width = (properties[kCGImagePropertyPixelWidth] as? NSNumber)?.uint64Value,
      let height = (properties[kCGImagePropertyPixelHeight] as? NSNumber)?.uint64Value
    else {
      throw PencilKitHybridError.invalidImage("only single-frame raster images are supported")
    }
    let maxDimension = UInt64(PencilKitImportLimits.maxImageDimension)
    let (pixelCount, overflow) = width.multipliedReportingOverflow(by: height)
    guard width > 0, height > 0, width <= maxDimension, height <= maxDimension,
      !overflow, pixelCount <= UInt64(PencilKitImportLimits.maxImagePixelCount)
    else {
      throw PencilKitHybridError.invalidImage("image dimensions exceed the configured limits")
    }
    guard let image = UIImage(data: data, scale: 1) else {
      throw PencilKitHybridError.invalidImage("image data could not be decoded")
    }
    return image
  }
}

enum PencilKitDocumentFormat: String {
  case archive
  case png
  case jpeg
  case pdf

  var mimeType: String {
    switch self {
    case .archive: return "application/vnd.apple.pencilkit"
    case .png: return "image/png"
    case .jpeg: return "image/jpeg"
    case .pdf: return "application/pdf"
    }
  }

  var fileExtension: String {
    switch self {
    case .archive: return "pkdrawing"
    case .png: return "png"
    case .jpeg: return "jpg"
    case .pdf: return "pdf"
    }
  }
}

enum PencilKitDocumentOutput: String {
  case base64
  case fileUrl
}

struct PencilKitDocumentExportOptions {
  let format: PencilKitDocumentFormat
  let output: PencilKitDocumentOutput
  let crop: String
  let cropRect: CGRect?
  let scale: CGFloat
  let backgroundColor: UIColor?
  let quality: CGFloat

  init(_ object: [String: Any]) throws {
    guard (object["version"] as? NSNumber)?.intValue == 1 else {
      throw PencilKitHybridError.invalidOptions("version must be 1")
    }
    guard
      let rawFormat = object["format"] as? String,
      let format = PencilKitDocumentFormat(rawValue: rawFormat)
    else {
      throw PencilKitHybridError.invalidOptions("format must be archive, png, jpeg, or pdf")
    }
    let outputRaw = object["output"] as? String ?? "base64"
    guard let output = PencilKitDocumentOutput(rawValue: outputRaw) else {
      throw PencilKitHybridError.invalidOptions("output must be base64 or fileUrl")
    }
    let crop = object["crop"] as? String ?? "drawingBounds"
    guard ["drawingBounds", "canvas", "custom"].contains(crop) else {
      throw PencilKitHybridError.invalidOptions("crop must be drawingBounds, canvas, or custom")
    }

    let scale = CGFloat((object["scale"] as? NSNumber)?.doubleValue ?? 1)
    guard scale.isFinite, scale >= 0.1, scale <= 8 else {
      throw PencilKitHybridError.invalidOptions("scale must be finite and between 0.1 and 8")
    }
    let quality = CGFloat((object["quality"] as? NSNumber)?.doubleValue ?? 0.9)
    guard quality.isFinite, quality >= 0, quality <= 1 else {
      throw PencilKitHybridError.invalidOptions("quality must be between 0 and 1")
    }

    var cropRect: CGRect?
    if let rect = object["cropRect"] as? [String: Any] {
      let x = CGFloat((rect["x"] as? NSNumber)?.doubleValue ?? .nan)
      let y = CGFloat((rect["y"] as? NSNumber)?.doubleValue ?? .nan)
      let width = CGFloat((rect["width"] as? NSNumber)?.doubleValue ?? .nan)
      let height = CGFloat((rect["height"] as? NSNumber)?.doubleValue ?? .nan)
      guard x.isFinite, y.isFinite, width.isFinite, height.isFinite, width > 0, height > 0 else {
        throw PencilKitHybridError.invalidOptions("cropRect must contain finite positive dimensions")
      }
      cropRect = CGRect(x: x, y: y, width: width, height: height)
    }
    if crop == "custom", cropRect == nil {
      throw PencilKitHybridError.invalidOptions("custom crop requires cropRect")
    }

    var backgroundColor: UIColor?
    if let rawColor = object["backgroundColor"] as? String {
      guard let color = UIColor.pencilKitCSSColor(rawColor) else {
        throw PencilKitHybridError.invalidOptions("backgroundColor must be #RRGGBB or #RRGGBBAA")
      }
      backgroundColor = color
    }

    self.format = format
    self.output = output
    self.crop = crop
    self.cropRect = cropRect
    self.scale = scale
    self.backgroundColor = backgroundColor
    self.quality = quality
  }
}

struct PencilKitDocumentImportOptions {
  let format: PencilKitDocumentFormat
  let data: Data

  init(_ object: [String: Any]) throws {
    guard (object["version"] as? NSNumber)?.intValue == 1 else {
      throw PencilKitHybridError.invalidOptions("version must be 1")
    }
    guard
      let rawFormat = object["format"] as? String,
      let format = PencilKitDocumentFormat(rawValue: rawFormat),
      format == .archive || format == .png || format == .jpeg
    else {
      throw PencilKitHybridError.invalidOptions("import format must be archive, png, or jpeg")
    }
    guard
      let rawInput = object["input"] as? String,
      let input = PencilKitDocumentOutput(rawValue: rawInput)
    else {
      throw PencilKitHybridError.invalidOptions("input must be base64 or fileUrl")
    }
    self.format = format

    switch input {
    case .base64:
      guard let base64 = object["dataBase64"] as? String else {
        throw PencilKitHybridError.invalidOptions("dataBase64 is required")
      }
      data = try PencilKitDataValidator.decodeBase64(base64, fieldName: "dataBase64")
    case .fileUrl:
      guard let rawURL = object["fileUrl"] as? String else {
        throw PencilKitHybridError.invalidOptions("fileUrl is required")
      }
      let url = try PencilKitDocumentFileStore.validatedReadableURL(rawURL)
      let values = try url.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey])
      guard values.isRegularFile == true else {
        throw PencilKitHybridError.invalidFileURL("fileUrl must reference a regular file")
      }
      guard let size = values.fileSize, size <= PencilKitImportLimits.maxBase64DecodedBytes else {
        throw PencilKitHybridError.decodedDataTooLarge(
          "fileUrl",
          PencilKitImportLimits.maxBase64DecodedBytes
        )
      }
      data = try Data(contentsOf: url, options: [.mappedIfSafe])
    }
  }
}

struct PencilKitRenderedDocument {
  let data: Data
  let width: Double
  let height: Double
}

enum PencilKitDocumentRenderer {
  /// Renders an export source into document bytes. Safe to call off the main
  /// thread; the source must have been captured on the main thread first.
  static func render(
    source: PencilKitExportSource,
    options: PencilKitDocumentExportOptions
  ) throws -> PencilKitRenderedDocument {
    if options.format == .archive {
      guard let drawing = source.drawing else {
        throw PencilKitHybridError.invalidOptions(
          "archive export requires the PencilKit engine; disable useCustomStylusView"
        )
      }
      return PencilKitRenderedDocument(
        data: drawing.dataRepresentation(),
        width: Double(source.drawingBounds.width),
        height: Double(source.drawingBounds.height)
      )
    }

    let rect = try exportRect(source: source, options: options)
    let image = renderImage(source: source, rect: rect, options: options)

    switch options.format {
    case .png:
      guard let data = image.pngData() else {
        throw PencilKitHybridError.exportFailed("PNG encoding produced no data")
      }
      return PencilKitRenderedDocument(
        data: data,
        width: Double(rect.width * options.scale),
        height: Double(rect.height * options.scale)
      )
    case .jpeg:
      guard let data = image.jpegData(compressionQuality: options.quality) else {
        throw PencilKitHybridError.exportFailed("JPEG encoding produced no data")
      }
      return PencilKitRenderedDocument(
        data: data,
        width: Double(rect.width * options.scale),
        height: Double(rect.height * options.scale)
      )
    case .pdf:
      let pageBounds = CGRect(origin: .zero, size: rect.size)
      let renderer = UIGraphicsPDFRenderer(bounds: pageBounds)
      let data = renderer.pdfData { context in
        context.beginPage()
        image.draw(in: pageBounds)
      }
      return PencilKitRenderedDocument(
        data: data,
        width: Double(rect.width),
        height: Double(rect.height)
      )
    case .archive:
      throw PencilKitHybridError.exportFailed("archive is handled before rasterization")
    }
  }

  private static func exportRect(
    source: PencilKitExportSource,
    options: PencilKitDocumentExportOptions
  ) throws -> CGRect {
    let rect: CGRect
    switch options.crop {
    case "canvas":
      rect = CGRect(origin: .zero, size: source.canvasSize)
    case "custom":
      guard let cropRect = options.cropRect else {
        throw PencilKitHybridError.invalidOptions("custom crop requires cropRect")
      }
      rect = cropRect
    default:
      rect = source.drawingBounds.isEmpty
        ? CGRect(origin: .zero, size: source.canvasSize)
        : source.drawingBounds
    }
    guard rect.width > 0, rect.height > 0 else {
      throw PencilKitHybridError.invalidOptions(
        "nothing to export: the drawing and canvas are both empty"
      )
    }

    let pixelWidth = rect.width * options.scale
    let pixelHeight = rect.height * options.scale
    let maxDimension = CGFloat(PencilKitImportLimits.maxImageDimension)
    guard
      pixelWidth <= maxDimension,
      pixelHeight <= maxDimension,
      pixelWidth * pixelHeight <= CGFloat(PencilKitImportLimits.maxImagePixelCount)
    else {
      throw PencilKitHybridError.invalidOptions(
        "export dimensions exceed \(PencilKitImportLimits.maxImageDimension)px per side "
          + "or \(PencilKitImportLimits.maxImagePixelCount) pixels"
      )
    }
    return rect
  }

  private static func renderImage(
    source: PencilKitExportSource,
    rect: CGRect,
    options: PencilKitDocumentExportOptions
  ) -> UIImage {
    let format = UIGraphicsImageRendererFormat()
    format.scale = options.scale
    format.opaque = false
    let renderer = UIGraphicsImageRenderer(size: rect.size, format: format)
    return renderer.image { context in
      let target = CGRect(origin: .zero, size: rect.size)
      if let backgroundColor = options.backgroundColor {
        backgroundColor.setFill()
        context.fill(target)
      } else if options.format == .jpeg {
        // JPEG has no alpha channel; avoid an undefined black background.
        UIColor.white.setFill()
        context.fill(target)
      }
      if let drawing = source.drawing {
        drawing.image(from: rect, scale: options.scale).draw(in: target)
      } else if let rasterImage = source.rasterImage {
        rasterImage.draw(
          in: CGRect(
            x: -rect.origin.x,
            y: -rect.origin.y,
            width: rasterImage.size.width,
            height: rasterImage.size.height
          )
        )
      }
    }
  }
}

enum PencilKitDocumentFileStore {
  static func write(_ data: Data, format: PencilKitDocumentFormat) throws -> URL {
    let directory = FileManager.default.temporaryDirectory
      .appendingPathComponent("munim-pencilkit", isDirectory: true)
      .appendingPathComponent("exports", isDirectory: true)
    try FileManager.default.createDirectory(
      at: directory,
      withIntermediateDirectories: true,
      attributes: [.posixPermissions: 0o700]
    )
    let url = directory
      .appendingPathComponent(UUID().uuidString)
      .appendingPathExtension(format.fileExtension)
    try data.write(to: url, options: [.atomic])
    return url
  }

  static func validatedReadableURL(_ rawURL: String) throws -> URL {
    guard let url = URL(string: rawURL), url.isFileURL else {
      throw PencilKitHybridError.invalidFileURL("only file URLs are accepted")
    }
    let resolved = url.standardizedFileURL.resolvingSymlinksInPath()
    var roots = [FileManager.default.temporaryDirectory]
    if let documents = FileManager.default.urls(
      for: .documentDirectory,
      in: .userDomainMask
    ).first {
      roots.append(documents)
    }
    roots = roots.map { $0.standardizedFileURL.resolvingSymlinksInPath() }
    guard roots.contains(where: { resolved.path == $0.path || resolved.path.hasPrefix($0.path + "/") }) else {
      throw PencilKitHybridError.invalidFileURL(
        "fileUrl must be inside this app's temporary or Documents directory"
      )
    }
    return resolved
  }
}

extension UIColor {
  static func pencilKitCSSColor(_ value: String) -> UIColor? {
    guard value.hasPrefix("#") else { return nil }
    let hex = String(value.dropFirst())
    guard hex.count == 6 || hex.count == 8 else { return nil }
    let scanner = Scanner(string: hex)
    var raw: UInt64 = 0
    guard scanner.scanHexInt64(&raw), scanner.isAtEnd else { return nil }
    if hex.count == 6 {
      return UIColor(
        red: CGFloat((raw >> 16) & 0xff) / 255,
        green: CGFloat((raw >> 8) & 0xff) / 255,
        blue: CGFloat(raw & 0xff) / 255,
        alpha: 1
      )
    }
    return UIColor(
      red: CGFloat((raw >> 24) & 0xff) / 255,
      green: CGFloat((raw >> 16) & 0xff) / 255,
      blue: CGFloat((raw >> 8) & 0xff) / 255,
      alpha: CGFloat(raw & 0xff) / 255
    )
  }

  var pencilKitHexRGBA: String {
    guard let components = cgColor.converted(
      to: CGColorSpaceCreateDeviceRGB(),
      intent: .defaultIntent,
      options: nil
    )?.components, components.count >= 4 else {
      return "#000000FF"
    }
    return String(
      format: "#%02X%02X%02X%02X",
      Int((components[0] * 255).rounded()),
      Int((components[1] * 255).rounded()),
      Int((components[2] * 255).rounded()),
      Int((components[3] * 255).rounded())
    )
  }
}
