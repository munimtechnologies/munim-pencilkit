#import <MunimPencilkitSpec/MunimPencilkitSpec.h>
#import <PencilKit/PencilKit.h>
#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTUtils.h>
#import <React/RCTEventEmitter.h>

// Forward declarations
@class StylusDrawingView;

// StylusDrawingView Delegate Protocol
@protocol StylusDrawingViewDelegate <NSObject>
- (void)stylusViewDidToggleEraser:(StylusDrawingView *)view isOn:(BOOL)isOn;
- (void)stylusViewDidStartDrawing:(StylusDrawingView *)view;
- (void)stylusViewDidEndDrawing:(StylusDrawingView *)view;
@end

@interface MunimPencilkit : RCTEventEmitter <NativeMunimPencilkitSpec>

@end

// PencilKit View Manager
@interface PencilKitViewManager : RCTViewManager

@end

// PencilKit Native View with Apple Pencil support
@interface PencilKitView : UIView <PKCanvasViewDelegate, StylusDrawingViewDelegate>

@property (nonatomic, assign) NSInteger viewId;
@property (nonatomic, assign) BOOL enableApplePencilData;
@property (nonatomic, assign) BOOL enableToolPicker;
@property (nonatomic, assign) BOOL enableHapticFeedback;
@property (nonatomic, assign) BOOL enableMotionTracking;
@property (nonatomic, assign) BOOL useCustomStylusView; // New: Toggle between PencilKit and custom view
@property (nonatomic, strong) PKCanvasView *canvasView;
@property (nonatomic, strong) StylusDrawingView *stylusView; // New: Custom stylus drawing view
@property (nonatomic, strong) PKToolPicker *toolPicker;
@property (nonatomic, strong) CMMotionManager *motionManager;

// Apple Pencil interaction state
@property (nonatomic, assign) BOOL isApplePencilActive;
@property (nonatomic, assign) double lastRollAngle;
@property (nonatomic, assign) double lastPitchAngle;
@property (nonatomic, assign) double lastYawAngle;

// Velocity and acceleration tracking
@property (nonatomic, assign) CGPoint lastTouchLocation;
@property (nonatomic, assign) NSTimeInterval lastTouchTimestamp;
@property (nonatomic, assign) double lastVelocity;
@property (nonatomic, assign) double lastAcceleration;

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

// Custom Stylus View methods
- (void)setUseCustomStylusView:(BOOL)useCustom;
- (void)switchToCustomStylusView;
- (void)switchToPencilKitView;

// Apple Pencil methods
- (void)enableHapticFeedback:(BOOL)enabled;
- (void)triggerHapticFeedback:(UIImpactFeedbackStyle)style;
- (void)enableMotionTracking:(BOOL)enabled;
- (void)startMotionTracking;
- (void)stopMotionTracking;

// Stroke analysis methods
- (NSDictionary *)analyzeStroke:(NSArray<NSDictionary *> *)strokePoints;
- (double)calculateStrokeSmoothness:(NSArray<NSDictionary *> *)strokePoints;
- (double)calculateStrokeConsistency:(NSArray<NSDictionary *> *)strokePoints;

@end

// Custom Stylus Drawing View (similar to MotesXcode)
@interface StylusDrawingView : UIView <UIPencilInteractionDelegate>

// Public configuration
@property (nonatomic, assign) BOOL allowsFingerDrawing;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, assign) CGFloat baseLineWidth;
@property (nonatomic, weak) id<StylusDrawingViewDelegate> delegate;

// Drawing methods
- (void)clearCanvas;
- (void)setCanvasImage:(UIImage *)image;
- (UIImage *)snapshotImage;
- (void)setEraserEnabled:(BOOL)enabled;

// Hover handling methods
- (void)updateHoverPreviewAtLocation:(CGPoint)location;
- (void)hideHoverPreview;
- (void)sendHoverEventAtLocation:(CGPoint)location;

@end
