import { NitroModules } from 'react-native-nitro-modules'
import type { MunimPencilkit as MunimPencilkitSpec } from './specs/munim-pencilkit.nitro'

export const MunimPencilkit =
  NitroModules.createHybridObject<MunimPencilkitSpec>('MunimPencilkit')
