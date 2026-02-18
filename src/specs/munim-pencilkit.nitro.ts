import { type HybridObject } from 'react-native-nitro-modules'

export interface MunimPencilkit extends HybridObject<{ ios: 'swift' }> {
  sum(num1: number, num2: number): number
  createPencilKitView(): number
  destroyPencilKitView(viewId: number): void
  setPencilKitConfig(viewId: number, configJson: string): void
  getPencilKitDrawing(viewId: number): string
  setPencilKitDrawing(viewId: number, drawingJson: string): void
  clearPencilKitDrawing(viewId: number): void
  undoPencilKitDrawing(viewId: number): boolean
  redoPencilKitDrawing(viewId: number): boolean
  canUndoPencilKitDrawing(viewId: number): boolean
  canRedoPencilKitDrawing(viewId: number): boolean
  startApplePencilDataCapture(viewId: number): void
  stopApplePencilDataCapture(viewId: number): void
  isApplePencilDataCaptureActive(viewId: number): boolean
}