import Foundation

enum PencilKitHybridError: Error {
  case viewNotFound(Int)
  case invalidJSON
}

final class HybridMunimPencilkit: HybridMunimPencilkitSpec {
  func sum(num1: Double, num2: Double) throws -> Double {
    return num1 + num2
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
        throw PencilKitHybridError.viewNotFound(id)
      }
      view.removeFromSuperview()
      PencilKitRegistry.shared.unregister(id: id)
    }
  }

  func setPencilKitConfig(viewId: Double, configJson: String) throws {
    try onMain {
      let id = Int(viewId)
      guard
        let data = configJson.data(using: .utf8),
        let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]
      else {
        throw PencilKitHybridError.invalidJSON
      }
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
      return String(data: data, encoding: .utf8) ?? "{\"strokes\":[],\"bounds\":{\"x\":0,\"y\":0,\"width\":0,\"height\":0}}"
    }
  }

  func setPencilKitDrawing(viewId: Double, drawingJson: String) throws {
    try onMain {
      let id = Int(viewId)
      guard let view = PencilKitRegistry.shared.view(for: id) else {
        throw PencilKitHybridError.viewNotFound(id)
      }
      guard
        let data = drawingJson.data(using: .utf8),
        let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]
      else {
        throw PencilKitHybridError.invalidJSON
      }
      view.setDrawingData(object)
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
      throw PencilKitHybridError.invalidJSON
    }
    return try result.get()
  }
}
