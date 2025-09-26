import { registerWebModule, NativeModule } from "expo";

import {
  MunimPencilkitModuleEvents,
  PKTool,
  PKDrawingPolicy,
} from "./MunimPencilkit.types";

class MunimPencilkitModule extends NativeModule<MunimPencilkitModuleEvents> {
  // Legacy support
  PI = Math.PI;

  async setValueAsync(value: string): Promise<void> {
    // Legacy event for backward compatibility
    this.emit("onDrawingChanged", {
      hasContent: false,
      strokeCount: 0,
      bounds: { x: 0, y: 0, width: 0, height: 0 },
    });
  }

  hello() {
    return "Hello world! 👋";
  }

  // PencilKit functionality (web stubs)
  getAvailableTools(): { [key: string]: PKTool } {
    return {
      pen: {
        type: "pen",
        name: "Pen",
        supportsColor: true,
        supportsWidth: true,
        minWidth: 1,
        maxWidth: 100,
      },
      pencil: {
        type: "pencil",
        name: "Pencil",
        supportsColor: true,
        supportsWidth: true,
        minWidth: 1,
        maxWidth: 50,
      },
      marker: {
        type: "marker",
        name: "Marker",
        supportsColor: true,
        supportsWidth: true,
        minWidth: 5,
        maxWidth: 100,
      },
      eraser: {
        type: "eraser",
        name: "Eraser",
        supportsColor: false,
        supportsWidth: true,
        minWidth: 5,
        maxWidth: 200,
      },
      lasso: {
        type: "lasso",
        name: "Lasso Tool",
        supportsColor: false,
        supportsWidth: false,
      },
    };
  }

  getInkTypes(): { [key: string]: string } {
    return {
      pen: "Creates crisp, precise lines that are ideal for writing and detailed drawings",
      pencil: "Creates soft, textured lines that simulate a real pencil",
      marker: "Creates broad, semi-transparent lines ideal for highlighting",
    };
  }

  isPencilKitAvailable(): boolean {
    return false; // PencilKit is not available on web
  }

  getSupportedFeatures(): string[] {
    return ["basic-drawing"]; // Limited web support
  }

  getVersion(): string {
    return "1.0.0-web";
  }

  setGlobalDrawingPolicy(policy: PKDrawingPolicy): void {
    console.log("setGlobalDrawingPolicy not supported on web:", policy);
  }

  async exportDrawingAsImage(scale: number = 1.0): Promise<string | null> {
    console.log("exportDrawingAsImage not supported on web");
    return null;
  }

  async exportDrawingAsData(): Promise<ArrayBuffer | null> {
    console.log("exportDrawingAsData not supported on web");
    return null;
  }

  async exportDrawingAsPDF(scale: number = 1.0): Promise<ArrayBuffer | null> {
    console.log("exportDrawingAsPDF not supported on web");
    return null;
  }

  async createDrawingData(strokes?: any[]): Promise<ArrayBuffer> {
    return new ArrayBuffer(0);
  }

  async validateDrawingData(data: ArrayBuffer): Promise<boolean> {
    return data.byteLength > 0;
  }

  async convertDrawingDataToImage(
    data: ArrayBuffer,
    options?: any
  ): Promise<string | null> {
    return null;
  }

  getCurrentDevice(): any {
    return {
      model: "Web Browser",
      systemVersion: navigator.userAgent,
      supportsPencil: false,
      supportsHover: false,
    };
  }

  async optimizeDrawingData(data: ArrayBuffer): Promise<ArrayBuffer> {
    return data;
  }

  async getDrawingComplexity(data: ArrayBuffer): Promise<any> {
    return {
      strokeCount: 0,
      pointCount: 0,
      complexity: "low" as const,
      estimatedMemoryUsage: 0,
    };
  }

  hexToColor(hex: string): { r: number; g: number; b: number; a: number } {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result
      ? {
          r: parseInt(result[1], 16),
          g: parseInt(result[2], 16),
          b: parseInt(result[3], 16),
          a: 1,
        }
      : { r: 0, g: 0, b: 0, a: 1 };
  }

  colorToHex(r: number, g: number, b: number, a: number = 1): string {
    return "#" + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
  }

  generatePalette(baseColor: string, count: number): string[] {
    return Array(count).fill(baseColor);
  }

  getToolPresets(): any {
    return {
      writing: [
        { name: "Fine Pen", toolType: "pen", color: "#000000", width: 2 },
      ],
      drawing: [
        { name: "Pencil", toolType: "pencil", color: "#333333", width: 5 },
      ],
      sketching: [
        {
          name: "Light Pencil",
          toolType: "pencil",
          color: "#666666",
          width: 3,
        },
      ],
      highlighting: [
        {
          name: "Yellow Marker",
          toolType: "marker",
          color: "#FFFF00",
          width: 15,
        },
      ],
    };
  }

  configureAccessibility(options: any): void {
    console.log("configureAccessibility not supported on web");
  }

  getAccessibilityDescription(toolType: string): string {
    return `${toolType} tool`;
  }

  async enableAdvancedFeatures(): Promise<boolean> {
    return false;
  }

  getCapabilities(): any {
    return {
      maxCanvasSize: { width: 1920, height: 1080 },
      maxStrokeCount: 1000,
      supportedExportFormats: ["png"],
      supportedImportFormats: ["png"],
      supportsRealTimeCollaboration: false,
      supportsLayering: false,
      supportsAnimation: false,
    };
  }
}

export default registerWebModule(MunimPencilkitModule, "MunimPencilkitModule");
