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

// MARK: - Debug Types

export interface DebugEventPayload {
  debug: true;
  method: string;
  step?: string;
  strokes: number;
  result?: any;
  bytes?: number;
  error?: string;
  timestamp: number;
}

// MARK: - Event Payload Types

export interface OnDrawingChangedEventPayload {
  hasContent: boolean;
  strokeCount: number;
  bounds: PKDrawingBounds;
  // Debug properties (optional)
  debug?: boolean;
  method?: string;
  step?: string;
  strokes?: number;
  result?: any;
  bytes?: number;
  error?: string;
  timestamp?: number;
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
  onAdvancedTap: (params: PKAdvancedTouchEvent) => void;
  onAdvancedLongPress: (params: PKAdvancedTouchEvent) => void;
  onScribbleWillBegin: (params: PKScribbleEvent) => void;
  onScribbleDidFinish: (params: PKScribbleEvent) => void;
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

  // Ink Behavior Controls
  enableInkSmoothing?: boolean;
  enableStrokeRefinement?: boolean;
  enableHandwritingRecognition?: boolean;
  naturalDrawingMode?: boolean;

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
  onAdvancedTap?: (event: { nativeEvent: PKAdvancedTouchEvent }) => void;
  onAdvancedLongPress?: (event: { nativeEvent: PKAdvancedTouchEvent }) => void;
  onScribbleWillBegin?: (event: { nativeEvent: PKScribbleEvent }) => void;
  onScribbleDidFinish?: (event: { nativeEvent: PKScribbleEvent }) => void;

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
  getDrawingData(
    debug?: boolean
  ): Promise<string | null | DebugEventPayload>;
  loadDrawingData(data: ArrayBuffer): Promise<void>;

  // Export Functions
  exportAsImage(options?: PKDrawingExportOptions): Promise<string | null>;
  exportAsPDF(options?: PKDrawingExportOptions): Promise<ArrayBuffer | null>;
  exportAsData(): Promise<string | null>;

  // Tool Management
  setTool(toolType: PKToolType, color?: string, width?: number): Promise<void>;
  getTool(): Promise<PKToolConfiguration | null>;

  // Ink Behavior Controls
  setEnableInkSmoothing(enable: boolean): Promise<void>;
  setEnableStrokeRefinement(enable: boolean): Promise<void>;
  setEnableHandwritingRecognition(enable: boolean): Promise<void>;
  setNaturalDrawingMode(natural: boolean): Promise<void>;

  // View State
  hasContent(debug?: boolean): Promise<boolean | DebugEventPayload>;
  getStrokeCount(debug?: boolean): Promise<number | DebugEventPayload>;
  getDrawingBounds(): Promise<PKDrawingBounds>;
  getDrawingBoundsStruct(): Promise<PKDrawingBounds>;

  // Zoom and Pan
  zoomToFitDrawing(animated?: boolean): Promise<void>;
  setZoomScale(scale: number, animated?: boolean): Promise<void>;

  // Advanced Features
  beginDrawing(): Promise<void>;
  endDrawing(): Promise<void>;
  suspendDrawing(): Promise<void>;
  resumeDrawing(): Promise<void>;

  // MARK: - Advanced Stroke Inspection
  getAllStrokes(): Promise<PKStroke[]>;
  getStroke(index: number): Promise<PKStroke | null>;
  getStrokesInRegion(region: PKDrawingBounds): Promise<PKStroke[]>;
  analyzeDrawing(): Promise<PKDrawingAnalysis>;
  findStrokesNear(
    point: { x: number; y: number },
    threshold?: number
  ): Promise<PKStroke[]>;

  // MARK: - Content Version Management
  getContentVersion(): Promise<PKContentVersion>;
  setContentVersion(version: PKContentVersion): Promise<void>;
  getSupportedContentVersions(): Promise<PKContentVersion[]>;

  // MARK: - Advanced Tool Picker
  setToolPickerVisibility(
    visibility: PKToolPickerVisibilityState,
    animated?: boolean
  ): Promise<void>;
  getToolPickerVisibility(): Promise<PKToolPickerVisibilityState>;
  getToolPickerInfo(): Promise<PKToolPickerInfo>;

  // MARK: - Scribble Support
  configureScribbleInteraction(enabled: boolean): Promise<void>;
  isScribbleAvailable(): Promise<boolean>;
  getScribbleConfiguration(): Promise<PKScribbleConfiguration>;

  // MARK: - Advanced Responder State
  getResponderState(): Promise<PKResponderState>;
  handleAdvancedTouchEvents(enabled: boolean): Promise<void>;

  // MARK: - Advanced Drawing Features
  createStrokeFromPoints(options: PKStrokeCreationOptions): Promise<boolean>;
  replaceStroke(index: number, newStroke: PKStroke): Promise<boolean>;
  getDrawingStatistics(): Promise<PKDrawingAnalysis>;
  searchStrokes(options: PKStrokeSearchOptions): Promise<PKStroke[]>;

  // MARK: - Performance & Analytics
  optimizeDrawing(): Promise<void>;
  getPerformanceMetrics(): Promise<{
    renderTime: number;
    strokeComplexity: "low" | "medium" | "high";
    memoryUsage: number;
    recommendedOptimizations: string[];
  }>;
}

// MARK: - Module Interface

export interface MunimPencilkitModule {
  // Test Functions
  testNativeModule(): string;

  // Tool Information
  getAvailableTools(): { [key: string]: PKTool };
  getInkTypes(): { [key: string]: string };

  // Drawing Export (Global Functions - these return null as they're handled by view)
  exportDrawingAsImage(scale?: number): Promise<string | null>;
  exportDrawingAsData(): Promise<ArrayBuffer | null>;
  exportDrawingAsPDF(scale?: number): Promise<ArrayBuffer | null>;
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

// MARK: - Advanced Stroke Types

export interface PKStrokePoint {
  location: { x: number; y: number };
  timeOffset: number;
  size: { width: number; height: number };
  opacity: number;
  force: number;
  azimuth: number;
  altitude: number;
}

export interface PKStrokePath {
  count: number;
  creationDate: number; // timestamp
  points: PKStrokePoint[];
  interpolatedPoints: PKStrokePoint[];
}

export interface PKStroke {
  renderBounds: PKDrawingBounds;
  path: PKStrokePath;
  ink: {
    type: PKInkType;
    color: string;
    requiredContentVersion?: number;
  };
  transform: {
    a: number;
    b: number;
    c: number;
    d: number;
    tx: number;
    ty: number;
  };
  uuid?: string; // Available iOS 14+
}

export interface PKDrawingAnalysis {
  strokeCount: number;
  totalPoints: number;
  inkTypes: { [key: string]: number };
  averageForce: number;
  bounds: PKDrawingBounds;
  timestamp?: number;
  canvasSize?: { width: number; height: number };
}

// MARK: - Content Version Types

export type PKContentVersion = 1 | 2 | 3 | 4;

export interface PKContentVersionInfo {
  current: PKContentVersion;
  supported: PKContentVersion[];
  description: string;
}

// MARK: - Tool Picker Visibility Types

export type PKToolPickerVisibilityState = "visible" | "hidden" | "auto";

export interface PKToolPickerInfo {
  visibility: PKToolPickerVisibilityState;
  isVisible: boolean;
  frameObscured: boolean;
  animated: boolean;
}

// MARK: - Scribble Support Types

export interface PKScribbleConfiguration {
  enabled: boolean;
  available: boolean;
  shouldDelayFocus: boolean;
}

export interface PKScribbleEvent {
  type: "scribbleWillBegin" | "scribbleDidFinish";
  timestamp: number;
  location?: { x: number; y: number };
}

// MARK: - Advanced Responder Types

export interface PKResponderState {
  isFirstResponder: boolean;
  canBecomeFirstResponder: boolean;
  canResignFirstResponder: boolean;
  toolPickerVisible: boolean;
  toolPickerFrameObscured: boolean;
  allowsFingerDrawing: boolean;
  isRulerActive: boolean;
  drawingPolicy: PKDrawingPolicy;
}

export interface PKAdvancedTouchEvent {
  type: "advancedTap" | "advancedLongPress";
  location: { x: number; y: number };
  timestamp: number;
  nearbyStrokes?: PKStroke[];
}

// MARK: - Advanced Drawing Features

export interface PKStrokeCreationOptions {
  points: PKStrokePoint[];
  inkType: PKInkType;
  color: string;
  width: number;
  opacity?: number;
}

export interface PKStrokeSearchOptions {
  region?: PKDrawingBounds;
  point?: { x: number; y: number };
  threshold?: number;
  inkType?: PKInkType;
  timeRange?: { start: number; end: number };
}

// MARK: - Legacy Advanced Types (Enhanced)

export interface PKStrokeInfo extends PKStroke {
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
  contentVersion: PKContentVersion;
  analysis: PKDrawingAnalysis;
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
