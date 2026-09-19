import { type HybridObject } from 'react-native-nitro-modules'

export interface MunimPencilkit extends HybridObject<{ ios: 'swift' }> {
  /**
   * @deprecated Leftover from the Nitro module template. Kept for backwards
   * compatibility; it will be removed in a future major version.
   */
  sum(num1: number, num2: number): number
  isPencilKitSupported(): boolean
  getPencilKitCapabilities(): string
  createPencilKitView(): number
  destroyPencilKitView(viewId: number): void
  setPencilKitConfig(viewId: number, configJson: string): void
  /**
   * @deprecated Blocks the JS thread on the main thread. Use
   * `getPencilKitDrawingAsync`.
   */
  getPencilKitDrawing(viewId: number): string
  getPencilKitDrawingAsync(viewId: number, optionsJson: string): Promise<string>
  /**
   * @deprecated Blocks the JS thread on the main thread. Use
   * `setPencilKitDrawingAsync`.
   */
  setPencilKitDrawing(viewId: number, drawingJson: string): void
  setPencilKitDrawingAsync(viewId: number, drawingJson: string): Promise<void>
  clearPencilKitDrawing(viewId: number): void
  undoPencilKitDrawing(viewId: number): boolean
  redoPencilKitDrawing(viewId: number): boolean
  canUndoPencilKitDrawing(viewId: number): boolean
  canRedoPencilKitDrawing(viewId: number): boolean
  startApplePencilDataCapture(viewId: number): void
  stopApplePencilDataCapture(viewId: number): void
  isApplePencilDataCaptureActive(viewId: number): boolean
  /**
   * @deprecated Blocks the JS thread while rendering. Use
   * `exportPencilKitDocumentAsync`.
   */
  exportPencilKitDocument(viewId: number, optionsJson: string): string
  exportPencilKitDocumentAsync(
    viewId: number,
    optionsJson: string
  ): Promise<string>
  /**
   * @deprecated Blocks the JS thread while decoding. Use
   * `importPencilKitDocumentAsync`.
   */
  importPencilKitDocument(viewId: number, optionsJson: string): void
  importPencilKitDocumentAsync(
    viewId: number,
    optionsJson: string
  ): Promise<void>
  setPencilKitTool(viewId: number, toolJson: string): void
  getPencilKitTool(viewId: number): string
  setPencilKitToolPickerVisible(viewId: number, visible: boolean): void

  /** Resolves `{"strokes": PencilKitStroke[], "requiredContentVersion": n}`. */
  getPencilKitStrokes(viewId: number): Promise<string>
  /** `strokesJson` is `{"strokes": PencilKitStroke[]}`. Undoable. */
  setPencilKitStrokes(viewId: number, strokesJson: string): Promise<void>
  /** `strokesJson` is `{"strokes": PencilKitStroke[]}`. Undoable. */
  appendPencilKitStrokes(viewId: number, strokesJson: string): Promise<void>
  /** Resolves the number of strokes removed. Undoable. */
  removePencilKitStrokes(viewId: number, indices: number[]): Promise<number>
  /**
   * `transformJson` is a `PencilKitAffineTransform`, applied in canvas space
   * after each stroke's own transform. Resolves the number of strokes changed.
   * Undoable.
   */
  transformPencilKitStrokes(
    viewId: number,
    indices: number[],
    transformJson: string
  ): Promise<number>
}
