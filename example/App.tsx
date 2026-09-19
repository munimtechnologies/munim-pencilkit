import React, { useCallback, useMemo, useRef, useState } from 'react';
import {
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';
import {
  PencilKitView,
  type PencilKitConfig,
  type PencilKitContentVersion,
  type PencilKitStroke,
  type PencilKitToolItem,
  type PencilKitDrawingChangeEvent,
  type PencilKitDrawingSnapshotEvent,
  type PencilKitExportResult,
  type PencilKitToolState,
  type PencilKitViewRef,
} from 'munim-pencilkit';

function Button({
  label,
  onPress,
}: {
  label: string;
  onPress: () => void;
}): React.JSX.Element {
  return (
    <Pressable
      style={({ pressed }) => [styles.button, pressed && styles.buttonPressed]}
      onPress={onPress}
    >
      <Text style={styles.buttonLabel}>{label}</Text>
    </Pressable>
  );
}

function App(): React.JSX.Element {
  const canvasRef = useRef<PencilKitViewRef>(null);
  const archiveRef = useRef<string | null>(null);
  const [status, setStatus] = useState('Draw below, then try the buttons.');
  const [lastChange, setLastChange] =
    useState<PencilKitDrawingChangeEvent | null>(null);
  const [lastSnapshotRevision, setLastSnapshotRevision] = useState<
    number | null
  >(null);
  const [toolPickerVisible, setToolPickerVisible] = useState(true);
  const [includeStrokes, setIncludeStrokes] = useState(false);
  const [customPicker, setCustomPicker] = useState(false);
  const [contentVersion, setContentVersion] =
    useState<PencilKitContentVersion>('latest');
  const [eventLog, setEventLog] = useState('No native events yet');
  const renderCount = useRef(0);

  const toolItems = useMemo<PencilKitToolItem[] | null>(
    () =>
      customPicker
        ? [
            { type: 'ink', inkType: 'pen', color: '#111827', width: 3, identifier: 'pen' },
            { type: 'ink', inkType: 'marker', color: '#FACC15', width: 20, identifier: 'highlighter' },
            { type: 'eraser', eraserType: 'vector' },
            { type: 'lasso' },
            { type: 'ruler' },
            {
              type: 'custom',
              identifier: 'stamp',
              name: 'Stamp',
              systemImage: 'star.fill',
              defaultColor: '#DC2626',
              controls: ['width'],
            },
          ]
        : null,
    [customPicker]
  );

  const config: PencilKitConfig = useMemo(
    () => ({
      allowsFingerDrawing: true,
      allowsPencilOnlyDrawing: false,
      isRulerActive: false,
      drawingPolicy: 'anyInput',
      enableApplePencilData: true,
      useCustomStylusView: false,
      showHoverPreview: true,
      // Emit onDrawingSnapshot 300ms after the drawing settles.
      snapshotDebounceMs: 300,
      includeStrokesInDrawing: includeStrokes,
      maximumSupportedContentVersion: contentVersion,
      toolItems,
      toolPickerAccessoryItem: customPicker
        ? { systemImage: 'ellipsis.circle', title: 'More', identifier: 'more' }
        : null,
    }),
    [contentVersion, customPicker, includeStrokes, toolItems]
  );

  const run = useCallback(async (action: () => Promise<string>) => {
    try {
      setStatus(await action());
    } catch (error) {
      setStatus(`Error: ${error instanceof Error ? error.message : error}`);
    }
  }, []);

  const describeExport = (result: PencilKitExportResult): string =>
    `${result.format} export: ${result.byteLength} bytes, ` +
    `${Math.round(result.width ?? 0)}x${Math.round(result.height ?? 0)}` +
    (result.fileUrl ? `, file: ${result.fileUrl}` : '');

  const describeTool = (tool: PencilKitToolState): string => {
    if (tool.type === 'ink') {
      return `ink(${tool.inkType}) width ${tool.width} color ${tool.color}`;
    }
    if (tool.type === 'eraser') {
      return `eraser(${tool.eraserType ?? 'bitmap'}) width ${tool.width ?? '-'}`;
    }
    return 'lasso';
  };

  const describeStroke = (stroke: PencilKitStroke): string =>
    `${stroke.ink?.inkType ?? stroke.tool.type} ${stroke.color}, ` +
    `${stroke.points.length} pts, width ${stroke.width.toFixed(1)}, ` +
    `v${stroke.requiredContentVersion ?? '?'}`;

  // A closed wobbly loop built from scratch, to exercise appendStrokes.
  const makeLoopStroke = (): PencilKitStroke => {
    const points = Array.from({ length: 48 }, (_, i) => {
      const angle = (i / 47) * Math.PI * 2;
      const radius = 60 + 8 * Math.sin(angle * 5);
      return {
        location: {
          x: 160 + radius * Math.cos(angle),
          y: 140 + radius * Math.sin(angle),
        },
        timeOffset: i * 0.01,
        timestamp: i * 0.01,
        size: { width: 6, height: 6 },
        opacity: 1,
        force: 1,
        pressure: 1,
        azimuth: 0,
        altitude: Math.PI / 2,
      };
    });
    return {
      points,
      ink: { inkType: 'monoline', color: '#7C3AED' },
      tool: { type: 'pen', width: 6, color: '#7C3AED' },
      color: '#7C3AED',
      width: 6,
    };
  };

  const nextContentVersion: Record<string, PencilKitContentVersion> = {
    latest: 1,
    1: 2,
    2: 'latest',
  };

  return (
    <View style={styles.container}>
      <ScrollView
        style={styles.controls}
        contentContainerStyle={styles.controlsContent}
      >
        <Text style={styles.title}>munim-pencilkit demo</Text>
        <Text style={styles.status}>{status}</Text>
        <Text style={styles.meta}>
          {lastChange
            ? `rev ${lastChange.revision} | undo ${lastChange.canUndo} | ` +
              `redo ${lastChange.canRedo} | bounds ` +
              `${Math.round(lastChange.bounds.width)}x` +
              `${Math.round(lastChange.bounds.height)}`
            : 'No drawing changes yet'}
          {lastSnapshotRevision != null
            ? ` | snapshot @ rev ${lastSnapshotRevision}`
            : ''}
        </Text>

        <View style={styles.row}>
          <Button
            label="Undo"
            onPress={() =>
              run(async () => `undo -> ${await canvasRef.current?.undo()}`)
            }
          />
          <Button
            label="Redo"
            onPress={() =>
              run(async () => `redo -> ${await canvasRef.current?.redo()}`)
            }
          />
          <Button
            label="Clear"
            onPress={() =>
              run(async () => {
                await canvasRef.current?.clearDrawing();
                return 'Cleared drawing';
              })
            }
          />
        </View>

        <View style={styles.row}>
          <Button
            label="Export PNG"
            onPress={() =>
              run(async () => {
                const result = await canvasRef.current?.exportDocument({
                  version: 1,
                  format: 'png',
                  output: 'fileUrl',
                  crop: 'drawingBounds',
                  scale: 2,
                  backgroundColor: '#FFFFFF',
                });
                return result ? describeExport(result) : 'No result';
              })
            }
          />
          <Button
            label="Export archive"
            onPress={() =>
              run(async () => {
                const result = await canvasRef.current?.exportDocument({
                  version: 1,
                  format: 'archive',
                  output: 'base64',
                });
                archiveRef.current = result?.dataBase64 ?? null;
                return result
                  ? `${describeExport(result)} (kept for re-import)`
                  : 'No result';
              })
            }
          />
          <Button
            label="Import archive"
            onPress={() =>
              run(async () => {
                const dataBase64 = archiveRef.current;
                if (dataBase64 == null) {
                  return 'Export an archive first';
                }
                await canvasRef.current?.importDocument({
                  version: 1,
                  format: 'archive',
                  input: 'base64',
                  dataBase64,
                });
                return 'Imported saved archive';
              })
            }
          />
        </View>

        <View style={styles.row}>
          <Button
            label="Red crayon"
            onPress={() =>
              run(async () => {
                await canvasRef.current?.setTool({
                  type: 'ink',
                  inkType: 'crayon',
                  color: '#DC2626',
                  width: 12,
                });
                return 'Tool set: red crayon';
              })
            }
          />
          <Button
            label="Vector eraser"
            onPress={() =>
              run(async () => {
                await canvasRef.current?.setTool({
                  type: 'eraser',
                  eraserType: 'vector',
                  width: 24,
                });
                return 'Tool set: vector eraser';
              })
            }
          />
          <Button
            label="Get tool"
            onPress={() =>
              run(async () => {
                const tool = await canvasRef.current?.getTool();
                return tool ? `Current tool: ${describeTool(tool)}` : 'No tool';
              })
            }
          />
          <Button
            label={toolPickerVisible ? 'Hide picker' : 'Show picker'}
            onPress={() =>
              run(async () => {
                const next = !toolPickerVisible;
                await canvasRef.current?.setToolPickerVisible(next);
                setToolPickerVisible(next);
                return next ? 'Tool picker shown' : 'Tool picker hidden';
              })
            }
          />
        </View>

        <Text style={styles.section}>Strokes & picker</Text>
        <View style={styles.row}>
          <Button
            label="Get strokes"
            onPress={() =>
              run(async () => {
                const strokes = (await canvasRef.current?.getStrokes()) ?? [];
                return strokes.length === 0
                  ? '0 strokes'
                  : `${strokes.length} strokes; last: ` +
                      describeStroke(strokes[strokes.length - 1]!);
              })
            }
          />
          <Button
            label="Round-trip strokes"
            onPress={() =>
              run(async () => {
                const canvas = canvasRef.current;
                const strokes = (await canvas?.getStrokes()) ?? [];
                await canvas?.setStrokes(strokes);
                return `Re-set ${strokes.length} strokes (undoable)`;
              })
            }
          />
          <Button
            label="Append loop"
            onPress={() =>
              run(async () => {
                await canvasRef.current?.appendStrokes([makeLoopStroke()]);
                return 'Appended a purple monoline loop';
              })
            }
          />
          <Button
            label="Delete last"
            onPress={() =>
              run(async () => {
                const canvas = canvasRef.current;
                const count = (await canvas?.getStrokes())?.length ?? 0;
                if (count === 0) return 'Nothing to delete';
                const removed = await canvas?.removeStrokes([count - 1]);
                return `Removed ${removed} stroke`;
              })
            }
          />
          <Button
            label="Move all +40"
            onPress={() =>
              run(async () => {
                const canvas = canvasRef.current;
                const count = (await canvas?.getStrokes())?.length ?? 0;
                const indices = Array.from({ length: count }, (_, i) => i);
                const changed = await canvas?.transformStrokes(indices, {
                  a: 1,
                  b: 0,
                  c: 0,
                  d: 1,
                  tx: 40,
                  ty: 40,
                });
                return `Moved ${changed} strokes`;
              })
            }
          />
        </View>
        <View style={styles.row}>
          <Button
            label={`Strokes in drawing: ${includeStrokes ? 'on' : 'off'}`}
            onPress={() => setIncludeStrokes((value) => !value)}
          />
          <Button
            label="getDrawing"
            onPress={() =>
              run(async () => {
                const drawing = await canvasRef.current?.getDrawing();
                return drawing
                  ? `drawing: ${drawing.strokes.length} strokes in payload, ` +
                      `archive ${drawing.dataBase64?.length ?? 0} b64 chars, ` +
                      `requires v${drawing.requiredContentVersion ?? '?'}`
                  : 'No drawing';
              })
            }
          />
          <Button
            label={`Max content: ${contentVersion}`}
            onPress={() =>
              setContentVersion(
                (value) => nextContentVersion[String(value)] ?? 'latest'
              )
            }
          />
          <Button
            label={customPicker ? 'System picker' : 'Custom picker (iOS 18)'}
            onPress={() => setCustomPicker((value) => !value)}
          />
          <Button
            label="Select highlighter"
            onPress={() =>
              run(async () => {
                await canvasRef.current?.setTool({
                  type: 'ink',
                  inkType: 'marker',
                  color: '#22C55E',
                  width: 24,
                  itemIdentifier: 'highlighter',
                });
                return 'Tool set: green marker (picker should follow)';
              })
            }
          />
          <Button
            label="Export PDF (dark)"
            onPress={() =>
              run(async () => {
                const result = await canvasRef.current?.exportDocument({
                  version: 1,
                  format: 'pdf',
                  output: 'fileUrl',
                  crop: 'canvas',
                  scale: 2,
                  appearance: 'dark',
                });
                return result ? describeExport(result) : 'No result';
              })
            }
          />
        </View>
        <TextInput
          style={styles.input}
          placeholder="Focus me: the canvas must not steal the keyboard"
        />
        <Text style={styles.meta}>{eventLog}</Text>
      </ScrollView>

      <PencilKitView
        ref={canvasRef}
        style={styles.canvas}
        config={config}
        enableApplePencilData
        onDrawingChange={(event: PencilKitDrawingChangeEvent) => {
          setLastChange(event);
        }}
        onDrawingSnapshot={(event: PencilKitDrawingSnapshotEvent) => {
          setLastSnapshotRevision(event.revision);
          console.log(
            'Drawing snapshot',
            event.revision,
            event.drawing.dataBase64?.length ?? 0,
            'bytes of base64'
          );
        }}
        onToolPickerChange={(event) => {
          console.log('Tool picker change', event.visible, event.selectedTool);
        }}
        onToolPickerItemChange={(event) => {
          setEventLog(
            `item: ${event.itemType} "${event.identifier}"` +
              (event.reselected ? ' (tapped again)' : '') +
              (event.color ? ` ${event.color} w${event.width}` : '')
          );
        }}
        onToolPickerAccessoryPress={(event) => {
          setEventLog(`accessory pressed: ${event.identifier}`);
        }}
        onDidFinishRendering={() => {
          renderCount.current += 1;
          console.log('Finished rendering', renderCount.current);
        }}
        onApplePencilHover={(event) => {
          if (event.phase !== 'changed') {
            setEventLog(`hover ${event.phase}`);
          }
        }}
        onHistoryChange={(event) => {
          console.log('History change', event.revision, event.canUndo);
        }}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    paddingTop: 60,
    backgroundColor: '#fff',
  },
  controls: {
    maxHeight: 420,
    flexGrow: 0,
  },
  controlsContent: {
    paddingHorizontal: 16,
    paddingBottom: 12,
  },
  title: {
    fontSize: 18,
    fontWeight: '600',
    color: '#1f2937',
    marginBottom: 8,
  },
  status: {
    fontSize: 13,
    color: '#374151',
    marginBottom: 4,
  },
  meta: {
    fontSize: 12,
    color: '#6b7280',
    marginBottom: 8,
  },
  section: {
    fontSize: 14,
    fontWeight: '600',
    color: '#1f2937',
    marginTop: 8,
    marginBottom: 6,
  },
  input: {
    borderWidth: 1,
    borderColor: '#d1d5db',
    borderRadius: 8,
    paddingHorizontal: 10,
    paddingVertical: 8,
    marginBottom: 6,
    fontSize: 13,
  },
  row: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginBottom: 4,
  },
  button: {
    backgroundColor: '#2563eb',
    borderRadius: 8,
    paddingHorizontal: 12,
    paddingVertical: 8,
    marginRight: 8,
    marginBottom: 8,
  },
  buttonPressed: {
    opacity: 0.7,
  },
  buttonLabel: {
    color: '#fff',
    fontSize: 13,
    fontWeight: '500',
  },
  canvas: {
    flex: 1,
    marginHorizontal: 16,
    marginBottom: 16,
    borderWidth: 1,
    borderColor: '#d1d5db',
    borderRadius: 12,
    overflow: 'hidden',
  },
});

export default App;
