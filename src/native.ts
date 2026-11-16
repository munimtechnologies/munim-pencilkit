import { Platform } from 'react-native'
import { NitroModules } from 'react-native-nitro-modules'
import type { MunimPencilkit as MunimPencilkitSpec } from './specs/munim-pencilkit.nitro'

/**
 * Thrown (or rejected, for Promise-returning calls) by every PencilKit call on
 * platforms without PencilKit (Android, web). Check
 * `PencilKitUtils.isSupported()` first; `PencilKitView` renders nothing there.
 */
export class PencilKitUnsupportedError extends Error {
  readonly code = 'ERR_PENCILKIT_UNSUPPORTED_PLATFORM'
  readonly platform: string

  constructor(method: string, platform: string = Platform.OS) {
    super(
      `munim-pencilkit: ${method}() needs PencilKit, which is only available on iOS/iPadOS (current platform: ${platform})`
    )
    this.name = 'PencilKitUnsupportedError'
    this.platform = platform
  }
}

/** Spec methods that return a Promise: they reject instead of throwing. */
const ASYNC_METHODS = new Set<string>([
  'getPencilKitDrawingAsync',
  'setPencilKitDrawingAsync',
  'exportPencilKitDocumentAsync',
  'importPencilKitDocumentAsync',
  'getPencilKitStrokes',
  'setPencilKitStrokes',
  'appendPencilKitStrokes',
  'removePencilKitStrokes',
  'transformPencilKitStrokes',
  'getPencilKitStrokesWithOptions',
  'getPencilKitSelection',
  'setPencilKitSelection',
  'erasePencilKitPath',
  'recognizePencilKitText',
  'searchPencilKitText',
  'getPencilKitDrawingArchive',
  'setPencilKitDrawingArchive',
  'playPencilKitFeedback',
])

const unsupportedNativeModule = new Proxy(
  {
    isPencilKitSupported: () => false,
    getPencilKitRecognitionInfo: () =>
      Promise.resolve(
        JSON.stringify({
          supported: false,
          supportedLanguages: [],
          recognitionVersion: null,
        })
      ),
    getPencilKitCapabilities: () =>
      JSON.stringify({
        platform:
          Platform.OS === 'ios' || Platform.OS === 'android'
            ? Platform.OS
            : 'other',
        supported: false,
        minimumIOSVersion: '17.5',
        documentVersion: 1,
        documentFormats: [],
        outputKinds: [],
        importFormats: [],
        tools: { ink: [], eraser: [], lasso: false, toolPicker: false },
        telemetry: {
          pencilTouches: false,
          predictedTouches: false,
          coalescedTouches: false,
          hover: false,
          squeeze: false,
          barrelRoll: false,
          pencilMotion: false,
          deviceMotion: false,
        },
        strokes: false,
      }),
  },
  {
    get(target, property, receiver) {
      if (property in target) return Reflect.get(target, property, receiver)
      if (property === 'name') return 'MunimPencilkit'
      // Not a thenable, and no fake symbols/inspection hooks.
      if (typeof property !== 'string' || property === 'then') return undefined
      if (ASYNC_METHODS.has(property)) {
        return () => Promise.reject(new PencilKitUnsupportedError(property))
      }
      return () => {
        throw new PencilKitUnsupportedError(property)
      }
    },
  }
) as unknown as MunimPencilkitSpec

export const MunimPencilkit: MunimPencilkitSpec =
  Platform.OS === 'ios'
    ? NitroModules.createHybridObject<MunimPencilkitSpec>('MunimPencilkit')
    : unsupportedNativeModule
