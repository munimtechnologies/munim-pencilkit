import React, {
  forwardRef,
  type MutableRefObject,
  type Ref,
  useEffect,
  useImperativeHandle,
  useMemo,
  useRef,
  useState,
} from 'react'
import {
  Platform,
  requireNativeComponent,
  type NativeSyntheticEvent,
  type ViewProps,
} from 'react-native'
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
  PencilKitDrawingChangeEvent,
  PencilKitDrawingPhaseEvent,
  PencilKitDrawingSnapshotEvent,
  PencilKitConfig,
  PencilKitDrawingData,
  PencilKitExportOptions,
  PencilKitExportResult,
  PencilKitHistoryEvent,
  PencilKitImportOptions,
  PencilKitToolPickerEvent,
  PencilKitToolState,
} from './types'

type NativeEventPayload<T> = NativeSyntheticEvent<T>
type Listener<T> = (data: T) => void

interface ListenerEntry<T> {
  original: Listener<T>
  wrapped: Listener<T>
}

class ListenerRegistry<T extends { viewId?: number }> {
  private entries = new Set<ListenerEntry<T>>()

  emit(data: T): void {
    this.entries.forEach(entry => entry.wrapped(data))
  }

  add(cb: Listener<T>, viewId?: number): () => void {
    const entry: ListenerEntry<T> = {
      original: cb,
      wrapped: data => {
        if (viewId == null || data.viewId === viewId) cb(data)
      },
    }
    this.entries.add(entry)
    return () => this.entries.delete(entry)
  }

  /** Removes every registration of `cb`, or all listeners when omitted. */
  remove(cb?: Listener<T>): void {
    if (cb == null) {
      this.entries.clear()
      return
    }
    for (const entry of Array.from(this.entries)) {
      if (entry.original === cb) this.entries.delete(entry)
    }
  }
}

class PencilKitEventBus {
  private applePencilListeners = new ListenerRegistry<ApplePencilData>()
  private drawingListeners = new ListenerRegistry<PencilKitDrawingChangeEvent>()
  private historyListeners = new ListenerRegistry<PencilKitHistoryEvent>()
  private toolPickerListeners = new ListenerRegistry<PencilKitToolPickerEvent>()
  private coalescedListeners =
    new ListenerRegistry<ApplePencilCoalescedTouchesData>()
  private predictedListeners =
    new ListenerRegistry<ApplePencilPredictedTouchesData>()
  private estimatedListeners =
    new ListenerRegistry<ApplePencilEstimatedPropertiesData>()
  private motionListeners = new ListenerRegistry<ApplePencilMotionData>()
  private hoverListeners = new ListenerRegistry<ApplePencilHoverData>()
  private squeezeListeners = new ListenerRegistry<ApplePencilSqueezeData>()
  private doubleTapListeners = new ListenerRegistry<ApplePencilDoubleTapData>()
  private preferredSqueezeActionListeners =
    new ListenerRegistry<ApplePencilPreferredSqueezeActionData>()

  emitApplePencil(data: ApplePencilData): void {
    this.applePencilListeners.emit(data)
  }
  emitDrawing(data: PencilKitDrawingChangeEvent): void {
    this.drawingListeners.emit(data)
  }
  emitHistory(data: PencilKitHistoryEvent): void {
    this.historyListeners.emit(data)
  }
  emitToolPicker(data: PencilKitToolPickerEvent): void {
    this.toolPickerListeners.emit(data)
  }
  emitCoalesced(data: ApplePencilCoalescedTouchesData): void {
    this.coalescedListeners.emit(data)
  }
  emitPredicted(data: ApplePencilPredictedTouchesData): void {
    this.predictedListeners.emit(data)
  }
  emitEstimated(data: ApplePencilEstimatedPropertiesData): void {
    this.estimatedListeners.emit(data)
  }
  emitMotion(data: ApplePencilMotionData): void {
    this.motionListeners.emit(data)
  }
  emitHover(data: ApplePencilHoverData): void {
    this.hoverListeners.emit(data)
  }
  emitSqueeze(data: ApplePencilSqueezeData): void {
    this.squeezeListeners.emit(data)
  }
  emitDoubleTap(data: ApplePencilDoubleTapData): void {
    this.doubleTapListeners.emit(data)
  }
  emitPreferredSqueezeAction(data: ApplePencilPreferredSqueezeActionData): void {
    this.preferredSqueezeActionListeners.emit(data)
  }

  addApplePencil(cb: Listener<ApplePencilData>, viewId?: number): () => void {
    return this.applePencilListeners.add(cb, viewId)
  }
  addDrawing(
    cb: Listener<PencilKitDrawingChangeEvent>,
    viewId?: number
  ): () => void {
    return this.drawingListeners.add(cb, viewId)
  }
  addHistory(cb: Listener<PencilKitHistoryEvent>, viewId?: number): () => void {
    return this.historyListeners.add(cb, viewId)
  }
  addToolPicker(
    cb: Listener<PencilKitToolPickerEvent>,
    viewId?: number
  ): () => void {
    return this.toolPickerListeners.add(cb, viewId)
  }
  addCoalesced(
    cb: Listener<ApplePencilCoalescedTouchesData>,
    viewId?: number
  ): () => void {
    return this.coalescedListeners.add(cb, viewId)
  }
  addPredicted(
    cb: Listener<ApplePencilPredictedTouchesData>,
    viewId?: number
  ): () => void {
    return this.predictedListeners.add(cb, viewId)
  }
  addEstimated(
    cb: Listener<ApplePencilEstimatedPropertiesData>,
    viewId?: number
  ): () => void {
    return this.estimatedListeners.add(cb, viewId)
  }
  addMotion(cb: Listener<ApplePencilMotionData>, viewId?: number): () => void {
    return this.motionListeners.add(cb, viewId)
  }
  addHover(cb: Listener<ApplePencilHoverData>, viewId?: number): () => void {
    return this.hoverListeners.add(cb, viewId)
  }
  addSqueeze(cb: Listener<ApplePencilSqueezeData>, viewId?: number): () => void {
    return this.squeezeListeners.add(cb, viewId)
  }
  addDoubleTap(
    cb: Listener<ApplePencilDoubleTapData>,
    viewId?: number
  ): () => void {
    return this.doubleTapListeners.add(cb, viewId)
  }
  addPreferredSqueezeAction(
    cb: Listener<ApplePencilPreferredSqueezeActionData>,
    viewId?: number
  ): () => void {
    return this.preferredSqueezeActionListeners.add(cb, viewId)
  }

  removeApplePencil(cb?: Listener<ApplePencilData>): void {
    this.applePencilListeners.remove(cb)
  }
  removeDrawing(cb?: Listener<PencilKitDrawingChangeEvent>): void {
    this.drawingListeners.remove(cb)
  }
  removeHistory(cb?: Listener<PencilKitHistoryEvent>): void {
    this.historyListeners.remove(cb)
  }
  removeToolPicker(cb?: Listener<PencilKitToolPickerEvent>): void {
    this.toolPickerListeners.remove(cb)
  }
  removeCoalesced(cb?: Listener<ApplePencilCoalescedTouchesData>): void {
    this.coalescedListeners.remove(cb)
  }
  removePredicted(cb?: Listener<ApplePencilPredictedTouchesData>): void {
    this.predictedListeners.remove(cb)
  }
  removeEstimated(cb?: Listener<ApplePencilEstimatedPropertiesData>): void {
    this.estimatedListeners.remove(cb)
  }
  removeMotion(cb?: Listener<ApplePencilMotionData>): void {
    this.motionListeners.remove(cb)
  }
  removeHover(cb?: Listener<ApplePencilHoverData>): void {
    this.hoverListeners.remove(cb)
  }
  removeSqueeze(cb?: Listener<ApplePencilSqueezeData>): void {
    this.squeezeListeners.remove(cb)
  }
  removeDoubleTap(cb?: Listener<ApplePencilDoubleTapData>): void {
    this.doubleTapListeners.remove(cb)
  }
  removePreferredSqueezeAction(
    cb?: Listener<ApplePencilPreferredSqueezeActionData>
  ): void {
    this.preferredSqueezeActionListeners.remove(cb)
  }

  clearApplePencil(): void {
    this.applePencilListeners.remove()
  }
  clearDrawing(): void {
    this.drawingListeners.remove()
  }
  clearHistory(): void {
    this.historyListeners.remove()
  }
  clearToolPicker(): void {
    this.toolPickerListeners.remove()
  }
  clearCoalesced(): void {
    this.coalescedListeners.remove()
  }
  clearPredicted(): void {
    this.predictedListeners.remove()
  }
  clearEstimated(): void {
    this.estimatedListeners.remove()
  }
  clearMotion(): void {
    this.motionListeners.remove()
  }
  clearHover(): void {
    this.hoverListeners.remove()
  }
  clearSqueeze(): void {
    this.squeezeListeners.remove()
  }
  clearDoubleTap(): void {
    this.doubleTapListeners.remove()
  }
  clearPreferredSqueezeAction(): void {
    this.preferredSqueezeActionListeners.remove()
  }
}

export const pencilKitEventBus = new PencilKitEventBus()

interface NativePencilKitViewProps extends ViewProps {
  viewId: number
  enableApplePencilData: boolean
  enableToolPicker: boolean
  enableHapticFeedback: boolean
  enableMotionTracking: boolean
  enableSqueezeInteraction: boolean
  enableDoubleTapInteraction: boolean
  enableHoverSupport: boolean
  onApplePencilData?: (event: NativeEventPayload<ApplePencilData>) => void
  onPencilKitDrawingChange?: (
    event: NativeEventPayload<PencilKitDrawingChangeEvent>
  ) => void
  onPencilKitDrawingSnapshot?: (
    event: NativeEventPayload<PencilKitDrawingSnapshotEvent>
  ) => void
  onPencilKitDrawingPhase?: (
    event: NativeEventPayload<PencilKitDrawingPhaseEvent>
  ) => void
  onPencilKitHistoryChange?: (
    event: NativeEventPayload<PencilKitHistoryEvent>
  ) => void
  onPencilKitToolPickerChange?: (
    event: NativeEventPayload<PencilKitToolPickerEvent>
  ) => void
  onApplePencilCoalescedTouches?: (
    event: NativeEventPayload<ApplePencilCoalescedTouchesData>
  ) => void
  onApplePencilPredictedTouches?: (
    event: NativeEventPayload<ApplePencilPredictedTouchesData>
  ) => void
  onApplePencilEstimatedProperties?: (
    event: NativeEventPayload<ApplePencilEstimatedPropertiesData>
  ) => void
  onApplePencilMotion?: (
    event: NativeEventPayload<ApplePencilMotionData>
  ) => void
  onApplePencilHover?: (event: NativeEventPayload<ApplePencilHoverData>) => void
  onApplePencilSqueeze?: (
    event: NativeEventPayload<ApplePencilSqueezeData>
  ) => void
  onApplePencilDoubleTap?: (
    event: NativeEventPayload<ApplePencilDoubleTapData>
  ) => void
  onApplePencilPreferredSqueezeAction?: (
    event: NativeEventPayload<ApplePencilPreferredSqueezeActionData>
  ) => void
}

const NativePencilKitView =
  Platform.OS === 'ios'
    ? requireNativeComponent<NativePencilKitViewProps>('PencilKitView')
    : null

export interface PencilKitViewRef {
  getDrawing: () => Promise<PencilKitDrawingData>
  setDrawing: (drawing: PencilKitDrawingData) => Promise<void>
  clearDrawing: () => Promise<void>
  undo: () => Promise<boolean>
  redo: () => Promise<boolean>
  canUndo: () => Promise<boolean>
  canRedo: () => Promise<boolean>
  startApplePencilCapture: () => Promise<void>
  stopApplePencilCapture: () => Promise<void>
  isApplePencilCaptureActive: () => Promise<boolean>
  exportDocument: (options: PencilKitExportOptions) => Promise<PencilKitExportResult>
  importDocument: (options: PencilKitImportOptions) => Promise<void>
  setTool: (tool: PencilKitToolState) => Promise<void>
  getTool: () => Promise<PencilKitToolState>
  setToolPickerVisible: (visible: boolean) => Promise<void>
}

export interface PencilKitViewProps extends ViewProps {
  config?: PencilKitConfig
  onApplePencilData?: (data: ApplePencilData) => void
  onDrawingChange?: (event: PencilKitDrawingChangeEvent) => void
  onDrawingSnapshot?: (event: PencilKitDrawingSnapshotEvent) => void
  onDrawingBegin?: (event: PencilKitDrawingPhaseEvent) => void
  onDrawingEnd?: (event: PencilKitDrawingPhaseEvent) => void
  onHistoryChange?: (event: PencilKitHistoryEvent) => void
  onToolPickerChange?: (event: PencilKitToolPickerEvent) => void
  onApplePencilCoalescedTouches?: (
    data: ApplePencilCoalescedTouchesData
  ) => void
  onApplePencilPredictedTouches?: (
    data: ApplePencilPredictedTouchesData
  ) => void
  onApplePencilEstimatedProperties?: (
    data: ApplePencilEstimatedPropertiesData
  ) => void
  onApplePencilMotion?: (data: ApplePencilMotionData) => void
  onApplePencilHover?: (data: ApplePencilHoverData) => void
  onApplePencilSqueeze?: (data: ApplePencilSqueezeData) => void
  onApplePencilDoubleTap?: (data: ApplePencilDoubleTapData) => void
  onApplePencilPreferredSqueezeAction?: (
    data: ApplePencilPreferredSqueezeActionData
  ) => void
  onStylusViewToggleEraser?: (isOn: boolean) => void
  onStylusViewStartDrawing?: () => void
  onStylusViewEndDrawing?: () => void
  onViewReady?: (viewId: number) => void
  enableApplePencilData?: boolean
  enableToolPicker?: boolean
  enableHapticFeedback?: boolean
  enableMotionTracking?: boolean
  enableSqueezeInteraction?: boolean
  enableDoubleTapInteraction?: boolean
  enableHoverSupport?: boolean
}

function parseDrawingJson(raw: string): PencilKitDrawingData {
  return JSON.parse(raw) as PencilKitDrawingData
}

function isViewNotFoundError(error: unknown): boolean {
  return (
    error instanceof Error &&
    (error.message.includes('viewNotFound(') ||
      error.message.includes('PencilKit view not found'))
  )
}

export const PencilKitView = forwardRef<PencilKitViewRef, PencilKitViewProps>(
  (props, ref: Ref<PencilKitViewRef>) => {
    const {
      style,
      config,
      onApplePencilData,
      onDrawingChange,
      onDrawingSnapshot,
      onDrawingBegin,
      onDrawingEnd,
      onHistoryChange,
      onToolPickerChange,
      onApplePencilCoalescedTouches,
      onApplePencilPredictedTouches,
      onApplePencilEstimatedProperties,
      onApplePencilMotion,
      onApplePencilHover,
      onApplePencilSqueeze,
      onApplePencilDoubleTap,
      onApplePencilPreferredSqueezeAction,
      onStylusViewToggleEraser,
      onStylusViewStartDrawing,
      onStylusViewEndDrawing,
      onViewReady,
      enableApplePencilData = false,
      enableToolPicker = true,
      enableHapticFeedback = false,
      enableMotionTracking = false,
      enableSqueezeInteraction = true,
      enableDoubleTapInteraction = true,
      enableHoverSupport = true,
      ...viewProps
    } = props

    const [viewId, setViewId] = useState<number | null>(null)
    const createdIdRef = useRef<number | null>(null) as MutableRefObject<
      number | null
    >
    const onViewReadyRef = useRef(onViewReady)

    useEffect(() => {
      onViewReadyRef.current = onViewReady
    }, [onViewReady])

    useEffect(() => {
      if (Platform.OS !== 'ios') return
      const id = MunimPencilkit.createPencilKitView()
      createdIdRef.current = id
      setViewId(id)
      onViewReadyRef.current?.(id)
      return () => {
        const createdId = createdIdRef.current
        createdIdRef.current = null

        if (createdId != null) {
          try {
            MunimPencilkit.destroyPencilKitView(createdId)
          } catch (error) {
            if (!isViewNotFoundError(error)) {
              throw error
            }
          }
        }
      }
    }, [])

    useEffect(() => {
      if (viewId == null || config == null) return
      MunimPencilkit.setPencilKitConfig(viewId, JSON.stringify(config))
    }, [viewId, config])

    useImperativeHandle(
      ref,
      () => ({
        getDrawing: async () => {
          if (viewId == null) throw new Error('PencilKit view not ready')
          return parseDrawingJson(MunimPencilkit.getPencilKitDrawing(viewId))
        },
        setDrawing: async (drawing: PencilKitDrawingData) => {
          if (viewId == null) throw new Error('PencilKit view not ready')
          MunimPencilkit.setPencilKitDrawing(viewId, JSON.stringify(drawing))
        },
        clearDrawing: async () => {
          if (viewId == null) throw new Error('PencilKit view not ready')
          MunimPencilkit.clearPencilKitDrawing(viewId)
        },
        undo: async () => {
          if (viewId == null) throw new Error('PencilKit view not ready')
          return MunimPencilkit.undoPencilKitDrawing(viewId)
        },
        redo: async () => {
          if (viewId == null) throw new Error('PencilKit view not ready')
          return MunimPencilkit.redoPencilKitDrawing(viewId)
        },
        canUndo: async () => {
          if (viewId == null) throw new Error('PencilKit view not ready')
          return MunimPencilkit.canUndoPencilKitDrawing(viewId)
        },
        canRedo: async () => {
          if (viewId == null) throw new Error('PencilKit view not ready')
          return MunimPencilkit.canRedoPencilKitDrawing(viewId)
        },
        startApplePencilCapture: async () => {
          if (viewId == null) throw new Error('PencilKit view not ready')
          MunimPencilkit.startApplePencilDataCapture(viewId)
        },
        stopApplePencilCapture: async () => {
          if (viewId == null) throw new Error('PencilKit view not ready')
          MunimPencilkit.stopApplePencilDataCapture(viewId)
        },
        isApplePencilCaptureActive: async () => {
          if (viewId == null) throw new Error('PencilKit view not ready')
          return MunimPencilkit.isApplePencilDataCaptureActive(viewId)
        },
        exportDocument: async (options: PencilKitExportOptions) => {
          if (viewId == null) throw new Error('PencilKit view not ready')
          return JSON.parse(
            MunimPencilkit.exportPencilKitDocument(
              viewId,
              JSON.stringify(options)
            )
          ) as PencilKitExportResult
        },
        importDocument: async (options: PencilKitImportOptions) => {
          if (viewId == null) throw new Error('PencilKit view not ready')
          MunimPencilkit.importPencilKitDocument(
            viewId,
            JSON.stringify(options)
          )
        },
        setTool: async (tool: PencilKitToolState) => {
          if (viewId == null) throw new Error('PencilKit view not ready')
          MunimPencilkit.setPencilKitTool(viewId, JSON.stringify(tool))
        },
        getTool: async () => {
          if (viewId == null) throw new Error('PencilKit view not ready')
          return JSON.parse(
            MunimPencilkit.getPencilKitTool(viewId)
          ) as PencilKitToolState
        },
        setToolPickerVisible: async (visible: boolean) => {
          if (viewId == null) throw new Error('PencilKit view not ready')
          MunimPencilkit.setPencilKitToolPickerVisible(viewId, visible)
        },
      }),
      [viewId]
    )

    const callbacks = useMemo(
      () => ({
        onApplePencilData: (event: NativeEventPayload<ApplePencilData>) => {
          const data = event.nativeEvent
          onApplePencilData?.(data)
          pencilKitEventBus.emitApplePencil(data)

          if (data.action === 'drawingStarted') onStylusViewStartDrawing?.()
          if (data.action === 'drawingEnded') onStylusViewEndDrawing?.()
          if (typeof data.isEraserOn === 'boolean') {
            onStylusViewToggleEraser?.(data.isEraserOn)
          }
        },
        onPencilKitDrawingChange: (
          event: NativeEventPayload<PencilKitDrawingChangeEvent>
        ) => {
          const data = event.nativeEvent
          onDrawingChange?.(data)
          pencilKitEventBus.emitDrawing(data)
        },
        onPencilKitDrawingSnapshot: (
          event: NativeEventPayload<PencilKitDrawingSnapshotEvent>
        ) => {
          onDrawingSnapshot?.(event.nativeEvent)
        },
        onPencilKitDrawingPhase: (
          event: NativeEventPayload<PencilKitDrawingPhaseEvent>
        ) => {
          const data = event.nativeEvent
          if (data.phase === 'began') onDrawingBegin?.(data)
          if (data.phase === 'ended') onDrawingEnd?.(data)
        },
        onPencilKitHistoryChange: (
          event: NativeEventPayload<PencilKitHistoryEvent>
        ) => {
          const data = event.nativeEvent
          onHistoryChange?.(data)
          pencilKitEventBus.emitHistory(data)
        },
        onPencilKitToolPickerChange: (
          event: NativeEventPayload<PencilKitToolPickerEvent>
        ) => {
          const data = event.nativeEvent
          onToolPickerChange?.(data)
          pencilKitEventBus.emitToolPicker(data)
        },
        onApplePencilCoalescedTouches: (
          event: NativeEventPayload<ApplePencilCoalescedTouchesData>
        ) => {
          const data = event.nativeEvent
          onApplePencilCoalescedTouches?.(data)
          pencilKitEventBus.emitCoalesced(data)
        },
        onApplePencilPredictedTouches: (
          event: NativeEventPayload<ApplePencilPredictedTouchesData>
        ) => {
          const data = event.nativeEvent
          onApplePencilPredictedTouches?.(data)
          pencilKitEventBus.emitPredicted(data)
        },
        onApplePencilEstimatedProperties: (
          event: NativeEventPayload<ApplePencilEstimatedPropertiesData>
        ) => {
          const data = event.nativeEvent
          onApplePencilEstimatedProperties?.(data)
          pencilKitEventBus.emitEstimated(data)
        },
        onApplePencilMotion: (event: NativeEventPayload<ApplePencilMotionData>) => {
          const data = event.nativeEvent
          onApplePencilMotion?.(data)
          pencilKitEventBus.emitMotion(data)
        },
        onApplePencilHover: (event: NativeEventPayload<ApplePencilHoverData>) => {
          const data = event.nativeEvent
          onApplePencilHover?.(data)
          pencilKitEventBus.emitHover(data)
        },
        onApplePencilSqueeze: (event: NativeEventPayload<ApplePencilSqueezeData>) => {
          const data = event.nativeEvent
          onApplePencilSqueeze?.(data)
          pencilKitEventBus.emitSqueeze(data)
        },
        onApplePencilDoubleTap: (
          event: NativeEventPayload<ApplePencilDoubleTapData>
        ) => {
          const data = event.nativeEvent
          onApplePencilDoubleTap?.(data)
          pencilKitEventBus.emitDoubleTap(data)
        },
        onApplePencilPreferredSqueezeAction: (
          event: NativeEventPayload<ApplePencilPreferredSqueezeActionData>
        ) => {
          const data = event.nativeEvent
          onApplePencilPreferredSqueezeAction?.(data)
          pencilKitEventBus.emitPreferredSqueezeAction(data)
        },
      }),
      [
        onApplePencilData,
        onDrawingChange,
        onDrawingSnapshot,
        onDrawingBegin,
        onDrawingEnd,
        onHistoryChange,
        onToolPickerChange,
        onApplePencilCoalescedTouches,
        onApplePencilPredictedTouches,
        onApplePencilEstimatedProperties,
        onApplePencilMotion,
        onApplePencilHover,
        onApplePencilSqueeze,
        onApplePencilDoubleTap,
        onApplePencilPreferredSqueezeAction,
        onStylusViewStartDrawing,
        onStylusViewEndDrawing,
        onStylusViewToggleEraser,
      ]
    )

    if (viewId == null || NativePencilKitView == null) return null

    return (
      <NativePencilKitView
        {...viewProps}
        style={style}
        viewId={viewId}
        enableApplePencilData={enableApplePencilData}
        enableToolPicker={enableToolPicker}
        enableHapticFeedback={enableHapticFeedback}
        enableMotionTracking={enableMotionTracking}
        enableSqueezeInteraction={enableSqueezeInteraction}
        enableDoubleTapInteraction={enableDoubleTapInteraction}
        enableHoverSupport={enableHoverSupport}
        onApplePencilData={callbacks.onApplePencilData}
        onPencilKitDrawingChange={callbacks.onPencilKitDrawingChange}
        onPencilKitDrawingSnapshot={callbacks.onPencilKitDrawingSnapshot}
        onPencilKitDrawingPhase={callbacks.onPencilKitDrawingPhase}
        onPencilKitHistoryChange={callbacks.onPencilKitHistoryChange}
        onPencilKitToolPickerChange={callbacks.onPencilKitToolPickerChange}
        onApplePencilCoalescedTouches={callbacks.onApplePencilCoalescedTouches}
        onApplePencilPredictedTouches={callbacks.onApplePencilPredictedTouches}
        onApplePencilEstimatedProperties={
          callbacks.onApplePencilEstimatedProperties
        }
        onApplePencilMotion={callbacks.onApplePencilMotion}
        onApplePencilHover={callbacks.onApplePencilHover}
        onApplePencilSqueeze={callbacks.onApplePencilSqueeze}
        onApplePencilDoubleTap={callbacks.onApplePencilDoubleTap}
        onApplePencilPreferredSqueezeAction={
          callbacks.onApplePencilPreferredSqueezeAction
        }
      />
    )
  }
)

PencilKitView.displayName = 'PencilKitView'
