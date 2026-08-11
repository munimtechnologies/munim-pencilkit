import { type HybridObject } from 'react-native-nitro-modules'

export interface MunimPencilkit extends HybridObject<{ ios: 'swift' }> {
  sum(num1: number, num2: number): number
  isPencilKitSupported(): boolean
  getPencilKitCapabilities(): string
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
  exportPencilKitDocument(viewId: number, optionsJson: string): string
  importPencilKitDocument(viewId: number, optionsJson: string): void
  setPencilKitTool(viewId: number, toolJson: string): void
  getPencilKitTool(viewId: number): string
  setPencilKitToolPickerVisible(viewId: number, visible: boolean): void
}