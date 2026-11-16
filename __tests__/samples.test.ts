import {
  decodePencilSamples,
  PENCIL_SAMPLE_FIELD,
  PENCIL_SAMPLE_FORMAT_VERSION,
  PENCIL_SAMPLE_HEADER_LENGTH,
  PENCIL_SAMPLE_STRIDE,
} from '../src/samples'

/** Builds a buffer the way PencilSampleEncoder (ios/) lays it out. */
const encode = (
  records: Array<Partial<Record<keyof typeof PENCIL_SAMPLE_FIELD, number>>>,
  viewId = 7,
  version = PENCIL_SAMPLE_FORMAT_VERSION
): ArrayBuffer => {
  const values = new Float64Array(
    PENCIL_SAMPLE_HEADER_LENGTH + records.length * PENCIL_SAMPLE_STRIDE
  )
  values.set([version, PENCIL_SAMPLE_STRIDE, records.length, viewId])
  records.forEach((record, index) => {
    const offset = PENCIL_SAMPLE_HEADER_LENGTH + index * PENCIL_SAMPLE_STRIDE
    for (const [key, value] of Object.entries(record)) {
      values[
        offset + PENCIL_SAMPLE_FIELD[key as keyof typeof PENCIL_SAMPLE_FIELD]
      ] = value as number
    }
  })
  return values.buffer
}

describe('decodePencilSamples', () => {
  it('reads the header and every field without copying', () => {
    const buffer = encode([
      {
        kind: 0,
        phase: 0,
        timestamp: 12.5,
        x: 10,
        y: 20,
        preciseX: 10.25,
        preciseY: 20.5,
        force: 2,
        maximumPossibleForce: 4,
        altitude: 1.2,
        azimuth: 0.3,
        azimuthUnitX: 0.6,
        azimuthUnitY: 0.8,
        rollAngle: 0.9,
        estimatedMask: 1 | 8 | (1 << 4),
        estimationUpdateIndex: 42,
      },
      { kind: 1, phase: 1, estimationUpdateIndex: -1 },
      { kind: 2, phase: 2 },
    ])
    const batch = decodePencilSamples(buffer)
    expect(batch.viewId).toBe(7)
    expect(batch.count).toBe(3)
    expect(batch.stride).toBe(PENCIL_SAMPLE_STRIDE)
    expect(batch.samples.buffer).toBe(buffer)

    const [first, second, third] = batch.toArray()
    expect(first).toEqual({
      kind: 'sample',
      phase: 'began',
      timestamp: 12.5,
      x: 10,
      y: 20,
      preciseX: 10.25,
      preciseY: 20.5,
      force: 2,
      maximumPossibleForce: 4,
      pressure: 0.5,
      altitude: 1.2,
      azimuth: 0.3,
      azimuthUnitVector: { x: 0.6, y: 0.8 },
      rollAngle: 0.9,
      estimatedProperties: ['force', 'location'],
      estimatedPropertiesExpectingUpdates: ['force'],
      estimationUpdateIndex: 42,
    })
    expect(second?.kind).toBe('predicted')
    expect(second?.phase).toBe('moved')
    expect(second?.pressure).toBe(0)
    expect(third?.kind).toBe('estimatedUpdate')
    expect(third?.phase).toBe('ended')
  })

  it('accepts an empty batch', () => {
    expect(decodePencilSamples(encode([])).toArray()).toEqual([])
  })

  it('rejects unknown versions and truncated buffers', () => {
    expect(() => decodePencilSamples(encode([{}], 1, 2))).toThrow(
      'Unsupported pencil sample format version 2'
    )
    const truncated = encode([{}, {}]).slice(0, (4 + 16 + 3) * 8)
    expect(() => decodePencilSamples(truncated)).toThrow('Malformed')
    expect(() => decodePencilSamples(new ArrayBuffer(8))).toThrow('header')
  })
})
