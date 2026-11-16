import type {
  ApplePencilSample,
  ApplePencilSampleBatch,
  ApplePencilSampleKind,
} from './types'

/**
 * Binary layout of the buffers from `addPencilSampleListener`, all Float64
 * (native byte order):
 *
 *   header: [formatVersion, stride, count, viewId]
 *   then `count` records of `stride` values, see `PENCIL_SAMPLE_FIELD`.
 */
export const PENCIL_SAMPLE_FORMAT_VERSION = 1
export const PENCIL_SAMPLE_HEADER_LENGTH = 4
export const PENCIL_SAMPLE_STRIDE = 16

/** Offsets of each value inside one record. */
export const PENCIL_SAMPLE_FIELD = {
  /** 0 sample, 1 predicted, 2 estimatedUpdate. */
  kind: 0,
  /** 0 began, 1 moved, 2 ended, 3 cancelled. */
  phase: 1,
  timestamp: 2,
  x: 3,
  y: 4,
  preciseX: 5,
  preciseY: 6,
  force: 7,
  maximumPossibleForce: 8,
  altitude: 9,
  azimuth: 10,
  azimuthUnitX: 11,
  azimuthUnitY: 12,
  rollAngle: 13,
  /** Bits 0-3: estimated force/azimuth/altitude/location; bits 4-7: expecting updates. */
  estimatedMask: 14,
  estimationUpdateIndex: 15,
} as const

const KINDS: readonly ApplePencilSampleKind[] = [
  'sample',
  'predicted',
  'estimatedUpdate',
]
const PHASES: readonly ApplePencilSample['phase'][] = [
  'began',
  'moved',
  'ended',
  'cancelled',
]
const ESTIMATED_PROPERTIES = ['force', 'azimuth', 'altitude', 'location']

const maskToNames = (mask: number): string[] => {
  const names: string[] = []
  for (let bit = 0; bit < ESTIMATED_PROPERTIES.length; bit += 1) {
    if (mask & (1 << bit)) names.push(ESTIMATED_PROPERTIES[bit]!)
  }
  return names
}

/** Reads record `index` of `samples` into an object. */
export function readPencilSample(
  samples: Float64Array,
  index: number,
  stride: number = PENCIL_SAMPLE_STRIDE
): ApplePencilSample {
  const F = PENCIL_SAMPLE_FIELD
  const o = index * stride
  const force = samples[o + F.force]!
  const maximumPossibleForce = samples[o + F.maximumPossibleForce]!
  const mask = samples[o + F.estimatedMask]!
  return {
    kind: KINDS[samples[o + F.kind]!] ?? 'sample',
    phase: PHASES[samples[o + F.phase]!] ?? 'moved',
    timestamp: samples[o + F.timestamp]!,
    x: samples[o + F.x]!,
    y: samples[o + F.y]!,
    preciseX: samples[o + F.preciseX]!,
    preciseY: samples[o + F.preciseY]!,
    force,
    maximumPossibleForce,
    pressure: maximumPossibleForce > 0 ? force / maximumPossibleForce : 0,
    altitude: samples[o + F.altitude]!,
    azimuth: samples[o + F.azimuth]!,
    azimuthUnitVector: {
      x: samples[o + F.azimuthUnitX]!,
      y: samples[o + F.azimuthUnitY]!,
    },
    rollAngle: samples[o + F.rollAngle]!,
    estimatedProperties: maskToNames(mask & 0xf),
    estimatedPropertiesExpectingUpdates: maskToNames((mask >> 4) & 0xf),
    estimationUpdateIndex: samples[o + F.estimationUpdateIndex]!,
  }
}

/**
 * Wraps a buffer from `addPencilSampleListener` without copying it. Throws
 * on a buffer with an unknown format version or a truncated payload.
 */
export function decodePencilSamples(
  buffer: ArrayBuffer
): ApplePencilSampleBatch {
  const headerBytes = PENCIL_SAMPLE_HEADER_LENGTH * 8
  if (buffer.byteLength < headerBytes) {
    throw new Error('Pencil sample buffer is shorter than its header')
  }
  const header = new Float64Array(buffer, 0, PENCIL_SAMPLE_HEADER_LENGTH)
  const version = header[0]!
  const stride = header[1]!
  const count = header[2]!
  const viewId = header[3]!
  if (version !== PENCIL_SAMPLE_FORMAT_VERSION) {
    throw new Error(`Unsupported pencil sample format version ${version}`)
  }
  if (
    !Number.isInteger(stride) ||
    stride < PENCIL_SAMPLE_STRIDE ||
    !Number.isInteger(count) ||
    count < 0 ||
    headerBytes + count * stride * 8 > buffer.byteLength
  ) {
    throw new Error('Malformed pencil sample buffer')
  }
  const samples = new Float64Array(buffer, headerBytes, count * stride)
  return {
    viewId,
    count,
    stride,
    samples,
    toArray: () =>
      Array.from({ length: count }, (_, index) =>
        readPencilSample(samples, index, stride)
      ),
  }
}
