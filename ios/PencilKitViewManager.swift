import Foundation
import React
import UIKit

@objc(PencilKitViewManager)
final class PencilKitViewManager: RCTViewManager {
  override static func requiresMainQueueSetup() -> Bool {
    true
  }

  override func view() -> UIView! {
    return PencilKitNativeView()
  }
}
