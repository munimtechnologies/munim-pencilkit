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

const ApplePencilGesturesExample = () => {
  const pencilKitRef = useRef(null);
  const [gesturesEnabled, setGesturesEnabled] = useState(false);
  const [gesturesAvailable, setGesturesAvailable] = useState(false);
  const [gestureHistory, setGestureHistory] = useState([]);
  const [currentTool, setCurrentTool] = useState("pen");

  useEffect(() => {
    checkGesturesAvailability();
  }, []);

  const checkGesturesAvailability = async () => {
    try {
      const available = await pencilKitRef.current?.isPencilGesturesAvailable();
      setGesturesAvailable(available);

      if (available) {
        Alert.alert(
          "Apple Pencil Gestures Available",
          "Your device supports Apple Pencil double-tap and squeeze gestures!"
        );
      } else {
        Alert.alert(
          "Apple Pencil Gestures Not Available",
          "Apple Pencil gestures require iOS 12.1+ and compatible Apple Pencil."
        );
      }
    } catch (error) {
      console.error("Error checking gesture availability:", error);
    }
  };

  const toggleGestures = async () => {
    try {
      await pencilKitRef.current?.setEnablePencilGestures(!gesturesEnabled);
      setGesturesEnabled(!gesturesEnabled);

      if (!gesturesEnabled) {
        Alert.alert(
          "Gestures Enabled",
          "Apple Pencil gestures are now active!"
        );
      } else {
        Alert.alert(
          "Gestures Disabled",
          "Apple Pencil gestures are now disabled."
        );
      }
    } catch (error) {
      Alert.alert("Error", `Failed to toggle gestures: ${error.message}`);
    }
  };

  const addGestureToHistory = (gesture) => {
    const newGesture = {
      ...gesture,
      id: Date.now(),
      time: new Date().toLocaleTimeString(),
    };
    setGestureHistory((prev) => [newGesture, ...prev].slice(0, 10)); // Keep last 10
  };

  const handlePencilDoubleTap = (event) => {
    console.log("Apple Pencil Double Tap:", event.nativeEvent);
    addGestureToHistory({
      type: "Double Tap",
      action: "Switch to Eraser",
      timestamp: event.nativeEvent.timestamp,
    });

    // Switch between pen and eraser on double tap
    const newTool = currentTool === "pen" ? "eraser" : "pen";
    setCurrentTool(newTool);
    pencilKitRef.current?.setTool(newTool, "#000000", 10);
  };

  const handlePencilSqueeze = (event) => {
    console.log("Apple Pencil Squeeze:", event.nativeEvent);
    addGestureToHistory({
      type: "Squeeze",
      action: "Show Color Palette",
      timestamp: event.nativeEvent.timestamp,
    });

    // Show color palette on squeeze
    Alert.alert(
      "Color Palette",
      "Squeeze gesture detected! Show color picker here."
    );
  };

  const clearHistory = () => {
    setGestureHistory([]);
  };

  const switchTool = async (tool) => {
    setCurrentTool(tool);
    await pencilKitRef.current?.setTool(tool, "#000000", 10);
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Apple Pencil Gestures Demo</Text>
      <Text style={styles.subtitle}>
        Test double-tap and squeeze gestures with Apple Pencil
      </Text>

      {/* Controls */}
      <View style={styles.controls}>
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

        <TouchableOpacity
          style={styles.button}
          onPress={checkGesturesAvailability}
        >
          <Text style={styles.buttonText}>Check Availability</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.button, styles.clearButton]}
          onPress={clearHistory}
        >
          <Text style={styles.buttonText}>Clear History</Text>
        </TouchableOpacity>
      </View>

      {/* Status */}
      <View style={styles.statusContainer}>
        <Text style={styles.statusText}>
          Gestures Available: {gesturesAvailable ? "✅ Yes" : "❌ No"}
        </Text>
        <Text style={styles.statusText}>
          Gestures Enabled: {gesturesEnabled ? "✅ Yes" : "❌ No"}
        </Text>
        <Text style={styles.statusText}>Current Tool: {currentTool}</Text>
      </View>

      {/* Drawing Canvas */}
      <View style={styles.canvasContainer}>
        <MunimPencilkitView
          ref={pencilKitRef}
          style={styles.canvas}
          enablePencilGestures={gesturesEnabled}
          toolType={currentTool}
          onPencilDoubleTap={handlePencilDoubleTap}
          onPencilSqueeze={handlePencilSqueeze}
          onDrawingChanged={(event) => {
            console.log("Drawing changed:", event.nativeEvent);
          }}
        />
      </View>

      {/* Tool Selection */}
      <View style={styles.toolContainer}>
        <Text style={styles.sectionTitle}>Tools</Text>
        <View style={styles.toolButtons}>
          {["pen", "pencil", "marker", "eraser"].map((tool) => (
            <TouchableOpacity
              key={tool}
              style={[
                styles.toolButton,
                currentTool === tool && styles.toolButtonActive,
              ]}
              onPress={() => switchTool(tool)}
            >
              <Text style={styles.toolButtonText}>{tool}</Text>
            </TouchableOpacity>
          ))}
        </View>
      </View>

      {/* Gesture History */}
      <ScrollView style={styles.historyContainer}>
        <Text style={styles.sectionTitle}>Gesture History</Text>
        {gestureHistory.length === 0 ? (
          <Text style={styles.emptyText}>
            No gestures detected yet. Try double-tapping or squeezing your Apple
            Pencil!
          </Text>
        ) : (
          gestureHistory.map((gesture) => (
            <View key={gesture.id} style={styles.gestureItem}>
              <Text style={styles.gestureType}>{gesture.type}</Text>
              <Text style={styles.gestureAction}>{gesture.action}</Text>
              <Text style={styles.gestureTime}>{gesture.time}</Text>
            </View>
          ))
        )}
      </ScrollView>

      {/* Instructions */}
      <View style={styles.instructionsContainer}>
        <Text style={styles.sectionTitle}>Instructions</Text>
        <Text style={styles.instructionText}>
          • <Text style={styles.bold}>Double-tap</Text> Apple Pencil to switch
          between pen and eraser
        </Text>
        <Text style={styles.instructionText}>
          • <Text style={styles.bold}>Squeeze</Text> Apple Pencil Pro to show
          color palette
        </Text>
        <Text style={styles.instructionText}>
          • Gestures work when drawing on the canvas
        </Text>
        <Text style={styles.instructionText}>
          • Requires iOS 12.1+ and compatible Apple Pencil
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
  toolContainer: {
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
  sectionTitle: {
    fontSize: 18,
    fontWeight: "bold",
    marginBottom: 12,
    color: "#333",
  },
  toolButtons: {
    flexDirection: "row",
    justifyContent: "space-around",
  },
  toolButton: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 6,
    backgroundColor: "#E0E0E0",
  },
  toolButtonActive: {
    backgroundColor: "#007AFF",
  },
  toolButtonText: {
    fontSize: 14,
    fontWeight: "bold",
    color: "#333",
  },
  historyContainer: {
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
  emptyText: {
    fontSize: 14,
    color: "#666",
    textAlign: "center",
    fontStyle: "italic",
  },
  gestureItem: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    paddingVertical: 8,
    borderBottomWidth: 1,
    borderBottomColor: "#E0E0E0",
  },
  gestureType: {
    fontSize: 16,
    fontWeight: "bold",
    color: "#007AFF",
    flex: 1,
  },
  gestureAction: {
    fontSize: 14,
    color: "#333",
    flex: 2,
    marginLeft: 10,
  },
  gestureTime: {
    fontSize: 12,
    color: "#666",
    flex: 1,
    textAlign: "right",
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
  instructionText: {
    fontSize: 14,
    marginBottom: 8,
    color: "#856404",
  },
  bold: {
    fontWeight: "bold",
  },
});

export default ApplePencilGesturesExample;
