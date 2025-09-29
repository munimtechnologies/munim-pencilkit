# Munim PencilKit

Complete Apple PencilKit implementation for React Native with Turbo modules - 100% feature coverage including advanced stroke analysis, Scribble support, raw Apple Pencil data collection, gesture detection, and professional drawing tools.

## Features

- 🎨 **Full PencilKit Integration** - Complete Apple PencilKit framework support
- ✏️ **Apple Pencil Data Capture** - Raw pressure, tilt, azimuth, and force data
- 🛠️ **Professional Drawing Tools** - Pen, pencil, marker, eraser, and lasso tools
- 📱 **Native Performance** - Built with Turbo modules for optimal performance
- 🎯 **TypeScript Support** - Full TypeScript definitions included
- 🔄 **Undo/Redo Support** - Built-in drawing history management
- 📊 **Real-time Data** - Live Apple Pencil data streaming
- 🎛️ **Configurable** - Customizable drawing policies and tool settings

## Installation

```sh
npm install munim-pencilkit
```

### iOS Setup

Add PencilKit framework to your iOS project:

1. Open your project in Xcode
2. Select your target
3. Go to "Build Phases" → "Link Binary With Libraries"
4. Add `PencilKit.framework`

## Usage

### Basic PencilKit View

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
    drawingPolicy: 'default'
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

### Apple Pencil Data Capture

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
```

### Drawing Operations

```tsx
// Get current drawing
const drawing = await pencilKitRef.current.getDrawing();

// Set drawing data
await pencilKitRef.current.setDrawing(drawingData);

// Clear drawing
await pencilKitRef.current.clearDrawing();

// Undo/Redo
await pencilKitRef.current.undo();
await pencilKitRef.current.redo();

// Check if undo/redo is available
const canUndo = await pencilKitRef.current.canUndo();
const canRedo = await pencilKitRef.current.canRedo();
```

## API Reference

### PencilKitView Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `config` | `PencilKitConfig` | - | PencilKit configuration |
| `enableApplePencilData` | `boolean` | `false` | Enable Apple Pencil data capture |
| `enableToolPicker` | `boolean` | `true` | Show tool picker |
| `onApplePencilData` | `(data: ApplePencilData) => void` | - | Apple Pencil data callback |
| `onDrawingChange` | `(drawing: PencilKitDrawingData) => void` | - | Drawing change callback |
| `onViewReady` | `(viewId: number) => void` | - | View ready callback |

### ApplePencilData Interface

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

### PencilKitConfig Interface

```typescript
interface PencilKitConfig {
  allowsFingerDrawing: boolean;
  allowsPencilOnlyDrawing: boolean;
  isRulerActive: boolean;
  drawingPolicy: 'default' | 'anyInput' | 'pencilOnly';
}
```

### PencilKitDrawingData Interface

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

## Example App

Run the example app to see all features in action:

```bash
cd example
npm install
npx react-native run-ios
```

The example app demonstrates:
- Drawing with Apple Pencil
- Real-time Apple Pencil data display
- Undo/Redo functionality
- Drawing save/load
- Tool picker integration

## Requirements

- iOS 13.0+
- React Native 0.60+
- Xcode 11+
- Apple Pencil (for full functionality)

## Contributing

- [Development workflow](CONTRIBUTING.md#development-workflow)
- [Sending a pull request](CONTRIBUTING.md#sending-a-pull-request)
- [Code of conduct](CODE_OF_CONDUCT.md)

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
