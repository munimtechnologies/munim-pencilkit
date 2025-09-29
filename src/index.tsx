import MunimPencilkit from './NativeMunimPencilkit';
import { PencilKitView } from './PencilKitView';
import type {
  ApplePencilData,
  PencilKitDrawingData,
  PencilKitConfig,
} from './NativeMunimPencilkit';

// Export all interfaces
export type {
  ApplePencilData,
  PencilKitDrawingData,
  PencilKitStroke,
  PencilKitPoint,
  PencilKitTool,
  PencilKitConfig,
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
    MunimPencilkit.addApplePencilDataListener(callback),
  removeApplePencilListener: () =>
    MunimPencilkit.removeApplePencilDataListener(),
  addDrawingChangeListener: (
    callback: (viewId: number, drawing: PencilKitDrawingData) => void
  ) => MunimPencilkit.addPencilKitDrawingChangeListener(callback),
  removeDrawingChangeListener: () =>
    MunimPencilkit.removePencilKitDrawingChangeListener(),
};

// Default export
export default MunimPencilkit;
