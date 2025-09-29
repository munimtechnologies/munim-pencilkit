#import <MunimPencilkitSpec/MunimPencilkitSpec.h>
#import <PencilKit/PencilKit.h>
#import <UIKit/UIKit.h>

@interface MunimPencilkit : NSObject <NativeMunimPencilkitSpec>

@end

// PencilKit View Manager
@interface PencilKitViewManager : RCTViewManager

@end

// PencilKit Native View
@interface PencilKitView : UIView

@property (nonatomic, assign) NSInteger viewId;
@property (nonatomic, assign) BOOL enableApplePencilData;
@property (nonatomic, assign) BOOL enableToolPicker;
@property (nonatomic, strong) PKCanvasView *canvasView;
@property (nonatomic, strong) PKToolPicker *toolPicker;

- (instancetype)initWithViewId:(NSInteger)viewId;

@end
