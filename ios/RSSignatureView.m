#import "RSSignatureView.h"
#import "RCTConvert.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PPSSignatureView.h"
#import "RSSignatureViewManager.h"

#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)

@implementation RSSignatureView {
	BOOL _loaded;
	EAGLContext *_context;
	UIButton *saveButton;
	UIButton *clearButton;
	UILabel *titleLabel;
	BOOL _rotateClockwise;
	BOOL _square;
}

@synthesize sign;
@synthesize manager;

- (void) didRotate:(NSNotification *)notification {
	int ori=1;
	UIDeviceOrientation currOri = [[UIDevice currentDevice] orientation];
	if ((currOri == UIDeviceOrientationLandscapeLeft) || (currOri == UIDeviceOrientationLandscapeRight)) {
		ori=0;
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	if (!_loaded) {
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:)
																								 name:UIDeviceOrientationDidChangeNotification object:nil];
		
		_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		
		CGSize screen = self.bounds.size;
		
		sign = [[PPSSignatureView alloc]
						initWithFrame: CGRectMake(0, 0, screen.width, screen.height)
						context: _context];
		
		[self addSubview:sign];
		
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.height - 80, 24)];
        [titleLabel setCenter:CGPointMake(50, self.bounds.size.height/2)];
        [titleLabel setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90))];
        [titleLabel setText:@"x_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _"];
        [titleLabel setLineBreakMode:NSLineBreakByClipping];
        [titleLabel setTextAlignment: NSTextAlignmentLeft];
        [titleLabel setTextColor:[UIColor colorWithRed:200/255.f green:200/255.f blue:200/255.f alpha:1.f]];
        [sign addSubview:titleLabel];

        CGSize buttonSize = CGSizeMake(40, 130.0); //Width/Height is swapped

        clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [clearButton setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90))];
        [clearButton setLineBreakMode:NSLineBreakByClipping];
        [clearButton addTarget:self action:@selector(onClearButtonPressed)
                    forControlEvents:UIControlEventTouchUpInside];
        [clearButton setTitle:@"clear signature" forState:UIControlStateNormal];
        [clearButton setTitleColor:[UIColor colorWithRed:100/255.f green:100/255.f blue:100/255.f alpha:1.f] forState:UIControlStateNormal];
        clearButton.frame = CGRectMake(
                0,
                (sign.bounds.size.height - buttonSize.height) / 2,
                buttonSize.width,
                buttonSize.height
        );
        [sign addSubview:clearButton];
		
	}
	_loaded = true;
}

- (void)setRotateClockwise:(BOOL)rotateClockwise {
	_rotateClockwise = rotateClockwise;
}

- (void)setSquare:(BOOL)square {
	_square = square;
}

-(void) onSaveButtonPressed {
	saveButton.hidden = YES;
	clearButton.hidden = YES;
	UIImage *signImage = [self.sign signatureImage: _rotateClockwise withSquare:_square];
	
	saveButton.hidden = NO;
	clearButton.hidden = NO;
	
	NSError *error;
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths firstObject];
	NSString *tempPath = [documentsDirectory stringByAppendingFormat:@"/signature.png"];
	
	//remove if file already exists
	if ([[NSFileManager defaultManager] fileExistsAtPath:tempPath]) {
		[[NSFileManager defaultManager] removeItemAtPath:tempPath error:&error];
		if (error) {
			NSLog(@"Error: %@", error.debugDescription);
		}
	}
	
	// Convert UIImage object into NSData (a wrapper for a stream of bytes) formatted according to PNG spec
	NSData *imageData = UIImagePNGRepresentation(signImage);
	BOOL isSuccess = [imageData writeToFile:tempPath atomically:YES];
	if (isSuccess) {
		NSString *base64Encoded = [imageData base64EncodedStringWithOptions:0];
		[self.manager saveImage: tempPath withEncoded:base64Encoded];
	}
}

-(void) onClearButtonPressed {
	[self.sign erase];
}

-(NSString *) getImageData {
    UIImage *image = [self.sign signatureImage:_rotateClockwise withSquare:_square];

	if (image == nil) return nil;

    NSData *imageData = UIImagePNGRepresentation(image);
    return [imageData base64EncodedStringWithOptions:0];
}

@end
