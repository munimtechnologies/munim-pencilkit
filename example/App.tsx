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
