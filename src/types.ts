export interface ApplePencilData {
  pressure?: number
  altitude?: number
  azimuth?: number
  azimuthUnitVector?: { x: number; y: number }
  force?: number
  maximumPossibleForce?: number
  perpendicularForce?: number
  rollAngle?: number
  timestamp: number
  location?: { x: number; y: number }
  previousLocation?: { x: number; y: number }
  preciseLocation?: { x: number; y: number }
  isApplePencil?: boolean
  phase?: 'began' | 'moved' | 'ended' | 'cancelled'
  hasPreciseLocation?: boolean
  estimatedProperties?: string[]
  estimatedPropertiesExpectingUpdates?: string[]
  velocity?: number
  acceleration?: number
  action?: 'drawingStarted' | 'drawingEnded'
  isEraserOn?: boolean
  viewId?: number
  isPredicted?: boolean
  isEstimated?: boolean
  timestampClock?: 'systemUptime'
  preciseLocationAvailable?: boolean
}

export interface ApplePencilCoalescedTouchesData {
  viewId: number
  touches: ApplePencilData[]
  timestamp: number
}

export interface ApplePencilPredictedTouchesData {
  viewId: number
  touches: ApplePencilData[]
  timestamp: number
}

export interface ApplePencilEstimatedPropertiesData {
  viewId: number
  touchId: number
  updatedProperties: string[]
  newData: ApplePencilData
  timestamp: number
}

export interface ApplePencilMotionData {
  viewId: number
  rollAngle: number
  pitchAngle: number
  yawAngle: number
  timestamp: number
  source: 'deviceMotion'
  timestampClock: 'systemUptime'
}

export interface ApplePencilHoverData {
  viewId: number
  location: { x: number; y: number }
  altitude: number
  azimuth: number
  azimuthUnitVector: { x: number; y: number }
  zOffset?: number
  rollAngle?: number
  timestamp: number
}

export type ApplePencilPreferredAction =
  | 'ignore'
  | 'switchEraser'
  | 'switchPrevious'
  | 'showColorPalette'
  | 'showInkAttributes'
  | 'showContextualPalette'
  | 'runSystemShortcut'

export interface ApplePencilSqueezeData {
  viewId: number
  phase: 'began' | 'changed' | 'ended' | 'cancelled'
  timestamp: number
  preferredAction: ApplePencilPreferredAction
  hoverPose?: {
    location: { x: number; y: number }
    zOffset: number
    azimuth: number
    azimuthUnitVector: { x: number; y: number }
    altitude: number
    rollAngle: number
  }
}

export interface ApplePencilDoubleTapData {
  viewId: number
  phase: 'ended'
  timestamp: number
  preferredAction: ApplePencilPreferredAction
  hoverPose?: {
    location: { x: number; y: number }
    zOffset: number
    azimuth: number
    azimuthUnitVector: { x: number; y: number }
    altitude: number
    rollAngle: number
  }
}

export interface ApplePencilPreferredSqueezeActionData {
  viewId: number
  preferredAction: ApplePencilPreferredAction
}

export type SqueezeEraserBehavior =
  | 'alwaysOn'
  | 'switchEraserOnly'
  | 'toggle'
  | 'none'

export type CustomStylusRenderMode = 'incremental' | 'replay'

export type CustomStylusEraserMode = 'clear' | 'paint'

export interface PencilKitPoint {
  location: { x: number; y: number }
  pressure: number
  azimuth: number
  altitude: number
  timestamp: number
}

export interface PencilKitTool {
  type: 'pen' | 'pencil' | 'marker' | 'eraser' | 'lasso'
  width: number
  color: string
}

export interface PencilKitStroke {
  points: PencilKitPoint[]
  tool: PencilKitTool
  color: string
  width: number
}

export interface PencilKitDrawingData {
  strokes: PencilKitStroke[]
  bounds: {
    x: number
    y: number
    width: number
    height: number
  }
  dataBase64?: string
  imageBase64?: string
}

export interface PencilKitConfig {
  allowsFingerDrawing: boolean
  allowsPencilOnlyDrawing: boolean
  isRulerActive: boolean
  drawingPolicy: 'default' | 'anyInput' | 'pencilOnly'
  enableApplePencilData?: boolean
  enableToolPicker?: boolean
  enableHapticFeedback?: boolean
  enableMotionTracking?: boolean
  enableSqueezeInteraction?: boolean
  enableDoubleTapInteraction?: boolean
  enableHoverSupport?: boolean
  useCustomStylusView?: boolean
  squeezeEraserBehavior?: SqueezeEraserBehavior
  customStylusRenderMode?: CustomStylusRenderMode
  customStylusEraserMode?: CustomStylusEraserMode
  customStylusOpaqueCanvas?: boolean
  customStylusSurfaceColor?: string
  showHoverPreview?: boolean
  strokeColor?: string
  baseLineWidth?: number
  /**
   * Emits `onDrawingSnapshot` after drawing settles. Omit or use 0 to disable
   * automatic serialization.
   */
  snapshotDebounceMs?: number
}

export type PencilKitDocumentFormat = 'archive' | 'png' | 'jpeg' | 'pdf'
export type PencilKitDocumentOutput = 'base64' | 'fileUrl'
export type PencilKitCropMode = 'drawingBounds' | 'canvas' | 'custom'

export interface PencilKitRect {
  x: number
  y: number
  width: number
  height: number
}

export interface PencilKitExportOptions {
  version: 1
  format: PencilKitDocumentFormat
  output?: PencilKitDocumentOutput
  crop?: PencilKitCropMode
  cropRect?: PencilKitRect
  scale?: number
  backgroundColor?: string
  quality?: number
}

export interface PencilKitExportResult {
  version: 1
  format: PencilKitDocumentFormat
  output: PencilKitDocumentOutput
  mimeType: string
  byteLength: number
  width?: number
  height?: number
  dataBase64?: string
  fileUrl?: string
}

export interface PencilKitImportOptions {
  version: 1
  format: 'archive' | 'png' | 'jpeg'
  input: PencilKitDocumentOutput
  dataBase64?: string
  fileUrl?: string
}

export type PencilKitInkType =
  | 'pen'
  | 'pencil'
  | 'marker'
  | 'monoline'
  | 'fountainPen'
  | 'watercolor'
  | 'crayon'

export type PencilKitEraserType = 'bitmap' | 'vector'

export type PencilKitToolState =
  | {
      type: 'ink'
      inkType: PencilKitInkType
      color: string
      width: number
    }
  | { type: 'eraser'; eraserType?: PencilKitEraserType; width?: number }
  | { type: 'lasso' }

export interface PencilKitHistoryEvent {
  viewId: number
  revision: number
  canUndo: boolean
  canRedo: boolean
}

export interface PencilKitDrawingChangeEvent extends PencilKitHistoryEvent {
  dirty: boolean
  bounds: PencilKitRect
}

export interface PencilKitDrawingPhaseEvent extends PencilKitHistoryEvent {
  phase: 'began' | 'ended'
  timestamp: number
  timestampClock: 'systemUptime'
}

export interface PencilKitDrawingSnapshotEvent {
  viewId: number
  revision: number
  drawing: PencilKitDrawingData
}

export interface PencilKitToolPickerEvent {
  viewId: number
  visible: boolean
  selectedTool: PencilKitToolState
}

export interface PencilKitCapabilities {
  platform: 'ios' | 'android' | 'other'
  supported: boolean
  minimumIOSVersion: string
  /** Runtime OS version (iOS only). */
  osVersion?: string
  documentVersion: 1
  documentFormats: PencilKitDocumentFormat[]
  outputKinds: PencilKitDocumentOutput[]
  importFormats: Array<'archive' | 'png' | 'jpeg'>
  tools: {
    ink: PencilKitInkType[]
    eraser: PencilKitEraserType[]
    lasso: boolean
    toolPicker: boolean
  }
  telemetry: {
    pencilTouches: boolean
    predictedTouches: boolean
    coalescedTouches: boolean
    hover: boolean
    squeeze: boolean
    barrelRoll: boolean
    pencilMotion: false
    deviceMotion: boolean
  }
  /** Native import/export size limits, in bytes/pixels (iOS only). */
  limits?: {
    maxJSONUTF8Bytes: number
    maxBase64EncodedBytes: number
    maxBase64DecodedBytes: number
    maxImageDimension: number
    maxImagePixelCount: number
  }
}
