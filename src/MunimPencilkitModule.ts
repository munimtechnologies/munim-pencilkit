import { NativeModule, requireNativeModule } from "expo";

import {
  MunimPencilkitModuleEvents,
  PKTool,
  PKDrawingPolicy,
  PKDrawingExportOptions,
} from "./MunimPencilkit.types";

declare class MunimPencilkitModule extends NativeModule<MunimPencilkitModuleEvents> {
  // MARK: - Tool Information
  getAvailableTools(): { [key: string]: PKTool };
  getInkTypes(): { [key: string]: string };

  // MARK: - System Information
  isPencilKitAvailable(): boolean;
  getSupportedFeatures(): string[];
  getVersion(): string;

  // MARK: - Global Configuration
  setGlobalDrawingPolicy(policy: PKDrawingPolicy): void;

  // MARK: - Drawing Export (Global Functions)
  exportDrawingAsImage(scale?: number): Promise<string | null>;
  exportDrawingAsData(): Promise<ArrayBuffer | null>;
  exportDrawingAsPDF(scale?: number): Promise<ArrayBuffer | null>;

  // MARK: - Utility Functions
  createDrawingData(strokes?: any[]): Promise<ArrayBuffer>;
  validateDrawingData(data: ArrayBuffer): Promise<boolean>;
  convertDrawingDataToImage(
    data: ArrayBuffer,
    options?: PKDrawingExportOptions
  ): Promise<string | null>;

  // MARK: - Platform Information
  getCurrentDevice(): {
    model: string;
    systemVersion: string;
    supportsPencil: boolean;
    supportsHover: boolean;
  };

  // MARK: - Performance Utilities
  optimizeDrawingData(data: ArrayBuffer): Promise<ArrayBuffer>;
  getDrawingComplexity(data: ArrayBuffer): Promise<{
    strokeCount: number;
    pointCount: number;
    complexity: "low" | "medium" | "high";
    estimatedMemoryUsage: number;
  }>;

  // MARK: - Color Utilities
  hexToColor(hex: string): { r: number; g: number; b: number; a: number };
  colorToHex(r: number, g: number, b: number, a?: number): string;
  generatePalette(baseColor: string, count: number): string[];

  // MARK: - Tool Presets
  getToolPresets(): {
    writing: Array<{
      name: string;
      toolType: string;
      color: string;
      width: number;
    }>;
    drawing: Array<{
      name: string;
      toolType: string;
      color: string;
      width: number;
    }>;
    sketching: Array<{
      name: string;
      toolType: string;
      color: string;
      width: number;
    }>;
    highlighting: Array<{
      name: string;
      toolType: string;
      color: string;
      width: number;
    }>;
  };

  // MARK: - Accessibility
  configureAccessibility(options: {
    announceDrawingChanges?: boolean;
    describeTools?: boolean;
    enableVoiceOver?: boolean;
  }): void;

  getAccessibilityDescription(toolType: string): string;

  // MARK: - Advanced Features
  enableAdvancedFeatures(): Promise<boolean>;
  getCapabilities(): {
    maxCanvasSize: { width: number; height: number };
    maxStrokeCount: number;
    supportedExportFormats: string[];
    supportedImportFormats: string[];
    supportsRealTimeCollaboration: boolean;
    supportsLayering: boolean;
    supportsAnimation: boolean;
  };

  // MARK: - Legacy Support (for backward compatibility)
  PI: number;
  hello(): string;
  setValueAsync(value: string): Promise<void>;
}

// This call loads the native module object from the JSI.
export default requireNativeModule<MunimPencilkitModule>("MunimPencilkit");
