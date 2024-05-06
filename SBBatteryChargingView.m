//
//  SBBatteryChargingView.m
//  ClassicLockScreen
//
//  Created by coolstar on 1/9/14.
//  Copyright (c) 2014 CoolStar. All rights reserved.
//

#import "SBBatteryChargingView.h"
#import "SBAwayChargingView.h"

extern BOOL CSCLScheckModern();

@implementation SBBatteryChargingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autoresizesSubviews = YES;
        _topBatteryView = [[UIImageView alloc] initWithFrame:self.bounds];
        if (CSCLScheckModern())
            _topBatteryView.backgroundColor = [UIColor clearColor];
        else
            _topBatteryView.backgroundColor = [UIColor blackColor];
        _topBatteryView.contentMode = UIViewContentModeCenter;
        _topBatteryView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _topBatteryView.image = [UIImage imageNamed:@"BatteryBG_17"];
        [self addSubview:_topBatteryView];
        
        //_reflectionView = [[SBBatteryReflectionView alloc] initWithImage:[UIImage imageNamed:@"BatteryBG_17"] bottomMargin:0.0];
        //_reflectionView.frame = CGRectMake(28, 345, 264, 129);
        
        //[self addSubview:_reflectionView];
        
        [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_batteryStatusChanged:) name:UIDeviceBatteryStateDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_batteryStatusChanged:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
        [self _batteryStatusChanged:nil];
    }
    return self;
}

- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
    CGImageRef maskRef = maskImage.CGImage;
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef maskedImageRef = CGImageCreateWithMask([image CGImage], mask);
    UIImage *maskedImage = [UIImage imageWithCGImage:maskedImageRef];
    
    CGImageRelease(mask);
    CGImageRelease(maskedImageRef);
    
    // returns new image with mask applied
    return maskedImage;
}

- (int)_currentBatteryIndex {
#if TARGET_IPHONE_SIMULATOR
    return 17;
#endif
    int imageIndex = 17.0*[[UIDevice currentDevice] batteryLevel];
    if (imageIndex <= 2)
        imageIndex = 2;
    return imageIndex;
}

- (NSString *)_imageFormatString {
    int index = [self _currentBatteryIndex];
    return [NSString stringWithFormat:@"BatteryBG_%d",index];
}

- (void)hide {
    _topBatteryView.alpha = 0;
}

- (void)show {
    _topBatteryView.alpha = 1;
}

- (void)_batteryStatusChanged:(id)sender {
    if (![SBAwayChargingView shouldShowDeviceBattery])
        [self hide];
    else
        [self show];
    _topBatteryView.image = [UIImage imageNamed:[self _imageFormatString]];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
