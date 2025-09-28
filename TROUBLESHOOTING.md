# MunimPencilkit Troubleshooting Guide

## Common Issues and Solutions

### 1. Native Module Not Found Error

**Error Message:**
```
Error: Unable to resolve module `./MunimPencilkitModule` from `src/index.ts`
```

**Cause:** The native module isn't properly linked or the Expo development build doesn't include it.

**Solutions:**

#### Option A: Rebuild Development Build (Recommended)
```bash
# For iOS
npx expo run:ios

# For Android  
npx expo run:android
```

#### Option B: Clear Cache and Rebuild
```bash
# Clear Expo cache
npx expo r -c

# Clear Metro cache
npx react-native start --reset-cache

# Rebuild
npx expo run:ios
```

#### Option C: Check Expo Configuration
Make sure your `app.json` or `app.config.js` includes the plugin:

```json
{
  "expo": {
    "plugins": [
      "munim-pencilkit"
    ]
  }
}
```

### 2. requireNativeModule Error

**Error Message:**
```
Error: requireNativeModule is not a function
```

**Cause:** You're using Expo Go instead of a development build.

**Solution:** 
MunimPencilkit requires a development build. You cannot use it with Expo Go.

```bash
# Create development build
npx expo install --fix
npx expo run:ios
```

### 3. Native View Not Found

**Error Message:**
```
Error: Unable to resolve module `MunimPencilkit` from `MunimPencilkitView.tsx`
```

**Cause:** The native view component isn't registered.

**Solutions:**

#### Check Native Module Registration
Ensure your iOS project includes the module registration in `AppDelegate.swift`:

```swift
import MunimPencilkit

// In application:didFinishLaunchingWithOptions:
MunimPencilkitModule.register()
```

#### Verify Pod Installation
```bash
cd ios
pod install
cd ..
npx expo run:ios
```

### 4. Apple Pencil Not Working

**Symptoms:**
- Apple Pencil doesn't respond
- No pressure sensitivity
- Gestures not detected

**Solutions:**

#### Check Device Compatibility
- Apple Pencil (1st gen): iPad Pro 12.9" (1st & 2nd gen), iPad Pro 9.7"
- Apple Pencil (2nd gen): iPad Pro 11" (all), iPad Pro 12.9" (3rd gen+)
- Apple Pencil Pro: iPad Pro 11" (M4), iPad Pro 13" (M4)

#### Verify iOS Version
- PencilKit: iOS 13.0+
- Double-tap gestures: iOS 12.1+
- Squeeze gestures: iOS 16.4+

#### Check Pencil Pairing
1. Go to Settings > Apple Pencil
2. Ensure pencil is connected and charged
3. Test in Apple Notes app first

### 5. Build Errors

#### Swift Compilation Errors
If you see Swift compilation errors, update to the latest version:

```bash
npm install munim-pencilkit@latest
```

#### Metro Bundler Errors
```bash
# Clear Metro cache
npx react-native start --reset-cache

# Clear Expo cache
npx expo r -c
```

### 6. Performance Issues

#### Slow Drawing Performance
```typescript
// Disable raw data collection if not needed
<MunimPencilkitView
  enableRawPencilData={false}
  enablePencilGestures={true}
/>
```

#### Memory Issues
```typescript
// Clear raw samples periodically
useEffect(() => {
  const interval = setInterval(async () => {
    if (rawSamples.length > 1000) {
      await canvasRef.current?.clearRawTouchSamples();
    }
  }, 5000);
  
  return () => clearInterval(interval);
}, [rawSamples.length]);
```

### 7. Web Platform Issues

**Note:** MunimPencilkit is iOS/Android only. On web, it shows a fallback message.

**Solution:** Use platform-specific code:

```typescript
import { Platform } from 'react-native';

const DrawingCanvas = () => {
  if (Platform.OS === 'web') {
    return <div>PencilKit not available on web</div>;
  }
  
  return (
    <MunimPencilkitView
      enablePencilGestures={true}
      onPencilDoubleTap={handleDoubleTap}
    />
  );
};
```

## Debug Mode

Enable debug logging to troubleshoot issues:

```typescript
<MunimPencilkitView
  onDrawingChanged={({ nativeEvent }) => {
    if (nativeEvent.debug) {
      console.log('Debug info:', nativeEvent);
    }
  }}
/>
```

## Getting Help

1. **Check Console Logs:** Look for warning messages that explain the issue
2. **Test in Apple Notes:** Verify Apple Pencil works in native apps
3. **Update Dependencies:** Ensure you're using the latest version
4. **Rebuild Project:** Clear cache and rebuild development build

## Version Compatibility

| Expo SDK | React Native | iOS | Android |
|----------|--------------|-----|---------|
| 51+      | 0.81+        | 13.0+ | 21+ |

## Still Having Issues?

1. Create a minimal reproduction
2. Check the GitHub issues: https://github.com/munimtechnologies/munim-pencilkit/issues
3. Include your environment details:
   - Expo SDK version
   - React Native version
   - iOS/Android version
   - Device model
   - Error messages
