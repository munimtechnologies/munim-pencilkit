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
    return @[@"onApplePencilData", @"onPencilKitDrawingChange"];
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
        _isApplePencilDataCaptureActive = NO;
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

- (void)handleTouches:(NSSet<UITouch *> *)touches phase:(UITouchPhase)phase {
    if (!_isApplePencilDataCaptureActive || !self.enableApplePencilData) {
        return;
    }
    
    for (UITouch *touch in touches) {
        if (touch.type == UITouchTypePencil || touch.type == UITouchTypeStylus) {
            NSDictionary *applePencilData = [self convertUITouchToApplePencilData:touch phase:phase];
            [MunimPencilkit sendApplePencilDataEvent:applePencilData];
        }
    }
}

// Conversion methods
- (NSDictionary *)convertUITouchToApplePencilData:(UITouch *)touch phase:(UITouchPhase)phase {
    CGPoint location = [touch locationInView:self];
    CGPoint previousLocation = [touch previousLocationInView:self];
    
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
    
    return @{
        @"pressure": @(touch.force / touch.maximumPossibleForce),
        @"altitude": @(touch.altitudeAngle / (M_PI / 2)),
        @"azimuth": @(0.0), // Azimuth not available on UITouch
        @"force": @(touch.force),
        @"maximumPossibleForce": @(touch.maximumPossibleForce),
        @"timestamp": @(touch.timestamp),
        @"location": @{
            @"x": @(location.x),
            @"y": @(location.y)
        },
        @"previousLocation": @{
            @"x": @(previousLocation.x),
            @"y": @(previousLocation.y)
        },
        @"isApplePencil": @(touch.type == UITouchTypePencil),
        @"phase": phaseString
    };
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
