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
export default requireNativeModule<MunimPencilkitModule>("MunimPencilkit");
