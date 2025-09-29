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

**munim-pencilkit** is a React Native library for complete Apple PencilKit integration with Turbo modules. This library provides 100% feature coverage including advanced stroke analysis, Scribble support, raw Apple Pencil data collection, gesture detection, and professional drawing tools.

**Fully compatible with Expo!** Works seamlessly with both Expo managed and bare workflows.

**Note**: This library focuses on reliability and platform compatibility. It provides complete Apple PencilKit framework support with optimal performance through Turbo modules, rather than attempting to support all possible drawing features which may not work reliably.

## Table of contents

- [📚 Documentation](#-documentation)
- [🚀 Features](#-features)
- [📦 Installation](#-installation)
- [⚡ Quick Start](#-quick-start)
- [🔧 API Reference](#-api-reference)
- [📖 Usage Examples](#-usage-examples)
- [🔍 Troubleshooting](#-troubleshooting)
- [👏 Contributing](#-contributing)
- [📄 License](#-license)

## 📚 Documentation

<p>Learn about building PencilKit apps <a aria-label="documentation" href="https://github.com/munimtechnologies/munim-pencilkit#readme">in our documentation!</a></p>

- [Getting Started](#-installation)
- [API Reference](#-api-reference)
- [Usage Examples](#-usage-examples)
- [Troubleshooting](#-troubleshooting)

## 🚀 Features

- 🎨 **Full PencilKit Integration** - Complete Apple PencilKit framework support
- ✏️ **Apple Pencil Data Capture** - Raw pressure, tilt, azimuth, and force data
- 🛠️ **Professional Drawing Tools** - Pen, pencil, marker, eraser, and lasso tools
- 📱 **Native Performance** - Built with Turbo modules for optimal performance
- 🎯 **TypeScript Support** - Full TypeScript definitions included
- 🔄 **Undo/Redo Support** - Built-in drawing history management
- 📊 **Real-time Data** - Live Apple Pencil data streaming
- 🎛️ **Configurable** - Customizable drawing policies and tool settings
- 🚀 **Expo Compatible** - Works seamlessly with Expo managed and bare workflows
- ✅ **Platform-Supported Drawing** - Support for core PencilKit features that work reliably on iOS
- 🔧 **Dynamic Updates** - Update drawing configuration while drawing is active

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

### Advanced Usage with Apple Pencil Data

```tsx
import { PencilKitUtils, type ApplePencilData } from 'munim-pencilkit';

// Start capturing Apple Pencil data
await PencilKitUtils.startApplePencilCapture(viewId);

// Listen for Apple Pencil data
PencilKitUtils.addApplePencilListener((data: ApplePencilData) => {
  console.log('Pressure:', data.pressure);
  console.log('Tilt:', data.altitude);
  console.log('Azimuth:', data.azimuth);
  console.log('Force:', data.force);
  console.log('Location:', data.location);
  console.log('Is Apple Pencil:', data.isApplePencil);
});

// Drawing operations
const drawing = await pencilKitRef.current.getDrawing();
await pencilKitRef.current.setDrawing(drawingData);
await pencilKitRef.current.clearDrawing();
await pencilKitRef.current.undo();
await pencilKitRef.current.redo();
```

## 🔧 API Reference

### Functions

#### `PencilKitView`

Main React Native component for PencilKit integration.

**Props:**

- `config` (PencilKitConfig): PencilKit configuration
- `enableApplePencilData` (boolean): Enable Apple Pencil data capture
- `enableToolPicker` (boolean): Show tool picker
- `onApplePencilData` (function): Apple Pencil data callback
- `onDrawingChange` (function): Drawing change callback
- `onViewReady` (function): View ready callback

#### `PencilKitUtils`

Utility functions for advanced PencilKit operations.

**Methods:**

- `startApplePencilCapture(viewId)`: Start capturing Apple Pencil data
- `addApplePencilListener(callback)`: Add Apple Pencil data listener
- `removeApplePencilListener(callback)`: Remove Apple Pencil data listener

### Types

#### `ApplePencilData`

Interface for Apple Pencil data:

```typescript
interface ApplePencilData {
  pressure: number; // 0.0 to 1.0
  altitude: number; // 0.0 to 1.0
  azimuth: number; // 0.0 to 2π radians
  force: number; // 0.0 to 1.0
  maximumPossibleForce: number;
  timestamp: number;
  location: {
    x: number;
    y: number;
  };
  previousLocation: {
    x: number;
    y: number;
  };
  isApplePencil: boolean;
  phase: 'began' | 'moved' | 'ended' | 'cancelled';
}
```

#### `PencilKitConfig`

Configuration interface for PencilKit:

```typescript
interface PencilKitConfig {
  allowsFingerDrawing: boolean;
  allowsPencilOnlyDrawing: boolean;
  isRulerActive: boolean;
  drawingPolicy: 'default' | 'anyInput' | 'pencilOnly';
}
```

#### `PencilKitDrawingData`

Drawing data interface:

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

### Professional Drawing App

```tsx
import React, { useRef, useState } from 'react';
import { View, StyleSheet, Button } from 'react-native';
import { PencilKitView, PencilKitUtils } from 'munim-pencilkit';

const ProfessionalDrawingApp = () => {
  const pencilKitRef = useRef<any>(null);
  const [isDrawing, setIsDrawing] = useState(false);

  const config = {
    allowsFingerDrawing: false,
    allowsPencilOnlyDrawing: true,
    isRulerActive: true,
    drawingPolicy: 'pencilOnly',
  };

  const handleSave = async () => {
    const drawing = await pencilKitRef.current.getDrawing();
    console.log('Saving drawing:', drawing);
  };

  const handleClear = async () => {
    await pencilKitRef.current.clearDrawing();
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
      <View style={styles.controls}>
        <Button title="Save" onPress={handleSave} />
        <Button title="Clear" onPress={handleClear} />
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  canvas: {
    flex: 1,
  },
  controls: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    padding: 20,
  },
});
```

### Real-time Data Collection

```tsx
import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { PencilKitUtils, type ApplePencilData } from 'munim-pencilkit';

const DataCollectionApp = () => {
  const [pencilData, setPencilData] = useState<ApplePencilData | null>(null);

  useEffect(() => {
    const handlePencilData = (data: ApplePencilData) => {
      setPencilData(data);
    };

    PencilKitUtils.addApplePencilListener(handlePencilData);

    return () => {
      PencilKitUtils.removeApplePencilListener(handlePencilData);
    };
  }, []);

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Apple Pencil Data</Text>
      {pencilData && (
        <View style={styles.dataContainer}>
          <Text>Pressure: {pencilData.pressure.toFixed(3)}</Text>
          <Text>Altitude: {pencilData.altitude.toFixed(3)}</Text>
          <Text>Azimuth: {pencilData.azimuth.toFixed(3)}</Text>
          <Text>Force: {pencilData.force.toFixed(3)}</Text>
          <Text>
            Location: ({pencilData.location.x.toFixed(1)},{' '}
            {pencilData.location.y.toFixed(1)})
          </Text>
          <Text>
            Is Apple Pencil: {pencilData.isApplePencil ? 'Yes' : 'No'}
          </Text>
          <Text>Phase: {pencilData.phase}</Text>
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
  },
  dataContainer: {
    backgroundColor: '#f0f0f0',
    padding: 15,
    borderRadius: 8,
  },
});
```

### Custom Drawing Tools

```tsx
import React, { useRef } from 'react';
import { View, StyleSheet, Button } from 'react-native';
import { PencilKitView } from 'munim-pencilkit';

const CustomToolsApp = () => {
  const pencilKitRef = useRef<any>(null);

  const config = {
    allowsFingerDrawing: true,
    allowsPencilOnlyDrawing: false,
    isRulerActive: false,
    drawingPolicy: 'anyInput',
  };

  const handleUndo = async () => {
    const canUndo = await pencilKitRef.current.canUndo();
    if (canUndo) {
      await pencilKitRef.current.undo();
    }
  };

  const handleRedo = async () => {
    const canRedo = await pencilKitRef.current.canRedo();
    if (canRedo) {
      await pencilKitRef.current.redo();
    }
  };

  return (
    <View style={styles.container}>
      <PencilKitView
        ref={pencilKitRef}
        style={styles.canvas}
        config={config}
        enableToolPicker={true}
        onDrawingChange={(drawing) => {
          console.log('Drawing changed:', drawing);
        }}
      />
      <View style={styles.toolbar}>
        <Button title="Undo" onPress={handleUndo} />
        <Button title="Redo" onPress={handleRedo} />
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  canvas: {
    flex: 1,
  },
  toolbar: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    padding: 20,
  },
});
```

## 🔍 Troubleshooting

### Common Issues

1. **PencilKit Not Loading**: Ensure PencilKit.framework is properly linked in your iOS project
2. **Apple Pencil Data Not Captured**: Check that `enableApplePencilData` is set to true
3. **Drawing Not Appearing**: Verify that the PencilKitView has proper dimensions and styling

### Expo-Specific Issues

1. **Development Build Required**: This library requires a development build in Expo. Use `npx expo run:ios`
2. **Framework Not Found**: Ensure you're using Expo SDK 50+ and have the latest Expo CLI
3. **Build Errors**: Make sure PencilKit.framework is available in your iOS project

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
- Expo SDK 50+ (for Expo projects)

## 👏 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details on how to submit pull requests, report issues, and contribute to the project.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<img alt="Star the Munim Technologies repo on GitHub to support the project" src="https://user-images.githubusercontent.com/9664363/185428788-d762fd5d-97b3-4f59-8db7-f72405be9677.gif" width="50%">
