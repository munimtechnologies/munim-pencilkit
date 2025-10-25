//
//  StylusDrawingViewManager.swift
//  munim-pencilkit
//
//  Swift view manager for StylusDrawingView
//

import UIKit
import React

@objc(StylusDrawingViewManager)
class StylusDrawingViewManager: RCTViewManager {
    
    override func view() -> UIView! {
        return StylusDrawingView()
    }
    
    override static func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    // MARK: - Exported Properties
    
    @objc func setAllowsFingerDrawing(_ view: StylusDrawingView, allowsFingerDrawing: Bool) {
        view.allowsFingerDrawing = allowsFingerDrawing
    }
    
    @objc func setStrokeColor(_ view: StylusDrawingView, strokeColor: UIColor) {
        view.strokeColor = strokeColor
    }
    
    @objc func setBaseLineWidth(_ view: StylusDrawingView, baseLineWidth: CGFloat) {
        view.baseLineWidth = baseLineWidth
    }
    
    @objc func setShowHoverPreview(_ view: StylusDrawingView, showHoverPreview: Bool) {
        view.showHoverPreview = showHoverPreview
    }
    
    @objc func setEraserEnabled(_ view: StylusDrawingView, eraserEnabled: Bool) {
        view.setEraserEnabled(eraserEnabled)
    }
    
    // MARK: - Exported Methods
    
    @objc func clearCanvas(_ view: StylusDrawingView) {
        view.clearCanvas()
    }
    
    @objc func setCanvasImage(_ view: StylusDrawingView, image: UIImage?) {
        view.setCanvasImage(image)
    }
    
    @objc func snapshotImage(_ view: StylusDrawingView, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if let image = view.snapshotImage() {
            resolve(image)
        } else {
            reject("NO_IMAGE", "Failed to capture image", nil)
        }
    }
}

// MARK: - RCTViewManagerDelegate

extension StylusDrawingViewManager {
    override func constantsToExport() -> [AnyHashable : Any]! {
        return [:]
    }
}
