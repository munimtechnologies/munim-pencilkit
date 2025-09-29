#import <MunimPencilkitSpec/MunimPencilkitSpec.h>
#import <PencilKit/PencilKit.h>
#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTUtils.h>
#import <React/RCTEventEmitter.h>

@interface MunimPencilkit : NSObject <NativeMunimPencilkitSpec>

@end

// PencilKit View Manager
@interface PencilKitViewManager : RCTViewManager

@end

// PencilKit Native View with Apple Pencil support
@interface PencilKitView : UIView <PKCanvasViewDelegate>

@property (nonatomic, assign) NSInteger viewId;
@property (nonatomic, assign) BOOL enableApplePencilData;
@property (nonatomic, assign) BOOL enableToolPicker;
@property (nonatomic, assign) BOOL enableHapticFeedback;
@property (nonatomic, assign) BOOL enableMotionTracking;
@property (nonatomic, strong) PKCanvasView *canvasView;
@property (nonatomic, strong) PKToolPicker *toolPicker;
@property (nonatomic, strong) CMMotionManager *motionManager;

// Apple Pencil interaction state
@property (nonatomic, assign) BOOL isApplePencilActive;
@property (nonatomic, assign) double lastRollAngle;
@property (nonatomic, assign) double lastPitchAngle;
@property (nonatomic, assign) double lastYawAngle;

- (instancetype)initWithViewId:(NSInteger)viewId;
- (void)updateConfig:(NSDictionary *)config;
- (NSDictionary *)getDrawingData;
- (void)setDrawingData:(NSDictionary *)drawingData;
- (void)clearDrawing;
- (BOOL)undo;
- (BOOL)redo;
- (BOOL)canUndo;
- (BOOL)canRedo;
- (void)startApplePencilDataCapture;
- (void)stopApplePencilDataCapture;
- (BOOL)isApplePencilDataCaptureActive;

// Apple Pencil methods
- (void)enableHapticFeedback:(BOOL)enabled;
- (void)triggerHapticFeedback:(UIImpactFeedbackStyle)style;
- (void)enableMotionTracking:(BOOL)enabled;
- (void)startMotionTracking;
- (void)stopMotionTracking;

@end
