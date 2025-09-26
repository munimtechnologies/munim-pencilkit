import { requireNativeView } from "expo";
import * as React from "react";

import {
  MunimPencilkitViewProps,
  MunimPencilkitViewMethods,
  PKDrawingExportOptions,
  PKToolType,
  PKDrawingBounds,
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
    async getDrawingData(): Promise<ArrayBuffer | null> {
      const data = await nativeViewRef.current?.getDrawingData();
      return data ? data : null;
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
      return this.getDrawingData();
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

    // View State
    async hasContent(): Promise<boolean> {
      // This would need to be implemented in the native side or derived from events
      return false;
    },

    async getStrokeCount(): Promise<number> {
      // This would need to be implemented in the native side or derived from events
      return 0;
    },

    async getDrawingBounds(): Promise<PKDrawingBounds> {
      // This would need to be implemented in the native side
      return { x: 0, y: 0, width: 0, height: 0 };
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
  }));

  return <NativeView {...props} />;
});

MunimPencilkitView.displayName = "MunimPencilkitView";

export default MunimPencilkitView;
