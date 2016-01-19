#import "RSSignatureViewManager.h"
#import "RCTBridgeModule.h"
#import "RCTBridge.h"
#import "RCTEventDispatcher.h"
#import "RCTUIManager.h"

@implementation RSSignatureViewManager

@synthesize bridge = _bridge;
@synthesize signView;

RCT_EXPORT_MODULE()

RCT_EXPORT_VIEW_PROPERTY(rotateClockwise, BOOL)
RCT_EXPORT_VIEW_PROPERTY(square, BOOL)

// See https://github.com/facebook/react-native/issues/1365
- (dispatch_queue_t)methodQueue {
    return _bridge.uiManager.methodQueue;
}

-(UIView *) view
{
	self.signView = [[RSSignatureView alloc] init];
	self.signView.manager = self;
	return signView;
}

-(void) saveImage:(NSString *) aTempPath withEncoded: (NSString *) aEncoded {
	[self.bridge.eventDispatcher
	 sendDeviceEventWithName:@"onSaveEvent"
	 body:@{
					@"pathName": aTempPath,
					@"encoded": aEncoded
					}];
}

RCT_EXPORT_METHOD(getBase64ImageData:(nonnull NSNumber *)reactTag callback:(RCTResponseSenderBlock)callback) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary *viewRegistry) {
        RSSignatureView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RSSignatureView class]]) {
            NSLog(@"Invalid view returned from registry, expecting RSSignatureView, got: %@", view);
        }
        callback(@[[NSNull null], [view getImageData]]);
    }];
}

@end
