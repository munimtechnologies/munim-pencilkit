# Quick Start Guide - MunimPencilkit

## 🚀 Get Started in 5 Minutes

### 1. Install the Package

```bash
npm install munim-pencilkit@latest
# or
yarn add munim-pencilkit@latest
```

### 2. Configure Expo Plugin

Add to your `app.json` or `app.config.js`:

```json
{
  "expo": {
    "plugins": ["munim-pencilkit"]
  }
}
```

### 3. Create Development Build

**Important:** MunimPencilkit requires a development build (not Expo Go).

```bash
# For iOS
npx expo run:ios

# For Android
npx expo run:android
```

### 4. Basic Usage

```tsx
import React, { useRef } from "react";
import { MunimPencilkitView } from "munim-pencilkit";

export default function DrawingScreen() {
  const canvasRef = useRef(null);

  return (
    <MunimPencilkitView
      ref={canvasRef}
      style={{ flex: 1 }}
      enablePencilGestures={true}
      onPencilDoubleTap={(event) => {
        console.log("Double tap detected!", event);
      }}
      onDrawingChanged={(event) => {
        console.log("Drawing changed:", event.nativeEvent);
      }}
    />
  );
}
```

## 🔧 Troubleshooting

### If you see "Native module not found" error:

1. **Rebuild your development build:**

   ```bash
   npx expo run:ios
   ```

2. **Clear cache and rebuild:**

   ```bash
   npx expo r -c
   npx expo run:ios
   ```

3. **Check your app.json includes the plugin:**
   ```json
   {
     "expo": {
       "plugins": ["munim-pencilkit"]
     }
   }
   ```

### If Apple Pencil isn't working:

1. **Test in Apple Notes first** - ensure pencil is paired
2. **Check device compatibility** - see TROUBLESHOOTING.md
3. **Verify iOS version** - requires iOS 13.0+

## 📚 Next Steps

- **Raw Data Collection:** See `raw-pencil-data-example.js`
- **Gesture Detection:** See `apple-pencil-gestures-example.js`
- **Full Documentation:** See `README.md`
- **Troubleshooting:** See `TROUBLESHOOTING.md`

## 🆘 Need Help?

1. Check the console for helpful error messages
2. Read the TROUBLESHOOTING.md guide
3. Ensure you're using a development build (not Expo Go)
4. Test Apple Pencil in Apple Notes first

---

**Note:** This package is iOS/Android only. On web, it shows a helpful fallback message.
