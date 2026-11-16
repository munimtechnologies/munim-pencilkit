import { pencilKitEventBus, PencilKitView } from './PencilKitView'
import { MunimPencilkit, PencilKitUnsupportedError } from './native'
import { decodePencilSamples } from './samples'
import type {
  ApplePencilPreferences,
  ApplePencilSampleBatch,
  PencilKitFeedbackKind,
  ApplePencilCoalescedTouchesData,
  ApplePencilData,
  ApplePencilDoubleTapData,
  ApplePencilEstimatedPropertiesData,
  ApplePencilHoverData,
  ApplePencilMotionData,
  ApplePencilPreferredSqueezeActionData,
  ApplePencilPredictedTouchesData,
  ApplePencilSqueezeData,
  PencilKitAffineTransform,
  PencilKitCapabilities,
  PencilKitConfig,
  PencilKitDrawingChangeEvent,
  PencilKitDrawingData,
  PencilKitErasePathOptions,
  PencilKitErasePathResult,
  PencilKitExportOptions,
  PencilKitExportResult,
  PencilKitGetDrawingOptions,
  PencilKitGetStrokesOptions,
  PencilKitHistoryEvent,
  PencilKitImportOptions,
  PencilKitRecognitionInfo,
  PencilKitRecognizedText,
  PencilKitRecognizeTextOptions,
  PencilKitSearchTextOptions,
  PencilKitStroke,
  PencilKitTextSearchResult,
  PencilKitToolPickerEvent,
  PencilKitToolState,
  PencilKitToolStateInput,
} from './types'

export type { PencilKitViewRef } from './PencilKitView'

export {
  decodePencilSamples,
  readPencilSample,
  PENCIL_SAMPLE_FIELD,
  PENCIL_SAMPLE_FORMAT_VERSION,
  PENCIL_SAMPLE_HEADER_LENGTH,
  PENCIL_SAMPLE_STRIDE,
} from './samples'

export type {
  ApplePencilPreferences,
  ApplePencilSample,
  ApplePencilSampleBatch,
  ApplePencilSampleKind,
  PencilKitFeedbackKind,
  PencilKitAffineTransform,
  PencilKitContentVersion,
  PencilKitEraserType,
  PencilKitErasePathOptions,
  PencilKitErasePathPoint,
  PencilKitErasePathResult,
  PencilKitGetDrawingOptions,
  PencilKitGetStrokesOptions,
  PencilKitRecognitionInfo,
  PencilKitRecognizedText,
  PencilKitRecognizeTextOptions,
  PencilKitSearchTextOptions,
  PencilKitSelectionChangeEvent,
  PencilKitTextSearchResult,
  PencilKitRenderEvent,
  PencilKitToolItem,
  PencilKitToolPickerAccessoryEvent,
  PencilKitToolPickerAccessoryItem,
  PencilKitToolPickerItemEvent,
  PencilKitToolStateInput,
  ApplePencilCoalescedTouchesData,
  ApplePencilData,
  ApplePencilDoubleTapData,
  ApplePencilEstimatedPropertiesData,
  ApplePencilHoverData,
  ApplePencilMotionData,
  ApplePencilPreferredAction,
  ApplePencilPreferredSqueezeActionData,
  ApplePencilPredictedTouchesData,
  ApplePencilSqueezeData,
  CustomStylusEraserMode,
  CustomStylusRenderMode,
  PencilKitCapabilities,
  PencilKitConfig,
  PencilKitCropMode,
  PencilKitDocumentFormat,
  PencilKitDocumentOutput,
  PencilKitDrawingChangeEvent,
  PencilKitDrawingPhaseEvent,
  PencilKitDrawingSnapshotEvent,
  PencilKitDrawingData,
  PencilKitExportOptions,
  PencilKitExportResult,
  PencilKitHistoryEvent,
  PencilKitImportOptions,
  PencilKitInkType,
  PencilKitPoint,
  PencilKitRect,
  SqueezeEraserBehavior,
  PencilKitStroke,
  PencilKitTool,
  PencilKitToolPickerEvent,
  PencilKitToolState,
} from './types'

export { MunimPencilkit, PencilKitUnsupportedError, PencilKitView }

const parseDrawingJson = (raw: string): PencilKitDrawingData => {
  return JSON.parse(raw) as PencilKitDrawingData
}

const parseStrokesJson = (raw: string): PencilKitStroke[] =>
  (JSON.parse(raw) as { strokes: PencilKitStroke[] }).strokes

const parseSelectionJson = (raw: string): string[] =>
  (JSON.parse(raw) as { strokeIds: string[] }).strokeIds

export const PencilKitUtils = {
  isSupported: (): boolean => MunimPencilkit.isPencilKitSupported(),
  getCapabilities: (): PencilKitCapabilities =>
    JSON.parse(
      MunimPencilkit.getPencilKitCapabilities()
    ) as PencilKitCapabilities,
  createView: (): number => MunimPencilkit.createPencilKitView(),
  destroyView: (viewId: number): void =>
    MunimPencilkit.destroyPencilKitView(viewId),
  setConfig: (viewId: number, config: PencilKitConfig): void =>
    MunimPencilkit.setPencilKitConfig(viewId, JSON.stringify(config)),
  /**
   * @deprecated Blocks the JS thread on the main thread. Use
   * `getDrawingAsync` (or the `PencilKitView` ref).
   */
  getDrawing: (viewId: number): PencilKitDrawingData =>
    parseDrawingJson(MunimPencilkit.getPencilKitDrawing(viewId)),
  getDrawingAsync: async (
    viewId: number,
    options?: PencilKitGetDrawingOptions
  ): Promise<PencilKitDrawingData> =>
    parseDrawingJson(
      await MunimPencilkit.getPencilKitDrawingAsync(
        viewId,
        JSON.stringify(options ?? {})
      )
    ),
  /**
   * @deprecated Blocks the JS thread on the main thread. Use
   * `setDrawingAsync` (or the `PencilKitView` ref).
   */
  setDrawing: (viewId: number, drawing: PencilKitDrawingData): void =>
    MunimPencilkit.setPencilKitDrawing(viewId, JSON.stringify(drawing)),
  setDrawingAsync: (
    viewId: number,
    drawing: PencilKitDrawingData
  ): Promise<void> =>
    MunimPencilkit.setPencilKitDrawingAsync(viewId, JSON.stringify(drawing)),
  clearDrawing: (viewId: number): void =>
    MunimPencilkit.clearPencilKitDrawing(viewId),
  undo: (viewId: number): boolean =>
    MunimPencilkit.undoPencilKitDrawing(viewId),
  redo: (viewId: number): boolean =>
    MunimPencilkit.redoPencilKitDrawing(viewId),
  canUndo: (viewId: number): boolean =>
    MunimPencilkit.canUndoPencilKitDrawing(viewId),
  canRedo: (viewId: number): boolean =>
    MunimPencilkit.canRedoPencilKitDrawing(viewId),
  startApplePencilCapture: (viewId: number): void =>
    MunimPencilkit.startApplePencilDataCapture(viewId),
  stopApplePencilCapture: (viewId: number): void =>
    MunimPencilkit.stopApplePencilDataCapture(viewId),
  isApplePencilCaptureActive: (viewId: number): boolean =>
    MunimPencilkit.isApplePencilDataCaptureActive(viewId),
  /**
   * @deprecated Blocks the JS thread while rendering. Use
   * `exportDocumentAsync` (or the `PencilKitView` ref).
   */
  exportDocument: (
    viewId: number,
    options: PencilKitExportOptions
  ): PencilKitExportResult =>
    JSON.parse(
      MunimPencilkit.exportPencilKitDocument(viewId, JSON.stringify(options))
    ) as PencilKitExportResult,
  exportDocumentAsync: async (
    viewId: number,
    options: PencilKitExportOptions
  ): Promise<PencilKitExportResult> =>
    JSON.parse(
      await MunimPencilkit.exportPencilKitDocumentAsync(
        viewId,
        JSON.stringify(options)
      )
    ) as PencilKitExportResult,
  /**
   * @deprecated Blocks the JS thread while decoding. Use
   * `importDocumentAsync` (or the `PencilKitView` ref).
   */
  importDocument: (viewId: number, options: PencilKitImportOptions): void =>
    MunimPencilkit.importPencilKitDocument(viewId, JSON.stringify(options)),
  importDocumentAsync: (
    viewId: number,
    options: PencilKitImportOptions
  ): Promise<void> =>
    MunimPencilkit.importPencilKitDocumentAsync(
      viewId,
      JSON.stringify(options)
    ),
  getStrokes: async (
    viewId: number,
    options?: PencilKitGetStrokesOptions
  ): Promise<PencilKitStroke[]> =>
    parseStrokesJson(
      options == null
        ? await MunimPencilkit.getPencilKitStrokes(viewId)
        : await MunimPencilkit.getPencilKitStrokesWithOptions(
            viewId,
            JSON.stringify(options)
          )
    ),
  setStrokes: (viewId: number, strokes: PencilKitStroke[]): Promise<void> =>
    MunimPencilkit.setPencilKitStrokes(viewId, JSON.stringify({ strokes })),
  appendStrokes: (viewId: number, strokes: PencilKitStroke[]): Promise<void> =>
    MunimPencilkit.appendPencilKitStrokes(viewId, JSON.stringify({ strokes })),
  removeStrokes: (viewId: number, indices: number[]): Promise<number> =>
    MunimPencilkit.removePencilKitStrokes(viewId, indices),
  transformStrokes: (
    viewId: number,
    indices: number[],
    transform: PencilKitAffineTransform
  ): Promise<number> =>
    MunimPencilkit.transformPencilKitStrokes(
      viewId,
      indices,
      JSON.stringify(transform)
    ),
  /** iOS 27+: the ids of the lasso-selected strokes. */
  getSelection: async (viewId: number): Promise<string[]> =>
    parseSelectionJson(await MunimPencilkit.getPencilKitSelection(viewId)),
  /** iOS 27+: selects the strokes with these ids (unknown ids are ignored). */
  setSelection: (viewId: number, strokeIds: string[]): Promise<void> =>
    MunimPencilkit.setPencilKitSelection(viewId, JSON.stringify({ strokeIds })),
  /** iOS 27+: erases along a path, splitting or trimming strokes. Undoable. */
  erasePath: async (
    viewId: number,
    options: PencilKitErasePathOptions
  ): Promise<PencilKitErasePathResult> =>
    JSON.parse(
      await MunimPencilkit.erasePencilKitPath(viewId, JSON.stringify(options))
    ) as PencilKitErasePathResult,
  /** iOS 27+: recognizes the handwriting in all (or some) strokes. */
  recognizeText: async (
    viewId: number,
    options?: PencilKitRecognizeTextOptions
  ): Promise<PencilKitRecognizedText> =>
    JSON.parse(
      await MunimPencilkit.recognizePencilKitText(
        viewId,
        JSON.stringify(options ?? {})
      )
    ) as PencilKitRecognizedText,
  /** iOS 27+: finds `query` in the recognized handwriting. */
  searchText: async (
    viewId: number,
    query: string,
    options?: PencilKitSearchTextOptions
  ): Promise<PencilKitTextSearchResult[]> =>
    (
      JSON.parse(
        await MunimPencilkit.searchPencilKitText(
          viewId,
          query,
          JSON.stringify(options ?? {})
        )
      ) as { results: PencilKitTextSearchResult[] }
    ).results,
  /** Handwriting recognition support. `supported: false` before iOS 27. */
  getRecognitionInfo: async (): Promise<PencilKitRecognitionInfo> =>
    JSON.parse(
      await MunimPencilkit.getPencilKitRecognitionInfo()
    ) as PencilKitRecognitionInfo,
  /**
   * The drawing as raw `PKDrawing` archive bytes: no base64, no JSON.
   * PencilKit engine only.
   */
  getDrawingArchive: (viewId: number): Promise<ArrayBuffer> =>
    MunimPencilkit.getPencilKitDrawingArchive(viewId),
  /** Replaces the drawing with `PKDrawing` archive bytes. Not undoable. */
  setDrawingArchive: (viewId: number, archive: ArrayBuffer): Promise<void> =>
    MunimPencilkit.setPencilKitDrawingArchive(viewId, archive),
  /**
   * Streams Apple Pencil samples as zero-copy batches (about one per frame).
   * Far cheaper than `onApplePencilData` + coalesced/predicted events, which
   * send one JSON-like object per sample. Returns an unsubscribe function.
   */
  addPencilSampleListener: (
    viewId: number,
    callback: (batch: ApplePencilSampleBatch) => void
  ): (() => void) => {
    const subscription = MunimPencilkit.addPencilSampleListener(
      viewId,
      (buffer) => callback(decodePencilSamples(buffer))
    )
    let removed = false
    return () => {
      if (removed) return
      removed = true
      MunimPencilkit.removePencilSampleListener(subscription)
    }
  },
  /**
   * Plays feedback at `point` (view coordinates). Apple Pencil Pro plays it in
   * the pencil; see `PencilKitFeedbackKind`.
   */
  playFeedback: (
    viewId: number,
    kind: PencilKitFeedbackKind,
    point: { x: number; y: number }
  ): Promise<void> =>
    MunimPencilkit.playPencilKitFeedback(viewId, kind, point.x, point.y),
  /** The user's Apple Pencil settings (pencil-only drawing, hover preview, actions). */
  getApplePencilPreferences: (): ApplePencilPreferences =>
    MunimPencilkit.getApplePencilPreferences(),
  setTool: (viewId: number, tool: PencilKitToolStateInput): void =>
    MunimPencilkit.setPencilKitTool(viewId, JSON.stringify(tool)),
  getTool: (viewId: number): PencilKitToolState =>
    JSON.parse(MunimPencilkit.getPencilKitTool(viewId)) as PencilKitToolState,
  setToolPickerVisible: (viewId: number, visible: boolean): void =>
    MunimPencilkit.setPencilKitToolPickerVisible(viewId, visible),

  addApplePencilListener: (
    callback: (data: ApplePencilData) => void,
    viewId?: number
  ): (() => void) => pencilKitEventBus.addApplePencil(callback, viewId),
  /** Removes `callback`, or every listener when called without arguments. */
  removeApplePencilListener: (
    callback?: (data: ApplePencilData) => void
  ): void => pencilKitEventBus.removeApplePencil(callback),
  addDrawingChangeListener: (
    callback: (event: PencilKitDrawingChangeEvent) => void,
    viewId?: number
  ): (() => void) => pencilKitEventBus.addDrawing(callback, viewId),
  removeDrawingChangeListener: (
    callback?: (event: PencilKitDrawingChangeEvent) => void
  ): void => pencilKitEventBus.removeDrawing(callback),
  addHistoryChangeListener: (
    callback: (event: PencilKitHistoryEvent) => void,
    viewId?: number
  ): (() => void) => pencilKitEventBus.addHistory(callback, viewId),
  removeHistoryChangeListener: (
    callback?: (event: PencilKitHistoryEvent) => void
  ): void => pencilKitEventBus.removeHistory(callback),
  addToolPickerChangeListener: (
    callback: (event: PencilKitToolPickerEvent) => void,
    viewId?: number
  ): (() => void) => pencilKitEventBus.addToolPicker(callback, viewId),
  removeToolPickerChangeListener: (
    callback?: (event: PencilKitToolPickerEvent) => void
  ): void => pencilKitEventBus.removeToolPicker(callback),
  addApplePencilCoalescedTouchesListener: (
    callback: (data: ApplePencilCoalescedTouchesData) => void,
    viewId?: number
  ): (() => void) => pencilKitEventBus.addCoalesced(callback, viewId),
  removeApplePencilCoalescedTouchesListener: (
    callback?: (data: ApplePencilCoalescedTouchesData) => void
  ): void => pencilKitEventBus.removeCoalesced(callback),
  addApplePencilPredictedTouchesListener: (
    callback: (data: ApplePencilPredictedTouchesData) => void,
    viewId?: number
  ): (() => void) => pencilKitEventBus.addPredicted(callback, viewId),
  removeApplePencilPredictedTouchesListener: (
    callback?: (data: ApplePencilPredictedTouchesData) => void
  ): void => pencilKitEventBus.removePredicted(callback),
  addApplePencilEstimatedPropertiesListener: (
    callback: (data: ApplePencilEstimatedPropertiesData) => void,
    viewId?: number
  ): (() => void) => pencilKitEventBus.addEstimated(callback, viewId),
  removeApplePencilEstimatedPropertiesListener: (
    callback?: (data: ApplePencilEstimatedPropertiesData) => void
  ): void => pencilKitEventBus.removeEstimated(callback),
  addApplePencilMotionListener: (
    callback: (data: ApplePencilMotionData) => void,
    viewId?: number
  ): (() => void) => pencilKitEventBus.addMotion(callback, viewId),
  removeApplePencilMotionListener: (
    callback?: (data: ApplePencilMotionData) => void
  ): void => pencilKitEventBus.removeMotion(callback),
  addApplePencilHoverListener: (
    callback: (data: ApplePencilHoverData) => void,
    viewId?: number
  ): (() => void) => pencilKitEventBus.addHover(callback, viewId),
  removeApplePencilHoverListener: (
    callback?: (data: ApplePencilHoverData) => void
  ): void => pencilKitEventBus.removeHover(callback),
  addApplePencilSqueezeListener: (
    callback: (data: ApplePencilSqueezeData) => void,
    viewId?: number
  ): (() => void) => pencilKitEventBus.addSqueeze(callback, viewId),
  removeApplePencilSqueezeListener: (
    callback?: (data: ApplePencilSqueezeData) => void
  ): void => pencilKitEventBus.removeSqueeze(callback),
  addApplePencilDoubleTapListener: (
    callback: (data: ApplePencilDoubleTapData) => void,
    viewId?: number
  ): (() => void) => pencilKitEventBus.addDoubleTap(callback, viewId),
  removeApplePencilDoubleTapListener: (
    callback?: (data: ApplePencilDoubleTapData) => void
  ): void => pencilKitEventBus.removeDoubleTap(callback),
  addApplePencilPreferredSqueezeActionListener: (
    callback: (data: ApplePencilPreferredSqueezeActionData) => void,
    viewId?: number
  ): (() => void) =>
    pencilKitEventBus.addPreferredSqueezeAction(callback, viewId),
  removeApplePencilPreferredSqueezeActionListener: (
    callback?: (data: ApplePencilPreferredSqueezeActionData) => void
  ): void => pencilKitEventBus.removePreferredSqueezeAction(callback),
}

export default MunimPencilkit
