import { TurboModuleRegistry, type TurboModule } from 'react-native';

// Apple Pencil data interface
export interface ApplePencilData {
  pressure: number; // 0.0 to 1.0
  altitude: number; // 0.0 to 1.0
  azimuth: number; // 0.0 to 2π radians
  force: number; // 0.0 to 1.0
  maximumPossibleForce: number;
  perpendicularForce: number; // Computed perpendicular force
  // Note: rollAngle may not be available on all iOS versions
  timestamp: number;
  location: {
    x: number;
    y: number;
  };
  previousLocation: {
    x: number;
    y: number;
  };
  preciseLocation: {
    x: number;
    y: number;
  };
  isApplePencil: boolean;
  phase: 'began' | 'moved' | 'ended' | 'cancelled';
  hasPreciseLocation: boolean;
  estimatedProperties: string[];
  estimatedPropertiesExpectingUpdates: string[];
}


export interface ApplePencilCoalescedTouchesData {
  viewId: number;
  touches: ApplePencilData[];
  timestamp: number;
}

export interface ApplePencilPredictedTouchesData {
  viewId: number;
  touches: ApplePencilData[];
  timestamp: number;
}

export interface ApplePencilEstimatedPropertiesData {
  viewId: number;
  touchId: number;
  updatedProperties: string[];
  newData: ApplePencilData;
  timestamp: number;
}


// PencilKit drawing data
export interface PencilKitDrawingData {
  strokes: PencilKitStroke[];
  bounds: {
    x: number;
    y: number;
    width: number;
    height: number;
  };
}

export interface PencilKitStroke {
  points: PencilKitPoint[];
  tool: PencilKitTool;
  color: string;
  width: number;
}

export interface PencilKitPoint {
  location: {
    x: number;
    y: number;
  };
  pressure: number;
  azimuth: number;
  altitude: number;
  timestamp: number;
}

export interface PencilKitTool {
  type: 'pen' | 'pencil' | 'marker' | 'eraser' | 'lasso';
  width: number;
  color: string;
}

// PencilKit configuration
export interface PencilKitConfig {
  allowsFingerDrawing: boolean;
  allowsPencilOnlyDrawing: boolean;
  isRulerActive: boolean;
  drawingPolicy: 'default' | 'anyInput' | 'pencilOnly';
  enableApplePencilData?: boolean;
  enableToolPicker?: boolean;
  enableHapticFeedback?: boolean;
}

export interface Spec extends TurboModule {
  // Legacy method
  multiply(a: number, b: number): number;

  // PencilKit methods
  createPencilKitView(): Promise<number>;
  destroyPencilKitView(viewId: number): Promise<void>;
  setPencilKitConfig(viewId: number, config: PencilKitConfig): Promise<void>;
  getPencilKitDrawing(viewId: number): Promise<PencilKitDrawingData>;
  setPencilKitDrawing(
    viewId: number,
    drawing: PencilKitDrawingData
  ): Promise<void>;
  clearPencilKitDrawing(viewId: number): Promise<void>;
  undoPencilKitDrawing(viewId: number): Promise<boolean>;
  redoPencilKitDrawing(viewId: number): Promise<boolean>;
  canUndoPencilKitDrawing(viewId: number): Promise<boolean>;
  canRedoPencilKitDrawing(viewId: number): Promise<boolean>;

  // Apple Pencil data methods
  startApplePencilDataCapture(viewId: number): Promise<void>;
  stopApplePencilDataCapture(viewId: number): Promise<void>;
  isApplePencilDataCaptureActive(viewId: number): Promise<boolean>;

  // Event listeners
  addApplePencilDataListener(callback: (data: ApplePencilData) => void): void;
  removeApplePencilDataListener(): void;
  addPencilKitDrawingChangeListener(
    callback: (viewId: number, drawing: PencilKitDrawingData) => void
  ): void;
  removePencilKitDrawingChangeListener(): void;
}

export default TurboModuleRegistry.getEnforcing<Spec>('MunimPencilkit');
