# munim-pencilkit

<!-- Banner Image -->
<p align="center">
  <a href="https://github.com/munimtechnologies/munim-pencilkit">
    <img alt="Munim Technologies PencilKit" height="128" src="./.github/resources/banner.png?v=1">
    <h1 align="center">munim-pencilkit</h1>
  </a>
</p>

<p align="center">
   <a aria-label="Package version" href="https://www.npmjs.com/package/munim-pencilkit" target="_blank">
    <img alt="Package version" src="https://img.shields.io/npm/v/munim-pencilkit.svg?style=flat-square&label=Version&labelColor=000000&color=0066CC" />
  </a>
  <a aria-label="Package is free to use" href="https://github.com/munimtechnologies/munim-pencilkit/blob/main/LICENSE" target="_blank">
    <img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-success.svg?style=flat-square&color=33CC12" target="_blank" />
  </a>
  <a aria-label="package downloads" href="https://www.npmtrends.com/munim-pencilkit" target="_blank">
    <img alt="Downloads" src="https://img.shields.io/npm/dm/munim-pencilkit.svg?style=flat-square&labelColor=gray&color=33CC12&label=Downloads" />
  </a>
  <a aria-label="total package downloads" href="https://www.npmjs.com/package/munim-pencilkit" target="_blank">
    <img alt="Total Downloads" src="https://img.shields.io/npm/dt/munim-pencilkit.svg?style=flat-square&labelColor=gray&color=0066CC&label=Total%20Downloads" />
  </a>
</p>

<p align="center">
  <a aria-label="try with expo" href="https://docs.expo.dev/"><b>Works with Expo</b></a>
&ensp;•&ensp;
  <a aria-label="documentation" href="https://github.com/munimtechnologies/munim-pencilkit#readme">Read the Documentation</a>
&ensp;•&ensp;
  <a aria-label="report issues" href="https://github.com/munimtechnologies/munim-pencilkit/issues">Report Issues</a>
</p>

<h6 align="center">Follow Munim Technologies</h6>
<p align="center">
  <a aria-label="Follow Munim Technologies on GitHub" href="https://github.com/munimtechnologies" target="_blank">
    <img alt="Munim Technologies on GitHub" src="https://img.shields.io/badge/GitHub-222222?style=for-the-badge&logo=github&logoColor=white" target="_blank" />
  </a>&nbsp;
  <a aria-label="Follow Munim Technologies on LinkedIn" href="https://linkedin.com/in/sheehanmunim" target="_blank">
    <img alt="Munim Technologies on LinkedIn" src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white" target="_blank" />
  </a>&nbsp;
  <a aria-label="Visit Munim Technologies Website" href="https://munimtech.com" target="_blank">
    <img alt="Munim Technologies Website" src="https://img.shields.io/badge/Website-0066CC?style=for-the-badge&logo=globe&logoColor=white" target="_blank" />
  </a>
</p>

## Introduction

**munim-pencilkit** is the most comprehensive React Native library for Apple's PencilKit framework, providing **100% feature parity** with native iOS drawing capabilities. Transform your React Native app into a professional drawing and note-taking application with advanced stroke analysis, handwriting recognition, and Apple Pencil support.

**Fully compatible with Expo!** Works seamlessly with both Expo managed and bare workflows.

**Note**: This library provides complete access to all PencilKit features including advanced stroke inspection, Scribble support, content version management, and professional-grade drawing tools. It's the only React Native PencilKit implementation with full framework coverage.

## Table of contents

- [📚 Documentation](#-documentation)
- [🚀 Features](#-features)
- [📦 Installation](#-installation)
- [⚡ Quick Start](#-quick-start)
- [🔧 API Reference](#-api-reference)
- [🎛️ Ink Behavior Controls](#️-ink-behavior-controls)
- [📊 Raw Apple Pencil Data Collection](#-raw-apple-pencil-data-collection)
- [🎯 Apple Pencil Gesture Detection](#-apple-pencil-gesture-detection)
- [📖 Usage Examples](#-usage-examples)
- [🎨 Advanced Features](#-advanced-features)
- [🔍 Troubleshooting](#-troubleshooting)
- [👏 Contributing](#-contributing)
- [📄 License](#-license)

## 📚 Documentation

<p>Learn about building professional drawing apps <a aria-label="documentation" href="https://github.com/munimtechnologies/munim-pencilkit/blob/main/ADVANCED_FEATURES.md">in our comprehensive documentation!</a></p>

- [Getting Started](#-installation)
- [API Reference](#-api-reference)
- [Advanced Features Guide](./ADVANCED_FEATURES.md)
- [Usage Examples](#-usage-examples)
- [Troubleshooting](#-troubleshooting)

## 🚀 Features

### 🎨 **Core Drawing Capabilities**

- 🖊️ **Complete Tool Set**: Pen, Pencil, Marker, Eraser, and Lasso tools
- 🎨 **Full Customization**: Colors, brush sizes, opacity, and tool properties
- 📱 **Apple Pencil Integration**: Pressure sensitivity, tilt, azimuth, and hover detection
- 👆 **Touch Support**: Finger drawing with configurable policies
- 📏 **Ruler & Guides**: Built-in ruler and drawing aids

### 🔍 **Advanced Stroke Analysis**

- 📊 **Individual Stroke Access**: Complete PKStroke, PKStrokePath, PKStrokePoint data
- 🔢 **Point-Level Analysis**: Force, azimuth, altitude, and timing data
- 📈 **Drawing Analytics**: Stroke count, complexity analysis, and drawing insights
- 🎯 **Spatial Search**: Find strokes by region, proximity, or properties
- 🧮 **Path Interpolation**: Smooth stroke reconstruction and analysis

### ✍️ **Text & Handwriting**

- 🖋️ **Scribble Support**: iOS handwriting-to-text conversion
- 📝 **Text Recognition**: Custom interaction delegates for text input
- 🔤 **Writing Analysis**: Handwriting pattern recognition and analysis

### 📤 **Professional Export**

- 🖼️ **Multiple Formats**: PNG, PDF, and native PKDrawing data
- ⚖️ **Custom Scaling**: High-resolution exports with quality control
- 📄 **Vector Output**: PDF generation with scalable vector graphics
- 💾 **Data Serialization**: Native PKDrawing format for cross-platform compatibility

### 🎛️ **Advanced Controls**

- 🔧 **Tool Picker Integration**: Native iOS tool palette with animations
- 👥 **Responder Management**: Advanced touch and pencil input handling
- 🎚️ **Visibility Control**: Granular tool picker visibility states
- 🔄 **Version Compatibility**: Cross-iOS version support (13.0-17.0+)

### ⚡ **Performance & Quality**

- 🚄 **60fps Drawing**: Optimized for smooth Apple Pencil rendering
- 💾 **Memory Efficient**: Smart memory management for large drawings
- 📊 **Real-time Analytics**: Drawing analysis and optimization insights
- 🎯 **Sub-pixel Precision**: Apple Pencil sub-pixel accuracy

### 🎛️ **Ink Behavior Controls**

- 🖋️ **Ink Smoothing**: Control automatic stroke smoothing for refined appearance
- ✨ **Stroke Refinement**: Toggle stroke refinement processing for cleaner lines
- 📝 **Handwriting Recognition**: Enable/disable Scribble handwriting-to-text features
- 🎨 **Natural Drawing Mode**: Master toggle for unprocessed, authentic drawing experience
- 🧠 **Smart Tool Selection**: Automatically switches tools and adjusts settings based on mode

### 📊 **Raw Apple Pencil Data Collection**

- 🎯 **Direct Hardware Access**: Raw, unprocessed Apple Pencil data straight from sensors
- 📈 **Complete Touch Data**: Position, pressure, tilt, azimuth, timestamp, and touch phases
- 🔄 **Real-time Events**: Live touch began, moved, ended, and stroke completed events
- 🎨 **Notability-Style Drawing**: Create natural, pen-on-paper experiences like professional apps
- ⚡ **Dual Data Streams**: Access both PencilKit processed data AND raw unprocessed data
- 🛠️ **Full Control**: Custom smoothing, filtering, and processing algorithms

### 🎯 **Apple Pencil Gesture Detection**

- 👆 **Double-Tap Support**: Detect Apple Pencil double-tap gestures (iOS 12.1+)
- 🤏 **Squeeze Detection**: Apple Pencil Pro squeeze gesture support (iOS 16.4+)
- ⚡ **Real-time Events**: Instant gesture recognition with custom actions
- 🎨 **Professional Integration**: Same gesture system used by Notability and Procreate
- 🔧 **Easy Configuration**: Simple enable/disable with automatic device compatibility checking

### 🔧 **Developer Experience**

- 📘 **Full TypeScript**: Complete type definitions with IntelliSense and debug support
- ⚛️ **Modern React**: Hooks, refs, and imperative API support
- 🚀 **Expo Compatible**: Works with Expo SDK 51+ managed and bare workflows
- 🔗 **Event System**: Comprehensive drawing event handling with debug payloads
- ♿ **Accessibility**: VoiceOver and accessibility support
- 🐛 **Debug Support**: Built-in debug mode with detailed method return types

## 📦 Installation

### React Native CLI

```bash
npm install munim-pencilkit
# or
yarn add munim-pencilkit
```

### Expo

```bash
npx expo install munim-pencilkit
```

> **Note**: This library requires Expo SDK 51+ and works with both managed and bare workflows.

### iOS Setup

For iOS, the library is automatically linked. However, you need to add PencilKit usage description to your `Info.plist`:

```xml
<key>NSApplePencilUsageDescription</key>
<string>This app uses Apple Pencil for drawing and note-taking</string>
```

**For Expo projects**, add these permissions to your `app.json`:

```json
{
  "expo": {
    "ios": {
      "infoPlist": {
        "NSApplePencilUsageDescription": "This app uses Apple Pencil for drawing and note-taking"
      }
    }
  }
}
```

### Platform Requirements

- **iOS**: 13.0+ (Advanced features require iOS 14.0+)
- **iPadOS**: 13.0+
- **Mac Catalyst**: 13.0+
- **macOS**: 10.15+
- **visionOS**: 1.0+

> **Note**: PencilKit is Apple-exclusive. On other platforms, the library provides graceful fallbacks.

## ⚡ Quick Start

### Basic Drawing Canvas

```typescript
import React, { useRef } from 'react';
import { View, StyleSheet } from 'react-native';
import { MunimPencilkitView, MunimPencilkitViewRef } from 'munim-pencilkit';

export default function DrawingApp() {
  const canvasRef = useRef<MunimPencilkitViewRef>(null);

  return (
    <View style={styles.container}>
      <MunimPencilkitView
        ref={canvasRef}
        style={styles.canvas}
        showToolPicker={true}
        allowsFingerDrawing={true}
        toolType="pen"
        toolColor="#007AFF"
        toolWidth={10}
        onDrawingChanged={({ nativeEvent }) => {
          console.log('Stroke count:', nativeEvent.strokeCount);
        }}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  canvas: {
    flex: 1,
    backgroundColor: 'white',
  },
});
```

### Advanced Drawing with All Tools

```typescript
import React, { useRef, useState } from 'react';
import { View, Button, Alert } from 'react-native';
import {
  MunimPencilkitView,
  MunimPencilkitViewRef,
  PKToolType
} from 'munim-pencilkit';

export default function AdvancedDrawingApp() {
  const canvasRef = useRef<MunimPencilkitViewRef>(null);
  const [currentTool, setCurrentTool] = useState<PKToolType>('pen');

  const switchTool = async (tool: PKToolType) => {
    setCurrentTool(tool);
    await canvasRef.current?.setTool(tool, '#FF6B6B', 15);
  };

  const exportDrawing = async () => {
    try {
      const imageBase64 = await canvasRef.current?.exportAsImage({ scale: 2.0 });
      if (imageBase64) {
        Alert.alert('Success', 'Drawing exported!');
        // Save or share the image
      }
    } catch (error) {
      Alert.alert('Error', 'Failed to export drawing');
    }
  };

  return (
    <View style={{ flex: 1 }}>
      <MunimPencilkitView
        ref={canvasRef}
        style={{ flex: 1, backgroundColor: 'white' }}
        showToolPicker={true}
        allowsFingerDrawing={true}
        isRulerActive={false}
        drawingPolicy="default"
        toolType={currentTool}
        onDrawingChanged={({ nativeEvent }) => {
          console.log(`Drawing has ${nativeEvent.strokeCount} strokes`);
        }}
      />

      <View style={{ flexDirection: 'row', padding: 10 }}>
        <Button title="Pen" onPress={() => switchTool('pen')} />
        <Button title="Pencil" onPress={() => switchTool('pencil')} />
        <Button title="Marker" onPress={() => switchTool('marker')} />
        <Button title="Eraser" onPress={() => switchTool('eraser')} />
        <Button title="Export" onPress={exportDrawing} />
      </View>
    </View>
  );
}
```

## 🔧 API Reference

### Components

#### `MunimPencilkitView`

The main drawing canvas component with full PencilKit integration.

**Props:**

```typescript
interface MunimPencilkitViewProps {
  // Visual Configuration
  style?: StyleProp<ViewStyle>;
  backgroundColor?: string;

  // Canvas Configuration
  showToolPicker?: boolean; // Show/hide native tool picker
  allowsFingerDrawing?: boolean; // Enable finger drawing
  isRulerActive?: boolean; // Show ruler guide
  drawingPolicy?: PKDrawingPolicy; // 'default' | 'pencilOnly' | 'anyInput'

  // Tool Configuration
  toolType?: PKToolType; // 'pen' | 'pencil' | 'marker' | 'eraser' | 'lasso'
  toolColor?: string; // Hex color code
  toolWidth?: number; // Tool width in points

  // Ink Behavior Controls
  enableInkSmoothing?: boolean; // Control automatic stroke smoothing
  enableStrokeRefinement?: boolean; // Control stroke refinement processing
  enableHandwritingRecognition?: boolean; // Toggle Scribble handwriting features
  naturalDrawingMode?: boolean; // Master toggle for natural, unprocessed drawing

  // Raw Apple Pencil Data Collection
  enableRawPencilData?: boolean; // Enable raw UITouch data collection

  // Apple Pencil Gesture Detection
  enablePencilGestures?: boolean; // Enable Apple Pencil gesture detection

  // Event Handlers
  onDrawingChanged?: (event) => void;
  onToolChanged?: (event) => void;
  onDrawingStarted?: (event) => void;
  onDrawingEnded?: (event) => void;

  // Advanced Events
  onAdvancedTap?: (event) => void;
  onAdvancedLongPress?: (event) => void;
  onScribbleWillBegin?: (event) => void;
  onScribbleDidFinish?: (event) => void;

  // Raw Touch Events
  onRawTouchBegan?: (event) => void;
  onRawTouchMoved?: (event) => void;
  onRawTouchEnded?: (event) => void;
  onRawTouchCancelled?: (event) => void;
  onRawStrokeCompleted?: (event) => void;

  // Apple Pencil Gesture Events
  onPencilDoubleTap?: (event) => void;
  onPencilSqueeze?: (event) => void;
}
```

### Imperative API

Access advanced functionality through ref methods:

```typescript
const canvasRef = useRef<MunimPencilkitViewRef>(null);

// Basic Drawing Operations
await canvasRef.current?.clearDrawing();
await canvasRef.current?.undo();
await canvasRef.current?.redo();

// Export Functions
const imageBase64 = await canvasRef.current?.exportAsImage({ scale: 2.0 });
const pdfData = await canvasRef.current?.exportAsPDF({ scale: 1.0 });
const drawingData = await canvasRef.current?.getDrawingData();

// Advanced Stroke Analysis
const strokes = await canvasRef.current?.getAllStrokes();
const analysis = await canvasRef.current?.analyzeDrawing();
const nearbyStrokes = await canvasRef.current?.findStrokesNear(
  { x: 100, y: 100 },
  20
);

// Tool Management
await canvasRef.current?.setTool("pen", "#FF0000", 12);
const toolInfo = await canvasRef.current?.getToolPickerVisibility();

// Ink Behavior Controls
await canvasRef.current?.setEnableInkSmoothing(true);
await canvasRef.current?.setEnableStrokeRefinement(false);
await canvasRef.current?.setEnableHandwritingRecognition(true);
await canvasRef.current?.setNaturalDrawingMode(false);

// Raw Apple Pencil Data Collection
await canvasRef.current?.setEnableRawPencilData(true);
const rawSamples = await canvasRef.current?.getRawTouchSamples();
await canvasRef.current?.clearRawTouchSamples();

// Apple Pencil Gesture Detection
await canvasRef.current?.setEnablePencilGestures(true);
const gesturesAvailable = await canvasRef.current?.isPencilGesturesAvailable();

// Scribble Support
const isAvailable = await canvasRef.current?.isScribbleAvailable();
await canvasRef.current?.configureScribbleInteraction(true);

// Performance Monitoring (Note: getPerformanceMetrics not yet implemented)
// const metrics = await canvasRef.current?.getPerformanceMetrics();
```

### Content & Serialization Helpers (1.1.3+)

The following helpers report real-time canvas content and bounds directly from the native view:

```typescript
// Content state
const hasContent = await canvasRef.current?.hasContent();
const strokeCount = await canvasRef.current?.getStrokeCount();

// Drawing bounds (in view coordinates)
const bounds = await canvasRef.current?.getDrawingBounds();

// Serialization
const data = await canvasRef.current?.getDrawingData(); // ArrayBuffer (non-null when content exists)
```

### Debug Support & Type Safety (1.1.4+)

The library now includes comprehensive debug support with proper TypeScript definitions:

### Critical Fixes & Reliability Improvements (1.2.8+)

Version 1.2.8 includes critical fixes for method reliability and view initialization:

### Debug Mode Control (1.2.9+)

Version 1.2.9 introduces proper debug mode control for methods that previously always returned debug objects:

### Swift Compilation Fixes (1.2.10+)

Version 1.2.10 fixes critical Swift compilation errors that were preventing the package from building:

- **Fixed Swift closure default arguments error** - Removed default parameters from Expo AsyncFunction closures
- **Added missing native methods** - getDrawingBoundsStruct, getToolPickerInfo, getScribbleConfiguration, searchStrokes
- **Fixed PKStrokePath property access** - Corrected boundingBox to use stroke.renderBounds
- **Improved error handling** - Better fallback strategies for failed method calls

### Comprehensive Bug Fixes (1.2.11+)

Version 1.2.11 includes comprehensive fixes for all identified critical issues:

- **Added missing native methods** - Complete implementation of all TypeScript wrapper methods
- **Fixed view readiness detection** - More lenient checks for better reliability
- **Added robust error handling** - safeExecute helper for consistent error management
- **Improved data serialization** - Multiple fallback strategies for reliable data export
- **Standardized return formats** - Consistent handling between debug and non-debug modes

### Drawing Commit Timing Fixes (1.2.12-1.2.15)

Versions 1.2.12-1.2.15 address critical drawing commit timing issues:

- **Fixed drawing commit timing bug** - Ensures strokes are properly committed to PKDrawing object
- **Added forceDrawingCommit() method** - Forces PencilKit to commit all pending strokes
- **Enhanced drawing pipeline synchronization** - Proper sync with PencilKit's internal drawing pipeline
- **Added comprehensive debug logging** - Track drawing state changes and method execution
- **Multiple fallback strategies** - Graceful degradation when drawing isn't immediately available

### Simplified Apple-Compliant Implementation (1.2.16+)

Version 1.2.16+ simplifies the implementation to match Apple's PencilKit documentation exactly:

- **Removed all complex timing logic** - No more force commits, waiting, or complex synchronization
- **Direct PencilKit API usage** - Uses canvasView.drawing exactly as Apple intended
- **Simplified delegate methods** - Clean, straightforward event handling
- **Added debugDrawingState() method** - Comprehensive debugging for troubleshooting
- **Apple-compliant approach** - Follows PencilKit documentation precisely

### Final Optimization (1.2.17+)

Version 1.2.17 represents the final, optimized implementation:

- **Complete API compliance** - Uses PencilKit exactly as documented by Apple
- **Simplified method implementations** - Direct access to drawing properties
- **Enhanced debugging capabilities** - Comprehensive state inspection
- **Removed all overcomplicated logic** - Clean, maintainable codebase
- **Maximum reliability** - Follows Apple's intended usage patterns

### Debug Mode Control (1.2.9+)

Version 1.2.9 introduces proper debug mode control for methods that previously always returned debug objects:

```typescript
// Default behavior - returns raw data (no debug wrapper)
const hasContent = await canvasRef.current?.hasContent(); // boolean
const strokeCount = await canvasRef.current?.getStrokeCount(); // number
const drawingData = await canvasRef.current?.getDrawingData(); // ArrayBuffer | null

// Debug mode - returns detailed debug objects
const debugInfo = await canvasRef.current?.hasContent(true); // DebugEventPayload
const debugStrokes = await canvasRef.current?.getStrokeCount(true); // DebugEventPayload
const debugData = await canvasRef.current?.getDrawingData(true); // DebugEventPayload

console.log("Has content:", hasContent); // true/false
console.log("Stroke count:", strokeCount); // 42
console.log("Drawing data:", drawingData); // ArrayBuffer or null
```

### Comprehensive Debugging (1.2.17+)

Version 1.2.17+ includes a comprehensive debugging method for troubleshooting:

```typescript
// Debug drawing state - shows everything about the canvas and drawing
const debugState = await canvasRef.current?.debugDrawingState();
console.log("Debug state:", debugState);

// Returns:
// {
//   strokeCount: number,
//   bounds: { x, y, width, height },
//   canvasFrame: { x, y, width, height },
//   canvasHidden: boolean,
//   canvasAlpha: number
// }
```

This method helps diagnose:

- Whether strokes are actually being detected
- Canvas view setup and visibility
- Drawing bounds and frame information
- Any view hierarchy issues

**Key Improvements:**

- 🔧 **Fixed Undefined Returns**: Methods no longer return `undefined` due to timing issues
- ⏱️ **View Initialization**: Added proper async waiting for view readiness
- 🛡️ **Error Handling**: Enhanced error handling with detailed debug information
- 🔄 **Fallback Mechanisms**: Robust fallbacks for serialization failures
- 🐛 **Debug Information**: Comprehensive debug objects for troubleshooting
- 🎛️ **Debug Mode Control**: Optional debug parameter for methods (default: false)
- 📊 **Raw Data Returns**: Methods now return actual data by default, not debug wrappers

**Reliability Features:**

- ✅ **Async Method Calls**: All critical methods now use proper async/await
- ✅ **Initialization Timeout**: 2-second timeout for view readiness
- ✅ **Thread Safety**: Methods properly called on main thread
- ✅ **Fallback Serialization**: JSON fallback when PKDrawing serialization fails

```typescript
// Methods can return either data or debug objects
const result = await canvasRef.current?.getDrawingData();

// Type-safe handling of debug responses
if (result && typeof result === 'object' && 'debug' in result) {
  // Debug response
  console.log('Debug info:', {
    method: result.method,
    strokes: result.strokes,
    timestamp: result.timestamp,
    step: result.step,
    error: result.error
  });
} else {
  // Regular data response
  console.log('Drawing data:', result);
}

// Event payloads also support debug properties
<MunimPencilkitView
  onDrawingChanged={({ nativeEvent }) => {
    if (nativeEvent.debug) {
      console.log('Debug drawing event:', nativeEvent);
    } else {
      console.log('Regular drawing event:', nativeEvent);
    }
  }}
/>
```

**Debug Features:**

- 🐛 **Debug Return Types**: Methods return detailed debug objects when in debug mode
- 📊 **Method Tracking**: Track which methods are called and their execution steps
- ⏱️ **Timing Information**: Timestamps for performance analysis
- 🔍 **Error Details**: Detailed error information when operations fail
- 📈 **Stroke Analytics**: Real-time stroke count and processing information

Notes:

- If drawing bounds are empty, image/PDF export will fall back to a canvas snapshot (1.1.2+).
- Ensure `drawingPolicy` and `allowsFingerDrawing` are set to allow your input method.
- Debug mode provides enhanced type safety and detailed method return information.

## 🎛️ Ink Behavior Controls

The library provides granular control over PencilKit's automatic processing features, allowing you to create the perfect drawing experience for your users.

### Understanding the Controls

#### `enableInkSmoothing` (Default: `true`)

Controls PencilKit's automatic stroke smoothing algorithm. When enabled, strokes are automatically smoothed for a more refined appearance.

```typescript
<MunimPencilkitView
  enableInkSmoothing={true}  // Smooth, refined strokes
  enableInkSmoothing={false} // Raw, unprocessed strokes
/>
```

#### `enableStrokeRefinement` (Default: `true`)

Toggles stroke refinement processing that cleans up and optimizes stroke paths for better rendering.

```typescript
<MunimPencilkitView
  enableStrokeRefinement={true}  // Clean, optimized strokes
  enableStrokeRefinement={false} // Natural stroke paths
/>
```

#### `enableHandwritingRecognition` (Default: `true`)

Controls Scribble handwriting-to-text conversion features. When disabled, handwriting won't be processed for text recognition.

```typescript
<MunimPencilkitView
  enableHandwritingRecognition={true}  // Enable Scribble features
  enableHandwritingRecognition={false} // Disable text recognition
/>
```

#### `naturalDrawingMode` (Default: `false`)

**Master toggle** that disables all automatic processing for the most authentic drawing experience. When enabled:

- Automatically disables ink smoothing, stroke refinement, and handwriting recognition
- Switches to marker tool for natural drawing
- Adjusts stroke widths for optimal natural rendering

```typescript
<MunimPencilkitView
  naturalDrawingMode={true}  // Pure, unprocessed drawing
  naturalDrawingMode={false} // Processed drawing with all features
/>
```

### Smart Tool Selection

The library intelligently manages tool selection based on your settings:

- **Natural Drawing Mode**: Automatically switches to marker tool
- **Stroke Refinement Disabled**: Adjusts stroke widths for better natural rendering
- **Handwriting Recognition**: Optimizes tool settings for text input

### Usage Patterns

#### For Digital Artists

```typescript
<MunimPencilkitView
  naturalDrawingMode={true}  // Pure artistic expression
  toolType="marker"          // Automatically selected
  toolWidth={15}             // Optimized for natural drawing
/>
```

#### For Note-Taking Apps

```typescript
<MunimPencilkitView
  enableInkSmoothing={true}           // Clean, readable text
  enableStrokeRefinement={true}       // Optimized for writing
  enableHandwritingRecognition={true} // Enable Scribble
  naturalDrawingMode={false}
/>
```

#### For Sketching Apps

```typescript
<MunimPencilkitView
  enableInkSmoothing={false}          // Raw, expressive strokes
  enableStrokeRefinement={false}      // Natural sketch appearance
  enableHandwritingRecognition={false} // Focus on drawing
  naturalDrawingMode={false}
/>
```

### Imperative Control

You can also control these features programmatically:

```typescript
const canvasRef = useRef<MunimPencilkitViewRef>(null);

// Enable natural drawing mode
await canvasRef.current?.setNaturalDrawingMode(true);

// Disable specific features
await canvasRef.current?.setEnableInkSmoothing(false);
await canvasRef.current?.setEnableStrokeRefinement(false);

// Re-enable handwriting recognition
await canvasRef.current?.setEnableHandwritingRecognition(true);
```

### Troubleshooting Ink Behavior

#### "My strokes are being modified as I draw"

- **Solution**: Enable `naturalDrawingMode={true}` or disable `enableInkSmoothing` and `enableStrokeRefinement`

#### "Handwriting recognition is interfering with my drawing"

- **Solution**: Set `enableHandwritingRecognition={false}` or use `naturalDrawingMode={true}`

#### "Strokes look too processed for my art app"

- **Solution**: Use `naturalDrawingMode={true}` for authentic, unprocessed drawing

#### "I want clean text but natural sketches"

- **Solution**: Dynamically toggle settings based on tool selection or user preference

## 📊 Raw Apple Pencil Data Collection

Access **raw, unprocessed Apple Pencil data** just like Notability, Procreate, and other professional drawing apps. This gives you complete control over how strokes are processed and rendered.

### What's the Difference?

| **PencilKit (Processed)**    | **Raw UITouch (Unprocessed)** |
| ---------------------------- | ----------------------------- |
| Smoothed, polished strokes   | Raw, natural imperfections    |
| Apple's filtering algorithms | No processing applied         |
| Consistent appearance        | Variable, organic feel        |
| Easy to use                  | Full control                  |

### Key Data Available

```typescript
interface RawTouchSample {
  location: { x: number; y: number }; // Position
  force: number; // Pressure (0.0 - 1.0)
  altitudeAngle: number; // Tilt angle
  azimuthAngle: number; // Rotation angle
  timestamp: number; // High-resolution timestamp
  size: { width: number; height: number }; // Touch size
  type: "pencil" | "direct" | "indirect"; // Input type
  phase: "began" | "moved" | "ended"; // Touch phase
  estimatedProperties: string[]; // Apple's predictions
  estimatedPropertiesExpectingUpdates: string[]; // Pending updates
}
```

### Basic Usage

```typescript
import React, { useRef } from 'react';
import { View } from 'react-native';
import { MunimPencilkitView, MunimPencilkitViewRef } from 'munim-pencilkit';

export default function RawDataApp() {
  const canvasRef = useRef<MunimPencilkitViewRef>(null);

  return (
    <View style={{ flex: 1 }}>
      <MunimPencilkitView
        ref={canvasRef}
        style={{ flex: 1, backgroundColor: 'white' }}
        enableRawPencilData={true}
        onRawTouchBegan={(event) => {
          console.log('Touch started:', event.nativeEvent.force);
        }}
        onRawTouchMoved={(event) => {
          console.log('Touch moved:', event.nativeEvent.location);
        }}
        onRawTouchEnded={(event) => {
          console.log('Touch ended:', event.nativeEvent);
        }}
        onRawStrokeCompleted={(event) => {
          console.log('Complete stroke:', event.nativeEvent.samples);
        }}
      />
    </View>
  );
}
```

### Advanced Raw Data Processing

```typescript
// Get all collected raw touch samples
const samples = await canvasRef.current?.getRawTouchSamples();

// Clear collected samples
await canvasRef.current?.clearRawTouchSamples();

// Compare with PencilKit data
const pkStrokes = await canvasRef.current?.getAllStrokes();
const rawSamples = await canvasRef.current?.getRawTouchSamples();

console.log("PencilKit points:", pkStrokes[0]?.path?.points?.length);
console.log("Raw samples:", rawSamples.length);
```

### Real-World Applications

#### Natural Drawing Apps (Notability-style)

```typescript
// Minimal smoothing for natural feel
const processRawStroke = (samples: RawTouchSample[]) => {
  return samples.map((sample) => ({
    ...sample,
    // Apply only light jitter reduction
    location: applyLightSmoothing(sample.location, previousLocation),
  }));
};
```

#### Pressure-Sensitive Brushes

```typescript
// Use raw pressure data for brush dynamics
const createPressureBrush = (samples: RawTouchSample[]) => {
  return samples.map((sample) => ({
    ...sample,
    brushSize: sample.force * maxBrushSize,
    opacity: sample.force * maxOpacity,
  }));
};
```

#### Tilt-Based Effects

```typescript
// Use tilt angles for shading effects
const createTiltShading = (samples: RawTouchSample[]) => {
  return samples.map((sample) => ({
    ...sample,
    shadingIntensity: Math.sin(sample.altitudeAngle) * maxShading,
  }));
};
```

### Event Types

- `onRawTouchBegan` - Touch started
- `onRawTouchMoved` - Touch moved
- `onRawTouchEnded` - Touch ended
- `onRawTouchCancelled` - Touch cancelled
- `onRawStrokeCompleted` - Complete stroke with all samples

### Performance Considerations

```typescript
// Clear samples periodically to prevent memory buildup
useEffect(() => {
  const interval = setInterval(async () => {
    if (rawSamples.length > 1000) {
      await canvasRef.current?.clearRawTouchSamples();
    }
  }, 5000);

  return () => clearInterval(interval);
}, [rawSamples.length]);
```

### Best Practices

1. **Enable only when needed** - Raw data collection has overhead
2. **Process samples efficiently** - Use appropriate algorithms for your use case
3. **Manage memory** - Clear samples periodically
4. **Test on device** - Raw data behavior varies by device
5. **Combine with PencilKit** - Use both for maximum flexibility

## 🎯 Apple Pencil Gesture Detection

Detect **Apple Pencil double-tap and squeeze gestures** just like professional drawing apps. These gestures provide intuitive shortcuts for common actions.

### Supported Gestures

| Gesture        | Device Support                            | iOS Version | Description                         |
| -------------- | ----------------------------------------- | ----------- | ----------------------------------- |
| **Double-Tap** | Apple Pencil (2nd gen) + Apple Pencil Pro | iOS 12.1+   | Quick tool switching, color palette |
| **Squeeze**    | Apple Pencil Pro only                     | iOS 16.4+   | Advanced shortcuts, tool switching  |

### Basic Usage

```typescript
import React, { useRef } from 'react';
import { View } from 'react-native';
import { MunimPencilkitView, MunimPencilkitViewRef } from 'munim-pencilkit';

export default function GestureApp() {
  const canvasRef = useRef<MunimPencilkitViewRef>(null);

  const handleDoubleTap = (event) => {
    console.log('Double-tap detected:', event.nativeEvent);
    // Switch between pen and eraser
    // Show color palette
    // Toggle tool picker
  };

  const handleSqueeze = (event) => {
    console.log('Squeeze detected:', event.nativeEvent);
    // Show advanced options
    // Quick tool switching
    // Custom actions
  };

  return (
    <View style={{ flex: 1 }}>
      <MunimPencilkitView
        ref={canvasRef}
        style={{ flex: 1, backgroundColor: 'white' }}
        enablePencilGestures={true}
        onPencilDoubleTap={handleDoubleTap}
        onPencilSqueeze={handleSqueeze}
      />
    </View>
  );
}
```

### Advanced Gesture Configuration

```typescript
// Check if gestures are available
const isAvailable = await canvasRef.current?.isPencilGesturesAvailable();

// Enable/disable gestures programmatically
await canvasRef.current?.setEnablePencilGestures(true);

// Gesture event data
interface PencilGestureEventPayload {
  type: "doubleTap" | "squeeze";
  timestamp: number;
  location: { x: number; y: number };
}
```

### Real-World Applications

#### Tool Switching (Notability-style)

```typescript
const handleDoubleTap = (event) => {
  // Switch between current tool and eraser
  const newTool = currentTool === "pen" ? "eraser" : "pen";
  setCurrentTool(newTool);
  canvasRef.current?.setTool(newTool, "#000000", 10);
};
```

#### Color Palette (Procreate-style)

```typescript
const handleSqueeze = (event) => {
  // Show color picker
  setShowColorPicker(true);
};
```

#### Quick Actions

```typescript
const handleDoubleTap = (event) => {
  // Cycle through tools
  const tools = ["pen", "pencil", "marker", "eraser"];
  const currentIndex = tools.indexOf(currentTool);
  const nextTool = tools[(currentIndex + 1) % tools.length];
  setCurrentTool(nextTool);
};
```

### Device Compatibility

```typescript
// Check gesture availability
const checkGestures = async () => {
  const available = await canvasRef.current?.isPencilGesturesAvailable();

  if (available) {
    console.log("Apple Pencil gestures supported!");
  } else {
    console.log("Apple Pencil gestures not available on this device");
  }
};
```

### Best Practices

1. **Check Availability First** - Always verify gesture support before enabling
2. **Provide Visual Feedback** - Show users when gestures are detected
3. **Consistent Actions** - Use the same gesture for the same action across your app
4. **Accessibility** - Provide alternative ways to access gesture functions
5. **User Education** - Guide users on how to use gestures effectively

### Troubleshooting Gestures

- **Gestures not working**: Ensure `enablePencilGestures={true}` and device supports gestures
- **Double-tap not detected**: Check Apple Pencil is properly paired and charged
- **Squeeze not working**: Requires Apple Pencil Pro and iOS 16.4+
- **Events not firing**: Verify gesture handlers are properly connected

## 📖 Usage Examples

### Digital Art Application

```typescript
import React, { useRef, useState } from 'react';
import { View, ScrollView, TouchableOpacity, Text } from 'react-native';
import { MunimPencilkitView, MunimPencilkitViewRef } from 'munim-pencilkit';

export default function DigitalArtApp() {
  const canvasRef = useRef<MunimPencilkitViewRef>(null);
  const [strokeCount, setStrokeCount] = useState(0);

  const colors = ['#FF0000', '#00FF00', '#0000FF', '#FFFF00', '#FF00FF'];
  const brushSizes = [2, 5, 10, 15, 20];

  return (
    <View style={{ flex: 1 }}>
      <MunimPencilkitView
        ref={canvasRef}
        style={{ flex: 1, backgroundColor: '#F5F5F5' }}
        showToolPicker={true}
        allowsFingerDrawing={true}
        toolType="pen"
        onDrawingChanged={({ nativeEvent }) => {
          setStrokeCount(nativeEvent.strokeCount);
        }}
      />

      <View style={{ padding: 10 }}>
        <Text>Strokes: {strokeCount}</Text>

        <ScrollView horizontal showsHorizontalScrollIndicator={false}>
          {colors.map(color => (
            <TouchableOpacity
              key={color}
              style={{
                width: 30,
                height: 30,
                backgroundColor: color,
                borderRadius: 15,
                margin: 5,
              }}
              onPress={() => canvasRef.current?.setTool('pen', color, 10)}
            />
          ))}
        </ScrollView>

        <ScrollView horizontal showsHorizontalScrollIndicator={false}>
          {brushSizes.map(size => (
            <TouchableOpacity
              key={size}
              style={{
                padding: 10,
                backgroundColor: '#E0E0E0',
                borderRadius: 5,
                margin: 5,
              }}
              onPress={() => canvasRef.current?.setTool('pen', '#000000', size)}
            >
              <Text>{size}px</Text>
            </TouchableOpacity>
          ))}
        </ScrollView>
      </View>
    </View>
  );
}
```

### Note-Taking with Handwriting Recognition

```typescript
import React, { useRef, useState } from 'react';
import { View, Text, Button, Alert } from 'react-native';
import { MunimPencilkitView, MunimPencilkitViewRef } from 'munim-pencilkit';

export default function NoteTakingApp() {
  const canvasRef = useRef<MunimPencilkitViewRef>(null);
  const [scribbleEnabled, setScribbleEnabled] = useState(false);

  const enableScribble = async () => {
    try {
      const available = await canvasRef.current?.isScribbleAvailable();
      if (available) {
        await canvasRef.current?.configureScribbleInteraction(true);
        setScribbleEnabled(true);
        Alert.alert('Scribble Enabled', 'You can now write text that will be recognized!');
      } else {
        Alert.alert('Not Available', 'Scribble is not supported on this device');
      }
    } catch (error) {
      Alert.alert('Error', 'Failed to enable Scribble');
    }
  };

  const analyzeHandwriting = async () => {
    try {
      const analysis = await canvasRef.current?.analyzeDrawing();
      Alert.alert(
        'Handwriting Analysis',
        `Strokes: ${analysis.strokeCount}\n` +
        `Average Force: ${analysis.averageForce.toFixed(2)}\n` +
        `Complexity: ${analysis.strokeCount > 50 ? 'High' : 'Normal'}`
      );
    } catch (error) {
      Alert.alert('Error', 'Failed to analyze handwriting');
    }
  };

  return (
    <View style={{ flex: 1 }}>
      <MunimPencilkitView
        ref={canvasRef}
        style={{ flex: 1, backgroundColor: 'white' }}
        showToolPicker={true}
        allowsFingerDrawing={true}
        toolType="pen"
        toolColor="#000080"
        toolWidth={3}
        onScribbleWillBegin={() => console.log('Scribble writing started')}
        onScribbleDidFinish={() => console.log('Scribble writing finished')}
      />

      <View style={{ flexDirection: 'row', padding: 10, justifyContent: 'space-around' }}>
        <Button
          title={scribbleEnabled ? "Scribble On" : "Enable Scribble"}
          onPress={enableScribble}
        />
        <Button title="Analyze Writing" onPress={analyzeHandwriting} />
      </View>
    </View>
  );
}
```

### Ink Behavior Control Example

```typescript
import React, { useRef, useState } from 'react';
import { View, Switch, Text, StyleSheet } from 'react-native';
import { MunimPencilkitView, MunimPencilkitViewRef } from 'munim-pencilkit';

export default function InkControlApp() {
  const canvasRef = useRef<MunimPencilkitViewRef>(null);
  const [naturalMode, setNaturalMode] = useState(false);
  const [inkSmoothing, setInkSmoothing] = useState(true);
  const [strokeRefinement, setStrokeRefinement] = useState(true);
  const [handwritingRecognition, setHandwritingRecognition] = useState(true);

  const toggleNaturalMode = (value: boolean) => {
    setNaturalMode(value);
    if (value) {
      // Natural mode disables all processing
      setInkSmoothing(false);
      setStrokeRefinement(false);
      setHandwritingRecognition(false);
    }
  };

  return (
    <View style={styles.container}>
      <MunimPencilkitView
        ref={canvasRef}
        style={styles.canvas}
        naturalDrawingMode={naturalMode}
        enableInkSmoothing={inkSmoothing}
        enableStrokeRefinement={strokeRefinement}
        enableHandwritingRecognition={handwritingRecognition}
        toolType={naturalMode ? "marker" : "pen"}
        toolWidth={naturalMode ? 15 : 10}
      />

      <View style={styles.controls}>
        <Text style={styles.title}>Ink Behavior Controls</Text>

        <View style={styles.controlRow}>
          <Text>Natural Drawing Mode</Text>
          <Switch value={naturalMode} onValueChange={toggleNaturalMode} />
        </View>

        <View style={styles.controlRow}>
          <Text>Ink Smoothing</Text>
          <Switch
            value={inkSmoothing}
            onValueChange={setInkSmoothing}
            disabled={naturalMode}
          />
        </View>

        <View style={styles.controlRow}>
          <Text>Stroke Refinement</Text>
          <Switch
            value={strokeRefinement}
            onValueChange={setStrokeRefinement}
            disabled={naturalMode}
          />
        </View>

        <View style={styles.controlRow}>
          <Text>Handwriting Recognition</Text>
          <Switch
            value={handwritingRecognition}
            onValueChange={setHandwritingRecognition}
            disabled={naturalMode}
          />
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  canvas: { flex: 1, backgroundColor: 'white' },
  controls: { padding: 20, backgroundColor: '#f5f5f5' },
  title: { fontSize: 18, fontWeight: 'bold', marginBottom: 15 },
  controlRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 10
  },
});
```

### Professional Drawing with Advanced Features

```typescript
import React, { useRef, useState, useCallback } from 'react';
import { View, Button, Alert, ScrollView, Text } from 'react-native';
import { MunimPencilkitView, MunimPencilkitViewRef } from 'munim-pencilkit';

export default function ProfessionalDrawingApp() {
  const canvasRef = useRef<MunimPencilkitViewRef>(null);
  const [drawingStats, setDrawingStats] = useState(null);

  const getDetailedAnalysis = useCallback(async () => {
    try {
      const [analysis, strokes] = await Promise.all([
        canvasRef.current?.analyzeDrawing(),
        canvasRef.current?.getAllStrokes(),
      ]);

      setDrawingStats({
        strokeCount: analysis.strokeCount,
        totalPoints: analysis.totalPoints,
        averageForce: analysis.averageForce,
        inkTypes: analysis.inkTypes,
        complexity: analysis.strokeCount > 50 ? 'high' : 'normal',
        memoryUsage: 0, // Performance metrics not yet implemented
      });

      Alert.alert('Analysis Complete', 'Check the stats below!');
    } catch (error) {
      Alert.alert('Error', 'Failed to analyze drawing');
    }
  }, []);

  const exportHighResolution = useCallback(async () => {
    try {
      const imageBase64 = await canvasRef.current?.exportAsImage({
        scale: 3.0,  // 3x resolution
        format: 'png'
      });

      if (imageBase64) {
        // Save to device or upload to cloud
        Alert.alert('Success', 'High-resolution image exported!');
      }
    } catch (error) {
      Alert.alert('Error', 'Failed to export image');
    }
  }, []);

  const findStrokesInRegion = useCallback(async () => {
    try {
      const regionStrokes = await canvasRef.current?.getStrokesInRegion({
        x: 0, y: 0, width: 200, height: 200
      });

      Alert.alert(
        'Region Analysis',
        `Found ${regionStrokes.length} strokes in top-left corner`
      );
    } catch (error) {
      Alert.alert('Error', 'Failed to analyze region');
    }
  }, []);

  return (
    <View style={{ flex: 1 }}>
      <MunimPencilkitView
        ref={canvasRef}
        style={{ flex: 1, backgroundColor: '#FAFAFA' }}
        showToolPicker={true}
        allowsFingerDrawing={true}
        isRulerActive={true}
        drawingPolicy="default"
        toolType="pen"
        onDrawingChanged={({ nativeEvent }) => {
          // Real-time stats could be updated here
        }}
      />

      <ScrollView style={{ maxHeight: 200, padding: 10 }}>
        {drawingStats && (
          <View>
            <Text style={{ fontWeight: 'bold', marginBottom: 10 }}>Drawing Statistics:</Text>
            <Text>Strokes: {drawingStats.strokeCount}</Text>
            <Text>Total Points: {drawingStats.totalPoints}</Text>
            <Text>Average Force: {drawingStats.averageForce.toFixed(3)}</Text>
            <Text>Complexity: {drawingStats.complexity}</Text>
            <Text>Memory Usage: Not available</Text>
            <Text>Ink Types: {JSON.stringify(drawingStats.inkTypes)}</Text>
          </View>
        )}

        <View style={{ flexDirection: 'row', flexWrap: 'wrap', marginTop: 10 }}>
          <Button title="Detailed Analysis" onPress={getDetailedAnalysis} />
          <Button title="Export HD" onPress={exportHighResolution} />
          <Button title="Region Search" onPress={findStrokesInRegion} />
        </View>
      </ScrollView>
    </View>
  );
}
```

## 🎨 Advanced Features

### Stroke-Level Analysis

Access individual stroke data with complete metadata:

```typescript
const strokes = await canvasRef.current?.getAllStrokes();
const firstStroke = strokes[0];

console.log("Stroke data:", {
  pointCount: firstStroke.path.points.length,
  bounds: firstStroke.renderBounds,
  inkType: firstStroke.ink.type,
  averageForce:
    firstStroke.path.points.reduce((sum, p) => sum + p.force, 0) /
    firstStroke.path.points.length,
  duration:
    firstStroke.path.points[firstStroke.path.points.length - 1].timeOffset,
});
```

### Performance Monitoring

Get real-time performance insights:

```typescript
const metrics = await canvasRef.current?.getPerformanceMetrics();
console.log("Performance:", {
  complexity: metrics.strokeComplexity,
  memoryUsage: `${(metrics.memoryUsage / 1024).toFixed(1)}KB`,
  recommendations: metrics.recommendedOptimizations,
});
```

### Content Version Management

Ensure cross-iOS version compatibility:

```typescript
const supportedVersions =
  await canvasRef.current?.getSupportedContentVersions();
const currentVersion = await canvasRef.current?.getContentVersion();
console.log(
  `Current: ${currentVersion}, Supported: ${supportedVersions.join(", ")}`
);
```

For a complete guide to all advanced features, see our [Advanced Features Documentation](./ADVANCED_FEATURES.md).

## 🔍 Troubleshooting

### Common Issues

1. **Tool Picker Not Showing**: Ensure `showToolPicker={true}` and the canvas is focused
2. **Apple Pencil Not Working**: Check that the device supports Apple Pencil and it's paired
3. **Export Failing**: Verify the canvas has content before attempting to export
4. **Performance Issues**: Use the performance metrics API to identify bottlenecks
5. **Strokes Being Modified**: Enable `naturalDrawingMode={true}` or disable ink smoothing/refinement
6. **Handwriting Recognition Interference**: Disable `enableHandwritingRecognition` for pure drawing apps
7. **Empty Strokes or Null Serialization/Export (iOS)**: Update to `munim-pencilkit@1.1.2+`. A prior issue could prevent strokes from registering when disabling handwriting recognition. Version 1.1.2 also adds PNG/PDF fallbacks to snapshot the canvas when drawing bounds are empty.
8. **Need to check content programmatically**: Use `hasContent()`, `getStrokeCount()`, and `getDrawingBounds()` (available in `1.1.3+`).
9. **Methods returning undefined**: Update to `munim-pencilkit@1.2.17+`. This version uses Apple's PencilKit API exactly as documented, eliminating all timing issues.
10. **Serialization methods failing**: Version 1.2.17+ uses direct PencilKit API access with comprehensive debugging via `debugDrawingState()` method.
11. **Drawing not being detected**: Use the new `debugDrawingState()` method to inspect canvas state and verify proper setup.
12. **Complex timing issues**: Version 1.2.17+ removes all complex timing logic and uses PencilKit exactly as Apple intended.
13. **Raw data not appearing**: Ensure `enableRawPencilData={true}` is set and Apple Pencil is connected
14. **Raw data performance issues**: Clear samples periodically and implement sample filtering
15. **Raw data inconsistencies**: Raw data includes all touch phases; PencilKit only shows final processed strokes

### iOS-Specific Issues

1. **Canvas Not Responding**: Make sure the view is properly sized and not hidden
2. **Scribble Not Available**: Scribble requires iOS 14+ and compatible devices
3. **Build Errors**: Ensure you're targeting iOS 13.0+ in your project settings

### Expo-Specific Issues

1. **Development Build Required**: This library requires a development build in Expo
2. **Permissions**: Add Apple Pencil usage description to your `app.json`
3. **Build Errors**: Use Expo SDK 51+ and the latest Expo CLI

### Debug Mode

Enable debug logging in your app:

```typescript
// Debug mode is automatically enabled in development builds
// Debug information is included in method return values when available
```

### Performance Tips

1. **Large Drawings**: Consider using `getAllStrokes()` for analysis of complex drawings
2. **Memory Management**: Monitor stroke count and drawing bounds for memory usage
3. **Export Optimization**: Use appropriate scale factors (1.0-3.0) for exports
4. **Event Throttling**: Throttle `onDrawingChanged` events for better performance

## 👏 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details on how to submit pull requests, report issues, and contribute to the project.

### Development Setup

```bash
git clone https://github.com/munimtechnologies/munim-pencilkit.git
cd munim-pencilkit
npm install

# Run the example app
cd example
npx expo run:ios
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🌟 Why Choose munim-pencilkit?

- **🚀 Complete Feature Coverage**: Only React Native library with 100% PencilKit API coverage
- **💎 Production Ready**: Used in professional drawing and note-taking applications
- **🔬 Advanced Analytics**: Unique stroke-level analysis and drawing insights
- **📱 Modern React Native**: Built for React Native's new architecture with full TypeScript support
- **🎨 Professional Quality**: 60fps drawing with sub-pixel Apple Pencil precision
- **🔄 Future Proof**: Regular updates to support the latest iOS features

<img alt="Star the Munim Technologies repo on GitHub to support the project" src="https://user-images.githubusercontent.com/9664363/185428788-d762fd5d-97b3-4f59-8db7-f72405be9677.gif" width="50%">
