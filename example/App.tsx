import React from 'react';
import {Text, View, StyleSheet } from 'react-native';
import { PencilKitView, type PencilKitConfig } from 'munim-pencilkit';

function App(): React.JSX.Element {
  const config: PencilKitConfig = {
    allowsFingerDrawing: true,
    allowsPencilOnlyDrawing: false,
    isRulerActive: false,
    drawingPolicy: 'anyInput',
    enableApplePencilData: true,
    useCustomStylusView: false,
    showHoverPreview: true,
  };

  return (
    <View style={styles.container}>
      <Text style={styles.text}>Draw with PencilKit below</Text>
      <PencilKitView
        style={styles.canvas}
        config={config}
        enableApplePencilData
        onApplePencilData={(data) => {
          if (data.phase === 'began') {
            console.log('Apple Pencil touch began', data.location);
          }
        }}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    paddingTop: 60,
    backgroundColor: '#fff',
  },
  text: {
    fontSize: 18,
    color: '#1f2937',
    marginHorizontal: 16,
    marginBottom: 16,
  },
  canvas: {
    flex: 1,
    marginHorizontal: 16,
    marginBottom: 16,
    borderWidth: 1,
    borderColor: '#d1d5db',
    borderRadius: 12,
    overflow: 'hidden',
  }
});

export default App;