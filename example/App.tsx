import { useEvent } from "expo";
import React, { useRef, useState, useCallback } from "react";
import MunimPencilkit, {
  MunimPencilkitView,
  MunimPencilkitViewRef,
  PKToolType,
  OnDrawingChangedEventPayload,
  OnToolChangedEventPayload,
} from "munim-pencilkit";
import {
  Alert,
  Button,
  SafeAreaView,
  ScrollView,
  Text,
  View,
  Switch,
  StyleSheet,
  TouchableOpacity,
  Share,
  Platform,
} from "react-native";

export default function App() {
  // Refs and state
  const pencilKitRef = useRef<MunimPencilkitViewRef>(null);
  const [showToolPicker, setShowToolPicker] = useState(true);
  const [allowsFingerDrawing, setAllowsFingerDrawing] = useState(true);
  const [isRulerActive, setIsRulerActive] = useState(false);
  const [currentTool, setCurrentTool] = useState<PKToolType>("pen");
  const [currentColor, setCurrentColor] = useState("#000000");
  const [currentWidth, setCurrentWidth] = useState(10);
  const [hasDrawingContent, setHasDrawingContent] = useState(false);
  const [strokeCount, setStrokeCount] = useState(0);

  // Ink behavior controls
  const [enableInkSmoothing, setEnableInkSmoothing] = useState(true);
  const [enableStrokeRefinement, setEnableStrokeRefinement] = useState(true);
  const [enableHandwritingRecognition, setEnableHandwritingRecognition] =
    useState(true);
  const [naturalDrawingMode, setNaturalDrawingMode] = useState(false);

  // Event handlers
  const handleDrawingChanged = useCallback(
    ({ nativeEvent }: { nativeEvent: OnDrawingChangedEventPayload }) => {
      setHasDrawingContent(nativeEvent.hasContent);
      setStrokeCount(nativeEvent.strokeCount);
    },
    []
  );

  const handleToolChanged = useCallback(
    ({ nativeEvent }: { nativeEvent: OnToolChangedEventPayload }) => {
      setCurrentTool(nativeEvent.toolType);
      setCurrentColor(nativeEvent.color || "#000000");
      setCurrentWidth(nativeEvent.width || 10);
    },
    []
  );

  // Drawing actions
  const clearDrawing = useCallback(async () => {
    try {
      await pencilKitRef.current?.clearDrawing();
      Alert.alert("Success", "Drawing cleared successfully!");
    } catch (error) {
      Alert.alert("Error", "Failed to clear drawing");
    }
  }, []);

  const undoDrawing = useCallback(async () => {
    try {
      await pencilKitRef.current?.undo();
    } catch (error) {
      console.log("Undo failed:", error);
    }
  }, []);

  const redoDrawing = useCallback(async () => {
    try {
      await pencilKitRef.current?.redo();
    } catch (error) {
      console.log("Redo failed:", error);
    }
  }, []);

  // Export functions
  const exportAsImage = useCallback(async () => {
    try {
      const imageBase64 = await pencilKitRef.current?.exportAsImage({
        scale: 2.0,
      });
      if (imageBase64) {
        if (Platform.OS === "ios") {
          await Share.share({
            url: `data:image/png;base64,${imageBase64}`,
            title: "My Drawing",
          });
        } else {
          Alert.alert("Success", "Drawing exported successfully!");
        }
      } else {
        Alert.alert("Error", "No drawing to export");
      }
    } catch (error) {
      Alert.alert("Error", "Failed to export drawing");
      console.log("Export error:", error);
    }
  }, []);

  const exportAsPDF = useCallback(async () => {
    try {
      const pdfData = await pencilKitRef.current?.exportAsPDF({ scale: 1.0 });
      if (pdfData) {
        Alert.alert("Success", "Drawing exported as PDF successfully!");
      } else {
        Alert.alert("Error", "No drawing to export");
      }
    } catch (error) {
      Alert.alert("Error", "Failed to export as PDF");
      console.log("PDF export error:", error);
    }
  }, []);

  // Tool selection
  const selectTool = useCallback(
    async (toolType: PKToolType, color?: string, width?: number) => {
      try {
        await pencilKitRef.current?.setTool(toolType, color, width);
        setCurrentTool(toolType);
        if (color) setCurrentColor(color);
        if (width) setCurrentWidth(width);
      } catch (error) {
        console.log("Tool selection error:", error);
      }
    },
    []
  );

  // Get available tools
  const availableTools = MunimPencilkit.getAvailableTools();
  const inkTypes = MunimPencilkit.getInkTypes();

  const colors = [
    "#000000",
    "#FF0000",
    "#00FF00",
    "#0000FF",
    "#FFFF00",
    "#FF00FF",
    "#00FFFF",
  ];
  const widths = [2, 5, 10, 15, 20, 30];

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView style={styles.scrollView}>
        <Text style={styles.header}>PencilKit Demo</Text>

        {/* Drawing Canvas */}
        <Group name="Drawing Canvas">
          <MunimPencilkitView
            ref={pencilKitRef}
            style={styles.canvasView}
            showToolPicker={showToolPicker}
            allowsFingerDrawing={allowsFingerDrawing}
            isRulerActive={isRulerActive}
            drawingPolicy="default"
            backgroundColor="#FFFFFF"
            toolType={currentTool}
            toolColor={currentColor}
            toolWidth={currentWidth}
            // Ink behavior controls
            enableInkSmoothing={enableInkSmoothing}
            enableStrokeRefinement={enableStrokeRefinement}
            enableHandwritingRecognition={enableHandwritingRecognition}
            naturalDrawingMode={naturalDrawingMode}
            onDrawingChanged={handleDrawingChanged}
            onToolChanged={handleToolChanged}
            onDrawingStarted={({ nativeEvent }) =>
              console.log("Drawing started")
            }
            onDrawingEnded={({ nativeEvent }) => console.log("Drawing ended")}
          />
        </Group>

        {/* Drawing Info */}
        <Group name="Drawing Info">
          <Text style={styles.infoText}>
            Has Content: {hasDrawingContent ? "Yes" : "No"}
          </Text>
          <Text style={styles.infoText}>Stroke Count: {strokeCount}</Text>
          <Text style={styles.infoText}>Current Tool: {currentTool}</Text>
          <Text style={styles.infoText}>Current Color: {currentColor}</Text>
          <Text style={styles.infoText}>Current Width: {currentWidth}</Text>
        </Group>

        {/* Canvas Settings */}
        <Group name="Canvas Settings">
          <View style={styles.settingRow}>
            <Text style={styles.settingLabel}>Show Tool Picker</Text>
            <Switch value={showToolPicker} onValueChange={setShowToolPicker} />
          </View>
          <View style={styles.settingRow}>
            <Text style={styles.settingLabel}>Allow Finger Drawing</Text>
            <Switch
              value={allowsFingerDrawing}
              onValueChange={setAllowsFingerDrawing}
            />
          </View>
          <View style={styles.settingRow}>
            <Text style={styles.settingLabel}>Show Ruler</Text>
            <Switch value={isRulerActive} onValueChange={setIsRulerActive} />
          </View>
        </Group>

        {/* Ink Behavior Controls */}
        <Group name="Ink Behavior Controls">
          <View style={styles.settingRow}>
            <Text style={styles.settingLabel}>Enable Ink Smoothing</Text>
            <Switch
              value={enableInkSmoothing}
              onValueChange={setEnableInkSmoothing}
              disabled={naturalDrawingMode}
            />
          </View>
          <View style={styles.settingRow}>
            <Text style={styles.settingLabel}>Enable Stroke Refinement</Text>
            <Switch
              value={enableStrokeRefinement}
              onValueChange={setEnableStrokeRefinement}
              disabled={naturalDrawingMode}
            />
          </View>
          <View style={styles.settingRow}>
            <Text style={styles.settingLabel}>Handwriting Recognition</Text>
            <Switch
              value={enableHandwritingRecognition}
              onValueChange={setEnableHandwritingRecognition}
              disabled={naturalDrawingMode}
            />
          </View>
          <View style={styles.settingRow}>
            <Text style={styles.settingLabel}>Natural Drawing Mode</Text>
            <Switch
              value={naturalDrawingMode}
              onValueChange={(value) => {
                setNaturalDrawingMode(value);
                if (value) {
                  // When natural drawing is enabled, disable other processing
                  setEnableInkSmoothing(false);
                  setEnableStrokeRefinement(false);
                  setEnableHandwritingRecognition(false);
                }
              }}
            />
          </View>
          <Text style={styles.helpText}>
            💡 Natural Drawing Mode disables all automatic processing for the
            most natural drawing experience
          </Text>
        </Group>

        {/* Drawing Tools */}
        <Group name="Drawing Tools">
          <ScrollView horizontal showsHorizontalScrollIndicator={false}>
            {Object.entries(availableTools).map(([key, tool]) => (
              <TouchableOpacity
                key={key}
                style={[
                  styles.toolButton,
                  currentTool === tool.type && styles.selectedToolButton,
                ]}
                onPress={() =>
                  selectTool(
                    tool.type as PKToolType,
                    currentColor,
                    currentWidth
                  )
                }
              >
                <Text
                  style={[
                    styles.toolButtonText,
                    currentTool === tool.type && styles.selectedToolButtonText,
                  ]}
                >
                  {tool.name}
                </Text>
              </TouchableOpacity>
            ))}
          </ScrollView>
        </Group>

        {/* Color Palette */}
        <Group name="Colors">
          <ScrollView horizontal showsHorizontalScrollIndicator={false}>
            {colors.map((color) => (
              <TouchableOpacity
                key={color}
                style={[
                  styles.colorButton,
                  { backgroundColor: color },
                  currentColor === color && styles.selectedColorButton,
                ]}
                onPress={() => selectTool(currentTool, color, currentWidth)}
              />
            ))}
          </ScrollView>
        </Group>

        {/* Brush Sizes */}
        <Group name="Brush Size">
          <ScrollView horizontal showsHorizontalScrollIndicator={false}>
            {widths.map((width) => (
              <TouchableOpacity
                key={width}
                style={[
                  styles.sizeButton,
                  currentWidth === width && styles.selectedSizeButton,
                ]}
                onPress={() => selectTool(currentTool, currentColor, width)}
              >
                <View
                  style={[
                    styles.sizeIndicator,
                    { width, height: width, backgroundColor: currentColor },
                  ]}
                />
                <Text style={styles.sizeButtonText}>{width}px</Text>
              </TouchableOpacity>
            ))}
          </ScrollView>
        </Group>

        {/* Drawing Actions */}
        <Group name="Drawing Actions">
          <View style={styles.buttonRow}>
            <Button title="Clear" onPress={clearDrawing} color="#FF6B6B" />
            <Button title="Undo" onPress={undoDrawing} color="#4ECDC4" />
            <Button title="Redo" onPress={redoDrawing} color="#45B7D1" />
          </View>
        </Group>

        {/* Export Options */}
        <Group name="Export">
          <View style={styles.buttonRow}>
            <Button
              title="Export PNG"
              onPress={exportAsImage}
              color="#96CEB4"
              disabled={!hasDrawingContent}
            />
            <Button
              title="Export PDF"
              onPress={exportAsPDF}
              color="#FFEAA7"
              disabled={!hasDrawingContent}
            />
          </View>
        </Group>

        {/* Tool Information */}
        <Group name="Available Tools">
          {Object.entries(availableTools).map(([key, tool]) => (
            <View key={key} style={styles.toolInfo}>
              <Text style={styles.toolInfoTitle}>
                {tool.name} ({tool.type})
              </Text>
              <Text style={styles.toolInfoDetail}>
                Supports Color: {tool.supportsColor ? "Yes" : "No"}
              </Text>
              <Text style={styles.toolInfoDetail}>
                Supports Width: {tool.supportsWidth ? "Yes" : "No"}
              </Text>
              {tool.minWidth && tool.maxWidth && (
                <Text style={styles.toolInfoDetail}>
                  Width Range: {tool.minWidth} - {tool.maxWidth}px
                </Text>
              )}
            </View>
          ))}
        </Group>

        {/* Ink Types */}
        <Group name="Ink Types">
          {Object.entries(inkTypes).map(([key, description]) => (
            <View key={key} style={styles.inkInfo}>
              <Text style={styles.inkInfoTitle}>{key.toUpperCase()}</Text>
              <Text style={styles.inkInfoDescription}>{description}</Text>
            </View>
          ))}
        </Group>

        {/* Advanced Features */}
        <Group name="Advanced Stroke Analysis">
          <View style={styles.buttonRow}>
            <Button
              title="Analyze Drawing"
              onPress={async () => {
                try {
                  const analysis = await pencilKitRef.current?.analyzeDrawing();
                  Alert.alert(
                    "Drawing Analysis",
                    `Strokes: ${analysis?.strokeCount || 0}\nPoints: ${analysis?.totalPoints || 0}\nAvg Force: ${(analysis?.averageForce || 0).toFixed(2)}`
                  );
                } catch (error) {
                  console.log("Analysis error:", error);
                }
              }}
              color="#9B59B6"
              disabled={!hasDrawingContent}
            />
            <Button
              title="Get All Strokes"
              onPress={async () => {
                try {
                  const strokes = await pencilKitRef.current?.getAllStrokes();
                  Alert.alert(
                    "Stroke Data",
                    `Found ${strokes?.length || 0} strokes\n${strokes?.[0] ? `First stroke has ${strokes[0].path?.points?.length || 0} points` : "No stroke data"}`
                  );
                } catch (error) {
                  console.log("Stroke analysis error:", error);
                }
              }}
              color="#3498DB"
              disabled={!hasDrawingContent}
            />
          </View>
        </Group>

        {/* Content Version & Compatibility */}
        <Group name="Content Version & Compatibility">
          <Button
            title="Check Version Support"
            onPress={async () => {
              try {
                const versions =
                  await pencilKitRef.current?.getSupportedContentVersions();
                const current = await pencilKitRef.current?.getContentVersion();
                Alert.alert(
                  "Version Info",
                  `Current: ${current}\nSupported: ${versions?.join(", ") || "Unknown"}`
                );
              } catch (error) {
                console.log("Version check error:", error);
              }
            }}
            color="#E74C3C"
          />
        </Group>

        {/* Advanced Tool Picker */}
        <Group name="Advanced Tool Picker Controls">
          <View style={styles.buttonRow}>
            <Button
              title="Show Animated"
              onPress={async () => {
                await pencilKitRef.current?.setToolPickerVisibility(
                  "visible",
                  true
                );
              }}
              color="#27AE60"
            />
            <Button
              title="Hide Animated"
              onPress={async () => {
                await pencilKitRef.current?.setToolPickerVisibility(
                  "hidden",
                  true
                );
              }}
              color="#E67E22"
            />
            <Button
              title="Auto Mode"
              onPress={async () => {
                await pencilKitRef.current?.setToolPickerVisibility(
                  "auto",
                  true
                );
              }}
              color="#8E44AD"
            />
          </View>
        </Group>

        {/* Scribble Support */}
        <Group name="Scribble Support">
          <View style={styles.buttonRow}>
            <Button
              title="Enable Scribble"
              onPress={async () => {
                try {
                  const available =
                    await pencilKitRef.current?.isScribbleAvailable();
                  if (available) {
                    await pencilKitRef.current?.configureScribbleInteraction(
                      true
                    );
                    Alert.alert("Success", "Scribble interaction enabled!");
                  } else {
                    Alert.alert(
                      "Not Available",
                      "Scribble is not supported on this device"
                    );
                  }
                } catch (error) {
                  Alert.alert("Error", "Failed to configure Scribble");
                }
              }}
              color="#1ABC9C"
            />
            <Button
              title="Check Availability"
              onPress={async () => {
                try {
                  const available =
                    await pencilKitRef.current?.isScribbleAvailable();
                  Alert.alert(
                    "Scribble Support",
                    available
                      ? "✅ Scribble is available"
                      : "❌ Scribble is not available"
                  );
                } catch (error) {
                  Alert.alert("Error", "Failed to check Scribble availability");
                }
              }}
              color="#F39C12"
            />
          </View>
        </Group>

        {/* Advanced Touch Events */}
        <Group name="Advanced Touch & Gestures">
          <View style={styles.buttonRow}>
            <Button
              title="Enable Advanced Touch"
              onPress={async () => {
                await pencilKitRef.current?.handleAdvancedTouchEvents(true);
                Alert.alert(
                  "Enabled",
                  "Try double-tapping or long-pressing on the canvas!"
                );
              }}
              color="#9B59B6"
            />
            <Button
              title="Get Responder State"
              onPress={async () => {
                try {
                  const state = await pencilKitRef.current?.getResponderState();
                  Alert.alert(
                    "Responder State",
                    `First Responder: ${state?.isFirstResponder ? "Yes" : "No"}\nFinger Drawing: ${state?.allowsFingerDrawing ? "Yes" : "No"}\nRuler: ${state?.isRulerActive ? "Active" : "Inactive"}`
                  );
                } catch (error) {
                  Alert.alert("Error", "Failed to get responder state");
                }
              }}
              color="#E74C3C"
            />
          </View>
        </Group>

        {/* Performance & Analytics */}
        <Group name="Performance & Analytics">
          <View style={styles.buttonRow}>
            <Button
              title="Performance Metrics"
              onPress={async () => {
                try {
                  const metrics =
                    await pencilKitRef.current?.getPerformanceMetrics();
                  Alert.alert(
                    "Performance Report",
                    `Complexity: ${metrics?.strokeComplexity || "Unknown"}\nMemory: ${((metrics?.memoryUsage || 0) / 1024).toFixed(1)}KB\n${metrics?.recommendedOptimizations?.length > 0 ? `Suggestions: ${metrics.recommendedOptimizations.join(", ")}` : "No optimizations needed"}`
                  );
                } catch (error) {
                  Alert.alert("Error", "Failed to get performance metrics");
                }
              }}
              color="#34495E"
              disabled={!hasDrawingContent}
            />
            <Button
              title="Find Nearby Strokes"
              onPress={async () => {
                try {
                  // Find strokes near center of canvas
                  const nearbyStrokes =
                    await pencilKitRef.current?.findStrokesNear(
                      { x: 150, y: 150 },
                      50
                    );
                  Alert.alert(
                    "Nearby Strokes",
                    `Found ${nearbyStrokes?.length || 0} strokes within 50px of center`
                  );
                } catch (error) {
                  Alert.alert("Error", "Failed to find nearby strokes");
                }
              }}
              color="#16A085"
              disabled={!hasDrawingContent}
            />
          </View>
        </Group>

        {/* Advanced Export Options */}
        <Group name="Advanced Export & Analysis">
          <Text style={styles.infoText}>
            Advanced features for professional drawing applications
          </Text>
          <View style={styles.buttonRow}>
            <Button
              title="Full Statistics"
              onPress={async () => {
                try {
                  const stats =
                    await pencilKitRef.current?.getDrawingStatistics();
                  const jsonStats = JSON.stringify(stats, null, 2);
                  console.log("Drawing Statistics:", jsonStats);
                  Alert.alert(
                    "Statistics",
                    "Check console for detailed drawing statistics"
                  );
                } catch (error) {
                  Alert.alert("Error", "Failed to get drawing statistics");
                }
              }}
              color="#2980B9"
              disabled={!hasDrawingContent}
            />
            <Button
              title="Region Analysis"
              onPress={async () => {
                try {
                  const regionStrokes =
                    await pencilKitRef.current?.getStrokesInRegion({
                      x: 0,
                      y: 0,
                      width: 150,
                      height: 150,
                    });
                  Alert.alert(
                    "Region Analysis",
                    `Found ${regionStrokes?.length || 0} strokes in top-left quadrant`
                  );
                } catch (error) {
                  Alert.alert("Error", "Failed to analyze region");
                }
              }}
              color="#8E44AD"
              disabled={!hasDrawingContent}
            />
          </View>
        </Group>
      </ScrollView>
    </SafeAreaView>
  );
}

function Group(props: { name: string; children: React.ReactNode }) {
  return (
    <View style={styles.group}>
      <Text style={styles.groupHeader}>{props.name}</Text>
      {props.children}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#F5F7FA",
  },
  scrollView: {
    flex: 1,
  },
  header: {
    fontSize: 32,
    fontWeight: "bold",
    margin: 20,
    textAlign: "center",
    color: "#2C3E50",
  },
  groupHeader: {
    fontSize: 18,
    fontWeight: "600",
    marginBottom: 15,
    color: "#34495E",
  },
  group: {
    margin: 15,
    backgroundColor: "#FFFFFF",
    borderRadius: 12,
    padding: 20,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  canvasView: {
    height: 300,
    backgroundColor: "#FFFFFF",
    borderRadius: 8,
    borderWidth: 2,
    borderColor: "#E9ECEF",
  },
  infoText: {
    fontSize: 14,
    marginBottom: 5,
    color: "#6C757D",
  },
  settingRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 10,
  },
  settingLabel: {
    fontSize: 16,
    color: "#495057",
  },
  helpText: {
    fontSize: 12,
    color: "#6C757D",
    marginTop: 10,
    fontStyle: "italic",
    lineHeight: 16,
  },
  toolButton: {
    paddingHorizontal: 15,
    paddingVertical: 8,
    marginHorizontal: 5,
    backgroundColor: "#F8F9FA",
    borderRadius: 20,
    borderWidth: 1,
    borderColor: "#DEE2E6",
  },
  selectedToolButton: {
    backgroundColor: "#007BFF",
    borderColor: "#007BFF",
  },
  toolButtonText: {
    fontSize: 14,
    color: "#495057",
  },
  selectedToolButtonText: {
    color: "#FFFFFF",
    fontWeight: "600",
  },
  colorButton: {
    width: 40,
    height: 40,
    marginHorizontal: 5,
    borderRadius: 20,
    borderWidth: 2,
    borderColor: "#DEE2E6",
  },
  selectedColorButton: {
    borderColor: "#007BFF",
    borderWidth: 3,
  },
  sizeButton: {
    alignItems: "center",
    marginHorizontal: 8,
    paddingVertical: 8,
    paddingHorizontal: 12,
    borderRadius: 8,
    backgroundColor: "#F8F9FA",
    borderWidth: 1,
    borderColor: "#DEE2E6",
  },
  selectedSizeButton: {
    backgroundColor: "#E3F2FD",
    borderColor: "#2196F3",
  },
  sizeIndicator: {
    borderRadius: 15,
    marginBottom: 4,
  },
  sizeButtonText: {
    fontSize: 12,
    color: "#6C757D",
  },
  buttonRow: {
    flexDirection: "row",
    justifyContent: "space-around",
    gap: 10,
  },
  toolInfo: {
    marginBottom: 15,
    paddingBottom: 15,
    borderBottomWidth: 1,
    borderBottomColor: "#E9ECEF",
  },
  toolInfoTitle: {
    fontSize: 16,
    fontWeight: "600",
    color: "#343A40",
    marginBottom: 5,
  },
  toolInfoDetail: {
    fontSize: 14,
    color: "#6C757D",
    marginBottom: 2,
  },
  inkInfo: {
    marginBottom: 12,
  },
  inkInfoTitle: {
    fontSize: 15,
    fontWeight: "600",
    color: "#495057",
    marginBottom: 4,
  },
  inkInfoDescription: {
    fontSize: 13,
    color: "#6C757D",
    lineHeight: 18,
  },
});
