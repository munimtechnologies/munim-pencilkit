// Robust serialization example that handles both formats
// This works with both v1.2.10 and v1.2.11+

const fetchSerializedDrawing = async () => {
  try {
    console.log('🔍 Fetching drawing data...');
    
    // Try to get drawing data with multiple fallback strategies
    let drawingData = null;
    let hasContent = false;
    let strokeCount = 0;
    
    // Strategy 1: Try normal mode first
    try {
      const dataResult = await canvasRef.current?.getDrawingData();
      console.log('📊 Data result:', dataResult);
      
      if (dataResult) {
        // Handle both ArrayBuffer and debug object formats
        if (dataResult instanceof ArrayBuffer) {
          drawingData = dataResult;
          console.log('✅ Got ArrayBuffer data directly');
        } else if (dataResult && typeof dataResult === 'object') {
          // Handle debug object format
          if (dataResult.data) {
            drawingData = dataResult.data;
            console.log('✅ Got data from debug object:', dataResult);
          } else if (dataResult.result) {
            drawingData = dataResult.result;
            console.log('✅ Got data from result field:', dataResult);
          }
        }
      }
    } catch (error) {
      console.warn('⚠️ Normal mode failed, trying debug mode:', error);
      
      // Strategy 2: Try debug mode as fallback
      try {
        const debugResult = await canvasRef.current?.getDrawingData(true);
        console.log('🐛 Debug result:', debugResult);
        
        if (debugResult && debugResult.result) {
          drawingData = debugResult.result;
          console.log('✅ Got data from debug result');
        }
      } catch (debugError) {
        console.error('❌ Debug mode also failed:', debugError);
      }
    }
    
    // Get content status with similar fallback
    try {
      const contentResult = await canvasRef.current?.hasContent();
      if (typeof contentResult === 'boolean') {
        hasContent = contentResult;
      } else if (contentResult && typeof contentResult === 'object') {
        hasContent = contentResult.hasContent || contentResult.result || false;
      }
    } catch (error) {
      console.warn('⚠️ hasContent failed:', error);
    }
    
    // Get stroke count with similar fallback
    try {
      const strokeResult = await canvasRef.current?.getStrokeCount();
      if (typeof strokeResult === 'number') {
        strokeCount = strokeResult;
      } else if (strokeResult && typeof strokeResult === 'object') {
        strokeCount = strokeResult.strokeCount || strokeResult.result || 0;
      }
    } catch (error) {
      console.warn('⚠️ getStrokeCount failed:', error);
    }
    
    console.log('📈 Final results:', {
      hasContent,
      strokeCount,
      dataSize: drawingData ? drawingData.byteLength : 0
    });
    
    if (hasContent && drawingData) {
      // Convert ArrayBuffer to base64 for storage
      const uint8Array = new Uint8Array(drawingData);
      const base64 = btoa(String.fromCharCode(...uint8Array));
      
      console.log('💾 Saving drawing data:', {
        base64Length: base64.length,
        originalSize: drawingData.byteLength
      });
      
      // Save to your storage system
      await saveDrawingData(base64);
      
      return {
        success: true,
        data: base64,
        strokeCount,
        size: drawingData.byteLength
      };
    } else {
      console.log('📝 No content to save');
      return {
        success: false,
        message: 'No drawing content found',
        hasContent,
        strokeCount
      };
    }
    
  } catch (error) {
    console.error('❌ Serialization failed:', error);
    return {
      success: false,
      error: error.message
    };
  }
};

// Helper function to save data (implement based on your storage system)
const saveDrawingData = async (base64Data) => {
  // Example: Save to AsyncStorage, database, or file system
  // await AsyncStorage.setItem('drawingData', base64Data);
  console.log('💾 Would save data:', base64Data.substring(0, 50) + '...');
};

export default fetchSerializedDrawing;
