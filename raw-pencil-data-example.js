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

const RawPencilDataExample = () => {
  const pencilKitRef = useRef(null);
  const [rawDataEnabled, setRawDataEnabled] = useState(false);
  const [pencilKitStrokes, setPencilKitStrokes] = useState([]);
  const [rawTouchSamples, setRawTouchSamples] = useState([]);
  const [comparisonData, setComparisonData] = useState(null);

  // Enable/disable raw data collection
  const toggleRawData = async () => {
    try {
      await pencilKitRef.current?.setEnableRawPencilData(!rawDataEnabled);
      setRawDataEnabled(!rawDataEnabled);

      if (!rawDataEnabled) {
        // Clear previous data when enabling
        setRawTouchSamples([]);
        setPencilKitStrokes([]);
        setComparisonData(null);
      }
    } catch (error) {
      Alert.alert("Error", `Failed to toggle raw data: ${error.message}`);
    }
  };

  // Get PencilKit processed strokes
  const getPencilKitData = async () => {
    try {
      const strokes = await pencilKitRef.current?.getAllStrokes();
      setPencilKitStrokes(strokes || []);
      return strokes;
    } catch (error) {
      console.error("Error getting PencilKit data:", error);
      return [];
    }
  };

  // Get raw touch samples
  const getRawData = async () => {
    try {
      const samples = await pencilKitRef.current?.getRawTouchSamples();
      setRawTouchSamples(samples || []);
      return samples;
    } catch (error) {
      console.error("Error getting raw data:", error);
      return [];
    }
  };

  // Compare PencilKit vs Raw data
  const compareData = async () => {
    const pkStrokes = await getPencilKitData();
    const rawSamples = await getRawData();

    if (pkStrokes.length === 0 || rawSamples.length === 0) {
      Alert.alert("No Data", "Please draw something first to compare data.");
      return;
    }

    // Analyze PencilKit data
    const pkAnalysis = {
      strokeCount: pkStrokes.length,
      totalPoints: pkStrokes.reduce(
        (sum, stroke) => sum + (stroke.path?.points?.length || 0),
        0
      ),
      averageForce: 0,
      forceRange: { min: 1, max: 0 },
      hasSmoothing: true,
      dataType: "Processed (PencilKit)",
    };

    // Calculate force statistics for PencilKit
    let totalForce = 0;
    let forceCount = 0;
    pkStrokes.forEach((stroke) => {
      if (stroke.path?.points) {
        stroke.path.points.forEach((point) => {
          const force = point.force || 0;
          totalForce += force;
          forceCount++;
          pkAnalysis.forceRange.min = Math.min(
            pkAnalysis.forceRange.min,
            force
          );
          pkAnalysis.forceRange.max = Math.max(
            pkAnalysis.forceRange.max,
            force
          );
        });
      }
    });
    pkAnalysis.averageForce = forceCount > 0 ? totalForce / forceCount : 0;

    // Analyze Raw data
    const rawAnalysis = {
      sampleCount: rawSamples.length,
      totalPoints: rawSamples.length,
      averageForce: 0,
      forceRange: { min: 1, max: 0 },
      hasSmoothing: false,
      dataType: "Raw (UITouch)",
      uniquePhases: [...new Set(rawSamples.map((s) => s.phase))],
      hasEstimatedProperties: rawSamples.some(
        (s) => s.estimatedProperties?.length > 0
      ),
    };

    // Calculate force statistics for Raw data
    let rawTotalForce = 0;
    rawSamples.forEach((sample) => {
      const force = sample.force || 0;
      rawTotalForce += force;
      rawAnalysis.forceRange.min = Math.min(rawAnalysis.forceRange.min, force);
      rawAnalysis.forceRange.max = Math.max(rawAnalysis.forceRange.max, force);
    });
    rawAnalysis.averageForce =
      rawSamples.length > 0 ? rawTotalForce / rawSamples.length : 0;

    setComparisonData({
      pencilKit: pkAnalysis,
      raw: rawAnalysis,
      timestamp: new Date().toISOString(),
    });
  };

  // Clear all data
  const clearAll = async () => {
    try {
      await pencilKitRef.current?.clearDrawing();
      await pencilKitRef.current?.clearRawTouchSamples();
      setPencilKitStrokes([]);
      setRawTouchSamples([]);
      setComparisonData(null);
    } catch (error) {
      Alert.alert("Error", `Failed to clear data: ${error.message}`);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Apple Pencil Data Comparison</Text>
      <Text style={styles.subtitle}>
        Compare PencilKit processed data vs Raw UITouch data
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

        <TouchableOpacity style={styles.button} onPress={compareData}>
          <Text style={styles.buttonText}>Compare Data</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.button, styles.clearButton]}
          onPress={clearAll}
        >
          <Text style={styles.buttonText}>Clear All</Text>
        </TouchableOpacity>
      </View>

      {/* Drawing Canvas */}
      <View style={styles.canvasContainer}>
        <MunimPencilkitView
          ref={pencilKitRef}
          style={styles.canvas}
          enableRawPencilData={rawDataEnabled}
          onRawTouchBegan={(event) => {
            console.log("Raw Touch Began:", event.nativeEvent);
          }}
          onRawTouchMoved={(event) => {
            console.log("Raw Touch Moved:", event.nativeEvent);
          }}
          onRawTouchEnded={(event) => {
            console.log("Raw Touch Ended:", event.nativeEvent);
          }}
          onRawStrokeCompleted={(event) => {
            console.log("Raw Stroke Completed:", event.nativeEvent);
            // Update raw samples when stroke completes
            getRawData();
          }}
          onDrawingEnded={(event) => {
            console.log("PencilKit Drawing Ended:", event.nativeEvent);
            // Update PencilKit strokes when drawing ends
            getPencilKitData();
          }}
        />
      </View>

      {/* Data Display */}
      <ScrollView style={styles.dataContainer}>
        {comparisonData && (
          <View style={styles.comparisonContainer}>
            <Text style={styles.sectionTitle}>Data Comparison</Text>

            {/* PencilKit Data */}
            <View style={styles.dataSection}>
              <Text style={styles.dataTitle}>PencilKit (Processed)</Text>
              <Text style={styles.dataText}>
                Strokes: {comparisonData.pencilKit.strokeCount}
              </Text>
              <Text style={styles.dataText}>
                Points: {comparisonData.pencilKit.totalPoints}
              </Text>
              <Text style={styles.dataText}>
                Avg Force: {comparisonData.pencilKit.averageForce.toFixed(3)}
              </Text>
              <Text style={styles.dataText}>
                Force Range:{" "}
                {comparisonData.pencilKit.forceRange.min.toFixed(3)} -{" "}
                {comparisonData.pencilKit.forceRange.max.toFixed(3)}
              </Text>
              <Text style={styles.dataText}>
                Smoothed: {comparisonData.pencilKit.hasSmoothing ? "Yes" : "No"}
              </Text>
            </View>

            {/* Raw Data */}
            <View style={styles.dataSection}>
              <Text style={styles.dataTitle}>Raw UITouch</Text>
              <Text style={styles.dataText}>
                Samples: {comparisonData.raw.sampleCount}
              </Text>
              <Text style={styles.dataText}>
                Points: {comparisonData.raw.totalPoints}
              </Text>
              <Text style={styles.dataText}>
                Avg Force: {comparisonData.raw.averageForce.toFixed(3)}
              </Text>
              <Text style={styles.dataText}>
                Force Range: {comparisonData.raw.forceRange.min.toFixed(3)} -{" "}
                {comparisonData.raw.forceRange.max.toFixed(3)}
              </Text>
              <Text style={styles.dataText}>
                Smoothed: {comparisonData.raw.hasSmoothing ? "Yes" : "No"}
              </Text>
              <Text style={styles.dataText}>
                Phases: {comparisonData.raw.uniquePhases.join(", ")}
              </Text>
              <Text style={styles.dataText}>
                Has Predictions:{" "}
                {comparisonData.raw.hasEstimatedProperties ? "Yes" : "No"}
              </Text>
            </View>

            {/* Key Differences */}
            <View style={styles.differencesSection}>
              <Text style={styles.dataTitle}>Key Differences</Text>
              <Text style={styles.differenceText}>
                • PencilKit: {comparisonData.pencilKit.totalPoints} points
                (processed/smoothed)
              </Text>
              <Text style={styles.differenceText}>
                • Raw UITouch: {comparisonData.raw.totalPoints} samples
                (unprocessed)
              </Text>
              <Text style={styles.differenceText}>
                • Raw data includes touch phases:{" "}
                {comparisonData.raw.uniquePhases.join(", ")}
              </Text>
              <Text style={styles.differenceText}>
                • Raw data includes prediction properties
              </Text>
              <Text style={styles.differenceText}>
                • PencilKit applies Apple's smoothing algorithms
              </Text>
            </View>
          </View>
        )}

        {/* Current Data Counts */}
        <View style={styles.currentDataContainer}>
          <Text style={styles.sectionTitle}>Current Data</Text>
          <Text style={styles.dataText}>
            PencilKit Strokes: {pencilKitStrokes.length}
          </Text>
          <Text style={styles.dataText}>
            Raw Touch Samples: {rawTouchSamples.length}
          </Text>
          <Text style={styles.dataText}>
            Raw Data Collection: {rawDataEnabled ? "Enabled" : "Disabled"}
          </Text>
        </View>
      </ScrollView>
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
  dataContainer: {
    flex: 1,
    paddingHorizontal: 20,
  },
  comparisonContainer: {
    backgroundColor: "white",
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
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
  dataSection: {
    backgroundColor: "#f8f9fa",
    padding: 12,
    borderRadius: 8,
    marginBottom: 12,
  },
  dataTitle: {
    fontSize: 16,
    fontWeight: "bold",
    marginBottom: 8,
    color: "#333",
  },
  dataText: {
    fontSize: 14,
    marginBottom: 4,
    color: "#666",
  },
  differencesSection: {
    backgroundColor: "#fff3cd",
    padding: 12,
    borderRadius: 8,
    borderLeftWidth: 4,
    borderLeftColor: "#ffc107",
  },
  differenceText: {
    fontSize: 14,
    marginBottom: 4,
    color: "#856404",
  },
  currentDataContainer: {
    backgroundColor: "white",
    borderRadius: 12,
    padding: 16,
    marginBottom: 20,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
});

export default RawPencilDataExample;
