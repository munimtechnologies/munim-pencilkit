import MunimPencilkit from './NativeMunimPencilkit';
import { PencilKitView } from './PencilKitView';
import { NativeEventEmitter, NativeModules } from 'react-native';
import type {
  ApplePencilData,
  PencilKitDrawingData,
  PencilKitConfig,
  ApplePencilSqueezeData,
  ApplePencilDoubleTapData,
  ApplePencilHoverData,
  ApplePencilCoalescedTouchesData,
} from './NativeMunimPencilkit';

// Create event emitter for the native module
const eventEmitter = new NativeEventEmitter(NativeModules.MunimPencilkit);

// Export all interfaces
export type {
  ApplePencilData,
  PencilKitDrawingData,
  PencilKitStroke,
  PencilKitPoint,
  PencilKitTool,
  PencilKitConfig,
  ApplePencilSqueezeData,
  ApplePencilDoubleTapData,
  ApplePencilHoverData,
  ApplePencilCoalescedTouchesData,
} from './NativeMunimPencilkit';

// Export the PencilKit view component
export { PencilKitView };

// Legacy function
export function multiply(a: number, b: number): number {
  return MunimPencilkit.multiply(a, b);
}

// PencilKit utility functions
export const PencilKitUtils = {
  // Create a new PencilKit view
  createView: () => MunimPencilkit.createPencilKitView(),

  // Destroy a PencilKit view
  destroyView: (viewId: number) => MunimPencilkit.destroyPencilKitView(viewId),

  // Configure PencilKit view
  setConfig: (viewId: number, config: PencilKitConfig) =>
    MunimPencilkit.setPencilKitConfig(viewId, config),

  // Drawing operations
  getDrawing: (viewId: number) => MunimPencilkit.getPencilKitDrawing(viewId),
  setDrawing: (viewId: number, drawing: PencilKitDrawingData) =>
    MunimPencilkit.setPencilKitDrawing(viewId, drawing),
  clearDrawing: (viewId: number) =>
    MunimPencilkit.clearPencilKitDrawing(viewId),
  undo: (viewId: number) => MunimPencilkit.undoPencilKitDrawing(viewId),
  redo: (viewId: number) => MunimPencilkit.redoPencilKitDrawing(viewId),
  canUndo: (viewId: number) => MunimPencilkit.canUndoPencilKitDrawing(viewId),
  canRedo: (viewId: number) => MunimPencilkit.canRedoPencilKitDrawing(viewId),

  // Apple Pencil data capture
  startApplePencilCapture: (viewId: number) =>
    MunimPencilkit.startApplePencilDataCapture(viewId),
  stopApplePencilCapture: (viewId: number) =>
    MunimPencilkit.stopApplePencilDataCapture(viewId),
  isApplePencilCaptureActive: (viewId: number) =>
    MunimPencilkit.isApplePencilDataCaptureActive(viewId),

  // Event listeners
  addApplePencilListener: (callback: (data: ApplePencilData) => void) =>
    eventEmitter.addListener('onApplePencilData', (data: any) =>
      callback(data as ApplePencilData)
    ),
  removeApplePencilListener: () =>
    eventEmitter.removeAllListeners('onApplePencilData'),
  addDrawingChangeListener: (
    callback: (viewId: number, drawing: PencilKitDrawingData) => void
  ) =>
    eventEmitter.addListener('onPencilKitDrawingChange', (event: any) => {
      if (event.viewId && event.drawing) {
        callback(event.viewId, event.drawing as PencilKitDrawingData);
      }
    }),
  removeDrawingChangeListener: () =>
    eventEmitter.removeAllListeners('onPencilKitDrawingChange'),
  
  // Apple Pencil Pro event listeners
  addApplePencilSqueezeListener: (callback: (data: ApplePencilSqueezeData) => void) =>
    eventEmitter.addListener('onApplePencilSqueeze', (data: any) => callback(data as ApplePencilSqueezeData)),
  removeApplePencilSqueezeListener: () =>
    eventEmitter.removeAllListeners('onApplePencilSqueeze'),
  addApplePencilDoubleTapListener: (callback: (data: ApplePencilDoubleTapData) => void) =>
    eventEmitter.addListener('onApplePencilDoubleTap', (data: any) => callback(data as ApplePencilDoubleTapData)),
  removeApplePencilDoubleTapListener: () =>
    eventEmitter.removeAllListeners('onApplePencilDoubleTap'),
  addApplePencilHoverListener: (callback: (data: ApplePencilHoverData) => void) =>
    eventEmitter.addListener('onApplePencilHover', (data: any) => callback(data as ApplePencilHoverData)),
  removeApplePencilHoverListener: () =>
    eventEmitter.removeAllListeners('onApplePencilHover'),
  addApplePencilCoalescedTouchesListener: (callback: (data: ApplePencilCoalescedTouchesData) => void) =>
    eventEmitter.addListener('onApplePencilCoalescedTouches', (data: any) => callback(data as ApplePencilCoalescedTouchesData)),
  removeApplePencilCoalescedTouchesListener: () =>
    eventEmitter.removeAllListeners('onApplePencilCoalescedTouches'),
};

// Default export
export default MunimPencilkit;
