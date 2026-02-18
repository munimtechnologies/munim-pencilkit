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
  PencilKitConfig,
  PencilKitDrawingData,
} from './types'

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
  PencilKitConfig,
  PencilKitDrawingData,
  PencilKitPoint,
  PencilKitStroke,
  PencilKitTool,
} from './types'

export { MunimPencilkit, PencilKitView }

const parseDrawingJson = (raw: string): PencilKitDrawingData => {
  try {
    return JSON.parse(raw) as PencilKitDrawingData
  } catch {
    return {
      strokes: [],
      bounds: { x: 0, y: 0, width: 0, height: 0 },
    }
  }
}

export const PencilKitUtils = {
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

  addApplePencilListener: (callback: (data: ApplePencilData) => void): (() => void) =>
    pencilKitEventBus.addApplePencil(callback),
  removeApplePencilListener: (): void => pencilKitEventBus.clearApplePencil(),
  addDrawingChangeListener: (
    callback: (viewId: number, drawing: PencilKitDrawingData) => void
  ): (() => void) =>
    pencilKitEventBus.addDrawing(({ viewId, drawing }) => callback(viewId, drawing)),
  removeDrawingChangeListener: (): void => pencilKitEventBus.clearDrawing(),
  addApplePencilCoalescedTouchesListener: (
    callback: (data: ApplePencilCoalescedTouchesData) => void
  ): (() => void) => pencilKitEventBus.addCoalesced(callback),
  removeApplePencilCoalescedTouchesListener: (): void =>
    pencilKitEventBus.clearCoalesced(),
  addApplePencilPredictedTouchesListener: (
    callback: (data: ApplePencilPredictedTouchesData) => void
  ): (() => void) => pencilKitEventBus.addPredicted(callback),
  removeApplePencilPredictedTouchesListener: (): void =>
    pencilKitEventBus.clearPredicted(),
  addApplePencilEstimatedPropertiesListener: (
    callback: (data: ApplePencilEstimatedPropertiesData) => void
  ): (() => void) => pencilKitEventBus.addEstimated(callback),
  removeApplePencilEstimatedPropertiesListener: (): void =>
    pencilKitEventBus.clearEstimated(),
  addApplePencilMotionListener: (
    callback: (data: ApplePencilMotionData) => void
  ): (() => void) => pencilKitEventBus.addMotion(callback),
  removeApplePencilMotionListener: (): void => pencilKitEventBus.clearMotion(),
  addApplePencilHoverListener: (
    callback: (data: ApplePencilHoverData) => void
  ): (() => void) => pencilKitEventBus.addHover(callback),
  removeApplePencilHoverListener: (): void => pencilKitEventBus.clearHover(),
  addApplePencilSqueezeListener: (
    callback: (data: ApplePencilSqueezeData) => void
  ): (() => void) => pencilKitEventBus.addSqueeze(callback),
  removeApplePencilSqueezeListener: (): void => pencilKitEventBus.clearSqueeze(),
  addApplePencilDoubleTapListener: (
    callback: (data: ApplePencilDoubleTapData) => void
  ): (() => void) => pencilKitEventBus.addDoubleTap(callback),
  removeApplePencilDoubleTapListener: (): void => pencilKitEventBus.clearDoubleTap(),
  addApplePencilPreferredSqueezeActionListener: (
    callback: (data: ApplePencilPreferredSqueezeActionData) => void
  ): (() => void) => pencilKitEventBus.addPreferredSqueezeAction(callback),
  removeApplePencilPreferredSqueezeActionListener: (): void =>
    pencilKitEventBus.clearPreferredSqueezeAction(),
}

export default MunimPencilkit