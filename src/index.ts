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
  PencilKitCapabilities,
  PencilKitConfig,
  PencilKitDrawingChangeEvent,
  PencilKitDrawingData,
  PencilKitExportOptions,
  PencilKitExportResult,
  PencilKitHistoryEvent,
  PencilKitImportOptions,
  PencilKitToolPickerEvent,
  PencilKitToolState,
} from './types'

export type {
  PencilKitViewRef,
} from './PencilKitView'

export type {
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
  getDrawing: (viewId: number): PencilKitDrawingData =>
    parseDrawingJson(MunimPencilkit.getPencilKitDrawing(viewId)),
  setDrawing: (viewId: number, drawing: PencilKitDrawingData): void =>
    MunimPencilkit.setPencilKitDrawing(viewId, JSON.stringify(drawing)),
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
  exportDocument: (
    viewId: number,
    options: PencilKitExportOptions
  ): PencilKitExportResult =>
    JSON.parse(
      MunimPencilkit.exportPencilKitDocument(viewId, JSON.stringify(options))
    ) as PencilKitExportResult,
  importDocument: (viewId: number, options: PencilKitImportOptions): void =>
    MunimPencilkit.importPencilKitDocument(viewId, JSON.stringify(options)),
  setTool: (viewId: number, tool: PencilKitToolState): void =>
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
