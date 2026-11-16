import { Platform } from 'react-native'

const loadModule = () => {
  let loaded: typeof import('../src/native') | undefined
  jest.isolateModules(() => {
    loaded = jest.requireActual('../src/native')
  })
  return loaded!
}

describe('unsupported platforms', () => {
  beforeEach(() => {
    Platform.OS = 'android'
  })

  it('reports PencilKit as unsupported', () => {
    const { MunimPencilkit } = loadModule()
    expect(MunimPencilkit.isPencilKitSupported()).toBe(false)
    const capabilities = JSON.parse(MunimPencilkit.getPencilKitCapabilities())
    expect(capabilities).toMatchObject({
      platform: 'android',
      supported: false,
      strokes: false,
    })
  })

  it('throws a typed error from synchronous calls', () => {
    const { MunimPencilkit, PencilKitUnsupportedError } = loadModule()
    let thrown: unknown
    try {
      MunimPencilkit.createPencilKitView()
    } catch (error) {
      thrown = error
    }
    expect(thrown).toBeInstanceOf(PencilKitUnsupportedError)
    expect(thrown).toMatchObject({
      code: 'ERR_PENCILKIT_UNSUPPORTED_PLATFORM',
      platform: 'android',
    })
  })

  it('rejects (never throws) from Promise-returning calls', async () => {
    const { MunimPencilkit, PencilKitUnsupportedError } = loadModule()
    const pending = MunimPencilkit.getPencilKitDrawingArchive(1)
    await expect(pending).rejects.toBeInstanceOf(PencilKitUnsupportedError)
    await expect(
      MunimPencilkit.playPencilKitFeedback(1, 'alignment', 0, 0)
    ).rejects.toMatchObject({ code: 'ERR_PENCILKIT_UNSUPPORTED_PLATFORM' })
  })

  it('is not mistaken for a thenable', async () => {
    const { MunimPencilkit } = loadModule()
    expect(
      (MunimPencilkit as unknown as { then?: unknown }).then
    ).toBeUndefined()
    await expect(Promise.resolve(MunimPencilkit)).resolves.toBe(MunimPencilkit)
  })

  it('still answers recognition info', async () => {
    const { MunimPencilkit } = loadModule()
    expect(
      JSON.parse(await MunimPencilkit.getPencilKitRecognitionInfo())
    ).toEqual({
      supported: false,
      supportedLanguages: [],
      recognitionVersion: null,
    })
  })
})
