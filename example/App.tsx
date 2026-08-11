import React, { useCallback, useMemo, useRef, useState } from 'react';
import {
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import {
  PencilKitView,
  type PencilKitConfig,
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
    }),
    []
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
    maxHeight: 280,
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
