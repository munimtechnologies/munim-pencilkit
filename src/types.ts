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
  /**
   * Hover gesture phase. `ended`/`cancelled` fire once when the pencil leaves
   * hover range; their pose fields are not meaningful.
   */
  phase?: 'began' | 'changed' | 'ended' | 'cancelled'
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

/**
 * One control point of a stroke path (`PKStrokePoint`), in stroke space:
 * apply the stroke's `transform` to get canvas coordinates.
 *
 * `pressure` and `timestamp` are the legacy names; native output fills them
 * with `force` and `timeOffset`. On input every field except `location` is
 * optional and falls back to: `timeOffset` = `timestamp` minus the first
 * point's `timestamp` (else 0), `size` = the stroke `width`, `opacity` 1,
 * `force` = `pressure` (else 1), `azimuth` 0, `altitude` pi/2,
 * `secondaryScale` 1.
 */
export interface PencilKitPoint {
  location: { x: number; y: number }
  pressure: number
  azimuth: number
  altitude: number
  timestamp: number
  /** Seconds since the stroke started. */
  timeOffset?: number
  size?: { width: number; height: number }
  opacity?: number
  force?: number
  /** iOS 17+ ink-specific scale (e.g. watercolor, fountain pen). */
  secondaryScale?: number
  /** iOS 26+ ink threshold (reed pen). Ignored on older iOS. */
  threshold?: number
}

export interface PencilKitTool {
  type: 'pen' | 'pencil' | 'marker' | 'eraser' | 'lasso'
  width: number
  color: string
}

/** Row-major 2D affine transform (`CGAffineTransform`). */
export interface PencilKitAffineTransform {
  a: number
  b: number
  c: number
  d: number
  tx: number
  ty: number
}

/**
 * A PencilKit stroke. The legacy fields (`points`, `tool`, `color`, `width`)
 * are always present in native output; the rest round-trip `PKStroke`
 * exactly. `tool.type` only distinguishes pen/pencil/marker (other inks
 * report `pen`), so `ink.inkType` is authoritative. `width` is the mean point
 * width; PencilKit itself stores width per point in `size`.
 *
 * On input the ink comes from `ink.inkType`, then `tool.type`, else `pen`;
 * the color from `ink.color`, then `color`, then `tool.color`.
 */
export interface PencilKitStroke {
  points: PencilKitPoint[]
  tool: PencilKitTool
  color: string
  width: number
  ink?: { inkType: PencilKitInkType; color: string }
  /** Maps `points` into canvas space. Identity when omitted. */
  transform?: PencilKitAffineTransform
  /** Clip mask as SVG path data (absolute M/L/Q/C/Z), in stroke space. */
  mask?: string
  /** Seed for ink texture randomness (UInt32). Random when omitted. */
  randomSeed?: number
  /** Milliseconds since the Unix epoch. */
  creationDate?: number
  /** Output only: the rendered bounds in canvas space. */
  renderBounds?: PencilKitRect
  /** Output only: the PKContentVersion this stroke needs. */
  requiredContentVersion?: number
}

/** PKContentVersion: 1 (iOS 14 inks), 2 (iOS 17 inks), 3 (iOS 17.5 fountain pen), 4 (iOS 26 reed), 5 (iOS 27 render state). */
export type PencilKitContentVersion = 1 | 2 | 3 | 4 | 5 | 'latest'

export interface PencilKitGetDrawingOptions {
  /**
   * Fill `strokes` in the result. Defaults to the view's
   * `config.includeStrokesInDrawing` (false).
   */
  includeStrokes?: boolean
}

/**
 * A drawing snapshot. `strokes` is only filled when requested
 * (`includeStrokesInDrawing` / `getDrawing({ includeStrokes: true })`).
 *
 * When passed to `setDrawing`, `dataBase64` (the PKDrawing archive) wins;
 * without it a non-empty `strokes` array is used instead.
 */
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
  /** PencilKit engine only: the PKContentVersion needed to render this drawing. */
  requiredContentVersion?: number
}

/** iOS 18+ custom tool picker items (`PKToolPicker(toolItems:)`). */
export type PencilKitToolItem =
  | {
      type: 'ink'
      inkType: PencilKitInkType
      color?: string
      width?: number
      identifier?: string
      allowsColorSelection?: boolean
    }
  | { type: 'eraser'; eraserType?: PencilKitEraserType; width?: number }
  | { type: 'lasso' }
  | { type: 'ruler' }
  | { type: 'scribble' }
  | {
      /**
       * App-defined tool. PencilKit does not draw with it: listen to
       * `onToolPickerItemChange` and handle input yourself.
       */
      type: 'custom'
      identifier: string
      name: string
      /** SF Symbol name for the picker image. Defaults to `pencil.tip`. */
      systemImage?: string
      defaultColor?: string
      defaultWidth?: number
      allowsColorSelection?: boolean
      controls?: Array<'width' | 'opacity'>
    }

export interface PencilKitToolPickerAccessoryItem {
  /** SF Symbol name. Falls back to `title` as a text button. */
  systemImage?: string
  title?: string
  /** Echoed back in `onToolPickerAccessoryPress`. */
  identifier?: string
}

export interface PencilKitToolPickerItemEvent {
  viewId: number
  identifier: string
  itemType:
    | 'ink'
    | 'eraser'
    | 'lasso'
    | 'ruler'
    | 'scribble'
    | 'custom'
    | 'unknown'
  /**
   * True when the event is for the item that was already selected (for
   * example its color or width changed) rather than a switch to another item.
   */
  reselected: boolean
  /** Built-in items. */
  selectedTool?: PencilKitToolState
  /** Custom items. */
  color?: string
  width?: number
}

export interface PencilKitToolPickerAccessoryEvent {
  viewId: number
  identifier: string
}

export interface PencilKitRenderEvent {
  viewId: number
  revision: number
  timestamp: number
  timestampClock: 'systemUptime'
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
  /**
   * Lets the PencilKit canvas scroll and bounce on its own. `PKCanvasView` is
   * a `UIScrollView`, so when this is on, one-finger pans are consumed by the
   * canvas and never reach a parent React Native `ScrollView`, even with
   * `drawingPolicy: 'pencilOnly'`. Defaults to false so the surrounding
   * layout owns scrolling; set true to restore PencilKit's built-in panning.
   */
  scrollEnabled?: boolean
  /**
   * Fill `strokes` in `getDrawing()` results and `onDrawingSnapshot` events.
   * Off by default: strokes can be many times larger than the archive.
   */
  includeStrokesInDrawing?: boolean
  /**
   * Highest PKContentVersion new strokes may use (iOS 17+), applied to the
   * canvas and tool picker. Inks that need a newer version are hidden or
   * downgraded. Clamped to what the OS supports; `null` restores `latest`.
   */
  maximumSupportedContentVersion?: PencilKitContentVersion | null
  /**
   * iOS 18+: builds the tool picker from these items instead of the system
   * set. Ignored on iOS 17. `null` restores the default picker. Changing the
   * items recreates the picker.
   */
  toolItems?: PencilKitToolItem[] | null
  /** iOS 18+: a button at the end of the tool picker. `null` removes it. */
  toolPickerAccessoryItem?: PencilKitToolPickerAccessoryItem | null
  /**
   * Whether showing the tool picker may make the canvas first responder
   * (required for the picker to appear). Defaults to true, but focus is only
   * taken when the picker goes from hidden to shown and never from a focused
   * text input. With false, the picker appears when the user starts drawing
   * or on `setToolPickerVisible(true)`.
   */
  autoFocusToolPicker?: boolean
  /** Custom stylus engine: max undo (and redo) entries. Default 20. */
  customStylusHistoryLimit?: number
  /**
   * Custom stylus engine: memory budget for undo + redo bitmaps, in MB.
   * Default 96. The newest undo entry is always kept.
   */
  customStylusHistoryMemoryMB?: number
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
  /**
   * Light/dark rendering of the ink (PencilKit adapts black/white ink to the
   * interface style). `view` uses the canvas's current style. Default `light`.
   */
  appearance?: 'light' | 'dark' | 'view'
}

export interface PencilKitExportResult {
  version: 1
  format: PencilKitDocumentFormat
  output: PencilKitDocumentOutput
  mimeType: string
  byteLength: number
  /**
   * png/jpeg: pixels (points x `scale`). pdf: page size in points; the page
   * holds a raster image rendered at `scale` (PencilKit has no vector export).
   * archive: drawing bounds in points.
   */
  width?: number
  height?: number
  /** PencilKit engine only: the PKContentVersion needed to render the drawing. */
  requiredContentVersion?: number
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
  /** iOS 26+. Check `getCapabilities().tools.ink` before selecting it. */
  | 'reed'

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

/**
 * Input for `setTool`. On iOS 18+ `itemIdentifier` selects that tool picker
 * item; otherwise the first item of the same kind is selected.
 */
export type PencilKitToolStateInput = PencilKitToolState & {
  itemIdentifier?: string
}

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
    /** iOS 18+: `config.toolItems` is supported. */
    toolItems?: boolean
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
  /** Stroke read/write APIs are available. */
  strokes?: boolean
  /** Highest PKContentVersion the OS can render. */
  contentVersion?: { maximum: number }
  /** Native import/export size limits, in bytes/pixels (iOS only). */
  limits?: {
    maxJSONUTF8Bytes: number
    maxBase64EncodedBytes: number
    maxBase64DecodedBytes: number
    maxImageDimension: number
    maxImagePixelCount: number
    maxStrokes?: number
    maxStrokePoints?: number
  }
}
