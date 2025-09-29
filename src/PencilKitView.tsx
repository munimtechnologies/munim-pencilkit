import {
  useEffect,
  useRef,
  useState,
  useImperativeHandle,
  forwardRef,
} from 'react';
import {
  View,
  type ViewStyle,
  requireNativeComponent,
  NativeModules,
  NativeEventEmitter,
} from 'react-native';
import type {
  ApplePencilData,
  PencilKitDrawingData,
  PencilKitConfig,
  ApplePencilSqueezeData,
  ApplePencilDoubleTapData,
  ApplePencilHoverData,
  ApplePencilCoalescedTouchesData,
  ApplePencilPredictedTouchesData,
  ApplePencilEstimatedPropertiesData,
  ApplePencilPreferredSqueezeActionData,
} from './NativeMunimPencilkit';

// Create event emitter for the native module
const eventEmitter = new NativeEventEmitter(NativeModules.MunimPencilkit);

const { MunimPencilkit } = NativeModules;

// Native component interface
interface PencilKitNativeViewProps {
  style?: ViewStyle;
  viewId: number;
  enableApplePencilData: boolean;
  enableToolPicker: boolean;
  enableSqueezeInteraction: boolean;
  enableDoubleTapInteraction: boolean;
  enableHoverSupport: boolean;
  enableHapticFeedback: boolean;
}

// Native component
const PencilKitNativeView =
  requireNativeComponent<PencilKitNativeViewProps>('PencilKitView');

export interface PencilKitViewProps {
  style?: ViewStyle;
  config?: PencilKitConfig;
  onApplePencilData?: (data: ApplePencilData) => void;
  onDrawingChange?: (drawing: PencilKitDrawingData) => void;
  onApplePencilSqueeze?: (data: ApplePencilSqueezeData) => void;
  onApplePencilDoubleTap?: (data: ApplePencilDoubleTapData) => void;
  onApplePencilHover?: (data: ApplePencilHoverData) => void;
  onApplePencilCoalescedTouches?: (
    data: ApplePencilCoalescedTouchesData
  ) => void;
  onApplePencilPredictedTouches?: (
    data: ApplePencilPredictedTouchesData
  ) => void;
  onApplePencilEstimatedProperties?: (
    data: ApplePencilEstimatedPropertiesData
  ) => void;
  onApplePencilPreferredSqueezeAction?: (
    data: ApplePencilPreferredSqueezeActionData
  ) => void;
  onViewReady?: (viewId: number) => void;
  enableApplePencilData?: boolean;
  enableToolPicker?: boolean;
  enableSqueezeInteraction?: boolean;
  enableDoubleTapInteraction?: boolean;
  enableHoverSupport?: boolean;
  enableHapticFeedback?: boolean;
}

export interface PencilKitViewRef {
  getDrawing: () => Promise<PencilKitDrawingData>;
  setDrawing: (drawing: PencilKitDrawingData) => Promise<void>;
  clearDrawing: () => Promise<void>;
  undo: () => Promise<boolean>;
  redo: () => Promise<boolean>;
  canUndo: () => Promise<boolean>;
  canRedo: () => Promise<boolean>;
  startApplePencilCapture: () => Promise<void>;
  stopApplePencilCapture: () => Promise<void>;
  isApplePencilCaptureActive: () => Promise<boolean>;
}

export const PencilKitView = forwardRef<PencilKitViewRef, PencilKitViewProps>(
  (
    {
      style,
      config,
      onApplePencilData,
      onDrawingChange,
      onApplePencilSqueeze,
      onApplePencilDoubleTap,
      onApplePencilHover,
      onApplePencilCoalescedTouches,
      onApplePencilPredictedTouches,
      onApplePencilEstimatedProperties,
      onApplePencilPreferredSqueezeAction,
      onViewReady,
      enableApplePencilData = false,
      enableToolPicker = true,
      enableSqueezeInteraction = false,
      enableDoubleTapInteraction = false,
      enableHoverSupport = false,
      enableHapticFeedback = false,
    },
    ref
  ) => {
    const [viewId, setViewId] = useState<number | null>(null);
    const applePencilListenerRef = useRef<any>(null);
    const drawingChangeListenerRef = useRef<any>(null);
    const squeezeListenerRef = useRef<any>(null);
    const doubleTapListenerRef = useRef<any>(null);
    const hoverListenerRef = useRef<any>(null);
    const coalescedTouchesListenerRef = useRef<any>(null);
    const predictedTouchesListenerRef = useRef<any>(null);
    const estimatedPropertiesListenerRef = useRef<any>(null);
    const preferredSqueezeActionListenerRef = useRef<any>(null);

    // Initialize the PencilKit view
    useEffect(() => {
      let isMounted = true;

      const initializeView = async () => {
        try {
          const id = await MunimPencilkit.createPencilKitView();
          if (isMounted) {
            setViewId(id);
            onViewReady?.(id);

            // Apply initial config if provided
            if (config) {
              await MunimPencilkit.setPencilKitConfig(id, config);
            }
          }
        } catch (error) {
          console.error('Failed to create PencilKit view:', error);
        }
      };

      initializeView();

      return () => {
        isMounted = false;
        if (viewId) {
          MunimPencilkit.destroyPencilKitView(viewId).catch(console.error);
        }
      };
    }, []);

    // Set up event listeners
    // eslint-disable-next-line react-hooks/exhaustive-deps
    useEffect(() => {
      if (!viewId) return;

      // Apple Pencil data listener
      if (onApplePencilData && enableApplePencilData) {
        applePencilListenerRef.current = eventEmitter.addListener(
          'onApplePencilData',
          (data: any) => onApplePencilData(data as ApplePencilData)
        );
      }

      // Drawing change listener
      if (onDrawingChange) {
        drawingChangeListenerRef.current = eventEmitter.addListener(
          'onPencilKitDrawingChange',
          (event: any) => {
            if (event.viewId === viewId) {
              onDrawingChange(event.drawing as PencilKitDrawingData);
            }
          }
        );
      }

      // Apple Pencil Pro squeeze listener
      if (onApplePencilSqueeze && enableSqueezeInteraction) {
        squeezeListenerRef.current = eventEmitter.addListener(
          'onApplePencilSqueeze',
          (data: any) => onApplePencilSqueeze(data as ApplePencilSqueezeData)
        );
      }

      // Apple Pencil Pro double tap listener
      if (onApplePencilDoubleTap && enableDoubleTapInteraction) {
        doubleTapListenerRef.current = eventEmitter.addListener(
          'onApplePencilDoubleTap',
          (data: any) =>
            onApplePencilDoubleTap(data as ApplePencilDoubleTapData)
        );
      }

      // Apple Pencil Pro hover listener
      if (onApplePencilHover && enableHoverSupport) {
        hoverListenerRef.current = eventEmitter.addListener(
          'onApplePencilHover',
          (data: any) => onApplePencilHover(data as ApplePencilHoverData)
        );
      }

      // Apple Pencil Pro coalesced touches listener
      if (onApplePencilCoalescedTouches && enableApplePencilData) {
        coalescedTouchesListenerRef.current = eventEmitter.addListener(
          'onApplePencilCoalescedTouches',
          (data: any) =>
            onApplePencilCoalescedTouches(
              data as ApplePencilCoalescedTouchesData
            )
        );
      }

      // Apple Pencil Pro predicted touches listener
      if (onApplePencilPredictedTouches && enableApplePencilData) {
        predictedTouchesListenerRef.current = eventEmitter.addListener(
          'onApplePencilPredictedTouches',
          (data: any) =>
            onApplePencilPredictedTouches(
              data as ApplePencilPredictedTouchesData
            )
        );
      }

      // Apple Pencil Pro estimated properties listener
      if (onApplePencilEstimatedProperties && enableApplePencilData) {
        estimatedPropertiesListenerRef.current = eventEmitter.addListener(
          'onApplePencilEstimatedProperties',
          (data: any) =>
            onApplePencilEstimatedProperties(
              data as ApplePencilEstimatedPropertiesData
            )
        );
      }

      // Apple Pencil Pro preferred squeeze action listener
      if (onApplePencilPreferredSqueezeAction && enableSqueezeInteraction) {
        preferredSqueezeActionListenerRef.current = eventEmitter.addListener(
          'onApplePencilPreferredSqueezeAction',
          (data: any) =>
            onApplePencilPreferredSqueezeAction(
              data as ApplePencilPreferredSqueezeActionData
            )
        );
      }

      return () => {
        applePencilListenerRef.current?.remove();
        drawingChangeListenerRef.current?.remove();
        squeezeListenerRef.current?.remove();
        doubleTapListenerRef.current?.remove();
        hoverListenerRef.current?.remove();
        coalescedTouchesListenerRef.current?.remove();
        predictedTouchesListenerRef.current?.remove();
        estimatedPropertiesListenerRef.current?.remove();
        preferredSqueezeActionListenerRef.current?.remove();
      };
    }, [
      viewId,
      onApplePencilData,
      onDrawingChange,
      onApplePencilSqueeze,
      onApplePencilDoubleTap,
      onApplePencilHover,
      onApplePencilCoalescedTouches,
      onApplePencilPredictedTouches,
      onApplePencilEstimatedProperties,
      onApplePencilPreferredSqueezeAction,
      enableApplePencilData,
      enableSqueezeInteraction,
      enableDoubleTapInteraction,
      enableHoverSupport,
      enableHapticFeedback,
      config,
      onViewReady,
    ]);

    // Update config when it changes
    useEffect(() => {
      if (viewId && config) {
        MunimPencilkit.setPencilKitConfig(viewId, config).catch(console.error);
      }
    }, [viewId, config]);

    // Expose methods via ref
    useImperativeHandle(
      ref,
      () => ({
        getDrawing: async () => {
          if (!viewId) throw new Error('PencilKit view not ready');
          return MunimPencilkit.getPencilKitDrawing(viewId);
        },
        setDrawing: async (drawing: PencilKitDrawingData) => {
          if (!viewId) throw new Error('PencilKit view not ready');
          return MunimPencilkit.setPencilKitDrawing(viewId, drawing);
        },
        clearDrawing: async () => {
          if (!viewId) throw new Error('PencilKit view not ready');
          return MunimPencilkit.clearPencilKitDrawing(viewId);
        },
        undo: async () => {
          if (!viewId) throw new Error('PencilKit view not ready');
          return MunimPencilkit.undoPencilKitDrawing(viewId);
        },
        redo: async () => {
          if (!viewId) throw new Error('PencilKit view not ready');
          return MunimPencilkit.redoPencilKitDrawing(viewId);
        },
        canUndo: async () => {
          if (!viewId) throw new Error('PencilKit view not ready');
          return MunimPencilkit.canUndoPencilKitDrawing(viewId);
        },
        canRedo: async () => {
          if (!viewId) throw new Error('PencilKit view not ready');
          return MunimPencilkit.canRedoPencilKitDrawing(viewId);
        },
        startApplePencilCapture: async () => {
          if (!viewId) throw new Error('PencilKit view not ready');
          return MunimPencilkit.startApplePencilDataCapture(viewId);
        },
        stopApplePencilCapture: async () => {
          if (!viewId) throw new Error('PencilKit view not ready');
          return MunimPencilkit.stopApplePencilDataCapture(viewId);
        },
        isApplePencilCaptureActive: async () => {
          if (!viewId) throw new Error('PencilKit view not ready');
          return MunimPencilkit.isApplePencilDataCaptureActive(viewId);
        },
      }),
      [viewId]
    );

    if (!viewId) {
      return <View style={style} />;
    }

    return (
      <PencilKitNativeView
        style={style}
        viewId={viewId}
        enableApplePencilData={enableApplePencilData}
        enableToolPicker={enableToolPicker}
        enableSqueezeInteraction={enableSqueezeInteraction}
        enableDoubleTapInteraction={enableDoubleTapInteraction}
        enableHoverSupport={enableHoverSupport}
        enableHapticFeedback={enableHapticFeedback}
      />
    );
  }
);

PencilKitView.displayName = 'PencilKitView';
