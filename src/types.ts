export interface ApplePencilData {
  pressure?: number
  altitude?: number
  azimuth?: number
  azimuthUnitVector?: { x: number; y: number }
  force?: number
  maximumPossibleForce?: number
  perpendicularForce?: number
  rollAngle?: number
  timestamp: number
  location?: { x: number; y: number }
  previousLocation?: { x: number; y: number }
  preciseLocation?: { x: number; y: number }
  isApplePencil?: boolean
  phase?: 'began' | 'moved' | 'ended' | 'cancelled'
  hasPreciseLocation?: boolean
  estimatedProperties?: string[]
  estimatedPropertiesExpectingUpdates?: string[]
  velocity?: number
  acceleration?: number
  action?: 'drawingStarted' | 'drawingEnded'
  isEraserOn?: boolean
  viewId?: number
}

export interface ApplePencilCoalescedTouchesData {
  viewId: number
  touches: ApplePencilData[]
  timestamp: number
}

export interface ApplePencilPredictedTouchesData {
  viewId: number
  touches: ApplePencilData[]
  timestamp: number
}

export interface ApplePencilEstimatedPropertiesData {
  viewId: number
  touchId: number
  updatedProperties: string[]
  newData: ApplePencilData
  timestamp: number
}

export interface ApplePencilMotionData {
  viewId: number
  rollAngle: number
  pitchAngle: number
  yawAngle: number
  timestamp: number
}

export interface ApplePencilHoverData {
  viewId: number
  location: { x: number; y: number }
  altitude: number
  azimuth: number
  azimuthUnitVector: { x: number; y: number }
  zOffset?: number
  rollAngle?: number
  timestamp: number
}

export type ApplePencilPreferredAction =
  | 'ignore'
  | 'switchEraser'
  | 'switchPrevious'
  | 'showColorPalette'
  | 'showInkAttributes'
  | 'showContextualPalette'
  | 'runSystemShortcut'

export interface ApplePencilSqueezeData {
  viewId: number
  phase: 'began' | 'changed' | 'ended' | 'cancelled'
  timestamp: number
  preferredAction: ApplePencilPreferredAction
  hoverPose?: {
    location: { x: number; y: number }
    zOffset: number
    azimuth: number
    azimuthUnitVector: { x: number; y: number }
    altitude: number
    rollAngle: number
  }
}

export interface ApplePencilDoubleTapData {
  viewId: number
  phase: 'ended'
  timestamp: number
  preferredAction: ApplePencilPreferredAction
  hoverPose?: {
    location: { x: number; y: number }
    zOffset: number
    azimuth: number
    azimuthUnitVector: { x: number; y: number }
    altitude: number
    rollAngle: number
  }
}

export interface ApplePencilPreferredSqueezeActionData {
  preferredAction: ApplePencilPreferredAction
}

export type SqueezeEraserBehavior =
  | 'alwaysOn'
  | 'switchEraserOnly'
  | 'toggle'
  | 'none'

export type CustomStylusRenderMode = 'incremental' | 'replay'

export type CustomStylusEraserMode = 'clear' | 'paint'

export interface PencilKitPoint {
  location: { x: number; y: number }
  pressure: number
  azimuth: number
  altitude: number
  timestamp: number
}

export interface PencilKitTool {
  type: 'pen' | 'pencil' | 'marker' | 'eraser' | 'lasso'
  width: number
  color: string
}

export interface PencilKitStroke {
  points: PencilKitPoint[]
  tool: PencilKitTool
  color: string
  width: number
}

export interface PencilKitDrawingData {
  strokes: PencilKitStroke[]
  bounds: {
    x: number
    y: number
    width: number
    height: number
  }
  dataBase64?: string
  imageBase64?: string
}

export interface PencilKitConfig {
  allowsFingerDrawing: boolean
  allowsPencilOnlyDrawing: boolean
  isRulerActive: boolean
  drawingPolicy: 'default' | 'anyInput' | 'pencilOnly'
  enableApplePencilData?: boolean
  enableToolPicker?: boolean
  enableHapticFeedback?: boolean
  enableMotionTracking?: boolean
  enableSqueezeInteraction?: boolean
  enableDoubleTapInteraction?: boolean
  enableHoverSupport?: boolean
  useCustomStylusView?: boolean
  squeezeEraserBehavior?: SqueezeEraserBehavior
  customStylusRenderMode?: CustomStylusRenderMode
  customStylusEraserMode?: CustomStylusEraserMode
  customStylusOpaqueCanvas?: boolean
  customStylusSurfaceColor?: string
  showHoverPreview?: boolean
  strokeColor?: string
  baseLineWidth?: number
}
