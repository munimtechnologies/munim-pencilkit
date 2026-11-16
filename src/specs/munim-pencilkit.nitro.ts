import { type HybridObject } from 'react-native-nitro-modules'

/** What a double tap / squeeze should do, per the user's Apple Pencil settings. */
export type ApplePencilPreferredAction =
  | 'ignore'
  | 'switchEraser'
  | 'switchPrevious'
  | 'showColorPalette'
  | 'showInkAttributes'
  | 'showContextualPalette'
  | 'runSystemShortcut'

/** The user's system-wide Apple Pencil settings (`UIPencilInteraction`). */
export interface ApplePencilPreferences {
  /** Settings > Apple Pencil > "Only Draw with Apple Pencil". */
  prefersPencilOnlyDrawing: boolean
  /** Settings > Apple Pencil > "Show Hover Preview" (hover-capable iPads). */
  prefersHoverToolPreview: boolean
  /** The double-tap action the user picked. */
  preferredTapAction: ApplePencilPreferredAction
  /** The squeeze action the user picked (Apple Pencil Pro). */
  preferredSqueezeAction: ApplePencilPreferredAction
}

/**
 * Feedback to play at a point of the canvas. On Apple Pencil Pro the
 * pencil itself plays it (iPads have no Taptic Engine); elsewhere it is a
 * no-op chosen by the system.
 *
 * - `alignment` / `pathCompleted`: `UICanvasFeedbackGenerator` (snapping to a
 *   guide, closing a shape).
 * - `impactLight` / `impactMedium` / `impactHeavy`: `UIImpactFeedbackGenerator`.
 * - `selection`: `UISelectionFeedbackGenerator`.
 */
export type PencilKitFeedbackKind =
  | 'alignment'
  | 'pathCompleted'
  | 'impactLight'
  | 'impactMedium'
  | 'impactHeavy'
  | 'selection'

export interface MunimPencilkit extends HybridObject<{ ios: 'swift' }> {
  /**
   * @deprecated Leftover from the Nitro module template. Kept for backwards
   * compatibility; it will be removed in a future major version.
   */
  sum(num1: number, num2: number): number
  isPencilKitSupported(): boolean
  getPencilKitCapabilities(): string
  createPencilKitView(): number
  destroyPencilKitView(viewId: number): void
  setPencilKitConfig(viewId: number, configJson: string): void
  /**
   * @deprecated Blocks the JS thread on the main thread. Use
   * `getPencilKitDrawingAsync`.
   */
  getPencilKitDrawing(viewId: number): string
  getPencilKitDrawingAsync(viewId: number, optionsJson: string): Promise<string>
  /**
   * @deprecated Blocks the JS thread on the main thread. Use
   * `setPencilKitDrawingAsync`.
   */
  setPencilKitDrawing(viewId: number, drawingJson: string): void
  setPencilKitDrawingAsync(viewId: number, drawingJson: string): Promise<void>
  clearPencilKitDrawing(viewId: number): void
  undoPencilKitDrawing(viewId: number): boolean
  redoPencilKitDrawing(viewId: number): boolean
  canUndoPencilKitDrawing(viewId: number): boolean
  canRedoPencilKitDrawing(viewId: number): boolean
  startApplePencilDataCapture(viewId: number): void
  stopApplePencilDataCapture(viewId: number): void
  isApplePencilDataCaptureActive(viewId: number): boolean
  /**
   * @deprecated Blocks the JS thread while rendering. Use
   * `exportPencilKitDocumentAsync`.
   */
  exportPencilKitDocument(viewId: number, optionsJson: string): string
  exportPencilKitDocumentAsync(
    viewId: number,
    optionsJson: string
  ): Promise<string>
  /**
   * @deprecated Blocks the JS thread while decoding. Use
   * `importPencilKitDocumentAsync`.
   */
  importPencilKitDocument(viewId: number, optionsJson: string): void
  importPencilKitDocumentAsync(
    viewId: number,
    optionsJson: string
  ): Promise<void>
  setPencilKitTool(viewId: number, toolJson: string): void
  getPencilKitTool(viewId: number): string
  setPencilKitToolPickerVisible(viewId: number, visible: boolean): void

  /** Resolves `{"strokes": PencilKitStroke[], "requiredContentVersion": n}`. */
  getPencilKitStrokes(viewId: number): Promise<string>
  /** `strokesJson` is `{"strokes": PencilKitStroke[]}`. Undoable. */
  setPencilKitStrokes(viewId: number, strokesJson: string): Promise<void>
  /** `strokesJson` is `{"strokes": PencilKitStroke[]}`. Undoable. */
  appendPencilKitStrokes(viewId: number, strokesJson: string): Promise<void>
  /** Resolves the number of strokes removed. Undoable. */
  removePencilKitStrokes(viewId: number, indices: number[]): Promise<number>
  /**
   * `transformJson` is a `PencilKitAffineTransform`, applied in canvas space
   * after each stroke's own transform. Resolves the number of strokes changed.
   * Undoable.
   */
  transformPencilKitStrokes(
    viewId: number,
    indices: number[],
    transformJson: string
  ): Promise<number>
  /**
   * Like `getPencilKitStrokes`, with `optionsJson` a
   * `PencilKitGetStrokesOptions` (e.g. `includeBezierPaths`).
   */
  getPencilKitStrokesWithOptions(
    viewId: number,
    optionsJson: string
  ): Promise<string>

  // iOS 27+ (reject with an "iOS 27" error on older systems; check
  // `getPencilKitCapabilities().features` first).

  /** Resolves `{"strokeIds": string[]}`, the lasso selection. */
  getPencilKitSelection(viewId: number): Promise<string>
  /**
   * `selectionJson` is `{"strokeIds": string[]}`. Selects those strokes;
   * unknown ids are ignored.
   */
  setPencilKitSelection(viewId: number, selectionJson: string): Promise<void>
  /**
   * `eraseJson` is a `PencilKitErasePathOptions`. Resolves a
   * `PencilKitErasePathResult`. Undoable.
   */
  erasePencilKitPath(viewId: number, eraseJson: string): Promise<string>
  /**
   * Handwriting recognition. `optionsJson` is a
   * `PencilKitRecognizeTextOptions`; resolves a `PencilKitRecognizedText`.
   */
  recognizePencilKitText(viewId: number, optionsJson: string): Promise<string>
  /**
   * Searches the recognized handwriting. `optionsJson` is a
   * `PencilKitSearchTextOptions`; resolves `{"results": PencilKitTextSearchResult[]}`.
   */
  searchPencilKitText(
    viewId: number,
    query: string,
    optionsJson: string
  ): Promise<string>
  /**
   * Resolves a `PencilKitRecognitionInfo`. Never rejects: reports
   * `supported: false` before iOS 27.
   */
  getPencilKitRecognitionInfo(): Promise<string>

  // Binary transfer (no JSON, no base64).

  /**
   * The drawing as raw `PKDrawing.dataRepresentation()` bytes. PencilKit
   * engine only (rejects in custom-stylus mode).
   */
  getPencilKitDrawingArchive(viewId: number): Promise<ArrayBuffer>
  /**
   * Replaces the drawing with a `PKDrawing` archive (the bytes from
   * `getPencilKitDrawingArchive` or `exportDocument({ format: 'archive' })`).
   * Not undoable, like `setPencilKitDrawing`. PencilKit engine only.
   */
  setPencilKitDrawingArchive(
    viewId: number,
    archive: ArrayBuffer
  ): Promise<void>
  /**
   * Streams every Apple Pencil sample of the view (coalesced, predicted and
   * estimated-property updates) as packed Float64 records, one buffer per
   * touch event (about once per frame). See `decodePencilSamples`. Returns a
   * subscription id for `removePencilSampleListener`.
   */
  addPencilSampleListener(
    viewId: number,
    listener: (samples: ArrayBuffer) => void
  ): number
  removePencilSampleListener(subscriptionId: number): void

  // Apple Pencil (Pro) system integration.

  /** Plays `kind` at (`x`, `y`) in view coordinates. See `PencilKitFeedbackKind`. */
  playPencilKitFeedback(
    viewId: number,
    kind: PencilKitFeedbackKind,
    x: number,
    y: number
  ): Promise<void>
  /** The user's Apple Pencil settings, read when called. */
  getApplePencilPreferences(): ApplePencilPreferences
}
