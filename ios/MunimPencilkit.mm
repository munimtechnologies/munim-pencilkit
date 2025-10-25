#import "MunimPencilkit.h"
#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTUtils.h>
#import <React/RCTEventEmitter.h>

// Global dictionary to store PencilKit views
static NSMutableDictionary<NSNumber *, PencilKitView *> *pencilKitViews = nil;
// Global reference to the MunimPencilkit instance for event sending
static MunimPencilkit *munimPencilkitInstance = nil;

@implementation MunimPencilkit
RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

- (NSArray<NSString *> *)supportedEvents
{
    return @[
        @"onApplePencilData", 
        @"onPencilKitDrawingChange",
        @"onApplePencilCoalescedTouches",
        @"onApplePencilPredictedTouches",
        @"onApplePencilEstimatedProperties",
        @"onApplePencilMotion",
        @"onApplePencilHover"
    ];
}

- (void)addListener:(NSString *)eventName
{
    [super addListener:eventName];
}

- (void)removeListeners:(NSInteger)count
{
    [super removeListeners:count];
}

+ (void)initialize {
    if (self == [MunimPencilkit class]) {
        pencilKitViews = [[NSMutableDictionary alloc] init];
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        munimPencilkitInstance = self;
    }
    return self;
}

- (NSNumber *)multiply:(double)a b:(double)b {
    NSNumber *result = @(a * b);
    return result;
}

// PencilKit View Management
- (void)createPencilKitView:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    dispatch_async(dispatch_get_main_queue(), ^{
        static NSInteger nextViewId = 1;
        NSInteger viewId = nextViewId++;
        
        PencilKitView *pencilKitView = [[PencilKitView alloc] initWithViewId:viewId];
        pencilKitViews[@(viewId)] = pencilKitView;
        
        resolve(@(viewId));
    });
}

- (void)destroyPencilKitView:(double)viewId resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNumber *viewIdNumber = @((NSInteger)viewId);
        PencilKitView *pencilKitView = pencilKitViews[viewIdNumber];
        
        if (pencilKitView) {
            [pencilKitView removeFromSuperview];
            [pencilKitViews removeObjectForKey:viewIdNumber];
            if (resolve) { resolve(nil); }
        } else {
            if (reject) { reject(@"VIEW_NOT_FOUND", @"PencilKit view not found", nil); }
        }
    });
}

- (void)setPencilKitConfig:(double)viewId config:(NSDictionary *)config resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    dispatch_async(dispatch_get_main_queue(), ^{
        PencilKitView *pencilKitView = pencilKitViews[@((NSInteger)viewId)];
        if (pencilKitView) {
            [pencilKitView updateConfig:config];
            if (resolve) { resolve(nil); }
        } else {
            if (reject) { reject(@"VIEW_NOT_FOUND", @"PencilKit view not found", nil); }
        }
    });
}



- (void)getPencilKitDrawing:(double)viewId resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    dispatch_async(dispatch_get_main_queue(), ^{
        PencilKitView *pencilKitView = pencilKitViews[@((NSInteger)viewId)];
        if (pencilKitView) {
            NSDictionary *drawing = [pencilKitView getDrawingData];
            resolve(drawing);
        } else {
            reject(@"VIEW_NOT_FOUND", @"PencilKit view not found", nil);
        }
    });
}

- (void)setPencilKitDrawing:(double)viewId drawing:(NSDictionary *)drawing resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    dispatch_async(dispatch_get_main_queue(), ^{
        PencilKitView *pencilKitView = pencilKitViews[@((NSInteger)viewId)];
        if (pencilKitView) {
            [pencilKitView setDrawingData:drawing];
            if (resolve) { resolve(nil); }
        } else {
            if (reject) { reject(@"VIEW_NOT_FOUND", @"PencilKit view not found", nil); }
        }
    });
}

- (void)clearPencilKitDrawing:(double)viewId resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    dispatch_async(dispatch_get_main_queue(), ^{
        PencilKitView *pencilKitView = pencilKitViews[@((NSInteger)viewId)];
        if (pencilKitView) {
            [pencilKitView clearDrawing];
            if (resolve) { resolve(nil); }
        } else {
            if (reject) { reject(@"VIEW_NOT_FOUND", @"PencilKit view not found", nil); }
        }
    });
}

- (void)undoPencilKitDrawing:(double)viewId resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    dispatch_async(dispatch_get_main_queue(), ^{
        PencilKitView *pencilKitView = pencilKitViews[@((NSInteger)viewId)];
        if (pencilKitView) {
            BOOL canUndo = [pencilKitView undo];
            resolve(@(canUndo));
        } else {
            reject(@"VIEW_NOT_FOUND", @"PencilKit view not found", nil);
        }
    });
}

- (void)redoPencilKitDrawing:(double)viewId resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    dispatch_async(dispatch_get_main_queue(), ^{
        PencilKitView *pencilKitView = pencilKitViews[@((NSInteger)viewId)];
        if (pencilKitView) {
            BOOL canRedo = [pencilKitView redo];
            resolve(@(canRedo));
        } else {
            reject(@"VIEW_NOT_FOUND", @"PencilKit view not found", nil);
        }
    });
}

- (void)canUndoPencilKitDrawing:(double)viewId resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    dispatch_async(dispatch_get_main_queue(), ^{
        PencilKitView *pencilKitView = pencilKitViews[@((NSInteger)viewId)];
        if (pencilKitView) {
            BOOL canUndo = [pencilKitView canUndo];
            resolve(@(canUndo));
        } else {
            reject(@"VIEW_NOT_FOUND", @"PencilKit view not found", nil);
        }
    });
}

- (void)canRedoPencilKitDrawing:(double)viewId resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    dispatch_async(dispatch_get_main_queue(), ^{
        PencilKitView *pencilKitView = pencilKitViews[@((NSInteger)viewId)];
        if (pencilKitView) {
            BOOL canRedo = [pencilKitView canRedo];
            resolve(@(canRedo));
        } else {
            reject(@"VIEW_NOT_FOUND", @"PencilKit view not found", nil);
        }
    });
}

// Apple Pencil Data Capture
- (void)startApplePencilDataCapture:(double)viewId resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    dispatch_async(dispatch_get_main_queue(), ^{
        PencilKitView *pencilKitView = pencilKitViews[@((NSInteger)viewId)];
        if (pencilKitView) {
            [pencilKitView startApplePencilDataCapture];
            if (resolve) { resolve(nil); }
        } else {
            if (reject) { reject(@"VIEW_NOT_FOUND", @"PencilKit view not found", nil); }
        }
    });
}

- (void)stopApplePencilDataCapture:(double)viewId resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    dispatch_async(dispatch_get_main_queue(), ^{
        PencilKitView *pencilKitView = pencilKitViews[@((NSInteger)viewId)];
        if (pencilKitView) {
            [pencilKitView stopApplePencilDataCapture];
            if (resolve) { resolve(nil); }
        } else {
            if (reject) { reject(@"VIEW_NOT_FOUND", @"PencilKit view not found", nil); }
        }
    });
}

- (void)isApplePencilDataCaptureActive:(double)viewId resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    dispatch_async(dispatch_get_main_queue(), ^{
        PencilKitView *pencilKitView = pencilKitViews[@((NSInteger)viewId)];
        if (pencilKitView) {
            BOOL isActive = [pencilKitView isApplePencilDataCaptureActive];
            resolve(@(isActive));
        } else {
            reject(@"VIEW_NOT_FOUND", @"PencilKit view not found", nil);
        }
    });
}

// Event sending methods - now instance methods to access RCTEventEmitter
- (void)sendApplePencilDataEvent:(NSDictionary *)data
{
    [self sendEventWithName:@"onApplePencilData" body:data];
}

- (void)sendDrawingChangeEvent:(NSDictionary *)data
{
    [self sendEventWithName:@"onPencilKitDrawingChange" body:data];
}

- (void)sendApplePencilCoalescedTouchesEvent:(NSDictionary *)data
{
    [self sendEventWithName:@"onApplePencilCoalescedTouches" body:data];
}

- (void)sendApplePencilPredictedTouchesEvent:(NSDictionary *)data
{
    [self sendEventWithName:@"onApplePencilPredictedTouches" body:data];
}

- (void)sendApplePencilEstimatedPropertiesEvent:(NSDictionary *)data
{
    [self sendEventWithName:@"onApplePencilEstimatedProperties" body:data];
}

- (void)sendApplePencilMotionEvent:(NSDictionary *)data
{
    [self sendEventWithName:@"onApplePencilMotion" body:data];
}

- (void)sendApplePencilHoverEvent:(NSDictionary *)data
{
    [self sendEventWithName:@"onApplePencilHover" body:data];
}

// Static methods to send events from PencilKitView
+ (void)sendApplePencilDataEvent:(NSDictionary *)data
{
    if (munimPencilkitInstance) {
        [munimPencilkitInstance sendApplePencilDataEvent:data];
    }
}

+ (void)sendDrawingChangeEvent:(NSDictionary *)data
{
    if (munimPencilkitInstance) {
        [munimPencilkitInstance sendDrawingChangeEvent:data];
    }
}

+ (void)sendApplePencilCoalescedTouchesEvent:(NSDictionary *)data
{
    if (munimPencilkitInstance) {
        [munimPencilkitInstance sendApplePencilCoalescedTouchesEvent:data];
    }
}

+ (void)sendApplePencilPredictedTouchesEvent:(NSDictionary *)data
{
    if (munimPencilkitInstance) {
        [munimPencilkitInstance sendApplePencilPredictedTouchesEvent:data];
    }
}

+ (void)sendApplePencilEstimatedPropertiesEvent:(NSDictionary *)data
{
    if (munimPencilkitInstance) {
        [munimPencilkitInstance sendApplePencilEstimatedPropertiesEvent:data];
    }
}

+ (void)sendApplePencilMotionEvent:(NSDictionary *)data
{
    if (munimPencilkitInstance) {
        [munimPencilkitInstance sendApplePencilMotionEvent:data];
    }
}

+ (void)sendApplePencilHoverEvent:(NSDictionary *)data
{
    if (munimPencilkitInstance) {
        [munimPencilkitInstance sendApplePencilHoverEvent:data];
    }
}


- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeMunimPencilkitSpecJSI>(params);
}

@end

// PencilKit View Manager Implementation
@implementation PencilKitViewManager

RCT_EXPORT_MODULE(PencilKitView)

RCT_EXPORT_VIEW_PROPERTY(viewId, NSInteger)
RCT_EXPORT_VIEW_PROPERTY(enableApplePencilData, BOOL)
RCT_EXPORT_VIEW_PROPERTY(enableToolPicker, BOOL)
RCT_EXPORT_VIEW_PROPERTY(enableHapticFeedback, BOOL)
RCT_EXPORT_VIEW_PROPERTY(enableMotionTracking, BOOL)

- (UIView *)view {
    return [[PencilKitView alloc] initWithViewId:0];
}

@end

// PencilKit Native View Implementation
@implementation PencilKitView {
    BOOL _isApplePencilDataCaptureActive;
}

- (instancetype)initWithViewId:(NSInteger)viewId {
    self = [super init];
    if (self) {
        _viewId = viewId;
        _enableApplePencilData = NO;
        _enableToolPicker = YES;
        _enableHapticFeedback = NO;
        _enableMotionTracking = NO;
        _useCustomStylusView = NO; // Default to PencilKit
        _isApplePencilDataCaptureActive = NO;
        _isApplePencilActive = NO;
        _lastRollAngle = 0.0;
        _lastPitchAngle = 0.0;
        _lastYawAngle = 0.0;
        _lastTouchLocation = CGPointZero;
        _lastTouchTimestamp = 0.0;
        _lastVelocity = 0.0;
        _lastAcceleration = 0.0;
        [self setupPencilKitView];
    }
    return self;
}

// Hover handling (iOS 16+)
- (void)handleHover:(UIHoverGestureRecognizer *)recognizer {
    if (@available(iOS 16.0, *)) {
        // Attempt to access UIPencilHoverPose via KVC if available
        id pose = [recognizer valueForKey:@"pencilHoverPose"];
        if (pose) {
            CGPoint location = [[pose valueForKey:@"location"] CGPointValue];
            NSNumber *altitude = [pose valueForKey:@"altitude"];
            NSValue *azimuthVectorValue = [pose valueForKey:@"azimuth"];
            CGPoint azimuthVector = CGPointZero;
            if (azimuthVectorValue) {
                azimuthVector = [azimuthVectorValue CGPointValue];
            }
            NSDictionary *hoverData = @{
                @"viewId": @(self.viewId),
                @"location": @{ @"x": @(location.x), @"y": @(location.y) },
                @"altitude": altitude ?: @(0),
                @"azimuth": @{ @"x": @(azimuthVector.x), @"y": @(azimuthVector.y) },
                @"timestamp": @([[NSDate date] timeIntervalSince1970])
            };
            [MunimPencilkit sendApplePencilHoverEvent:hoverData];
        }
    }
}

- (void)setupPencilKitView {
    if (_useCustomStylusView) {
        [self setupCustomStylusView];
    } else {
        [self setupPencilKitCanvasView];
    }
}

- (void)setupPencilKitCanvasView {
    // Create PKCanvasView
    self.canvasView = [[PKCanvasView alloc] init];
    self.canvasView.delegate = self;
    self.canvasView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.canvasView];
    
    // Set up constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.canvasView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.canvasView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.canvasView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.canvasView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
    ]];
    
    // Configure default settings
    self.canvasView.allowsFingerDrawing = YES;
    self.canvasView.drawingPolicy = PKCanvasViewDrawingPolicyAnyInput;
    
    // Set up tool picker if enabled
    if (self.enableToolPicker) {
        [self setupToolPicker];
    }
    
    // Add hover recognizer on iOS 16+
    if (@available(iOS 16.0, *)) {
        UIHoverGestureRecognizer *hoverRecognizer = [[UIHoverGestureRecognizer alloc] initWithTarget:self action:@selector(handleHover:)];
        [self.canvasView addGestureRecognizer:hoverRecognizer];
    }
}

- (void)setupCustomStylusView {
    // Create StylusDrawingView
    self.stylusView = [[StylusDrawingView alloc] init];
    self.stylusView.delegate = self;
    self.stylusView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.stylusView];
    
    // Set up constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.stylusView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.stylusView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.stylusView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.stylusView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
    ]];
    
    // Configure default settings
    self.stylusView.allowsFingerDrawing = YES;
    self.stylusView.strokeColor = [UIColor labelColor];
    self.stylusView.baseLineWidth = 4.0;
}

- (void)setupToolPicker {
    if (@available(iOS 14.0, *)) {
        self.toolPicker = [PKToolPicker sharedToolPickerForWindow:self.window];
        [self.toolPicker addObserver:self.canvasView];
    } else {
        self.toolPicker = [[PKToolPicker alloc] init];
        [self.toolPicker addObserver:self.canvasView];
    }
}

- (void)updateConfig:(NSDictionary *)config {
    // Handle custom stylus view toggle
    if (config[@"useCustomStylusView"]) {
        BOOL useCustom = [config[@"useCustomStylusView"] boolValue];
        if (useCustom != _useCustomStylusView) {
            [self setUseCustomStylusView:useCustom];
        }
    }
    
    if (_useCustomStylusView) {
        // Update custom stylus view config
        if (config[@"allowsFingerDrawing"]) {
            self.stylusView.allowsFingerDrawing = [config[@"allowsFingerDrawing"] boolValue];
        }
        if (config[@"strokeColor"]) {
            // Parse color from string if needed
            NSString *colorString = config[@"strokeColor"];
            if ([colorString isKindOfClass:[NSString class]]) {
                // Simple color parsing - in a real implementation you'd want more robust parsing
                self.stylusView.strokeColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
            }
        }
        if (config[@"baseLineWidth"]) {
            self.stylusView.baseLineWidth = [config[@"baseLineWidth"] floatValue];
        }
    } else {
        // Update PencilKit canvas view config
        if (config[@"allowsFingerDrawing"]) {
            self.canvasView.allowsFingerDrawing = [config[@"allowsFingerDrawing"] boolValue];
        }
        
        if (config[@"allowsPencilOnlyDrawing"]) {
            self.canvasView.allowsFingerDrawing = ![config[@"allowsPencilOnlyDrawing"] boolValue];
        }
        
        if (config[@"isRulerActive"]) {
            self.canvasView.rulerActive = [config[@"isRulerActive"] boolValue];
        }
        
        if (config[@"drawingPolicy"]) {
            NSString *policy = config[@"drawingPolicy"];
            if ([policy isEqualToString:@"anyInput"]) {
                self.canvasView.drawingPolicy = PKCanvasViewDrawingPolicyAnyInput;
            } else if ([policy isEqualToString:@"pencilOnly"]) {
                self.canvasView.drawingPolicy = PKCanvasViewDrawingPolicyPencilOnly;
            } else {
                self.canvasView.drawingPolicy = PKCanvasViewDrawingPolicyDefault;
            }
        }
    }
}

- (NSDictionary *)getDrawingData {
    if (_useCustomStylusView) {
        // For custom stylus view, we return a simple representation
        // In a real implementation, you might want to store stroke data
        return @{
            @"strokes": @[],
            @"bounds": @{
                @"x": @(0),
                @"y": @(0),
                @"width": @(self.bounds.size.width),
                @"height": @(self.bounds.size.height)
            }
        };
    } else {
        PKDrawing *drawing = self.canvasView.drawing;
        return [self convertPKDrawingToDictionary:drawing];
    }
}

- (void)setDrawingData:(NSDictionary *)drawingData {
    if (_useCustomStylusView) {
        // For custom stylus view, we could load an image if provided
        // This is a simplified implementation
        [self.stylusView clearCanvas];
    } else {
        PKDrawing *drawing = [self convertDictionaryToPKDrawing:drawingData];
        self.canvasView.drawing = drawing;
    }
}

- (void)clearDrawing {
    if (_useCustomStylusView) {
        [self.stylusView clearCanvas];
    } else {
        self.canvasView.drawing = [[PKDrawing alloc] init];
    }
}

- (BOOL)undo {
    if (self.canvasView.undoManager.canUndo) {
        [self.canvasView.undoManager undo];
        return YES;
    }
    return NO;
}

- (BOOL)redo {
    if (self.canvasView.undoManager.canRedo) {
        [self.canvasView.undoManager redo];
        return YES;
    }
    return NO;
}

- (BOOL)canUndo {
    return self.canvasView.undoManager.canUndo;
}

- (BOOL)canRedo {
    return self.canvasView.undoManager.canRedo;
}

- (void)startApplePencilDataCapture {
    _isApplePencilDataCaptureActive = YES;
}

- (void)stopApplePencilDataCapture {
    _isApplePencilDataCaptureActive = NO;
}

- (BOOL)isApplePencilDataCaptureActive {
    return _isApplePencilDataCaptureActive;
}

#pragma mark - Custom Stylus View Methods

- (void)setUseCustomStylusView:(BOOL)useCustom {
    if (_useCustomStylusView != useCustom) {
        _useCustomStylusView = useCustom;
        [self switchToCustomStylusView];
    }
}

- (void)switchToCustomStylusView {
    // Remove existing views
    [self.canvasView removeFromSuperview];
    [self.stylusView removeFromSuperview];
    
    // Create and setup custom stylus view
    [self setupCustomStylusView];
}

- (void)switchToPencilKitView {
    // Remove existing views
    [self.canvasView removeFromSuperview];
    [self.stylusView removeFromSuperview];
    
    // Create and setup PencilKit canvas view
    [self setupPencilKitCanvasView];
}

#pragma mark - StylusDrawingViewDelegate

- (void)stylusViewDidToggleEraser:(StylusDrawingView *)view isOn:(BOOL)isOn {
    // Send event to React Native
    NSDictionary *eventData = @{
        @"viewId": @(self.viewId),
        @"isEraserOn": @(isOn),
        @"timestamp": @([[NSDate date] timeIntervalSince1970])
    };
    [MunimPencilkit sendApplePencilDataEvent:eventData];
}

- (void)stylusViewDidStartDrawing:(StylusDrawingView *)view {
    // Send event to React Native
    NSDictionary *eventData = @{
        @"viewId": @(self.viewId),
        @"action": @"drawingStarted",
        @"timestamp": @([[NSDate date] timeIntervalSince1970])
    };
    [MunimPencilkit sendApplePencilDataEvent:eventData];
}

- (void)stylusViewDidEndDrawing:(StylusDrawingView *)view {
    // Send event to React Native
    NSDictionary *eventData = @{
        @"viewId": @(self.viewId),
        @"action": @"drawingEnded",
        @"timestamp": @([[NSDate date] timeIntervalSince1970])
    };
    [MunimPencilkit sendApplePencilDataEvent:eventData];
}

// Apple Pencil Pro interaction methods

- (void)enableHapticFeedback:(BOOL)enabled {
    self.enableHapticFeedback = enabled;
}

- (void)triggerHapticFeedback:(UIImpactFeedbackStyle)style {
    if (self.enableHapticFeedback) {
        UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:style];
        [generator impactOccurred];
    }
}

- (void)enableMotionTracking:(BOOL)enabled {
    self.enableMotionTracking = enabled;
    if (enabled) {
        [self startMotionTracking];
    } else {
        [self stopMotionTracking];
    }
}

- (void)startMotionTracking {
    if (!self.motionManager) {
        self.motionManager = [[CMMotionManager alloc] init];
    }
    
    if (self.motionManager.isDeviceMotionAvailable) {
        self.motionManager.deviceMotionUpdateInterval = 0.1; // 10 Hz
        [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                                withHandler:^(CMDeviceMotion *motion, NSError *error) {
            if (error) {
                NSLog(@"Motion tracking error: %@", error.localizedDescription);
                return;
            }
            
            // Update motion data
            self.lastRollAngle = motion.attitude.roll;
            self.lastPitchAngle = motion.attitude.pitch;
            self.lastYawAngle = motion.attitude.yaw;
            
            // Send motion data event
            NSDictionary *motionData = @{
                @"viewId": @(self.viewId),
                @"rollAngle": @(motion.attitude.roll),
                @"pitchAngle": @(motion.attitude.pitch),
                @"yawAngle": @(motion.attitude.yaw),
                @"timestamp": @([[NSDate date] timeIntervalSince1970])
            };
            [MunimPencilkit sendApplePencilMotionEvent:motionData];
        }];
    }
}

- (void)stopMotionTracking {
    if (self.motionManager && self.motionManager.isDeviceMotionActive) {
        [self.motionManager stopDeviceMotionUpdates];
    }
}

// PKCanvasViewDelegate
- (void)canvasViewDrawingDidChange:(PKCanvasView *)canvasView {
    NSDictionary *drawing = [self convertPKDrawingToDictionary:canvasView.drawing];
    [MunimPencilkit sendDrawingChangeEvent:@{
        @"viewId": @(self.viewId),
        @"drawing": drawing
    }];
}


// Touch handling for Apple Pencil data
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self handleTouches:touches phase:UITouchPhaseBegan withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    [self handleTouches:touches phase:UITouchPhaseMoved withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self handleTouches:touches phase:UITouchPhaseEnded withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self handleTouches:touches phase:UITouchPhaseCancelled withEvent:event];
}

- (void)touchesEstimatedPropertiesUpdated:(NSSet<UITouch *> *)touches {
    [super touchesEstimatedPropertiesUpdated:touches];
    
    if (!_isApplePencilDataCaptureActive || !self.enableApplePencilData) {
        return;
    }
    
    for (UITouch *touch in touches) {
        if (touch.type == UITouchTypePencil || touch.type == UITouchTypeStylus) {
            // Send updated properties event
            NSDictionary *updatedPropertiesData = [self convertUITouchToEstimatedPropertiesData:touch];
            [MunimPencilkit sendApplePencilEstimatedPropertiesEvent:updatedPropertiesData];
        }
    }
}

- (void)handleTouches:(NSSet<UITouch *> *)touches phase:(UITouchPhase)phase withEvent:(UIEvent *)event {
    if (!_isApplePencilDataCaptureActive || !self.enableApplePencilData) {
        return;
    }
    
    for (UITouch *touch in touches) {
        if (touch.type == UITouchTypePencil || touch.type == UITouchTypeStylus) {
            NSDictionary *applePencilData = [self convertUITouchToApplePencilData:touch phase:phase];
            [MunimPencilkit sendApplePencilDataEvent:applePencilData];
            
            // Handle coalesced touches for high-fidelity input (optimized)
            if (event) {
                NSArray<UITouch *> *coalescedTouches = [event coalescedTouchesForTouch:touch];
                if (coalescedTouches && coalescedTouches.count > 0) {
                    [self processCoalescedTouches:coalescedTouches phase:phase];
                }
            }
            
            // Handle predicted touches for latency compensation
            if (event) {
                NSArray<UITouch *> *predictedTouches = [event predictedTouchesForTouch:touch];
                if (predictedTouches && predictedTouches.count > 0) {
                    NSMutableArray *predictedData = [[NSMutableArray alloc] init];
                    for (UITouch *predictedTouch in predictedTouches) {
                        NSDictionary *predictedTouchData = [self convertUITouchToApplePencilData:predictedTouch phase:phase];
                        [predictedData addObject:predictedTouchData];
                    }
                    
                    NSDictionary *predictedTouchesData = @{
                        @"viewId": @(self.viewId),
                        @"touches": predictedData,
                        @"timestamp": @(touch.timestamp)
                    };
                    
                    [MunimPencilkit sendApplePencilPredictedTouchesEvent:predictedTouchesData];
                }
            }
            
            // Handle estimated properties updates
            if (touch.estimatedPropertiesExpectingUpdates != 0) {
                NSMutableArray *estimatedProperties = [[NSMutableArray alloc] init];
                if (touch.estimatedPropertiesExpectingUpdates & UITouchPropertyForce) {
                    [estimatedProperties addObject:@"force"];
                }
                if (touch.estimatedPropertiesExpectingUpdates & UITouchPropertyAzimuth) {
                    [estimatedProperties addObject:@"azimuth"];
                }
                if (touch.estimatedPropertiesExpectingUpdates & UITouchPropertyAltitude) {
                    [estimatedProperties addObject:@"altitude"];
                }
                if (touch.estimatedPropertiesExpectingUpdates & UITouchPropertyLocation) {
                    [estimatedProperties addObject:@"location"];
                }
                
                if (estimatedProperties.count > 0) {
                    NSDictionary *estimatedPropertiesData = @{
                        @"viewId": @(self.viewId),
                        @"touchId": @(touch.hash),
                        @"updatedProperties": estimatedProperties,
                        @"newData": applePencilData,
                        @"timestamp": @(touch.timestamp)
                    };
                    
                    [MunimPencilkit sendApplePencilEstimatedPropertiesEvent:estimatedPropertiesData];
                }
            }
        }
    }
}

// Conversion methods
- (NSDictionary *)convertUITouchToApplePencilData:(UITouch *)touch phase:(UITouchPhase)phase {
    CGPoint location = [touch locationInView:self];
    CGPoint previousLocation = [touch previousLocationInView:self];
    CGPoint preciseLocation = [touch preciseLocationInView:self];
    
    NSString *phaseString;
    switch (phase) {
        case UITouchPhaseBegan:
            phaseString = @"began";
            break;
        case UITouchPhaseMoved:
            phaseString = @"moved";
            break;
        case UITouchPhaseEnded:
            phaseString = @"ended";
            break;
        case UITouchPhaseCancelled:
            phaseString = @"cancelled";
            break;
        default:
            phaseString = @"began";
            break;
    }
    
    // Compute perpendicular force (force * cos(altitudeAngle))
    double perpendicularForce = touch.force * cos(touch.altitudeAngle);
    
    // Apply pressure curve (Apple's recommended approach)
    double pressure = touch.force / touch.maximumPossibleForce;
    double curvedPressure = [self applyPressureCurve:pressure];
    
    // Get estimated properties
    NSMutableArray *estimatedProperties = [[NSMutableArray alloc] init];
    if (touch.estimatedProperties & UITouchPropertyForce) {
        [estimatedProperties addObject:@"force"];
    }
    if (touch.estimatedProperties & UITouchPropertyAzimuth) {
        [estimatedProperties addObject:@"azimuth"];
    }
    if (touch.estimatedProperties & UITouchPropertyAltitude) {
        [estimatedProperties addObject:@"altitude"];
    }
    if (touch.estimatedProperties & UITouchPropertyLocation) {
        [estimatedProperties addObject:@"location"];
    }
    
    // Get properties expecting updates
    NSMutableArray *estimatedPropertiesExpectingUpdates = [[NSMutableArray alloc] init];
    if (touch.estimatedPropertiesExpectingUpdates & UITouchPropertyForce) {
        [estimatedPropertiesExpectingUpdates addObject:@"force"];
    }
    if (touch.estimatedPropertiesExpectingUpdates & UITouchPropertyAzimuth) {
        [estimatedPropertiesExpectingUpdates addObject:@"azimuth"];
    }
    if (touch.estimatedPropertiesExpectingUpdates & UITouchPropertyAltitude) {
        [estimatedPropertiesExpectingUpdates addObject:@"altitude"];
    }
    if (touch.estimatedPropertiesExpectingUpdates & UITouchPropertyLocation) {
        [estimatedPropertiesExpectingUpdates addObject:@"location"];
    }
    
    // Calculate velocity and acceleration
    double velocity = 0.0;
    double acceleration = 0.0;
    
    if (self.lastTouchTimestamp > 0 && phase != UITouchPhaseBegan) {
        NSTimeInterval timeDelta = touch.timestamp - self.lastTouchTimestamp;
        if (timeDelta > 0) {
            // Calculate distance moved
            double deltaX = location.x - self.lastTouchLocation.x;
            double deltaY = location.y - self.lastTouchLocation.y;
            double distance = sqrt(deltaX * deltaX + deltaY * deltaY);
            
            // Calculate velocity (pixels per second)
            velocity = distance / timeDelta;
            
            // Calculate acceleration (change in velocity)
            if (self.lastVelocity > 0) {
                acceleration = (velocity - self.lastVelocity) / timeDelta;
            }
        }
    }
    
    // Update tracking variables
    self.lastTouchLocation = location;
    self.lastTouchTimestamp = touch.timestamp;
    self.lastVelocity = velocity;
    self.lastAcceleration = acceleration;
    
    return @{
        @"pressure": @(curvedPressure),
        @"altitude": @(touch.altitudeAngle / (M_PI / 2)),
        @"azimuth": @([touch azimuthAngleInView:self]), // Azimuth angle method
        @"azimuthUnitVector": @{
            @"x": @([touch azimuthUnitVectorInView:self].dx),
            @"y": @([touch azimuthUnitVectorInView:self].dy)
        }, // Azimuth unit vector
        @"force": @(touch.force),
        @"maximumPossibleForce": @(touch.maximumPossibleForce),
        @"perpendicularForce": @(perpendicularForce),
        @"rollAngle": @(touch.rollAngle), // Barrel-roll angle of Apple Pencil
        @"timestamp": @(touch.timestamp),
        @"location": @{
            @"x": @(location.x),
            @"y": @(location.y)
        },
        @"previousLocation": @{
            @"x": @(previousLocation.x),
            @"y": @(previousLocation.y)
        },
        @"preciseLocation": @{
            @"x": @(preciseLocation.x),
            @"y": @(preciseLocation.y)
        },
        @"isApplePencil": @(touch.type == UITouchTypePencil),
        @"phase": phaseString,
        @"hasPreciseLocation": @(YES), // Always true for Apple Pencil
        @"estimatedProperties": estimatedProperties,
        @"estimatedPropertiesExpectingUpdates": estimatedPropertiesExpectingUpdates,
        @"velocity": @(velocity),
        @"acceleration": @(acceleration)
    };
}

- (NSDictionary *)convertUITouchToEstimatedPropertiesData:(UITouch *)touch {
    // Get updated properties
    NSMutableArray *updatedProperties = [[NSMutableArray alloc] init];
    if (touch.estimatedProperties & UITouchPropertyForce) {
        [updatedProperties addObject:@"force"];
    }
    if (touch.estimatedProperties & UITouchPropertyAzimuth) {
        [updatedProperties addObject:@"azimuth"];
    }
    if (touch.estimatedProperties & UITouchPropertyAltitude) {
        [updatedProperties addObject:@"altitude"];
    }
    if (touch.estimatedProperties & UITouchPropertyLocation) {
        [updatedProperties addObject:@"location"];
    }
    
    // Get properties still expecting updates
    NSMutableArray *propertiesExpectingUpdates = [[NSMutableArray alloc] init];
    if (touch.estimatedPropertiesExpectingUpdates & UITouchPropertyForce) {
        [propertiesExpectingUpdates addObject:@"force"];
    }
    if (touch.estimatedPropertiesExpectingUpdates & UITouchPropertyAzimuth) {
        [propertiesExpectingUpdates addObject:@"azimuth"];
    }
    if (touch.estimatedPropertiesExpectingUpdates & UITouchPropertyAltitude) {
        [propertiesExpectingUpdates addObject:@"altitude"];
    }
    if (touch.estimatedPropertiesExpectingUpdates & UITouchPropertyLocation) {
        [propertiesExpectingUpdates addObject:@"location"];
    }
    
    // Create updated Apple Pencil data with refined properties
    NSDictionary *newData = [self convertUITouchToApplePencilData:touch phase:touch.phase];
    
    return @{
        @"viewId": @(self.viewId),
        @"touchId": @(touch.hash), // Use touch hash as identifier
        @"updatedProperties": updatedProperties,
        @"propertiesExpectingUpdates": propertiesExpectingUpdates,
        @"newData": newData,
        @"timestamp": @([[NSDate date] timeIntervalSince1970])
    };
}

- (double)applyPressureCurve:(double)pressure {
    // Apple's recommended pressure curve for natural drawing
    // This creates a more responsive curve that feels natural
    if (pressure <= 0.0) return 0.0;
    if (pressure >= 1.0) return 1.0;
    
    // Apply a power curve for more natural pressure response
    // This makes light pressure more sensitive and heavy pressure less sensitive
    double curvedPressure = pow(pressure, 0.7);
    
    // Apply a slight S-curve for better control
    double sCurve = 3.0 * curvedPressure * curvedPressure - 2.0 * curvedPressure * curvedPressure * curvedPressure;
    
    return sCurve;
}

- (void)processCoalescedTouches:(NSArray<UITouch *> *)coalescedTouches phase:(UITouchPhase)phase {
    // Optimized coalesced touches processing
    // Only process if we have a reasonable number of touches to avoid performance issues
    if (coalescedTouches.count > 10) {
        // Sample every other touch for very high-frequency input
        NSMutableArray *sampledTouches = [[NSMutableArray alloc] init];
        for (NSUInteger i = 0; i < coalescedTouches.count; i += 2) {
            [sampledTouches addObject:coalescedTouches[i]];
        }
        coalescedTouches = sampledTouches;
    }
    
    NSMutableArray *coalescedData = [[NSMutableArray alloc] initWithCapacity:coalescedTouches.count];
    
    for (UITouch *coalescedTouch in coalescedTouches) {
        // Only process if it's a valid touch type
        if (coalescedTouch.type == UITouchTypePencil || coalescedTouch.type == UITouchTypeStylus) {
            NSDictionary *coalescedTouchData = [self convertUITouchToApplePencilData:coalescedTouch phase:phase];
            [coalescedData addObject:coalescedTouchData];
        }
    }
    
    if (coalescedData.count > 0) {
        NSDictionary *coalescedTouchesData = @{
            @"viewId": @(self.viewId),
            @"touches": coalescedData,
            @"timestamp": @([[NSDate date] timeIntervalSince1970]),
            @"count": @(coalescedData.count)
        };
        
        [MunimPencilkit sendApplePencilCoalescedTouchesEvent:coalescedTouchesData];
    }
}

- (NSDictionary *)analyzeStroke:(NSArray<NSDictionary *> *)strokePoints {
    if (strokePoints.count < 2) {
        return @{
            @"smoothness": @(0.0),
            @"consistency": @(0.0),
            @"length": @(0.0),
            @"duration": @(0.0),
            @"averageVelocity": @(0.0),
            @"maxVelocity": @(0.0),
            @"averagePressure": @(0.0),
            @"pressureVariance": @(0.0)
        };
    }
    
    double smoothness = [self calculateStrokeSmoothness:strokePoints];
    double consistency = [self calculateStrokeConsistency:strokePoints];
    
    // Calculate stroke length
    double totalLength = 0.0;
    for (NSUInteger i = 1; i < strokePoints.count; i++) {
        NSDictionary *prevPoint = strokePoints[i-1];
        NSDictionary *currPoint = strokePoints[i];
        
        double x1 = [prevPoint[@"location"][@"x"] doubleValue];
        double y1 = [prevPoint[@"location"][@"y"] doubleValue];
        double x2 = [currPoint[@"location"][@"x"] doubleValue];
        double y2 = [currPoint[@"location"][@"y"] doubleValue];
        
        double distance = sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));
        totalLength += distance;
    }
    
    // Calculate duration
    double startTime = [strokePoints.firstObject[@"timestamp"] doubleValue];
    double endTime = [strokePoints.lastObject[@"timestamp"] doubleValue];
    double duration = endTime - startTime;
    
    // Calculate velocity statistics
    double totalVelocity = 0.0;
    double maxVelocity = 0.0;
    for (NSDictionary *point in strokePoints) {
        double velocity = [point[@"velocity"] doubleValue];
        totalVelocity += velocity;
        maxVelocity = MAX(maxVelocity, velocity);
    }
    double averageVelocity = totalVelocity / strokePoints.count;
    
    // Calculate pressure statistics
    double totalPressure = 0.0;
    for (NSDictionary *point in strokePoints) {
        double pressure = [point[@"pressure"] doubleValue];
        totalPressure += pressure;
    }
    double averagePressure = totalPressure / strokePoints.count;
    
    // Calculate pressure variance
    double pressureVariance = 0.0;
    for (NSDictionary *point in strokePoints) {
        double pressure = [point[@"pressure"] doubleValue];
        pressureVariance += pow(pressure - averagePressure, 2);
    }
    pressureVariance = pressureVariance / strokePoints.count;
    
    return @{
        @"smoothness": @(smoothness),
        @"consistency": @(consistency),
        @"length": @(totalLength),
        @"duration": @(duration),
        @"averageVelocity": @(averageVelocity),
        @"maxVelocity": @(maxVelocity),
        @"averagePressure": @(averagePressure),
        @"pressureVariance": @(pressureVariance)
    };
}

- (double)calculateStrokeSmoothness:(NSArray<NSDictionary *> *)strokePoints {
    if (strokePoints.count < 3) return 0.0;
    
    double totalAngleChange = 0.0;
    int angleCount = 0;
    
    for (NSUInteger i = 1; i < strokePoints.count - 1; i++) {
        NSDictionary *prevPoint = strokePoints[i-1];
        NSDictionary *currPoint = strokePoints[i];
        NSDictionary *nextPoint = strokePoints[i+1];
        
        // Calculate angle between consecutive segments
        double x1 = [prevPoint[@"location"][@"x"] doubleValue];
        double y1 = [prevPoint[@"location"][@"y"] doubleValue];
        double x2 = [currPoint[@"location"][@"x"] doubleValue];
        double y2 = [currPoint[@"location"][@"y"] doubleValue];
        double x3 = [nextPoint[@"location"][@"x"] doubleValue];
        double y3 = [nextPoint[@"location"][@"y"] doubleValue];
        
        // Calculate vectors
        double v1x = x2 - x1;
        double v1y = y2 - y1;
        double v2x = x3 - x2;
        double v2y = y3 - y2;
        
        // Calculate angle between vectors
        double dotProduct = v1x * v2x + v1y * v2y;
        double mag1 = sqrt(v1x * v1x + v1y * v1y);
        double mag2 = sqrt(v2x * v2x + v2y * v2y);
        
        if (mag1 > 0 && mag2 > 0) {
            double cosAngle = dotProduct / (mag1 * mag2);
            cosAngle = MAX(-1.0, MIN(1.0, cosAngle)); // Clamp to valid range
            double angle = acos(cosAngle);
            totalAngleChange += angle;
            angleCount++;
        }
    }
    
    if (angleCount == 0) return 0.0;
    
    double averageAngleChange = totalAngleChange / angleCount;
    // Convert to smoothness score (0-1, where 1 is perfectly smooth)
    double smoothness = MAX(0.0, 1.0 - (averageAngleChange / M_PI));
    return smoothness;
}

- (double)calculateStrokeConsistency:(NSArray<NSDictionary *> *)strokePoints {
    if (strokePoints.count < 2) return 0.0;
    
    // Calculate velocity consistency
    NSMutableArray *velocities = [[NSMutableArray alloc] init];
    for (NSDictionary *point in strokePoints) {
        double velocity = [point[@"velocity"] doubleValue];
        [velocities addObject:@(velocity)];
    }
    
    // Calculate standard deviation of velocities
    double totalVelocity = 0.0;
    for (NSNumber *velocity in velocities) {
        totalVelocity += [velocity doubleValue];
    }
    double averageVelocity = totalVelocity / velocities.count;
    
    double velocityVariance = 0.0;
    for (NSNumber *velocity in velocities) {
        double diff = [velocity doubleValue] - averageVelocity;
        velocityVariance += diff * diff;
    }
    velocityVariance = velocityVariance / velocities.count;
    double velocityStdDev = sqrt(velocityVariance);
    
    // Calculate pressure consistency
    NSMutableArray *pressures = [[NSMutableArray alloc] init];
    for (NSDictionary *point in strokePoints) {
        double pressure = [point[@"pressure"] doubleValue];
        [pressures addObject:@(pressure)];
    }
    
    double totalPressure = 0.0;
    for (NSNumber *pressure in pressures) {
        totalPressure += [pressure doubleValue];
    }
    double averagePressure = totalPressure / pressures.count;
    
    double pressureVariance = 0.0;
    for (NSNumber *pressure in pressures) {
        double diff = [pressure doubleValue] - averagePressure;
        pressureVariance += diff * diff;
    }
    pressureVariance = pressureVariance / pressures.count;
    double pressureStdDev = sqrt(pressureVariance);
    
    // Combine velocity and pressure consistency (0-1, where 1 is most consistent)
    double velocityConsistency = MAX(0.0, 1.0 - (velocityStdDev / averageVelocity));
    double pressureConsistency = MAX(0.0, 1.0 - (pressureStdDev / averagePressure));
    
    return (velocityConsistency + pressureConsistency) / 2.0;
}

- (NSDictionary *)convertPKDrawingToDictionary:(PKDrawing *)drawing {
    NSMutableArray *strokes = [NSMutableArray array];
    
    for (PKStroke *stroke in drawing.strokes) {
        NSMutableArray *points = [NSMutableArray array];
        
        // Note: Some SDKs may not expose PKStrokePath interpolation APIs. To maintain
        // compatibility, we currently omit per-point extraction here.
        
        NSDictionary *tool = [self convertPKInkToDictionary:stroke.ink];
        
        [strokes addObject:@{
            @"points": points,
            @"tool": tool,
            @"color": [self colorToString:stroke.ink.color],
            @"width": @(1.0) // Default width since PKInk doesn't have width property
        }];
    }
    
    CGRect bounds = drawing.bounds;
    return @{
        @"strokes": strokes,
        @"bounds": @{
            @"x": @(bounds.origin.x),
            @"y": @(bounds.origin.y),
            @"width": @(bounds.size.width),
            @"height": @(bounds.size.height)
        }
    };
}

- (PKDrawing *)convertDictionaryToPKDrawing:(NSDictionary *)drawingData {
    // This is a simplified conversion - in a real implementation,
    // you'd need to properly reconstruct PKStroke objects
    return [[PKDrawing alloc] init];
}

- (NSDictionary *)convertPKInkToDictionary:(PKInk *)ink {
    NSString *type = @"pen"; // Default type
    
    // PKInkType is an enum, so we need to compare it properly
    if (ink.inkType == PKInkTypePen) {
        type = @"pen";
    } else if (ink.inkType == PKInkTypePencil) {
        type = @"pencil";
    } else if (ink.inkType == PKInkTypeMarker) {
        type = @"marker";
    }
    
    return @{
        @"type": type,
        @"width": @(1.0), // Default width
        @"color": [self colorToString:ink.color]
    };
}

- (NSString *)colorToString:(UIColor *)color {
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    return [NSString stringWithFormat:@"rgba(%d,%d,%d,%f)", 
            (int)(red * 255), (int)(green * 255), (int)(blue * 255), alpha];
}

@end

// MARK: - StylusDrawingView Implementation

@implementation StylusDrawingView {
    // Backing store for incremental rendering
    UIImageView *_renderImageView;
    
    // State per active stroke
    NSMutableDictionary<NSValue *, NSValue *> *_lastPointByTouch;
    NSMutableDictionary<NSValue *, UIBezierPath *> *_strokePaths;
    NSMutableDictionary<NSValue *, NSMutableArray<NSValue *> *> *_strokePoints;
    NSMutableDictionary<NSValue *, NSMutableArray<NSNumber *> *> *_strokePressures;
    
    // Hover preview
    CAShapeLayer *_hoverPreviewLayer;
    UIHoverGestureRecognizer *_hoverGesture;
    
    // Tool state
    BOOL _isEraserEnabled;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.multipleTouchEnabled = YES;
    self.backgroundColor = [UIColor systemBackgroundColor];
    
    // Initialize backing store
    _renderImageView = [[UIImageView alloc] init];
    _renderImageView.contentMode = UIViewContentModeCenter;
    _renderImageView.opaque = YES;
    [self addSubview:_renderImageView];
    
    // Initialize stroke tracking dictionaries
    _lastPointByTouch = [[NSMutableDictionary alloc] init];
    _strokePaths = [[NSMutableDictionary alloc] init];
    _strokePoints = [[NSMutableDictionary alloc] init];
    _strokePressures = [[NSMutableDictionary alloc] init];
    
    // Hover preview layer
    _hoverPreviewLayer = [CAShapeLayer layer];
    _hoverPreviewLayer.fillColor = [UIColor clearColor].CGColor;
    _hoverPreviewLayer.strokeColor = [[UIColor systemBlueColor] colorWithAlphaComponent:0.6].CGColor;
    _hoverPreviewLayer.lineWidth = 1.0;
    _hoverPreviewLayer.hidden = YES;
    [self.layer addSublayer:_hoverPreviewLayer];
    
    // Hover support (available on iPad with Pencil hover)
    if (@available(iOS 13.0, *)) {
        _hoverGesture = [[UIHoverGestureRecognizer alloc] initWithTarget:self action:@selector(handleHover:)];
        [self addGestureRecognizer:_hoverGesture];
    }
    
    // Pencil interaction (tap)
    if (@available(iOS 12.1, *)) {
        UIPencilInteraction *pencil = [[UIPencilInteraction alloc] init];
        pencil.delegate = self;
        [self addInteraction:pencil];
    }
    
    // Default values
    _allowsFingerDrawing = NO;
    _strokeColor = [UIColor labelColor];
    _baseLineWidth = 4.0;
    _isEraserEnabled = NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _renderImageView.frame = self.bounds;
    
    // Initialize image if needed
    if (_renderImageView.image == nil && self.bounds.size.width > 0 && self.bounds.size.height > 0) {
        _renderImageView.image = [self emptyImageWithSize:self.bounds.size];
    }
}

- (void)clearCanvas {
    _renderImageView.image = [self emptyImageWithSize:self.bounds.size];
    [_strokePaths removeAllObjects];
    [_strokePoints removeAllObjects];
    [_strokePressures removeAllObjects];
    [_lastPointByTouch removeAllObjects];
    [self setNeedsDisplay];
}

- (void)setCanvasImage:(UIImage *)image {
    if (image) {
        // Ensure the image is set with proper scaling to match the view bounds
        if (!CGSizeEqualToSize(self.bounds.size, CGSizeZero) && !CGSizeEqualToSize(self.bounds.size, image.size)) {
            // Create a properly sized image that matches the view bounds
            UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat defaultFormat];
            format.scale = [UIScreen mainScreen].scale;
            format.opaque = YES;
            UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:self.bounds.size format:format];
            UIImage *scaledImage = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
                [image drawInRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
            }];
            _renderImageView.image = scaledImage;
        } else {
            _renderImageView.image = image;
        }
    } else if (!CGSizeEqualToSize(self.bounds.size, CGSizeZero)) {
        _renderImageView.image = [self emptyImageWithSize:self.bounds.size];
    }
    [self setNeedsDisplay];
}

- (UIImage *)snapshotImage {
    return _renderImageView.image;
}

- (void)setEraserEnabled:(BOOL)enabled {
    _isEraserEnabled = enabled;
    if (_isEraserEnabled) {
        _hoverPreviewLayer.strokeColor = [[UIColor systemRedColor] colorWithAlphaComponent:0.7].CGColor;
    } else {
        _hoverPreviewLayer.strokeColor = [[UIColor systemBlueColor] colorWithAlphaComponent:0.6].CGColor;
    }
}

- (UIImage *)emptyImageWithSize:(CGSize)size {
    UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat defaultFormat];
    format.scale = [UIScreen mainScreen].scale;
    format.opaque = YES;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size format:format];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        [(self.backgroundColor ?: [UIColor whiteColor]) setFill];
        UIRectFill(CGRectMake(0, 0, size.width, size.height));
    }];
}

#pragma mark - Touch Handling

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_renderImageView.image) return;
    
    for (UITouch *touch in touches) {
        if (![self shouldAcceptTouch:touch]) continue;
        
        CGPoint point = [touch preciseLocationInView:self];
        NSValue *touchKey = [NSValue valueWithPointer:(__bridge const void *)touch];
        _lastPointByTouch[touchKey] = [NSValue valueWithCGPoint:point];
        
        // Initialize stroke path and points
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:point];
        _strokePaths[touchKey] = path;
        
        NSMutableArray<NSValue *> *points = [[NSMutableArray alloc] init];
        [points addObject:[NSValue valueWithCGPoint:point]];
        _strokePoints[touchKey] = points;
        
        NSMutableArray<NSNumber *> *pressures = [[NSMutableArray alloc] init];
        [pressures addObject:@([self normalizedForceForTouch:touch])];
        _strokePressures[touchKey] = pressures;
        
        // Notify delegate that drawing started
        if ([self.delegate respondsToSelector:@selector(stylusViewDidStartDrawing:)]) {
            [self.delegate stylusViewDidStartDrawing:self];
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_renderImageView.image) return;
    
    for (UITouch *touch in touches) {
        if (![self shouldAcceptTouch:touch]) continue;
        
        // Use coalesced touches for smoother strokes
        NSArray<UITouch *> *samples = [event coalescedTouchesForTouch:touch] ?: @[touch];
        NSValue *touchKey = [NSValue valueWithPointer:(__bridge const void *)touch];
        for (UITouch *sample in samples) {
            CGPoint current = [sample preciseLocationInView:self];
            
            // Add point to stroke path
            UIBezierPath *path = _strokePaths[touchKey];
            NSMutableArray<NSValue *> *points = _strokePoints[touchKey];
            NSMutableArray<NSNumber *> *pressures = _strokePressures[touchKey];
            
            if (path && points && pressures) {
                [path addLineToPoint:current];
                [points addObject:[NSValue valueWithCGPoint:current]];
                [pressures addObject:@([self normalizedForceForTouch:sample])];
            }
            
            _lastPointByTouch[touchKey] = [NSValue valueWithCGPoint:current];
        }
        
        // Render the entire stroke with pressure-sensitive segments
        [self renderStrokeWithPressureForTouch:touch onImage:_renderImageView.image];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self endTouches:touches];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self endTouches:touches];
}

- (void)endTouches:(NSSet<UITouch *> *)touches {
    for (UITouch *touch in touches) {
        NSValue *touchKey = [NSValue valueWithPointer:(__bridge const void *)touch];
        [_lastPointByTouch removeObjectForKey:touchKey];
        [_strokePaths removeObjectForKey:touchKey];
        [_strokePoints removeObjectForKey:touchKey];
        [_strokePressures removeObjectForKey:touchKey];
    }
    
    // Notify delegate that drawing ended
    if ([self.delegate respondsToSelector:@selector(stylusViewDidEndDrawing:)]) {
        [self.delegate stylusViewDidEndDrawing:self];
    }
}

- (BOOL)shouldAcceptTouch:(UITouch *)touch {
    if (_allowsFingerDrawing) return YES;
    if (@available(iOS 12.1, *)) {
        return touch.type == UITouchTypeStylus;
    } else {
        return YES;
    }
}

#pragma mark - Rendering

- (void)renderStrokeWithPressureForTouch:(UITouch *)touch onImage:(UIImage *)image {
    if (self.bounds.size.width <= 0 || self.bounds.size.height <= 0) return;
    
    NSValue *touchKey = [NSValue valueWithPointer:(__bridge const void *)touch];
    NSMutableArray<NSValue *> *points = _strokePoints[touchKey];
    NSMutableArray<NSNumber *> *pressures = _strokePressures[touchKey];
    
    if (!points || !pressures || points.count <= 1) return;
    
    UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat defaultFormat];
    format.scale = [UIScreen mainScreen].scale;
    format.opaque = YES;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:self.bounds.size format:format];
    
    UIColor *color = _isEraserEnabled ? (self.backgroundColor ?: [UIColor whiteColor]) : _strokeColor;
    
    UIImage *updated = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        [image drawAtPoint:CGPointZero];
        
        // Draw the stroke with pressure-sensitive segments
        for (NSUInteger i = 1; i < points.count; i++) {
            CGPoint from = [points[i-1] CGPointValue];
            CGPoint to = [points[i] CGPointValue];
            
            // Use the pressure stored for this point
            CGFloat force = [pressures[i] floatValue];
            CGFloat tiltFactor = [self tiltWidthFactorForTouch:touch];
            CGFloat width = MAX(2.0, _baseLineWidth * (0.5 + force) * tiltFactor);
            
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:from];
            [path addLineToPoint:to];
            path.lineCapStyle = kCGLineCapRound;
            path.lineJoinStyle = kCGLineJoinRound;
            path.lineWidth = width;
            
            [color setStroke];
            [path stroke];
        }
    }];
    
    _renderImageView.image = updated;
}

- (CGFloat)normalizedForceForTouch:(UITouch *)touch {
    if (touch.maximumPossibleForce <= 0) return 1.0;
    CGFloat value = touch.force / touch.maximumPossibleForce;
    return MAX(0.0, MIN(1.0, value));
}

- (CGFloat)tiltWidthFactorForTouch:(UITouch *)touch {
    // Increase width when the pencil is tilted (lower altitude)
    // altitudeAngle ranges roughly 0 (parallel) to ~pi/2 (perpendicular)
    CGFloat altitude = touch.altitudeAngle;
    CGFloat perpendicularity = MAX(0.0, MIN(1.0, altitude / (M_PI / 2.0)));
    // When perpendicularity is low (tilted), allow up to 1.8x width
    return 1.0 + (1.8 - 1.0) * (1.0 - perpendicularity);
}

#pragma mark - Hover Handling

- (void)handleHover:(UIHoverGestureRecognizer *)recognizer {
    if (@available(iOS 13.0, *)) {
        CGPoint location = [recognizer locationInView:self];
        switch (recognizer.state) {
            case UIGestureRecognizerStateBegan:
            case UIGestureRecognizerStateChanged:
                [self updateHoverPreviewAtLocation:location];
                _hoverPreviewLayer.hidden = NO;
                break;
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateFailed:
                _hoverPreviewLayer.hidden = YES;
                break;
            default:
                break;
        }
    }
}

- (void)updateHoverPreviewAtLocation:(CGPoint)location {
    // Use base width as preview size; could incorporate tilt/force when available via hover pose in future
    CGFloat previewDiameter = MAX(4.0, _baseLineWidth * 2.0);
    CGRect rect = CGRectMake(location.x - previewDiameter * 0.5,
                           location.y - previewDiameter * 0.5,
                           previewDiameter,
                           previewDiameter);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    _hoverPreviewLayer.path = path.CGPath;
}

#pragma mark - UIPencilInteractionDelegate

- (void)pencilInteractionDidTap:(UIPencilInteraction *)interaction {
    // Toggle eraser on pencil tap
    _isEraserEnabled = !_isEraserEnabled;
    [self setEraserEnabled:_isEraserEnabled];
    
    if ([self.delegate respondsToSelector:@selector(stylusViewDidToggleEraser:isOn:)]) {
        [self.delegate stylusViewDidToggleEraser:self isOn:_isEraserEnabled];
    }
}

@end
