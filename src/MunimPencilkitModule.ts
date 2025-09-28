import { NativeModule, requireNativeModule } from "expo";

import { MunimPencilkitModuleEvents, PKTool } from "./MunimPencilkit.types";

declare class MunimPencilkitModule extends NativeModule<MunimPencilkitModuleEvents> {
  // MARK: - Test Functions
  testNativeModule(): string;

  // MARK: - Tool Information
  getAvailableTools(): { [key: string]: PKTool };
  getInkTypes(): { [key: string]: string };

  // MARK: - Drawing Export (Global Functions - these return null as they're handled by view)
  exportDrawingAsImage(scale?: number): Promise<string | null>;
  exportDrawingAsData(): Promise<ArrayBuffer | null>;
  exportDrawingAsPDF(scale?: number): Promise<ArrayBuffer | null>;
}

// This call loads the native module object from the JSI.
// Add error handling for cases where the native module isn't available
let MunimPencilkitModuleInstance: MunimPencilkitModule;

try {
  MunimPencilkitModuleInstance =
    requireNativeModule<MunimPencilkitModule>("MunimPencilkit");
} catch (error) {
  console.warn(
    "[MunimPencilkit] Native module not found. This usually means:\n" +
      "1. You need to rebuild your Expo development build\n" +
      "2. The native module isn't properly linked\n" +
      "3. You're running in a web environment\n" +
      "Error:",
    error
  );

  // Create a fallback module for development
  MunimPencilkitModuleInstance = {
    testNativeModule: () =>
      "Native module not available - please rebuild your development build",
    getAvailableTools: () => ({}),
    getInkTypes: () => ({}),
    exportDrawingAsImage: async () => null,
    exportDrawingAsData: async () => null,
    exportDrawingAsPDF: async () => null,
  } as any;
}

export default MunimPencilkitModuleInstance;
