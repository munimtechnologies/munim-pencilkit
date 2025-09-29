#import <MunimPencilkitSpec/MunimPencilkitSpec.h>
#import <PencilKit/PencilKit.h>
#import <UIKit/UIKit.h>
#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTUtils.h>

@interface MunimPencilkit : NSObject <NativeMunimPencilkitSpec>

@end

// PencilKit View Manager
@interface PencilKitViewManager : RCTViewManager

@end

// PencilKit Native View
@interface PencilKitView : UIView <PKCanvasViewDelegate>

@property (nonatomic, assign) NSInteger viewId;
@property (nonatomic, assign) BOOL enableApplePencilData;
@property (nonatomic, assign) BOOL enableToolPicker;
@property (nonatomic, strong) PKCanvasView *canvasView;
@property (nonatomic, strong) PKToolPicker *toolPicker;
@property (nonatomic, copy) RCTBubblingEventBlock onApplePencilData;
@property (nonatomic, copy) RCTBubblingEventBlock onDrawingChange;

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

@end
