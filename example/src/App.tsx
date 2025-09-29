import { useState, useRef } from 'react';
import {
  Text,
  View,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Alert,
  SafeAreaView,
  StatusBar,
} from 'react-native';
import {
  PencilKitView,
  type ApplePencilData,
  type PencilKitDrawingData,
  type PencilKitConfig,
} from 'munim-pencilkit';

export default function App() {
  const [applePencilData, setApplePencilData] =
    useState<ApplePencilData | null>(null);
  const [isApplePencilCaptureActive, setIsApplePencilCaptureActive] =
    useState(false);
  const [canUndo, setCanUndo] = useState(false);
  const [canRedo, setCanRedo] = useState(false);
  const pencilKitRef = useRef<any>(null);

  const handleApplePencilData = (data: ApplePencilData) => {
    setApplePencilData(data);
    console.log('Apple Pencil Data:', data);
  };

  const handleDrawingChange = (drawing: PencilKitDrawingData) => {
    console.log('Drawing changed:', drawing);
    // Update undo/redo state
    if (pencilKitRef.current) {
      pencilKitRef.current.canUndo().then(setCanUndo);
      pencilKitRef.current.canRedo().then(setCanRedo);
    }
  };

  const handleViewReady = (viewId: number) => {
    console.log('PencilKit view ready with ID:', viewId);
  };

  const toggleApplePencilCapture = async () => {
    if (!pencilKitRef.current) return;

    try {
      if (isApplePencilCaptureActive) {
        await pencilKitRef.current.stopApplePencilCapture();
        setIsApplePencilCaptureActive(false);
      } else {
        await pencilKitRef.current.startApplePencilCapture();
        setIsApplePencilCaptureActive(true);
      }
    } catch (error) {
      console.error('Error toggling Apple Pencil capture:', error);
    }
  };

  const handleUndo = async () => {
    if (!pencilKitRef.current) return;
    try {
      await pencilKitRef.current.undo();
    } catch (error) {
      console.error('Error undoing:', error);
    }
  };

  const handleRedo = async () => {
    if (!pencilKitRef.current) return;
    try {
      await pencilKitRef.current.redo();
    } catch (error) {
      console.error('Error redoing:', error);
    }
  };

  const handleClear = async () => {
    if (!pencilKitRef.current) return;
    try {
      await pencilKitRef.current.clearDrawing();
    } catch (error) {
      console.error('Error clearing drawing:', error);
    }
  };

  const handleSaveDrawing = async () => {
    if (!pencilKitRef.current) return;
    try {
      const drawing = await pencilKitRef.current.getDrawing();
      console.log('Saved drawing:', drawing);
      Alert.alert('Drawing Saved', 'Drawing data has been logged to console');
    } catch (error) {
      console.error('Error saving drawing:', error);
    }
  };

  const pencilKitConfig: PencilKitConfig = {
    allowsFingerDrawing: true,
    allowsPencilOnlyDrawing: false,
    isRulerActive: false,
    drawingPolicy: 'default',
  };

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="dark-content" />

      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.title}>Munim PencilKit Demo</Text>
        <Text style={styles.subtitle}>
          Apple Pencil & PencilKit Integration
        </Text>
      </View>

      {/* Controls */}
      <View style={styles.controls}>
        <TouchableOpacity
          style={[
            styles.button,
            isApplePencilCaptureActive && styles.buttonActive,
          ]}
          onPress={toggleApplePencilCapture}
        >
          <Text style={styles.buttonText}>
            {isApplePencilCaptureActive ? 'Stop' : 'Start'} Apple Pencil Data
          </Text>
        </TouchableOpacity>

        <View style={styles.buttonRow}>
          <TouchableOpacity
            style={[
              styles.button,
              styles.smallButton,
              !canUndo && styles.buttonDisabled,
            ]}
            onPress={handleUndo}
            disabled={!canUndo}
          >
            <Text style={styles.buttonText}>Undo</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={[
              styles.button,
              styles.smallButton,
              !canRedo && styles.buttonDisabled,
            ]}
            onPress={handleRedo}
            disabled={!canRedo}
          >
            <Text style={styles.buttonText}>Redo</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={[styles.button, styles.smallButton]}
            onPress={handleClear}
          >
            <Text style={styles.buttonText}>Clear</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={[styles.button, styles.smallButton]}
            onPress={handleSaveDrawing}
          >
            <Text style={styles.buttonText}>Save</Text>
          </TouchableOpacity>
        </View>
      </View>

      {/* PencilKit Canvas */}
      <View style={styles.canvasContainer}>
        <PencilKitView
          ref={pencilKitRef}
          style={styles.canvas}
          config={pencilKitConfig}
          onApplePencilData={handleApplePencilData}
          onDrawingChange={handleDrawingChange}
          onViewReady={handleViewReady}
          enableApplePencilData={true}
          enableToolPicker={true}
        />
      </View>

      {/* Apple Pencil Data Display */}
      {applePencilData && (
        <ScrollView style={styles.dataContainer}>
          <Text style={styles.dataTitle}>Apple Pencil Data:</Text>
          <Text style={styles.dataText}>
            Pressure: {applePencilData.pressure.toFixed(3)}
          </Text>
          <Text style={styles.dataText}>
            Altitude: {applePencilData.altitude.toFixed(3)}
          </Text>
          <Text style={styles.dataText}>
            Azimuth: {applePencilData.azimuth.toFixed(3)}
          </Text>
          <Text style={styles.dataText}>
            Force: {applePencilData.force.toFixed(3)}
          </Text>
          <Text style={styles.dataText}>
            Location: ({applePencilData.location.x.toFixed(1)},{' '}
            {applePencilData.location.y.toFixed(1)})
          </Text>
          <Text style={styles.dataText}>Phase: {applePencilData.phase}</Text>
          <Text style={styles.dataText}>
            Is Apple Pencil: {applePencilData.isApplePencil ? 'Yes' : 'No'}
          </Text>
        </ScrollView>
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    padding: 20,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
    marginTop: 4,
  },
  controls: {
    padding: 16,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  button: {
    backgroundColor: '#007AFF',
    paddingVertical: 12,
    paddingHorizontal: 20,
    borderRadius: 8,
    marginVertical: 4,
  },
  buttonActive: {
    backgroundColor: '#FF3B30',
  },
  buttonDisabled: {
    backgroundColor: '#ccc',
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
    textAlign: 'center',
  },
  buttonRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 8,
  },
  smallButton: {
    flex: 1,
    marginHorizontal: 4,
    paddingVertical: 8,
  },
  canvasContainer: {
    flex: 1,
    margin: 16,
    backgroundColor: '#fff',
    borderRadius: 12,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  canvas: {
    flex: 1,
    borderRadius: 12,
  },
  dataContainer: {
    maxHeight: 200,
    backgroundColor: '#fff',
    margin: 16,
    padding: 16,
    borderRadius: 12,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  dataTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 8,
  },
  dataText: {
    fontSize: 14,
    color: '#666',
    marginVertical: 2,
  },
});
