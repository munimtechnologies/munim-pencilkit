#import <React/RCTBridgeModule.h>

/// Example-app helper for the device self-test (SelfTest.ts): writes the
/// result JSON to Documents so it can be read back with devicectl, and reports
/// whether the app was launched with `-selftest`.
@interface MunimSelfTest : NSObject <RCTBridgeModule>
@end

@implementation MunimSelfTest

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

RCT_EXPORT_METHOD(writeResult:(NSString *)json
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
  NSURL *documents = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                            inDomains:NSUserDomainMask].firstObject;
  NSURL *url = [documents URLByAppendingPathComponent:@"munim-pencilkit-selftest.json"];
  NSError *error = nil;
  if (![json writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
    reject(@"write_failed", error.localizedDescription, error);
    return;
  }
  NSLog(@"[munim-pencilkit-selftest] wrote %@", url.path);
  resolve(url.path);
}

RCT_EXPORT_METHOD(isAutoRun:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
  resolve(@([[NSProcessInfo processInfo].arguments containsObject:@"-selftest"]));
}

@end
