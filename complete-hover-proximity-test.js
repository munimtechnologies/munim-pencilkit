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

const CompleteHoverProximityTest = () => {
  const pencilKitRef = useRef(null);
  const [rawDataEnabled, setRawDataEnabled] = useState(false);
  const [hoverEnabled, setHoverEnabled] = useState(false);
  const [gesturesEnabled, setGesturesEnabled] = useState(false);
  const [eventLog, setEventLog] = useState([]);
  const [touchCount, setTouchCount] = useState(0);
  const [hoverCount, setHoverCount] = useState(0);
  const [proximityCount, setProximityCount] = useState(0);
  const [airMovementCount, setAirMovementCount] = useState(0);
  const [isPencilNearby, setIsPencilNearby] = useState(false);

  const addToLog = (message, type = "info") => {
    const timestamp = new Date().toLocaleTimeString();
    const logEntry = {
      id: Date.now(),
      time: timestamp,
      message,
      type,
    };
    setEventLog((prev) => [logEntry, ...prev].slice(0, 100));
  };

  const toggleRawData = async () => {
    try {
      const newState = !rawDataEnabled;
      await pencilKitRef.current?.setEnableRawPencilData(newState);
      setRawDataEnabled(newState);
      addToLog(
        `Raw data ${newState ? "ENABLED" : "DISABLED"}`,
        newState ? "success" : "warning"
      );
    } catch (error) {
      addToLog(`ERROR: ${error.message}`, "error");
    }
  };

  const toggleHover = async () => {
    try {
      const newState = !hoverEnabled;
      await pencilKitRef.current?.setEnableHoverDetection(newState);
      setHoverEnabled(newState);
      addToLog(
        `Hover detection ${newState ? "ENABLED" : "DISABLED"}`,
        newState ? "success" : "warning"
      );
    } catch (error) {
      addToLog(`ERROR: ${error.message}`, "error");
    }
  };

  const toggleGestures = async () => {
    try {
      const newState = !gesturesEnabled;
      await pencilKitRef.current?.setEnablePencilGestures(newState);
      setGesturesEnabled(newState);
      addToLog(
        `Gestures ${newState ? "ENABLED" : "DISABLED"}`,
        newState ? "success" : "warning"
      );
    } catch (error) {
      addToLog(`ERROR: ${error.message}`, "error");
    }
  };

  const clearAll = async () => {
    try {
      await pencilKitRef.current?.clearDrawing();
      await pencilKitRef.current?.clearRawTouchSamples();
      await pencilKitRef.current?.clearHoverSamples();
      await pencilKitRef.current?.clearProximitySamples();
      setEventLog([]);
      setTouchCount(0);
      setHoverCount(0);
      setProximityCount(0);
      setAirMovementCount(0);
      addToLog("All data cleared", "info");
    } catch (error) {
      addToLog(`ERROR clearing: ${error.message}`, "error");
    }
  };

  const getData = async () => {
    try {
      const samples = await pencilKitRef.current?.getRawTouchSamples();
      const hoverSamples = await pencilKitRef.current?.getHoverSamples();
      const proximitySamples =
        await pencilKitRef.current?.getProximitySamples();
      const nearby = await pencilKitRef.current?.isPencilNearby();
      addToLog(
        `Data: Raw=${samples?.length || 0}, Hover=${hoverSamples?.length || 0}, Proximity=${proximitySamples?.length || 0}, Nearby=${nearby}`,
        "info"
      );
    } catch (error) {
      addToLog(`ERROR getting data: ${error.message}`, "error");
    }
  };

  // Check proximity status periodically
  useEffect(() => {
    const interval = setInterval(async () => {
      try {
        const nearby = await pencilKitRef.current?.isPencilNearby();
        setIsPencilNearby(nearby);
      } catch (error) {
        // Ignore errors
      }
    }, 1000);

    return () => clearInterval(interval);
  }, []);

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Complete Hover & Proximity Test</Text>
      <Text style={styles.subtitle}>
        Test Apple Pencil hover, proximity, and air movement detection
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

        <TouchableOpacity
          style={[
            styles.button,
            hoverEnabled ? styles.buttonActive : styles.buttonInactive,
          ]}
          onPress={toggleHover}
        >
          <Text style={styles.buttonText}>
            {hoverEnabled ? "Disable" : "Enable"} Hover
          </Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={[
            styles.button,
            gesturesEnabled ? styles.buttonActive : styles.buttonInactive,
          ]}
          onPress={toggleGestures}
        >
          <Text style={styles.buttonText}>
            {gesturesEnabled ? "Disable" : "Enable"} Gestures
          </Text>
        </TouchableOpacity>
      </View>

      <View style={styles.controls}>
        <TouchableOpacity style={styles.button} onPress={getData}>
          <Text style={styles.buttonText}>Get Data</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.button, styles.clearButton]}
          onPress={clearAll}
        >
          <Text style={styles.buttonText}>Clear All</Text>
        </TouchableOpacity>
      </View>

      {/* Status */}
      <View style={styles.statusContainer}>
        <Text style={styles.statusText}>
          Raw Data: {rawDataEnabled ? "✅ ENABLED" : "❌ DISABLED"}
        </Text>
        <Text style={styles.statusText}>
          Hover: {hoverEnabled ? "✅ ENABLED" : "❌ DISABLED"}
        </Text>
        <Text style={styles.statusText}>
          Gestures: {gesturesEnabled ? "✅ ENABLED" : "❌ DISABLED"}
        </Text>
        <Text style={styles.statusText}>
          Pencil Nearby: {isPencilNearby ? "✅ YES" : "❌ NO"}
        </Text>
        <Text style={styles.statusText}>Touch Events: {touchCount}</Text>
        <Text style={styles.statusText}>Hover Events: {hoverCount}</Text>
        <Text style={styles.statusText}>
          Proximity Events: {proximityCount}
        </Text>
        <Text style={styles.statusText}>Air Movement: {airMovementCount}</Text>
      </View>

      {/* Drawing Canvas */}
      <View style={styles.canvasContainer}>
        <MunimPencilkitView
          ref={pencilKitRef}
          style={styles.canvas}
          enableRawPencilData={rawDataEnabled}
          enableHoverDetection={hoverEnabled}
          enablePencilGestures={gesturesEnabled}
          drawingPolicy="pencilOnly"
          allowsFingerDrawing={false}
          // Raw touch events
          onRawTouchBegan={(event) => {
            setTouchCount((prev) => prev + 1);
            addToLog(
              `🎯 RAW TOUCH BEGAN: ${JSON.stringify(event.nativeEvent, null, 2)}`,
              "touch"
            );
          }}
          onRawTouchMoved={(event) => {
            addToLog(
              `🎯 RAW TOUCH MOVED: ${JSON.stringify(event.nativeEvent, null, 2)}`,
              "touch"
            );
          }}
          onRawTouchEnded={(event) => {
            addToLog(
              `🎯 RAW TOUCH ENDED: ${JSON.stringify(event.nativeEvent, null, 2)}`,
              "touch"
            );
          }}
          onRawTouchCancelled={(event) => {
            addToLog(
              `🎯 RAW TOUCH CANCELLED: ${JSON.stringify(event.nativeEvent, null, 2)}`,
              "touch"
            );
          }}
          onRawStrokeCompleted={(event) => {
            addToLog(
              `🎯 RAW STROKE COMPLETED: ${event.nativeEvent.sampleCount} samples`,
              "stroke"
            );
          }}
          // Hover events
          onRawTouchHovered={(event) => {
            setHoverCount((prev) => prev + 1);
            addToLog(
              `🔄 HOVER DETECTED: ${JSON.stringify(event.nativeEvent, null, 2)}`,
              "hover"
            );
          }}
          onRawTouchEstimatedPropertiesUpdate={(event) => {
            addToLog(
              `🔮 ESTIMATED PROPERTIES UPDATE: ${JSON.stringify(event.nativeEvent, null, 2)}`,
              "prediction"
            );
          }}
          // Proximity events
          onPencilProximityChanged={(event) => {
            setProximityCount((prev) => prev + 1);
            addToLog(
              `📍 PROXIMITY CHANGED: ${JSON.stringify(event.nativeEvent, null, 2)}`,
              "proximity"
            );
          }}
          onPencilAirMovement={(event) => {
            setAirMovementCount((prev) => prev + 1);
            addToLog(
              `🌬️ AIR MOVEMENT: ${JSON.stringify(event.nativeEvent, null, 2)}`,
              "air"
            );
          }}
          // Gesture events
          onPencilDoubleTap={(event) => {
            addToLog(
              `👆 DOUBLE TAP: ${JSON.stringify(event.nativeEvent, null, 2)}`,
              "gesture"
            );
          }}
          onPencilSqueeze={(event) => {
            addToLog(
              `🤏 SQUEEZE: ${JSON.stringify(event.nativeEvent, null, 2)}`,
              "gesture"
            );
          }}
          // Drawing events
          onDrawingChanged={(event) => {
            addToLog(
              `📝 Drawing changed: ${JSON.stringify(event.nativeEvent, null, 2)}`,
              "drawing"
            );
          }}
          onDrawingEnded={(event) => {
            addToLog(
              `📝 Drawing ended: ${JSON.stringify(event.nativeEvent, null, 2)}`,
              "drawing"
            );
          }}
        />
      </View>

      {/* Event Log */}
      <ScrollView style={styles.logContainer}>
        <Text style={styles.logTitle}>Complete Event Log</Text>
        {eventLog.length === 0 ? (
          <Text style={styles.emptyLog}>
            No events yet. Enable features and move Apple Pencil near the
            screen!
          </Text>
        ) : (
          eventLog.map((log) => (
            <View
              key={log.id}
              style={[
                styles.logItem,
                styles[
                  `logItem${log.type.charAt(0).toUpperCase() + log.type.slice(1)}`
                ],
              ]}
            >
              <Text style={styles.logTime}>{log.time}</Text>
              <Text style={styles.logMessage}>{log.message}</Text>
            </View>
          ))
        )}
      </ScrollView>

      {/* Instructions */}
      <View style={styles.instructionsContainer}>
        <Text style={styles.instructionTitle}>
          Complete Hover & Proximity Test
        </Text>
        <Text style={styles.instructionText}>
          • Enable hover detection and move Apple Pencil near the screen
        </Text>
        <Text style={styles.instructionText}>
          • Hover the pencil above the screen without touching
        </Text>
        <Text style={styles.instructionText}>
          • Move the pencil in the air to detect air movement
        </Text>
        <Text style={styles.instructionText}>
          • Touch the screen to see raw touch data
        </Text>
        <Text style={styles.instructionText}>
          • Watch for proximity changes and hover events
        </Text>
        <Text style={styles.instructionText}>
          • Check console for detailed debug information
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
    marginBottom: 10,
  },
  button: {
    backgroundColor: "#007AFF",
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 6,
    minWidth: 80,
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
    fontSize: 12,
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
    fontSize: 14,
    marginBottom: 3,
    color: "#333",
  },
  canvasContainer: {
    height: 250,
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
  logItem: {
    paddingVertical: 6,
    paddingHorizontal: 8,
    marginBottom: 4,
    borderRadius: 4,
    borderLeftWidth: 3,
  },
  logItemTouch: {
    backgroundColor: "#e3f2fd",
    borderLeftColor: "#2196f3",
  },
  logItemHover: {
    backgroundColor: "#f3e5f5",
    borderLeftColor: "#9c27b0",
  },
  logItemProximity: {
    backgroundColor: "#fff3e0",
    borderLeftColor: "#ff9800",
  },
  logItemAir: {
    backgroundColor: "#e8f5e8",
    borderLeftColor: "#4caf50",
  },
  logItemGesture: {
    backgroundColor: "#fff3e0",
    borderLeftColor: "#ff9800",
  },
  logItemStroke: {
    backgroundColor: "#e8f5e8",
    borderLeftColor: "#4caf50",
  },
  logItemDrawing: {
    backgroundColor: "#fce4ec",
    borderLeftColor: "#e91e63",
  },
  logItemPrediction: {
    backgroundColor: "#f1f8e9",
    borderLeftColor: "#8bc34a",
  },
  logItemSuccess: {
    backgroundColor: "#e8f5e8",
    borderLeftColor: "#4caf50",
  },
  logItemWarning: {
    backgroundColor: "#fff8e1",
    borderLeftColor: "#ffc107",
  },
  logItemError: {
    backgroundColor: "#ffebee",
    borderLeftColor: "#f44336",
  },
  logItemInfo: {
    backgroundColor: "#e3f2fd",
    borderLeftColor: "#2196f3",
  },
  logTime: {
    fontSize: 10,
    color: "#666",
    marginBottom: 2,
  },
  logMessage: {
    fontSize: 11,
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

export default CompleteHoverProximityTest;
