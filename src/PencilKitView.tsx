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
  requireNativeComponent,
  type NativeSyntheticEvent,
  type ViewProps,
  type ViewStyle,
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
  PencilKitConfig,
  PencilKitDrawingData,
} from './types'

type NativeEventPayload<T> = NativeSyntheticEvent<T>
type Listener<T> = (data: T) => void

class PencilKitEventBus {
  private applePencilListeners = new Set<Listener<ApplePencilData>>()
  private drawingListeners = new Set<
    Listener<{ viewId: number; drawing: PencilKitDrawingData }>
  >()
  private coalescedListeners =
    new Set<Listener<ApplePencilCoalescedTouchesData>>()
  private predictedListeners =
    new Set<Listener<ApplePencilPredictedTouchesData>>()
  private estimatedListeners =
    new Set<Listener<ApplePencilEstimatedPropertiesData>>()
  private motionListeners = new Set<Listener<ApplePencilMotionData>>()
  private hoverListeners = new Set<Listener<ApplePencilHoverData>>()
  private squeezeListeners = new Set<Listener<ApplePencilSqueezeData>>()
  private doubleTapListeners = new Set<Listener<ApplePencilDoubleTapData>>()
  private preferredSqueezeActionListeners =
    new Set<Listener<ApplePencilPreferredSqueezeActionData>>()

  emitApplePencil(data: ApplePencilData): void {
    this.applePencilListeners.forEach(cb => cb(data))
  }
  emitDrawing(viewId: number, drawing: PencilKitDrawingData): void {
    this.drawingListeners.forEach(cb => cb({ viewId, drawing }))
  }
  emitCoalesced(data: ApplePencilCoalescedTouchesData): void {
    this.coalescedListeners.forEach(cb => cb(data))
  }
  emitPredicted(data: ApplePencilPredictedTouchesData): void {
    this.predictedListeners.forEach(cb => cb(data))
  }
  emitEstimated(data: ApplePencilEstimatedPropertiesData): void {
    this.estimatedListeners.forEach(cb => cb(data))
  }
  emitMotion(data: ApplePencilMotionData): void {
    this.motionListeners.forEach(cb => cb(data))
  }
  emitHover(data: ApplePencilHoverData): void {
    this.hoverListeners.forEach(cb => cb(data))
  }
  emitSqueeze(data: ApplePencilSqueezeData): void {
    this.squeezeListeners.forEach(cb => cb(data))
  }
  emitDoubleTap(data: ApplePencilDoubleTapData): void {
    this.doubleTapListeners.forEach(cb => cb(data))
  }
  emitPreferredSqueezeAction(data: ApplePencilPreferredSqueezeActionData): void {
    this.preferredSqueezeActionListeners.forEach(cb => cb(data))
  }

  addApplePencil(cb: Listener<ApplePencilData>): () => void {
    this.applePencilListeners.add(cb)
    return () => this.applePencilListeners.delete(cb)
  }
  addDrawing(
    cb: Listener<{ viewId: number; drawing: PencilKitDrawingData }>
  ): () => void {
    this.drawingListeners.add(cb)
    return () => this.drawingListeners.delete(cb)
  }
  addCoalesced(cb: Listener<ApplePencilCoalescedTouchesData>): () => void {
    this.coalescedListeners.add(cb)
    return () => this.coalescedListeners.delete(cb)
  }
  addPredicted(cb: Listener<ApplePencilPredictedTouchesData>): () => void {
    this.predictedListeners.add(cb)
    return () => this.predictedListeners.delete(cb)
  }
  addEstimated(cb: Listener<ApplePencilEstimatedPropertiesData>): () => void {
    this.estimatedListeners.add(cb)
    return () => this.estimatedListeners.delete(cb)
  }
  addMotion(cb: Listener<ApplePencilMotionData>): () => void {
    this.motionListeners.add(cb)
    return () => this.motionListeners.delete(cb)
  }
  addHover(cb: Listener<ApplePencilHoverData>): () => void {
    this.hoverListeners.add(cb)
    return () => this.hoverListeners.delete(cb)
  }
  addSqueeze(cb: Listener<ApplePencilSqueezeData>): () => void {
    this.squeezeListeners.add(cb)
    return () => this.squeezeListeners.delete(cb)
  }
  addDoubleTap(cb: Listener<ApplePencilDoubleTapData>): () => void {
    this.doubleTapListeners.add(cb)
    return () => this.doubleTapListeners.delete(cb)
  }
  addPreferredSqueezeAction(
    cb: Listener<ApplePencilPreferredSqueezeActionData>
  ): () => void {
    this.preferredSqueezeActionListeners.add(cb)
    return () => this.preferredSqueezeActionListeners.delete(cb)
  }

  clearApplePencil(): void {
    this.applePencilListeners.clear()
  }
  clearDrawing(): void {
    this.drawingListeners.clear()
  }
  clearCoalesced(): void {
    this.coalescedListeners.clear()
  }
  clearPredicted(): void {
    this.predictedListeners.clear()
  }
  clearEstimated(): void {
    this.estimatedListeners.clear()
  }
  clearMotion(): void {
    this.motionListeners.clear()
  }
  clearHover(): void {
    this.hoverListeners.clear()
  }
  clearSqueeze(): void {
    this.squeezeListeners.clear()
  }
  clearDoubleTap(): void {
    this.doubleTapListeners.clear()
  }
  clearPreferredSqueezeAction(): void {
    this.preferredSqueezeActionListeners.clear()
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
    event: NativeEventPayload<PencilKitDrawingData>
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
  requireNativeComponent<NativePencilKitViewProps>('PencilKitView')

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
}

export interface PencilKitViewProps {
  style?: ViewStyle
  config?: PencilKitConfig
  onApplePencilData?: (data: ApplePencilData) => void
  onDrawingChange?: (drawing: PencilKitDrawingData) => void
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
  try {
    return JSON.parse(raw) as PencilKitDrawingData
  } catch {
    return {
      strokes: [],
      bounds: { x: 0, y: 0, width: 0, height: 0 },
    }
  }
}

export const PencilKitView = forwardRef<PencilKitViewRef, PencilKitViewProps>(
  (props, ref: Ref<PencilKitViewRef>) => {
    const {
      style,
      config,
      onApplePencilData,
      onDrawingChange,
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
    } = props

    const [viewId, setViewId] = useState<number | null>(null)
    const createdIdRef = useRef<number | null>(null) as MutableRefObject<
      number | null
    >

    useEffect(() => {
      const id = MunimPencilkit.createPencilKitView()
      createdIdRef.current = id
      setViewId(id)
      onViewReady?.(id)
      return () => {
        if (createdIdRef.current != null) {
          MunimPencilkit.destroyPencilKitView(createdIdRef.current)
          createdIdRef.current = null
        }
      }
    }, [onViewReady])

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
          event: NativeEventPayload<PencilKitDrawingData>
        ) => {
          const drawing = event.nativeEvent
          onDrawingChange?.(drawing)
          if (viewId != null) {
            pencilKitEventBus.emitDrawing(viewId, drawing)
          }
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
        viewId,
      ]
    )

    if (viewId == null) return null

    return (
      <NativePencilKitView
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
