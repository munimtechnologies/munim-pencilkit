import type { StyleProp, ViewStyle } from "react-native";

// MARK: - Core PencilKit Types

export type PKDrawingBounds = {
  x: number;
  y: number;
  width: number;
  height: number;
};

export type PKToolType = "pen" | "pencil" | "marker" | "eraser" | "lasso";

export type PKDrawingPolicy = "default" | "pencilOnly" | "anyInput";

export type PKInkType = "pen" | "pencil" | "marker";

export type PKEraserType = "bitmap" | "vector";

// MARK: - Tool Configuration Types

export interface PKTool {
  type: PKToolType;
  name: string;
  supportsColor: boolean;
  supportsWidth: boolean;
  minWidth?: number;
  maxWidth?: number;
}

export interface PKInkingToolOptions {
  type: PKInkType;
  color?: string;
  width?: number;
  opacity?: number;
}

export interface PKEraserToolOptions {
  type?: PKEraserType;
  width?: number;
}

export interface PKToolConfiguration {
  toolType: PKToolType;
  color?: string;
  width?: number;
  eraserType?: PKEraserType;
}

// MARK: - Drawing Export Types

export interface PKDrawingExportOptions {
  scale?: number;
  format?: "png" | "pdf" | "data";
  quality?: number;
}

export interface PKDrawingData {
  data: ArrayBuffer;
  bounds: PKDrawingBounds;
  strokeCount: number;
}

// MARK: - Event Payload Types

export interface OnDrawingChangedEventPayload {
  hasContent: boolean;
  strokeCount: number;
  bounds: PKDrawingBounds;
}

export interface OnToolChangedEventPayload {
  toolType: PKToolType;
  color?: string;
  width?: number;
}

export interface OnDrawingStartedEventPayload {
  timestamp: number;
}

export interface OnDrawingEndedEventPayload {
  timestamp: number;
}

// MARK: - Module Events

export type MunimPencilkitModuleEvents = {
  onDrawingChanged: (params: OnDrawingChangedEventPayload) => void;
  onToolChanged: (params: OnToolChangedEventPayload) => void;
  onDrawingStarted: (params: OnDrawingStartedEventPayload) => void;
  onDrawingEnded: (params: OnDrawingEndedEventPayload) => void;
};

// MARK: - View Props and Configuration

export interface MunimPencilkitViewProps {
  // Visual Configuration
  style?: StyleProp<ViewStyle>;
  backgroundColor?: string;

  // Canvas Configuration
  showToolPicker?: boolean;
  allowsFingerDrawing?: boolean;
  isRulerActive?: boolean;
  drawingPolicy?: PKDrawingPolicy;

  // Tool Configuration
  toolType?: PKToolType;
  toolColor?: string;
  toolWidth?: number;
  eraserType?: PKEraserType;

  // Drawing Data
  drawingData?: ArrayBuffer;
  initialDrawing?: PKDrawingData;

  // Event Handlers
  onDrawingChanged?: (event: {
    nativeEvent: OnDrawingChangedEventPayload;
  }) => void;
  onToolChanged?: (event: { nativeEvent: OnToolChangedEventPayload }) => void;
  onDrawingStarted?: (event: {
    nativeEvent: OnDrawingStartedEventPayload;
  }) => void;
  onDrawingEnded?: (event: { nativeEvent: OnDrawingEndedEventPayload }) => void;

  // Advanced Configuration
  maxZoomScale?: number;
  minZoomScale?: number;
  contentMode?: "scaleToFill" | "scaleAspectFit" | "scaleAspectFill";

  // Accessibility
  accessibilityLabel?: string;
  accessibilityHint?: string;
}

// MARK: - View Methods Interface

export interface MunimPencilkitViewMethods {
  // Drawing Management
  clearDrawing(): Promise<void>;
  undo(): Promise<void>;
  redo(): Promise<void>;

  // Data Management
  getDrawingData(): Promise<ArrayBuffer | null>;
  loadDrawingData(data: ArrayBuffer): Promise<void>;

  // Export Functions
  exportAsImage(options?: PKDrawingExportOptions): Promise<string | null>;
  exportAsPDF(options?: PKDrawingExportOptions): Promise<ArrayBuffer | null>;
  exportAsData(): Promise<ArrayBuffer | null>;

  // Tool Management
  setTool(toolType: PKToolType, color?: string, width?: number): Promise<void>;
  getTool(): Promise<PKToolConfiguration | null>;

  // View State
  hasContent(): Promise<boolean>;
  getStrokeCount(): Promise<number>;
  getDrawingBounds(): Promise<PKDrawingBounds>;

  // Zoom and Pan
  zoomToFitDrawing(animated?: boolean): Promise<void>;
  setZoomScale(scale: number, animated?: boolean): Promise<void>;

  // Advanced Features
  beginDrawing(): Promise<void>;
  endDrawing(): Promise<void>;
  suspendDrawing(): Promise<void>;
  resumeDrawing(): Promise<void>;
}

// MARK: - Module Interface

export interface MunimPencilkitModule {
  // Tool Information
  getAvailableTools(): { [key: string]: PKTool };
  getInkTypes(): { [key: string]: string };

  // System Information
  isPencilKitAvailable(): boolean;
  getSupportedFeatures(): string[];

  // Global Configuration
  setGlobalDrawingPolicy(policy: PKDrawingPolicy): void;

  // Utility Functions
  createDrawingData(strokes?: any[]): Promise<ArrayBuffer>;
  validateDrawingData(data: ArrayBuffer): Promise<boolean>;
}

// MARK: - Legacy Support (for backward compatibility)

export type OnLoadEventPayload = {
  url: string;
};

export type ChangeEventPayload = {
  value: string;
};

// MARK: - Error Types

export interface PencilKitError extends Error {
  code: string;
  userInfo?: { [key: string]: any };
}

export type PKErrorCode =
  | "unavailable"
  | "invalidData"
  | "exportFailed"
  | "toolNotSupported"
  | "drawingTooLarge"
  | "permissionDenied";

// MARK: - Advanced Types

export interface PKStrokeInfo {
  id: string;
  toolType: PKToolType;
  color: string;
  width: number;
  bounds: PKDrawingBounds;
  timestamp: number;
  pointCount: number;
}

export interface PKDrawingInfo {
  bounds: PKDrawingBounds;
  strokeCount: number;
  strokes: PKStrokeInfo[];
  createdAt: Date;
  modifiedAt: Date;
  version: string;
}

// MARK: - Accessibility Types

export interface PKAccessibilityConfiguration {
  announceDrawingChanges?: boolean;
  describeTools?: boolean;
  enableVoiceOver?: boolean;
  customAccessibilityActions?: PKAccessibilityAction[];
}

export interface PKAccessibilityAction {
  name: string;
  hint?: string;
  action: () => void;
}
