import { requireNativeView } from "expo";
import * as React from "react";

import {
  MunimPencilkitViewProps,
  MunimPencilkitViewMethods,
  PKDrawingExportOptions,
  PKToolType,
  PKDrawingBounds,
  DebugEventPayload,
} from "./MunimPencilkit.types";

// Native view component
const NativeView: React.ComponentType<MunimPencilkitViewProps> =
  requireNativeView("MunimPencilkit");

// Forward ref interface for imperative methods
export interface MunimPencilkitViewRef extends MunimPencilkitViewMethods {}

const MunimPencilkitView = React.forwardRef<
  MunimPencilkitViewRef,
  MunimPencilkitViewProps
>((props, ref) => {
  const nativeViewRef = React.useRef<any>(null);

  React.useImperativeHandle(ref, () => ({
    // Drawing Management
    async clearDrawing(): Promise<void> {
      return nativeViewRef.current?.clearDrawing();
    },

    async undo(): Promise<void> {
      return nativeViewRef.current?.undo();
    },

    async redo(): Promise<void> {
      return nativeViewRef.current?.redo();
    },

    // Data Management
    async getDrawingData(debug: boolean = false): Promise<ArrayBuffer | null | DebugEventPayload> {
      const result = await nativeViewRef.current?.getDrawingData(debug);
      if (debug) {
        return result as DebugEventPayload;
      } else {
        // Extract data from the result object
        return result?.data || null;
      }
    },

    async loadDrawingData(data: ArrayBuffer): Promise<void> {
      return nativeViewRef.current?.loadDrawingData(data);
    },

    // Export Functions
    async exportAsImage(
      options?: PKDrawingExportOptions
    ): Promise<string | null> {
      const scale = options?.scale || 1.0;
      return nativeViewRef.current?.exportAsImage(scale);
    },

    async exportAsPDF(
      options?: PKDrawingExportOptions
    ): Promise<ArrayBuffer | null> {
      const scale = options?.scale || 1.0;
      const data = await nativeViewRef.current?.exportAsPDF(scale);
      return data ? data : null;
    },

    async exportAsData(): Promise<ArrayBuffer | null> {
      const result = await this.getDrawingData(false);
      return result as ArrayBuffer | null;
    },

    // Tool Management
    async setTool(
      toolType: PKToolType,
      color?: string,
      width?: number
    ): Promise<void> {
      return nativeViewRef.current?.setTool(toolType, color, width);
    },

    async getTool(): Promise<any> {
      // This would need to be implemented in the native side
      return null;
    },

    // Ink Behavior Controls
    async setEnableInkSmoothing(enable: boolean): Promise<void> {
      return nativeViewRef.current?.setEnableInkSmoothing?.(enable);
    },

    async setEnableStrokeRefinement(enable: boolean): Promise<void> {
      return nativeViewRef.current?.setEnableStrokeRefinement?.(enable);
    },

    async setEnableHandwritingRecognition(enable: boolean): Promise<void> {
      return nativeViewRef.current?.setEnableHandwritingRecognition?.(enable);
    },

    async setNaturalDrawingMode(natural: boolean): Promise<void> {
      return nativeViewRef.current?.setNaturalDrawingMode?.(natural);
    },

    // View State
    async hasContent(debug: boolean = false): Promise<boolean | DebugEventPayload> {
      const result = await nativeViewRef.current?.hasContent(debug);
      if (debug) {
        return result as DebugEventPayload;
      } else {
        return result?.hasContent || false;
      }
    },

    async getStrokeCount(debug: boolean = false): Promise<number | DebugEventPayload> {
      const result = await nativeViewRef.current?.getStrokeCount(debug);
      if (debug) {
        return result as DebugEventPayload;
      } else {
        return result?.strokeCount || 0;
      }
    },

    async getDrawingBounds(): Promise<PKDrawingBounds> {
      return (
        (await nativeViewRef.current?.getDrawingBounds()) || {
          x: 0,
          y: 0,
          width: 0,
          height: 0,
        }
      );
    },

    async getDrawingBoundsStruct(): Promise<PKDrawingBounds> {
      return (
        (await nativeViewRef.current?.getDrawingBoundsStruct()) || {
          x: 0,
          y: 0,
          width: 0,
          height: 0,
        }
      );
    },

    // Zoom and Pan - These would need native implementation
    async zoomToFitDrawing(animated?: boolean): Promise<void> {
      // To be implemented
    },

    async setZoomScale(scale: number, animated?: boolean): Promise<void> {
      // To be implemented
    },

    // Advanced Features - These would need native implementation
    async beginDrawing(): Promise<void> {
      // To be implemented
    },

    async endDrawing(): Promise<void> {
      // To be implemented
    },

    async suspendDrawing(): Promise<void> {
      // To be implemented
    },

    async resumeDrawing(): Promise<void> {
      // To be implemented
    },

    // MARK: - Advanced Stroke Inspection
    async getAllStrokes(): Promise<any[]> {
      return nativeViewRef.current?.getAllStrokes() || [];
    },

    async getStroke(index: number): Promise<any> {
      return nativeViewRef.current?.getStroke(index);
    },

    async getStrokesInRegion(region: any): Promise<any[]> {
      return (
        nativeViewRef.current?.getStrokesInRegion(
          region.x,
          region.y,
          region.width,
          region.height
        ) || []
      );
    },

    async analyzeDrawing(): Promise<any> {
      return nativeViewRef.current?.analyzeDrawing() || {};
    },

    async findStrokesNear(
      point: { x: number; y: number },
      threshold = 20.0
    ): Promise<any[]> {
      return (
        nativeViewRef.current?.findStrokesNear(point.x, point.y, threshold) ||
        []
      );
    },

    // MARK: - Content Version Management
    async getContentVersion(): Promise<any> {
      return nativeViewRef.current?.getContentVersion() || 1;
    },

    async setContentVersion(version: any): Promise<void> {
      return nativeViewRef.current?.setContentVersion(version);
    },

    async getSupportedContentVersions(): Promise<any[]> {
      return nativeViewRef.current?.getSupportedContentVersions() || [1];
    },

    // MARK: - Advanced Tool Picker
    async setToolPickerVisibility(
      visibility: any,
      animated = true
    ): Promise<void> {
      return nativeViewRef.current?.setToolPickerVisibility(
        visibility,
        animated
      );
    },

    async getToolPickerVisibility(): Promise<any> {
      return nativeViewRef.current?.getToolPickerVisibility() || "hidden";
    },

    async getToolPickerInfo(): Promise<any> {
      const visibility = await this.getToolPickerVisibility();
      return {
        visibility,
        isVisible: visibility === "visible",
        frameObscured: false,
        animated: true,
      };
    },

    // MARK: - Scribble Support
    async configureScribbleInteraction(enabled: boolean): Promise<void> {
      return nativeViewRef.current?.configureScribbleInteraction(enabled);
    },

    async isScribbleAvailable(): Promise<boolean> {
      return nativeViewRef.current?.isScribbleAvailable() || false;
    },

    async getScribbleConfiguration(): Promise<any> {
      const available = await this.isScribbleAvailable();
      return {
        enabled: false,
        available,
        shouldDelayFocus: false,
      };
    },

    // MARK: - Advanced Responder State
    async getResponderState(): Promise<any> {
      return nativeViewRef.current?.getResponderState() || {};
    },

    async handleAdvancedTouchEvents(enabled: boolean): Promise<void> {
      return nativeViewRef.current?.handleAdvancedTouchEvents(enabled);
    },

    // MARK: - Advanced Drawing Features
    async createStrokeFromPoints(options: any): Promise<boolean> {
      return (
        nativeViewRef.current?.createStrokeFromPoints(
          options.points,
          options.inkType,
          options.color,
          options.width
        ) || false
      );
    },

    async replaceStroke(index: number, newStroke: any): Promise<boolean> {
      return nativeViewRef.current?.replaceStroke(index, newStroke) || false;
    },

    async getDrawingStatistics(): Promise<any> {
      return nativeViewRef.current?.getDrawingStatistics() || {};
    },

    async searchStrokes(options: any): Promise<any[]> {
      if (options.region) {
        return this.getStrokesInRegion(options.region);
      } else if (options.point) {
        return this.findStrokesNear(options.point, options.threshold);
      } else {
        return this.getAllStrokes();
      }
    },

    // MARK: - Performance & Analytics
    async optimizeDrawing(): Promise<void> {
      // Could implement drawing optimization logic
    },

    async getPerformanceMetrics(): Promise<any> {
      const stats = await this.getDrawingStatistics();
      const strokeCount = stats.strokeCount || 0;

      let complexity: "low" | "medium" | "high" = "low";
      if (strokeCount > 100) complexity = "medium";
      if (strokeCount > 500) complexity = "high";

      return {
        renderTime: 0, // Would need native implementation
        strokeComplexity: complexity,
        memoryUsage: strokeCount * 1024, // Rough estimate
        recommendedOptimizations:
          complexity === "high"
            ? ["Consider using layers", "Optimize stroke density"]
            : [],
      };
    },
  }));

  return <NativeView {...props} />;
});

MunimPencilkitView.displayName = "MunimPencilkitView";

export default MunimPencilkitView;
