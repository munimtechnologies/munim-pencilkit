import Foundation
import NitroModules
import UIKit

typealias PencilSampleListener = (ArrayBuffer) -> Void

final class PencilKitRegistry {
  static let shared = PencilKitRegistry()

  private struct WeakView {
    weak var value: PencilKitNativeView?
  }

  private var nextViewId: Int = 1
  private var views: [Int: WeakView] = [:]
  private var pendingConfigs: [Int: [String: Any]] = [:]
  private var sampleListeners: [Int: (viewId: Int, listener: PencilSampleListener)] = [:]
  /// Views with at least one sample listener, so touch handling can skip
  /// encoding entirely when nobody listens.
  private var sampleListenerCounts: [Int: Int] = [:]
  private var nextSubscriptionId: Int = 1
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
    pendingConfigs.removeValue(forKey: id)
    sampleListeners = sampleListeners.filter { $0.value.viewId != id }
    sampleListenerCounts.removeValue(forKey: id)
    lock.unlock()
  }

  // MARK: Pencil sample listeners

  /// Listeners are keyed by view id, so they can be added before React has
  /// mounted the native view.
  func addSampleListener(viewId: Int, listener: @escaping PencilSampleListener) -> Int {
    lock.lock()
    defer { lock.unlock() }
    let subscriptionId = nextSubscriptionId
    nextSubscriptionId += 1
    sampleListeners[subscriptionId] = (viewId, listener)
    sampleListenerCounts[viewId, default: 0] += 1
    return subscriptionId
  }

  /// Idempotent: unknown or already-removed ids are ignored.
  func removeSampleListener(subscriptionId: Int) {
    lock.lock()
    defer { lock.unlock() }
    guard let entry = sampleListeners.removeValue(forKey: subscriptionId) else { return }
    let remaining = (sampleListenerCounts[entry.viewId] ?? 1) - 1
    sampleListenerCounts[entry.viewId] = remaining > 0 ? remaining : nil
  }

  func hasSampleListeners(viewId: Int) -> Bool {
    lock.lock()
    defer { lock.unlock() }
    return sampleListenerCounts[viewId] != nil
  }

  func sampleListeners(viewId: Int) -> [PencilSampleListener] {
    lock.lock()
    defer { lock.unlock() }
    return sampleListeners.values.filter { $0.viewId == viewId }.map(\.listener)
  }

  /// Unregisters `id` only if the currently registered view is `view` (or has
  /// already been deallocated). Safe to call multiple times.
  func unregister(id: Int, view: PencilKitNativeView) {
    lock.lock()
    defer { lock.unlock() }
    guard let weakView = views[id] else { return }
    if weakView.value == nil || weakView.value === view {
      views.removeValue(forKey: id)
    }
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
