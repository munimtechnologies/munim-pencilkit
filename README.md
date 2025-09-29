<!-- Banner Image -->

<p align="center">
  <a href="https://github.com/munimtechnologies/munim-pencilkit">
    <img alt="Munim Technologies PencilKit" height="128" src="./.github/resources/banner.png?v=3">
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

**munim-pencilkit** is a React Native library for Apple PencilKit integration with comprehensive Apple Pencil support. This library provides advanced stroke analysis, raw sensor data collection, haptic feedback, and professional drawing tools using well-established iOS APIs.

**Fully compatible with Expo!** Works seamlessly with both Expo managed and bare workflows.

**Comprehensive Apple Pencil Support!** Includes pressure sensitivity, tilt detection, predicted touches, coalesced touches, estimated properties, and haptic feedback using verified iOS APIs.

## Table of contents

- [📚 Documentation](#-documentation)
- [🚀 Features](#-features)
- [📦 Installation](#-installation)
- [⚡ Quick Start](#-quick-start)
- [🔧 API Reference](#-api-reference)
- [📖 Usage Examples](#-usage-examples)
- [🎨 Apple Pencil Pro Features](#-apple-pencil-pro-features)
- [🔍 Troubleshooting](#-troubleshooting)
- [👏 Contributing](#-contributing)
- [📄 License](#-license)

## 📚 Documentation

<p>Learn about building PencilKit apps <a aria-label="documentation" href="https://github.com/munimtechnologies/munim-pencilkit#readme">in our documentation!</a></p>

- [Getting Started](#-installation)
- [API Reference](#-api-reference)
- [Usage Examples](#-usage-examples)
- [Apple Pencil Pro Features](#-apple-pencil-pro-features)
- [Troubleshooting](#-troubleshooting)

## 🚀 Features

### Core PencilKit Integration

- 🎨 **Full PencilKit Framework** - Complete Apple PencilKit framework support
- ✏️ **Professional Drawing Tools** - Pen, pencil, marker, eraser, and lasso tools
- 📱 **Native Performance** - Built with Turbo modules for optimal performance
- 🎯 **TypeScript Support** - Full TypeScript definitions included
- 🔄 **Undo/Redo Support** - Built-in drawing history management
- 🎛️ **Configurable** - Customizable drawing policies and tool settings
- 🚀 **Expo Compatible** - Works seamlessly with Expo managed and bare workflows

### Apple Pencil Data Capture

- 📊 **Raw Sensor Data** - Pressure, tilt, azimuth, force, and location data
- 🎯 **Precise Location** - High-precision touch coordinates
- ⚡ **Real-time Streaming** - Live Apple Pencil data streaming
- 🔄 **Coalesced Touches** - High-fidelity input for smooth drawing
- 🔮 **Predicted Touches** - Latency compensation for responsive drawing
- 📈 **Property Tracking** - Estimated properties and refinement updates

### Apple Pencil Advanced Features

- 📊 **Pressure Sensitivity** - Full pressure detection and mapping
- 🎯 **Tilt Detection** - Altitude and azimuth angle tracking
- 🔄 **Coalesced Touches** - High-fidelity input for smooth drawing
- 🔮 **Predicted Touches** - Latency compensation for responsive drawing
- 📈 **Estimated Properties** - Track and handle property refinements
- 📱 **Haptic Feedback** - Tactile responses for interactions
- 🎢 **Motion Tracking** - Core Motion gyroscope data for barrel roll detection
- 🧭 **Device Orientation** - Roll, pitch, and yaw angle tracking

### Advanced Capabilities

- 🧮 **Perpendicular Force** - Computed perpendicular force for accurate pressure
- 📊 **Estimated Properties** - Track and handle property refinements
- 🎨 **Custom Brush Logic** - Advanced brush behavior based on sensor data
- 🔧 **Dynamic Updates** - Update drawing configuration while active
- 📱 **Cross-Platform** - Works on all iOS devices with Apple Pencil support

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

> **Note**: This library requires Expo SDK 50+ and works with both managed and bare workflows.

### iOS Setup

For iOS, add PencilKit framework to your project:

1. Open your project in Xcode
2. Select your target
3. Go to "Build Phases" → "Link Binary With Libraries"
4. Add `PencilKit.framework`

**For Expo projects**, PencilKit framework is automatically included. However, you need to add the following permissions to your `app.json`:

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

## ⚡ Quick Start

### Basic Usage

```tsx
import React, { useRef } from 'react';
import { View, StyleSheet } from 'react-native';
import { PencilKitView, type PencilKitConfig } from 'munim-pencilkit';

export default function DrawingScreen() {
  const pencilKitRef = useRef<any>(null);

  const config: PencilKitConfig = {
    allowsFingerDrawing: true,
    allowsPencilOnlyDrawing: false,
    isRulerActive: false,
    drawingPolicy: 'default',
  };

  return (
    <View style={styles.container}>
      <PencilKitView
        ref={pencilKitRef}
        style={styles.canvas}
        config={config}
        enableApplePencilData={true}
        enableToolPicker={true}
        onApplePencilData={(data) => {
          console.log('Apple Pencil Data:', data);
        }}
        onDrawingChange={(drawing) => {
          console.log('Drawing changed:', drawing);
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
  },
});
```

### Apple Pencil Advanced Usage

```tsx
import React, { useRef } from 'react';
import { View, StyleSheet } from 'react-native';
import {
  PencilKitView,
  type PencilKitConfig,
  type ApplePencilData,
  type ApplePencilMotionData,
} from 'munim-pencilkit';

export default function AdvancedDrawingScreen() {
  const pencilKitRef = useRef<any>(null);

  const config: PencilKitConfig = {
    allowsFingerDrawing: true,
    allowsPencilOnlyDrawing: false,
    isRulerActive: false,
    drawingPolicy: 'default',
    enableHapticFeedback: true,
  };

  return (
    <View style={styles.container}>
      <PencilKitView
        ref={pencilKitRef}
        style={styles.canvas}
        config={config}
        enableApplePencilData={true}
        enableToolPicker={true}
        enableHapticFeedback={true}
        enableMotionTracking={true}
        onApplePencilData={(data: ApplePencilData) => {
          console.log('Advanced Apple Pencil Data:', {
            pressure: data.pressure,
            perpendicularForce: data.perpendicularForce,
            rollAngle: data.rollAngle,
            preciseLocation: data.preciseLocation,
            estimatedProperties: data.estimatedProperties,
          });
        }}
        onApplePencilMotion={(data: ApplePencilMotionData) => {
          console.log('Motion data:', {
            rollAngle: data.rollAngle,
            pitchAngle: data.pitchAngle,
            yawAngle: data.yawAngle,
          });
          // Handle motion - adjust brush orientation, barrel roll effects
        }}
        onApplePencilCoalescedTouches={(data) => {
          console.log('Coalesced touches:', data.touches.length);
          // Handle high-fidelity input for smooth drawing
        }}
        onApplePencilPredictedTouches={(data) => {
          console.log('Predicted touches:', data.touches.length);
          // Handle predicted touches for latency compensation
        }}
        onDrawingChange={(drawing) => {
          console.log('Drawing changed:', drawing);
        }}
      />
    </View>
  );
}
```

## 🔧 API Reference

### PencilKitView Component

Main React Native component for PencilKit integration with full Apple Pencil Pro support.

**Props:**

#### Basic Props

- `config` (PencilKitConfig): PencilKit configuration
- `style` (ViewStyle): Component styling
- `onViewReady` (function): View ready callback

#### Apple Pencil Data Props

- `enableApplePencilData` (boolean): Enable Apple Pencil data capture
- `onApplePencilData` (function): Apple Pencil data callback
- `onApplePencilCoalescedTouches` (function): Coalesced touches callback
- `onApplePencilPredictedTouches` (function): Predicted touches callback
- `onApplePencilEstimatedProperties` (function): Estimated properties callback

#### Apple Pencil Pro Props

- `enableSqueezeInteraction` (boolean): Enable squeeze gesture detection
- `enableDoubleTapInteraction` (boolean): Enable double-tap detection
- `enableHoverSupport` (boolean): Enable hover pose detection
- `enableHapticFeedback` (boolean): Enable haptic feedback
- `onApplePencilSqueeze` (function): Squeeze gesture callback
- `onApplePencilDoubleTap` (function): Double-tap callback
- `onApplePencilHover` (function): Hover pose callback
- `onApplePencilPreferredSqueezeAction` (function): Preferred squeeze action callback

#### Drawing Props

- `enableToolPicker` (boolean): Show tool picker
- `onDrawingChange` (function): Drawing change callback

### PencilKitUtils

Utility functions for advanced PencilKit operations.

**Methods:**

#### View Management

- `createView()`: Create a new PencilKit view
- `destroyView(viewId)`: Destroy a PencilKit view
- `setConfig(viewId, config)`: Configure PencilKit view

#### Drawing Operations

- `getDrawing(viewId)`: Get current drawing data
- `setDrawing(viewId, drawing)`: Set drawing data
- `clearDrawing(viewId)`: Clear the drawing
- `undo(viewId)`: Undo last action
- `redo(viewId)`: Redo last action
- `canUndo(viewId)`: Check if undo is available
- `canRedo(viewId)`: Check if redo is available

#### Apple Pencil Data Capture

- `startApplePencilCapture(viewId)`: Start capturing Apple Pencil data
- `stopApplePencilCapture(viewId)`: Stop capturing Apple Pencil data
- `isApplePencilCaptureActive(viewId)`: Check if capture is active

#### Event Listeners

- `addApplePencilListener(callback)`: Add Apple Pencil data listener
- `removeApplePencilListener()`: Remove Apple Pencil data listener
- `addDrawingChangeListener(callback)`: Add drawing change listener
- `removeDrawingChangeListener()`: Remove drawing change listener
- `addApplePencilSqueezeListener(callback)`: Add squeeze listener
- `removeApplePencilSqueezeListener()`: Remove squeeze listener
- `addApplePencilDoubleTapListener(callback)`: Add double-tap listener
- `removeApplePencilDoubleTapListener()`: Remove double-tap listener
- `addApplePencilHoverListener(callback)`: Add hover listener
- `removeApplePencilHoverListener()`: Remove hover listener
- `addApplePencilCoalescedTouchesListener(callback)`: Add coalesced touches listener
- `removeApplePencilCoalescedTouchesListener()`: Remove coalesced touches listener
- `addApplePencilPredictedTouchesListener(callback)`: Add predicted touches listener
- `removeApplePencilPredictedTouchesListener()`: Remove predicted touches listener
- `addApplePencilEstimatedPropertiesListener(callback)`: Add estimated properties listener
- `removeApplePencilEstimatedPropertiesListener()`: Remove estimated properties listener
- `addApplePencilPreferredSqueezeActionListener(callback)`: Add preferred squeeze action listener
- `removeApplePencilPreferredSqueezeActionListener()`: Remove preferred squeeze action listener

### Types

#### ApplePencilData

Enhanced interface for Apple Pencil data with all advanced properties:

```typescript
interface ApplePencilData {
  // Basic properties
  pressure: number; // 0.0 to 1.0
  altitude: number; // 0.0 to 1.0
  azimuth: number; // 0.0 to 2π radians
  force: number; // 0.0 to 1.0
  maximumPossibleForce: number;
  timestamp: number;

  // Location data
  location: {
    x: number;
    y: number;
  };
  previousLocation: {
    x: number;
    y: number;
  };
  preciseLocation: {
    x: number;
    y: number;
  };

  // Apple Pencil Pro properties
  perpendicularForce: number; // Computed perpendicular force
  rollAngle: number; // Barrel roll angle (Apple Pencil Pro)

  // Touch properties
  isApplePencil: boolean;
  phase: 'began' | 'moved' | 'ended' | 'cancelled';
  hasPreciseLocation: boolean;

  // Advanced properties
  estimatedProperties: string[];
  estimatedPropertiesExpectingUpdates: string[];
}
```

#### Apple Pencil Pro Event Types

```typescript
interface ApplePencilSqueezeData {
  viewId: number;
  phase: 'began' | 'changed' | 'ended';
  value: number;
  timestamp: number;
  isActive: boolean;
  preferredAction:
    | 'ignore'
    | 'showContextualPalette'
    | 'switchPrevious'
    | 'runShortcut';
}

interface ApplePencilDoubleTapData {
  viewId: number;
  phase: 'began' | 'changed' | 'ended';
  timestamp: number;
  isActive: boolean;
}

interface ApplePencilHoverData {
  viewId: number;
  location: {
    x: number;
    y: number;
  };
  altitude: number;
  azimuth: number;
  timestamp: number;
}

interface ApplePencilCoalescedTouchesData {
  viewId: number;
  touches: ApplePencilData[];
  timestamp: number;
}

interface ApplePencilPredictedTouchesData {
  viewId: number;
  touches: ApplePencilData[];
  timestamp: number;
}

interface ApplePencilEstimatedPropertiesData {
  viewId: number;
  touchId: number;
  updatedProperties: string[];
  newData: ApplePencilData;
  timestamp: number;
}

interface ApplePencilPreferredSqueezeActionData {
  preferredAction:
    | 'ignore'
    | 'showContextualPalette'
    | 'switchPrevious'
    | 'runShortcut';
  customAction?: string;
}
```

#### PencilKitConfig

Configuration interface for PencilKit:

```typescript
interface PencilKitConfig {
  // Basic configuration
  allowsFingerDrawing: boolean;
  allowsPencilOnlyDrawing: boolean;
  isRulerActive: boolean;
  drawingPolicy: 'default' | 'anyInput' | 'pencilOnly';

  // Apple Pencil Pro configuration
  enableApplePencilData?: boolean;
  enableToolPicker?: boolean;
  enableSqueezeInteraction?: boolean;
  enableDoubleTapInteraction?: boolean;
  enableHoverSupport?: boolean;
  enableHapticFeedback?: boolean;
}
```

#### Drawing Data Types

```typescript
interface PencilKitDrawingData {
  strokes: PencilKitStroke[];
  bounds: {
    x: number;
    y: number;
    width: number;
    height: number;
  };
}

interface PencilKitStroke {
  points: PencilKitPoint[];
  tool: PencilKitTool;
  color: string;
  width: number;
}

interface PencilKitPoint {
  location: {
    x: number;
    y: number;
  };
  pressure: number;
  azimuth: number;
  altitude: number;
  timestamp: number;
}

interface PencilKitTool {
  type: 'pen' | 'pencil' | 'marker' | 'eraser' | 'lasso';
  width: number;
  color: string;
}
```

## 📖 Usage Examples

### Professional Drawing App with Apple Pencil Pro

```tsx
import React, { useRef, useState } from 'react';
import { View, StyleSheet, Button, Text } from 'react-native';
import {
  PencilKitView,
  PencilKitUtils,
  type ApplePencilData,
  type ApplePencilSqueezeData,
} from 'munim-pencilkit';

const ProfessionalDrawingApp = () => {
  const pencilKitRef = useRef<any>(null);
  const [isDrawing, setIsDrawing] = useState(false);
  const [brushSize, setBrushSize] = useState(5);

  const config = {
    allowsFingerDrawing: false,
    allowsPencilOnlyDrawing: true,
    isRulerActive: true,
    drawingPolicy: 'pencilOnly',
    enableSqueezeInteraction: true,
    enableDoubleTapInteraction: true,
    enableHoverSupport: true,
    enableHapticFeedback: true,
  };

  const handleApplePencilData = (data: ApplePencilData) => {
    // Use advanced properties for sophisticated brush behavior
    const newBrushSize = data.perpendicularForce * 20;
    setBrushSize(newBrushSize);

    // Use roll angle for brush orientation
    const brushAngle = data.rollAngle;

    // Use precise location if available
    const location = data.hasPreciseLocation
      ? data.preciseLocation
      : data.location;

    console.log('Advanced brush data:', {
      size: newBrushSize,
      angle: brushAngle,
      location,
      pressure: data.pressure,
    });
  };

  const handleSqueeze = (data: ApplePencilSqueezeData) => {
    if (data.phase === 'ended') {
      // Show contextual palette on squeeze
      console.log('Showing contextual palette');
    }
  };

  const handleSave = async () => {
    const drawing = await pencilKitRef.current.getDrawing();
    console.log('Saving drawing:', drawing);
  };

  return (
    <View style={styles.container}>
      <PencilKitView
        ref={pencilKitRef}
        style={styles.canvas}
        config={config}
        enableApplePencilData={true}
        enableToolPicker={true}
        enableSqueezeInteraction={true}
        enableDoubleTapInteraction={true}
        enableHoverSupport={true}
        enableHapticFeedback={true}
        onApplePencilData={handleApplePencilData}
        onApplePencilSqueeze={handleSqueeze}
        onApplePencilDoubleTap={(data) => {
          // Toggle between pen and eraser on double tap
          console.log('Double tap - switching tool');
        }}
        onApplePencilHover={(data) => {
          // Show brush preview on hover
          console.log('Hover preview at:', data.location);
        }}
        onDrawingChange={(drawing) => {
          console.log('Drawing changed:', drawing);
        }}
      />
      <View style={styles.controls}>
        <Text>Brush Size: {brushSize.toFixed(1)}</Text>
        <Button title="Save" onPress={handleSave} />
      </View>
    </View>
  );
};
```

### Real-time Data Collection with Advanced Features

```tsx
import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import {
  PencilKitUtils,
  type ApplePencilData,
  type ApplePencilPredictedTouchesData,
  type ApplePencilEstimatedPropertiesData,
} from 'munim-pencilkit';

const AdvancedDataCollectionApp = () => {
  const [pencilData, setPencilData] = useState<ApplePencilData | null>(null);
  const [predictedTouches, setPredictedTouches] =
    useState<ApplePencilPredictedTouchesData | null>(null);
  const [estimatedProperties, setEstimatedProperties] =
    useState<ApplePencilEstimatedPropertiesData | null>(null);

  useEffect(() => {
    // Apple Pencil data listener
    const handlePencilData = (data: ApplePencilData) => {
      setPencilData(data);
    };

    // Predicted touches listener
    const handlePredictedTouches = (data: ApplePencilPredictedTouchesData) => {
      setPredictedTouches(data);
    };

    // Estimated properties listener
    const handleEstimatedProperties = (
      data: ApplePencilEstimatedPropertiesData
    ) => {
      setEstimatedProperties(data);
    };

    PencilKitUtils.addApplePencilListener(handlePencilData);
    PencilKitUtils.addApplePencilPredictedTouchesListener(
      handlePredictedTouches
    );
    PencilKitUtils.addApplePencilEstimatedPropertiesListener(
      handleEstimatedProperties
    );

    return () => {
      PencilKitUtils.removeApplePencilListener(handlePencilData);
      PencilKitUtils.removeApplePencilPredictedTouchesListener(
        handlePredictedTouches
      );
      PencilKitUtils.removeApplePencilEstimatedPropertiesListener(
        handleEstimatedProperties
      );
    };
  }, []);

  return (
    <ScrollView style={styles.container}>
      <Text style={styles.title}>Advanced Apple Pencil Data</Text>

      {pencilData && (
        <View style={styles.dataContainer}>
          <Text style={styles.sectionTitle}>Basic Data</Text>
          <Text>Pressure: {pencilData.pressure.toFixed(3)}</Text>
          <Text>Altitude: {pencilData.altitude.toFixed(3)}</Text>
          <Text>Azimuth: {pencilData.azimuth.toFixed(3)}</Text>
          <Text>Force: {pencilData.force.toFixed(3)}</Text>

          <Text style={styles.sectionTitle}>Apple Pencil Pro Data</Text>
          <Text>
            Perpendicular Force: {pencilData.perpendicularForce.toFixed(3)}
          </Text>
          <Text>Roll Angle: {pencilData.rollAngle.toFixed(3)}</Text>
          <Text>
            Has Precise Location: {pencilData.hasPreciseLocation ? 'Yes' : 'No'}
          </Text>

          <Text style={styles.sectionTitle}>Location Data</Text>
          <Text>
            Location: ({pencilData.location.x.toFixed(1)},{' '}
            {pencilData.location.y.toFixed(1)})
          </Text>
          <Text>
            Precise: ({pencilData.preciseLocation.x.toFixed(1)},{' '}
            {pencilData.preciseLocation.y.toFixed(1)})
          </Text>

          <Text style={styles.sectionTitle}>Advanced Properties</Text>
          <Text>Estimated: {pencilData.estimatedProperties.join(', ')}</Text>
          <Text>
            Expecting Updates:{' '}
            {pencilData.estimatedPropertiesExpectingUpdates.join(', ')}
          </Text>
        </View>
      )}

      {predictedTouches && (
        <View style={styles.dataContainer}>
          <Text style={styles.sectionTitle}>Predicted Touches</Text>
          <Text>Count: {predictedTouches.touches.length}</Text>
          <Text>Timestamp: {predictedTouches.timestamp}</Text>
        </View>
      )}

      {estimatedProperties && (
        <View style={styles.dataContainer}>
          <Text style={styles.sectionTitle}>Estimated Properties Update</Text>
          <Text>Touch ID: {estimatedProperties.touchId}</Text>
          <Text>
            Updated: {estimatedProperties.updatedProperties.join(', ')}
          </Text>
          <Text>Timestamp: {estimatedProperties.timestamp}</Text>
        </View>
      )}
    </ScrollView>
  );
};
```

## 🎨 Apple Pencil Pro Features

### Squeeze Gestures

Apple Pencil Pro squeeze gestures allow users to perform actions by squeezing the pencil:

```tsx
<PencilKitView
  enableSqueezeInteraction={true}
  onApplePencilSqueeze={(data) => {
    if (data.phase === 'ended') {
      // Show contextual palette
      showContextualPalette(data.preferredAction);
    }
  }}
/>
```

### Double Tap Gestures

Double-tap gestures for quick tool switching:

```tsx
<PencilKitView
  enableDoubleTapInteraction={true}
  onApplePencilDoubleTap={(data) => {
    if (data.phase === 'ended') {
      // Toggle between pen and eraser
      toggleTool();
    }
  }}
/>
```

### Hover Effects

Hover pose detection for previews and visual feedback:

```tsx
<PencilKitView
  enableHoverSupport={true}
  onApplePencilHover={(data) => {
    // Show brush preview at hover location
    showBrushPreview(data.location, data.altitude);
  }}
/>
```

### Barrel Roll Support

Use barrel roll for brush angle control:

```tsx
<PencilKitView
  onApplePencilData={(data) => {
    // Use roll angle for brush orientation
    const brushAngle = data.rollAngle;
    updateBrushOrientation(brushAngle);
  }}
/>
```

### Predicted Touches

Use predicted touches for latency compensation:

```tsx
<PencilKitView
  onApplePencilPredictedTouches={(data) => {
    // Pre-render predicted strokes for smoothness
    preRenderStrokes(data.touches);
  }}
/>
```

### Haptic Feedback

Enable haptic feedback for interactions:

```tsx
<PencilKitView
  enableHapticFeedback={true}
  onApplePencilSqueeze={(data) => {
    // Haptic feedback is automatically triggered
    console.log('Squeeze with haptic feedback');
  }}
/>
```

## 🔍 Troubleshooting

### Common Issues

1. **PencilKit Not Loading**: Ensure PencilKit.framework is properly linked in your iOS project
2. **Apple Pencil Data Not Captured**: Check that `enableApplePencilData` is set to true
3. **Drawing Not Appearing**: Verify that the PencilKitView has proper dimensions and styling
4. **Apple Pencil Pro Features Not Working**: Ensure you're using Apple Pencil Pro and iOS 13.0+

### Expo-Specific Issues

1. **Development Build Required**: This library requires a development build in Expo. Use `npx expo run:ios`
2. **Framework Not Found**: Ensure you're using Expo SDK 50+ and have the latest Expo CLI
3. **Build Errors**: Make sure PencilKit.framework is available in your iOS project

### Apple Pencil Pro Issues

1. **Squeeze Not Working**: Ensure `enableSqueezeInteraction` is true and using Apple Pencil Pro
2. **Hover Not Detected**: Check that `enableHoverSupport` is true and pencil is hovering
3. **Haptic Feedback Missing**: Verify `enableHapticFeedback` is true and device supports haptics

### Debug Mode

Enable debug logging by setting the following environment variable:

```bash
export REACT_NATIVE_PENCILKIT_DEBUG=1
```

### Requirements

- iOS 13.0+
- React Native 0.60+
- Xcode 11+
- Apple Pencil (for full functionality)
- Apple Pencil Pro (for advanced features)
- Expo SDK 50+ (for Expo projects)

## 👏 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details on how to submit pull requests, report issues, and contribute to the project.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<img alt="Star the Munim Technologies repo on GitHub to support the project" src="https://user-images.githubusercontent.com/9664363/185428788-d762fd5d-97b3-4f59-8db7-f72405be9677.gif" width="50%">
