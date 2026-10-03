import { NativeModules } from 'react-native';
import {
  PencilKitUtils,
  type PencilKitSelectionChangeEvent,
  type PencilKitStroke,
  type PencilKitViewRef,
} from 'munim-pencilkit';

/**
 * Device self-test for the stroke, selection, erase and recognition APIs.
 * Writes `munim-pencilkit-selftest.json` to the app's Documents directory
 * (read it back with `xcrun devicectl device copy from --domain-type
 * appDataContainer`). Launch the app with the `-selftest` argument to run it
 * automatically, or tap "Run self-test".
 */

interface SelfTestWriter {
  writeResult(json: string): Promise<string>;
  isAutoRun(): Promise<boolean>;
}

const writer: SelfTestWriter | undefined = NativeModules.MunimSelfTest;

export const selfTestAutoRun = async (): Promise<boolean> =>
  (await writer?.isAutoRun()) ?? false;

export interface SelfTestCheck {
  name: string;
  pass: boolean;
  detail: string;
}

export interface SelfTestResult {
  package: string;
  osVersion?: string;
  startedAt: string;
  finishedAt: string;
  passed: number;
  failed: number;
  checks: SelfTestCheck[];
  outputPath?: string;
}

const hex = (length: number): string =>
  Array.from({ length }, () =>
    Math.floor(Math.random() * 16)
      .toString(16)
      .toUpperCase()
  ).join('');

/** An uppercase v4 UUID, the format `PKStroke.id` reports. */
export const makeUUID = (): string =>
  `${hex(8)}-${hex(4)}-4${hex(3)}-${'89AB'[Math.floor(Math.random() * 4)]}${hex(
    3
  )}-${hex(12)}`;

type Point = { x: number; y: number };

/** A pen stroke through `path`, densely resampled like real pencil input. */
export const makeStroke = (
  path: Point[],
  options: { id?: string; color?: string; width?: number } = {}
): PencilKitStroke => {
  const color = options.color ?? '#111827';
  const width = options.width ?? 5;
  const samples: Point[] = [];
  for (let i = 0; i < path.length - 1; i += 1) {
    const a = path[i]!;
    const b = path[i + 1]!;
    const steps = Math.max(2, Math.ceil(Math.hypot(b.x - a.x, b.y - a.y) / 4));
    for (let s = 0; s < steps; s += 1) {
      const t = s / steps;
      samples.push({ x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t });
    }
  }
  samples.push(path[path.length - 1]!);
  return {
    id: options.id,
    points: samples.map((location, index) => ({
      location,
      timeOffset: index / 120,
      timestamp: index / 120,
      size: { width, height: width },
      opacity: 1,
      force: 1,
      pressure: 1,
      azimuth: 0,
      altitude: Math.PI / 2,
    })),
    ink: { inkType: 'pen', color },
    tool: { type: 'pen', width, color },
    color,
    width,
  };
};

/** "HI" written as five strokes, offset by (x, y), letters 80 pt tall. */
const handwrittenHI = (x: number, y: number): PencilKitStroke[] => [
  makeStroke([
    { x, y },
    { x: x + 2, y: y + 40 },
    { x: x + 1, y: y + 80 },
  ]),
  makeStroke([
    { x: x + 50, y },
    { x: x + 49, y: y + 40 },
    { x: x + 51, y: y + 80 },
  ]),
  makeStroke([
    { x: x + 1, y: y + 41 },
    { x: x + 25, y: y + 39 },
    { x: x + 50, y: y + 40 },
  ]),
  makeStroke([
    { x: x + 85, y: y + 1 },
    { x: x + 86, y: y + 40 },
    { x: x + 85, y: y + 80 },
  ]),
];

const sameIds = (a: string[], b: string[]): boolean =>
  a.length === b.length &&
  [...a].sort().join() === [...b].sort().join();

const delay = (ms: number) =>
  new Promise<void>((resolve) => setTimeout(() => resolve(), ms));

export async function runSelfTest(
  canvas: PencilKitViewRef,
  viewId: number,
  selectionEvents: PencilKitSelectionChangeEvent[]
): Promise<SelfTestResult> {
  const startedAt = new Date().toISOString();
  const checks: SelfTestCheck[] = [];
  const check = async (
    name: string,
    body: () => Promise<string | { pass: boolean; detail: string }>
  ) => {
    try {
      const outcome = await body();
      checks.push(
        typeof outcome === 'string'
          ? { name, pass: true, detail: outcome }
          : { name, ...outcome }
      );
    } catch (error) {
      checks.push({
        name,
        pass: false,
        detail: `threw: ${error instanceof Error ? error.message : String(error)}`,
      });
    }
  };
  const expect = (pass: boolean, detail: string) => ({ pass, detail });

  const capabilities = PencilKitUtils.getCapabilities();
  const features = capabilities.features;

  await check('capabilities report the iOS 27 feature set', async () =>
    expect(
      features != null &&
        features.strokeIds &&
        features.selection &&
        features.erasePath &&
        features.bezierPaths &&
        features.handwritingRecognition &&
        features.toolPickerHDRColors &&
        capabilities.contentVersion?.maximum === 5,
      JSON.stringify({ features, contentVersion: capabilities.contentVersion })
    )
  );

  // Stroke ids: setStrokes keeps caller ids, getStrokes returns them.
  const ids = [makeUUID(), makeUUID(), makeUUID()];
  const baseStrokes = [
    makeStroke(
      [
        { x: 40, y: 60 },
        { x: 300, y: 60 },
      ],
      { id: ids[0] }
    ),
    makeStroke(
      [
        { x: 40, y: 120 },
        { x: 300, y: 140 },
      ],
      { id: ids[1], color: '#DC2626' }
    ),
    makeStroke(
      [
        { x: 40, y: 200 },
        { x: 120, y: 260 },
        { x: 200, y: 200 },
      ],
      { id: ids[2], color: '#2563EB' }
    ),
  ];

  await check('setStrokes/getStrokes keep stroke ids', async () => {
    await canvas.setStrokes(baseStrokes);
    const strokes = await canvas.getStrokes();
    const got = strokes.map((stroke) => stroke.id ?? '');
    return expect(
      strokes.length === 3 && got.join() === ids.join(),
      `sent ${ids.join()} got ${got.join()}`
    );
  });

  await check('strokes report pathId and lateralJitter', async () => {
    const strokes = await canvas.getStrokes();
    const first = strokes[0];
    return expect(
      strokes.every((stroke) => typeof stroke.pathId === 'string') &&
        typeof first?.points[0]?.lateralJitter === 'number',
      `pathId ${first?.pathId}, lateralJitter ${first?.points[0]?.lateralJitter}`
    );
  });

  await check('appendStrokes keeps new ids, re-ids duplicates', async () => {
    const freshId = makeUUID();
    await canvas.appendStrokes([
      makeStroke(
        [
          { x: 320, y: 60 },
          { x: 360, y: 90 },
        ],
        { id: freshId }
      ),
      makeStroke(
        [
          { x: 320, y: 120 },
          { x: 360, y: 150 },
        ],
        { id: ids[0] }
      ),
    ]);
    const got = (await canvas.getStrokes()).map((stroke) => stroke.id ?? '');
    const duplicateId = got[4];
    const unique = new Set(got).size === got.length;
    await canvas.undo();
    const afterUndo = (await canvas.getStrokes()).map((s) => s.id ?? '');
    return expect(
      got.length === 5 &&
        got.slice(0, 3).join() === ids.join() &&
        got[3] === freshId &&
        duplicateId !== ids[0] &&
        unique &&
        afterUndo.join() === ids.join(),
      `after append ${got.join()}; after undo ${afterUndo.join()}`
    );
  });

  await check('getDrawing/setDrawing round-trip keeps ids (archive)', async () => {
    const drawing = await canvas.getDrawing({ includeStrokes: true });
    const payloadIds = drawing.strokes.map((stroke) => stroke.id ?? '');
    await canvas.clearDrawing();
    await canvas.setDrawing(drawing);
    const got = (await canvas.getStrokes()).map((stroke) => stroke.id ?? '');
    return expect(
      payloadIds.join() === ids.join() && got.join() === ids.join(),
      `payload ${payloadIds.join()}, restored ${got.join()}`
    );
  });

  await check('setDrawing from strokes only keeps ids', async () => {
    const drawing = await canvas.getDrawing({ includeStrokes: true });
    await canvas.clearDrawing();
    await canvas.setDrawing({ ...drawing, dataBase64: undefined });
    const got = (await canvas.getStrokes()).map((stroke) => stroke.id ?? '');
    return expect(got.join() === ids.join(), `restored ${got.join()}`);
  });

  await check('Bezier paths for every stroke', async () => {
    const strokes = await canvas.getStrokes({ includeBezierPaths: true });
    const paths = strokes.map((stroke) => stroke.bezierPath ?? '');
    return expect(
      paths.length === 3 && paths.every((path) => /^M [-\d.e]+ [-\d.e]+/.test(path)),
      paths.map((path) => path.slice(0, 40)).join(' | ')
    );
  });

  await check('setSelection/getSelection round-trip', async () => {
    await canvas.setSelection([ids[0]!, ids[2]!]);
    await delay(150);
    const selected = await canvas.getSelection();
    await canvas.setSelection([]);
    await delay(150);
    const cleared = await canvas.getSelection();
    return expect(
      sameIds(selected, [ids[0]!, ids[2]!]) && cleared.length === 0,
      `selected ${selected.join()}, after clear ${cleared.length}`
    );
  });

  await check('setSelection ignores unknown ids', async () => {
    await canvas.setSelection([makeUUID(), ids[1]!]);
    await delay(100);
    const selected = await canvas.getSelection();
    await canvas.setSelection([]);
    return expect(
      sameIds(selected, [ids[1]!]) || selected.includes(ids[1]!),
      `selected ${selected.join()}`
    );
  });

  // Informational: whether PencilKit fires the delegate for programmatic changes.
  await check('selection change events (informational)', async () => {
    await delay(200);
    return `${selectionEvents.length} event(s): ${selectionEvents
      .map((event) => event.strokeIds.length)
      .join(',')}`;
  });

  await check('setSelection rejects invalid ids', async () => {
    try {
      await canvas.setSelection(['not-a-uuid']);
      return expect(false, 'resolved');
    } catch (error) {
      return expect(true, error instanceof Error ? error.message : String(error));
    }
  });

  await check('erasePath splits a stroke and is undoable', async () => {
    const before = await canvas.getStrokes();
    // A vertical swipe through the middle of the first horizontal line.
    const result = await canvas.erasePath({
      points: [
        { x: 170, y: 30 },
        { x: 170, y: 60 },
        { x: 170, y: 90 },
      ],
      width: 24,
    });
    const after = await canvas.getStrokes();
    const undone = await canvas.undo();
    const restored = await canvas.getStrokes();
    return expect(
      result.changed &&
        result.strokeCountBefore === before.length &&
        result.strokeCountAfter === after.length &&
        after.length > before.length &&
        undone &&
        restored.length === before.length,
      `${JSON.stringify(result)}; after ${after.length}, undo -> ${restored.length}`
    );
  });

  await check('erasePath away from ink changes nothing', async () => {
    const result = await canvas.erasePath({
      points: [
        { x: 600, y: 600 },
        { x: 620, y: 620 },
      ],
    });
    return expect(!result.changed && result.strokeCountAfter === 3, JSON.stringify(result));
  });

  await check('erasePath rejects an empty path', async () => {
    try {
      await canvas.erasePath({ points: [] });
      return expect(false, 'resolved');
    } catch (error) {
      return expect(true, error instanceof Error ? error.message : String(error));
    }
  });

  await check('recognition info lists languages', async () => {
    const info = await PencilKitUtils.getRecognitionInfo();
    return expect(
      info.supported &&
        info.supportedLanguages.length > 0 &&
        typeof info.recognitionVersion === 'number',
      `${info.supportedLanguages.length} languages (${info.supportedLanguages
        .slice(0, 8)
        .join(',')}), version ${info.recognitionVersion}`
    );
  });

  const handwriting = handwrittenHI(60, 320);
  await check('recognizeText on handwriting-like strokes', async () => {
    await canvas.setStrokes(handwriting);
    const result = await canvas.recognizeText({ includeIndexableContent: true });
    return expect(
      (result.text === null || typeof result.text === 'string') &&
        Array.isArray(result.languages) &&
        typeof result.recognitionVersion === 'number',
      JSON.stringify(result)
    );
  });

  await check('recognizeText for selected stroke ids + languages', async () => {
    const strokes = await canvas.getStrokes();
    const subset = strokes.slice(0, 3).map((stroke) => stroke.id!);
    const result = await canvas.recognizeText({
      strokeIds: subset,
      preferredLanguages: ['en'],
    });
    return expect(
      result.text === null || typeof result.text === 'string',
      JSON.stringify(result)
    );
  });

  await check('searchText resolves', async () => {
    const results = await canvas.searchText('HI', { fullWordsOnly: false });
    return expect(
      Array.isArray(results) &&
        results.every(
          (match) =>
            Array.isArray(match.strokeIds) && typeof match.bounds.width === 'number'
        ),
      JSON.stringify(results)
    );
  });

  await check('existing stroke APIs still work', async () => {
    await canvas.setStrokes(baseStrokes);
    const removed = await canvas.removeStrokes([1]);
    const changed = await canvas.transformStrokes([0], {
      a: 1,
      b: 0,
      c: 0,
      d: 1,
      tx: 10,
      ty: 0,
    });
    const strokes = await canvas.getStrokes();
    const png = await canvas.exportDocument({ version: 1, format: 'png' });
    return expect(
      removed === 1 &&
        changed === 1 &&
        strokes.length === 2 &&
        strokes[0]?.id === ids[0] &&
        png.byteLength > 0,
      `removed ${removed}, transformed ${changed}, ids ${strokes
        .map((s) => s.id)
        .join()}, png ${png.byteLength} B`
    );
  });

  await check('HDR tool picker config is accepted', async () => {
    PencilKitUtils.setConfig(viewId, {
      allowsFingerDrawing: true,
      allowsPencilOnlyDrawing: false,
      isRulerActive: false,
      drawingPolicy: 'anyInput',
      toolPickerColorMaximumLinearExposure: 4,
    });
    PencilKitUtils.setConfig(viewId, {
      allowsFingerDrawing: true,
      allowsPencilOnlyDrawing: false,
      isRulerActive: false,
      drawingPolicy: 'anyInput',
      toolPickerColorMaximumLinearExposure: null,
    });
    return 'set 4, then reset';
  });

  const passed = checks.filter((entry) => entry.pass).length;
  const result: SelfTestResult = {
    package: 'munim-pencilkit',
    osVersion: capabilities.osVersion,
    startedAt,
    finishedAt: new Date().toISOString(),
    passed,
    failed: checks.length - passed,
    checks,
  };
  if (writer) {
    result.outputPath = await writer.writeResult(JSON.stringify(result, null, 2));
  }
  return result;
}
