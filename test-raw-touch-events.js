import React, { useRef, useState, useEffect } from "react";
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Alert,
} from "react-native";
import MunimPencilkitView from "./src/MunimPencilkitView";

const TestRawTouchEvents = () => {
  const pencilKitRef = useRef(null);
  const [rawDataEnabled, setRawDataEnabled] = useState(false);
  const [eventLog, setEventLog] = useState([]);
  const [touchCount, setTouchCount] = useState(0);

  const addToLog = (message) => {
    const timestamp = new Date().toLocaleTimeString();
    setEventLog((prev) => [`${timestamp}: ${message}`, ...prev].slice(0, 20));
  };

  const toggleRawData = async () => {
    try {
      const newState = !rawDataEnabled;
      await pencilKitRef.current?.setEnableRawPencilData(newState);
      setRawDataEnabled(newState);
      addToLog(`Raw data ${newState ? "ENABLED" : "DISABLED"}`);
    } catch (error) {
      addToLog(`ERROR: ${error.message}`);
    }
  };

  const clearLog = () => {
    setEventLog([]);
    setTouchCount(0);
  };

  const clearDrawing = async () => {
    try {
      await pencilKitRef.current?.clearDrawing();
      addToLog("Drawing cleared");
    } catch (error) {
      addToLog(`ERROR clearing: ${error.message}`);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Raw Touch Events Test</Text>
      <Text style={styles.subtitle}>
        Test if raw Apple Pencil touch events are working
      </Text>

      {/* Controls */}
      <View style={styles.controls}>
        <TouchableOpacity
          style={[
            styles.button,
            rawDataEnabled ? styles.buttonActive : styles.buttonInactive,
          ]}
          onPress={toggleRawData}
        >
          <Text style={styles.buttonText}>
            {rawDataEnabled ? "Disable" : "Enable"} Raw Data
          </Text>
        </TouchableOpacity>

        <TouchableOpacity style={styles.button} onPress={clearLog}>
          <Text style={styles.buttonText}>Clear Log</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.button, styles.clearButton]}
          onPress={clearDrawing}
        >
          <Text style={styles.buttonText}>Clear Drawing</Text>
        </TouchableOpacity>
      </View>

      {/* Status */}
      <View style={styles.statusContainer}>
        <Text style={styles.statusText}>
          Raw Data: {rawDataEnabled ? "✅ ENABLED" : "❌ DISABLED"}
        </Text>
        <Text style={styles.statusText}>Touch Events: {touchCount}</Text>
      </View>

      {/* Drawing Canvas */}
      <View style={styles.canvasContainer}>
        <MunimPencilkitView
          ref={pencilKitRef}
          style={styles.canvas}
          enableRawPencilData={rawDataEnabled}
          drawingPolicy="pencilOnly"
          allowsFingerDrawing={false}
          onRawTouchBegan={(event) => {
            setTouchCount((prev) => prev + 1);
            addToLog(
              `🎯 RAW TOUCH BEGAN: ${JSON.stringify(event.nativeEvent)}`
            );
          }}
          onRawTouchMoved={(event) => {
            addToLog(
              `🎯 RAW TOUCH MOVED: ${JSON.stringify(event.nativeEvent)}`
            );
          }}
          onRawTouchEnded={(event) => {
            addToLog(
              `🎯 RAW TOUCH ENDED: ${JSON.stringify(event.nativeEvent)}`
            );
          }}
          onRawTouchCancelled={(event) => {
            addToLog(
              `🎯 RAW TOUCH CANCELLED: ${JSON.stringify(event.nativeEvent)}`
            );
          }}
          onRawStrokeCompleted={(event) => {
            addToLog(
              `🎯 RAW STROKE COMPLETED: ${event.nativeEvent.sampleCount} samples`
            );
          }}
          onDrawingChanged={(event) => {
            addToLog(
              `📝 Drawing changed: ${JSON.stringify(event.nativeEvent)}`
            );
          }}
          onDrawingEnded={(event) => {
            addToLog(`📝 Drawing ended: ${JSON.stringify(event.nativeEvent)}`);
          }}
        />
      </View>

      {/* Event Log */}
      <ScrollView style={styles.logContainer}>
        <Text style={styles.logTitle}>Event Log</Text>
        {eventLog.length === 0 ? (
          <Text style={styles.emptyLog}>
            No events yet. Enable raw data and draw with Apple Pencil!
          </Text>
        ) : (
          eventLog.map((log, index) => (
            <Text key={index} style={styles.logText}>
              {log}
            </Text>
          ))
        )}
      </ScrollView>

      {/* Instructions */}
      <View style={styles.instructionsContainer}>
        <Text style={styles.instructionTitle}>Instructions</Text>
        <Text style={styles.instructionText}>
          1. Enable raw data collection
        </Text>
        <Text style={styles.instructionText}>
          2. Draw with Apple Pencil on the canvas
        </Text>
        <Text style={styles.instructionText}>
          3. Watch for raw touch events in the log
        </Text>
        <Text style={styles.instructionText}>
          4. Check console for debug messages
        </Text>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#f5f5f5",
  },
  title: {
    fontSize: 24,
    fontWeight: "bold",
    textAlign: "center",
    marginTop: 50,
    marginBottom: 10,
    color: "#333",
  },
  subtitle: {
    fontSize: 16,
    textAlign: "center",
    marginBottom: 20,
    color: "#666",
    paddingHorizontal: 20,
  },
  controls: {
    flexDirection: "row",
    justifyContent: "space-around",
    paddingHorizontal: 20,
    marginBottom: 20,
  },
  button: {
    backgroundColor: "#007AFF",
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 8,
    minWidth: 100,
  },
  buttonActive: {
    backgroundColor: "#34C759",
  },
  buttonInactive: {
    backgroundColor: "#FF3B30",
  },
  clearButton: {
    backgroundColor: "#FF9500",
  },
  buttonText: {
    color: "white",
    fontWeight: "bold",
    textAlign: "center",
    fontSize: 14,
  },
  statusContainer: {
    backgroundColor: "white",
    marginHorizontal: 20,
    marginBottom: 20,
    padding: 15,
    borderRadius: 12,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  statusText: {
    fontSize: 16,
    marginBottom: 5,
    color: "#333",
  },
  canvasContainer: {
    height: 300,
    marginHorizontal: 20,
    marginBottom: 20,
    borderRadius: 12,
    overflow: "hidden",
    backgroundColor: "white",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  canvas: {
    flex: 1,
  },
  logContainer: {
    flex: 1,
    backgroundColor: "white",
    marginHorizontal: 20,
    marginBottom: 20,
    padding: 15,
    borderRadius: 12,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  logTitle: {
    fontSize: 18,
    fontWeight: "bold",
    marginBottom: 12,
    color: "#333",
  },
  emptyLog: {
    fontSize: 14,
    color: "#666",
    textAlign: "center",
    fontStyle: "italic",
  },
  logText: {
    fontSize: 12,
    marginBottom: 4,
    color: "#333",
    fontFamily: "monospace",
  },
  instructionsContainer: {
    backgroundColor: "#fff3cd",
    marginHorizontal: 20,
    marginBottom: 20,
    padding: 15,
    borderRadius: 12,
    borderLeftWidth: 4,
    borderLeftColor: "#ffc107",
  },
  instructionTitle: {
    fontSize: 16,
    fontWeight: "bold",
    marginBottom: 8,
    color: "#856404",
  },
  instructionText: {
    fontSize: 14,
    marginBottom: 4,
    color: "#856404",
  },
});

export default TestRawTouchEvents;
