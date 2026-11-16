import type { PencilKitStroke, PencilKitViewRef } from 'munim-pencilkit';

const now = (): number =>
  (globalThis as { performance?: { now(): number } }).performance?.now() ??
  Date.now();

/** A dense synthetic stroke (like real pencil input), `index` shifts it. */
const makeBenchStroke = (index: number): PencilKitStroke => {
  const points = Array.from({ length: 120 }, (_, i) => {
    const t = i / 119;
    return {
      location: {
        x: 20 + t * 260,
        y: 20 + (index % 40) * 8 + 10 * Math.sin(t * Math.PI * 6 + index),
      },
      timeOffset: i * 0.004,
      timestamp: i * 0.004,
      size: { width: 3, height: 3 },
      opacity: 1,
      force: 0.5 + 0.5 * Math.sin(t * Math.PI),
      pressure: 0.5 + 0.5 * Math.sin(t * Math.PI),
      azimuth: 0.5,
      altitude: 1.1,
    };
  });
  return {
    points,
    ink: { inkType: 'pen', color: '#1F2937' },
    tool: { type: 'pen', width: 3, color: '#1F2937' },
    color: '#1F2937',
    width: 3,
  };
};

export interface ArchiveBenchmark {
  strokes: number;
  runs: number;
  /** Mean ms per call, JS-measured (includes the native round trip). */
  getBase64Ms: number;
  getBinaryMs: number;
  setBase64Ms: number;
  setBinaryMs: number;
  base64Chars: number;
  binaryBytes: number;
}

/**
 * Replaces the drawing with `strokeCount` synthetic strokes, then times
 * getDrawing (JSON + base64) against getDrawingArchive (ArrayBuffer), and
 * setDrawing against setDrawingArchive. Restores the original drawing.
 */
export async function benchmarkArchive(
  canvas: PencilKitViewRef,
  strokeCount = 300,
  runs = 10,
): Promise<ArchiveBenchmark> {
  const original = await canvas.getDrawingArchive();
  try {
    await canvas.setStrokes(
      Array.from({ length: strokeCount }, (_, i) => makeBenchStroke(i)),
    );

    let start = now();
    let base64 = '';
    for (let i = 0; i < runs; i += 1) {
      base64 = (await canvas.getDrawing()).dataBase64 ?? '';
    }
    const getBase64Ms = (now() - start) / runs;

    start = now();
    let archive = new ArrayBuffer(0);
    for (let i = 0; i < runs; i += 1) {
      archive = await canvas.getDrawingArchive();
    }
    const getBinaryMs = (now() - start) / runs;

    start = now();
    for (let i = 0; i < runs; i += 1) {
      await canvas.setDrawing({
        strokes: [],
        bounds: { x: 0, y: 0, width: 0, height: 0 },
        dataBase64: base64,
      });
    }
    const setBase64Ms = (now() - start) / runs;

    start = now();
    for (let i = 0; i < runs; i += 1) {
      await canvas.setDrawingArchive(archive);
    }
    const setBinaryMs = (now() - start) / runs;

    return {
      strokes: strokeCount,
      runs,
      getBase64Ms,
      getBinaryMs,
      setBase64Ms,
      setBinaryMs,
      base64Chars: base64.length,
      binaryBytes: archive.byteLength,
    };
  } finally {
    await canvas.setDrawingArchive(original);
  }
}

export const describeArchiveBenchmark = (b: ArchiveBenchmark): string =>
  `${b.strokes} strokes x${b.runs}: get ${b.getBase64Ms.toFixed(1)}ms (base64) ` +
  `vs ${b.getBinaryMs.toFixed(1)}ms (binary); set ${b.setBase64Ms.toFixed(1)}ms ` +
  `vs ${b.setBinaryMs.toFixed(1)}ms; payload ${b.base64Chars} b64 chars vs ` +
  `${b.binaryBytes} bytes`;
