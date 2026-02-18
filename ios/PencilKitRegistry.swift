import Foundation
import UIKit

final class PencilKitRegistry {
  static let shared = PencilKitRegistry()

  private struct WeakView {
    weak var value: PencilKitNativeView?
  }

  private var nextViewId: Int = 1
  private var views: [Int: WeakView] = [:]
  private var pendingConfigs: [Int: [String: Any]] = [:]
  private let lock = NSLock()

  private init() {}

  func createViewId() -> Int {
    lock.lock()
    defer { lock.unlock() }
    let id = nextViewId
    nextViewId += 1
    return id
  }

  func register(view: PencilKitNativeView, id: Int) {
    lock.lock()
    views[id] = WeakView(value: view)
    let pendingConfig = pendingConfigs.removeValue(forKey: id)
    lock.unlock()
    if let pendingConfig {
      view.applyConfig(pendingConfig)
    }
  }

  func unregister(id: Int) {
    lock.lock()
    views.removeValue(forKey: id)
    lock.unlock()
  }

  func view(for id: Int) -> PencilKitNativeView? {
    lock.lock()
    defer { lock.unlock() }
    guard let weakView = views[id] else {
      return nil
    }
    if let view = weakView.value {
      return view
    }
    views.removeValue(forKey: id)
    return nil
  }

  func setPendingConfig(id: Int, config: [String: Any]) {
    lock.lock()
    pendingConfigs[id] = config
    lock.unlock()
  }
}
