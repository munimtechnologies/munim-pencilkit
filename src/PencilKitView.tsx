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
}

// Native component
const PencilKitNativeView =
  requireNativeComponent<PencilKitNativeViewProps>('PencilKitView');

export interface PencilKitViewProps {
  style?: ViewStyle;
  config?: PencilKitConfig;
  onApplePencilData?: (data: ApplePencilData) => void;
  onDrawingChange?: (drawing: PencilKitDrawingData) => void;
  onViewReady?: (viewId: number) => void;
  enableApplePencilData?: boolean;
  enableToolPicker?: boolean;
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
      onViewReady,
      enableApplePencilData = false,
      enableToolPicker = true,
    },
    ref
  ) => {
    const [viewId, setViewId] = useState<number | null>(null);
    const applePencilListenerRef = useRef<any>(null);
    const drawingChangeListenerRef = useRef<any>(null);

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

      return () => {
        applePencilListenerRef.current?.remove();
        drawingChangeListenerRef.current?.remove();
      };
    }, [
      viewId,
      onApplePencilData,
      onDrawingChange,
      enableApplePencilData,
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
      />
    );
  }
);

PencilKitView.displayName = 'PencilKitView';
