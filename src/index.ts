import { pencilKitEventBus, PencilKitView } from './PencilKitView'
import { MunimPencilkit } from './native'
import type {
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
  PencilKitExportOptions,
  PencilKitExportResult,
  PencilKitGetDrawingOptions,
  PencilKitHistoryEvent,
  PencilKitImportOptions,
  PencilKitStroke,
  PencilKitToolPickerEvent,
  PencilKitToolState,
  PencilKitToolStateInput,
} from './types'

export type {
  PencilKitViewRef,
} from './PencilKitView'

export type {
  PencilKitAffineTransform,
  PencilKitContentVersion,
  PencilKitEraserType,
  PencilKitGetDrawingOptions,
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

export { MunimPencilkit, PencilKitView }

const parseDrawingJson = (raw: string): PencilKitDrawingData => {
  return JSON.parse(raw) as PencilKitDrawingData
}

const parseStrokesJson = (raw: string): PencilKitStroke[] =>
  (JSON.parse(raw) as { strokes: PencilKitStroke[] }).strokes

export const PencilKitUtils = {
  isSupported: (): boolean => MunimPencilkit.isPencilKitSupported(),
  getCapabilities: (): PencilKitCapabilities =>
    JSON.parse(
      MunimPencilkit.getPencilKitCapabilities()
    ) as PencilKitCapabilities,
  createView: (): number => MunimPencilkit.createPencilKitView(),
  destroyView: (viewId: number): void => MunimPencilkit.destroyPencilKitView(viewId),
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
  undo: (viewId: number): boolean => MunimPencilkit.undoPencilKitDrawing(viewId),
  redo: (viewId: number): boolean => MunimPencilkit.redoPencilKitDrawing(viewId),
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
  getStrokes: async (viewId: number): Promise<PencilKitStroke[]> =>
    parseStrokesJson(await MunimPencilkit.getPencilKitStrokes(viewId)),
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
