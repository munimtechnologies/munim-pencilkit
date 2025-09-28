import React, { useRef, useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import MunimPencilkitView from './src/MunimPencilkitView';

const ReactNativeExample = () => {
  const pencilKitRef = useRef(null);
  const [isNearby, setIsNearby] = useState(false);
  const [hoverCount, setHoverCount] = useState(0);

  return (
    <View style={styles.container}>
      <Text style={styles.title}>React Native Hover & Proximity Test</Text>
      
      <MunimPencilkitView
        ref={pencilKitRef}
        style={styles.canvas}
        enableHoverDetection={true}
        enableRawPencilData={true}
        drawingPolicy="pencilOnly"
        allowsFingerDrawing={false}
        
        // Hover events - these work in React Native!
        onRawTouchHovered={(event) => {
          console.log('Hover detected:', event.nativeEvent);
          setHoverCount(prev => prev + 1);
        }}
        
        // Proximity events - these work in React Native!
        onPencilProximityChanged={(event) => {
          console.log('Proximity changed:', event.nativeEvent);
          setIsNearby(event.nativeEvent.isNearby);
        }}
        
        // Air movement events - these work in React Native!
        onPencilAirMovement={(event) => {
          console.log('Air movement:', event.nativeEvent);
        }}
        
        // Raw touch events - these work in React Native!
        onRawTouchBegan={(event) => {
          console.log('Raw touch began:', event.nativeEvent);
        }}
      />
      
      <View style={styles.status}>
        <Text>Pencil Nearby: {isNearby ? '✅ YES' : '❌ NO'}</Text>
        <Text>Hover Events: {hoverCount}</Text>
      </View>
      
      <TouchableOpacity 
        style={styles.button}
        onPress={async () => {
          // These methods work in React Native!
          const nearby = await pencilKitRef.current?.isPencilNearby();
          const hoverSamples = await pencilKitRef.current?.getHoverSamples();
          const proximitySamples = await pencilKitRef.current?.getProximitySamples();
          
          console.log('Pencil nearby:', nearby);
          console.log('Hover samples:', hoverSamples);
          console.log('Proximity samples:', proximitySamples);
        }}
      >
        <Text style={styles.buttonText}>Get Data</Text>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  title: {
    fontSize: 20,
    fontWeight: 'bold',
    textAlign: 'center',
    margin: 20,
  },
  canvas: {
    flex: 1,
    backgroundColor: 'white',
    margin: 20,
    borderRadius: 10,
  },
  status: {
    padding: 20,
    backgroundColor: 'white',
    margin: 20,
    borderRadius: 10,
  },
  button: {
    backgroundColor: '#007AFF',
    padding: 15,
    margin: 20,
    borderRadius: 10,
  },
  buttonText: {
    color: 'white',
    textAlign: 'center',
    fontWeight: 'bold',
  },
});

export default ReactNativeExample;
