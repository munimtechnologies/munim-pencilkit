import { Platform } from 'react-native'
import { NitroModules } from 'react-native-nitro-modules'
import type { MunimPencilkit as MunimPencilkitSpec } from './specs/munim-pencilkit.nitro'

const unsupported = (): never => {
  throw new Error('munim-pencilkit is only available on iOS')
}

const unsupportedNativeModule = new Proxy(
  {
    isPencilKitSupported: () => false,
    getPencilKitCapabilities: () =>
      JSON.stringify({
        platform: Platform.OS,
        supported: false,
        minimumIOSVersion: '14.0',
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
      }),
  },
  {
    get(target, property, receiver) {
      if (property in target) return Reflect.get(target, property, receiver)
      if (property === 'name') return 'MunimPencilkit'
      return unsupported
    },
  }
) as unknown as MunimPencilkitSpec

export const MunimPencilkit: MunimPencilkitSpec =
  Platform.OS === 'ios'
    ? NitroModules.createHybridObject<MunimPencilkitSpec>('MunimPencilkit')
    : unsupportedNativeModule
