#import "MunimPencilkit.h"
#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTUtils.h>
#import <React/RCTEventEmitter.h>

// Global dictionary to store PencilKit views
static NSMutableDictionary<NSNumber *, PencilKitView *> *pencilKitViews = nil;

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
        @"onApplePencilMotion"
    ];
}

+ (void)initialize {
    if (self == [MunimPencilkit class]) {
        pencilKitViews = [[NSMutableDictionary alloc] init];
    }
}

- (NSNumber *)multiply:(double)a b:(double)b {
    NSNumber *result = @(a * b);
    return result;
}

// PencilKit View Management
- (void)createPencilKitView:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject {
    dispatch_async(dispatch_get_main_queue(), ^{
        static NSInteger nextViewId = 1;
        NSInteger viewId = nextViewId++;
        
        PencilKitView *pencilKitView = [[PencilKitView alloc] initWithViewId:viewId];
        pencilKitViews[@(viewId)] = pencilKitView;
        
        resolve(@(viewId));
    });
}

- (void)destroyPencilKitView:(double)viewId rejecter:(RCTPromiseRejectBlock)reject {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNumber *viewIdNumber = @((NSInteger)viewId);
        PencilKitView *pencilKitView = pencilKitViews[viewIdNumber];
        
        if (pencilKitView) {
            [pencilKitView removeFromSuperview];
            [pencilKitViews removeObjectForKey:viewIdNumber];
        }
    });
}

- (void)setPencilKitConfig:(double)viewId config:(NSDictionary *)config rejecter:(RCTPromiseRejectBlock)reject {
    dispatch_async(dispatch_get_main_queue(), ^{
        PencilKitView *pencilKitView = pencilKitViews[@((NSInteger)viewId)];
        if (pencilKitView) {
            [pencilKitView updateConfig:config];
        }
    });
}

- (void)getPencilKitDrawing:(double)viewId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject {
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

- (void)setPencilKitDrawing:(double)viewId drawing:(NSDictionary *)drawing rejecter:(RCTPromiseRejectBlock)reject {
    dispatch_async(dispatch_get_main_queue(), ^{
        PencilKitView *pencilKitView = pencilKitViews[@((NSInteger)viewId)];
        if (pencilKitView) {
            [pencilKitView setDrawingData:drawing];
        } else {
            reject(@"VIEW_NOT_FOUND", @"PencilKit view not found", nil);
        }
    });
}

- (void)clearPencilKitDrawing:(double)viewId rejecter:(RCTPromiseRejectBlock)reject {
    dispatch_async(dispatch_get_main_queue(), ^{
        PencilKitView *pencilKitView = pencilKitViews[@((NSInteger)viewId)];
        if (pencilKitView) {
            [pencilKitView clearDrawing];
        }
    });
}

- (void)undoPencilKitDrawing:(double)viewId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject {
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

- (void)redoPencilKitDrawing:(double)viewId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject {
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

- (void)canUndoPencilKitDrawing:(double)viewId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject {
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

- (void)canRedoPencilKitDrawing:(double)viewId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject {
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
- (void)startApplePencilDataCapture:(double)viewId rejecter:(RCTPromiseRejectBlock)reject {
    dispatch_async(dispatch_get_main_queue(), ^{
        PencilKitView *pencilKitView = pencilKitViews[@((NSInteger)viewId)];
        if (pencilKitView) {
            [pencilKitView startApplePencilDataCapture];
        }
    });
}

- (void)stopApplePencilDataCapture:(double)viewId rejecter:(RCTPromiseRejectBlock)reject {
    dispatch_async(dispatch_get_main_queue(), ^{
        PencilKitView *pencilKitView = pencilKitViews[@((NSInteger)viewId)];
        if (pencilKitView) {
            [pencilKitView stopApplePencilDataCapture];
        }
    });
}

- (void)isApplePencilDataCaptureActive:(double)viewId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject {
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

// Event sending methods
+ (void)sendApplePencilDataEvent:(NSDictionary *)data
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MunimPencilkitApplePencilData" object:data];
}

+ (void)sendDrawingChangeEvent:(NSDictionary *)data
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MunimPencilkitDrawingChange" object:data];
}


+ (void)sendApplePencilCoalescedTouchesEvent:(NSDictionary *)data
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MunimPencilkitApplePencilCoalescedTouches" object:data];
}

+ (void)sendApplePencilPredictedTouchesEvent:(NSDictionary *)data
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MunimPencilkitApplePencilPredictedTouches" object:data];
}

+ (void)sendApplePencilEstimatedPropertiesEvent:(NSDictionary *)data
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MunimPencilkitApplePencilEstimatedProperties" object:data];
}

+ (void)sendApplePencilMotionEvent:(NSDictionary *)data
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MunimPencilkitApplePencilMotion" object:data];
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

- (void)setupPencilKitView {
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

- (NSDictionary *)getDrawingData {
    PKDrawing *drawing = self.canvasView.drawing;
    return [self convertPKDrawingToDictionary:drawing];
}

- (void)setDrawingData:(NSDictionary *)drawingData {
    PKDrawing *drawing = [self convertDictionaryToPKDrawing:drawingData];
    self.canvasView.drawing = drawing;
}

- (void)clearDrawing {
    self.canvasView.drawing = [[PKDrawing alloc] init];
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
    [self handleTouches:touches phase:UITouchPhaseBegan];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    [self handleTouches:touches phase:UITouchPhaseMoved];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self handleTouches:touches phase:UITouchPhaseEnded];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self handleTouches:touches phase:UITouchPhaseCancelled];
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

- (void)handleTouches:(NSSet<UITouch *> *)touches phase:(UITouchPhase)phase {
    if (!_isApplePencilDataCaptureActive || !self.enableApplePencilData) {
        return;
    }
    
    for (UITouch *touch in touches) {
        if (touch.type == UITouchTypePencil || touch.type == UITouchTypeStylus) {
            NSDictionary *applePencilData = [self convertUITouchToApplePencilData:touch phase:phase];
            [MunimPencilkit sendApplePencilDataEvent:applePencilData];
            
            // Handle coalesced touches for high-fidelity input (optimized)
            if (touch.coalescedTouches && touch.coalescedTouches.count > 0) {
                [self processCoalescedTouches:touch.coalescedTouches phase:phase];
            }
            
            // Handle predicted touches for latency compensation
            if (touch.predictedTouches && touch.predictedTouches.count > 0) {
                NSMutableArray *predictedData = [[NSMutableArray alloc] init];
                for (UITouch *predictedTouch in touch.predictedTouches) {
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
            
            // Handle estimated properties updates
            if (touch.estimatedPropertiesExpectingUpdates && touch.estimatedPropertiesExpectingUpdates.count > 0) {
                NSMutableArray *estimatedProperties = [[NSMutableArray alloc] init];
                for (NSString *property in touch.estimatedPropertiesExpectingUpdates) {
                    [estimatedProperties addObject:property];
                }
                
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
        @"hasPreciseLocation": @(touch.hasPreciseLocation),
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
        
        for (PKStrokePoint *point in stroke.path) {
            [points addObject:@{
                @"location": @{
                    @"x": @(point.location.x),
                    @"y": @(point.location.y)
                },
                @"pressure": @(point.force),
                @"azimuth": @(point.azimuth),
                @"altitude": @(point.altitude),
                @"timestamp": @([[NSDate date] timeIntervalSince1970])
            }];
        }
        
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
