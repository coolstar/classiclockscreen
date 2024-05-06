//
//  CSModernBatteryChargingView.m
//  ClassicLockScreen
//
//  Created by CoolStar on 7/14/14.
//  Copyright (c) 2014 CoolStar. All rights reserved.
//

#import "CSModernBatteryChargingView.h"

extern _UIBackdropViewSettings *getBackdropSettings();

@implementation CSModernBatteryChargingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _UIBackdropViewSettings *settings = getBackdropSettings();
        UIImage *mask = [self generateMaskForPercent:1.0];
        CGFloat width = mask.size.width;
        CGFloat height = mask.size.height;
        [settings setFilterMaskImage:mask];
        [settings setGrayscaleTintMaskImage:mask];
        [settings setColorTintMaskImage:mask];
        if ([settings respondsToSelector:@selector(setDarkeningTintMaskImage:)])
            [settings setDarkeningTintMaskImage:mask];
        if ([settings respondsToSelector:@selector(setColorBurnTintMaskImage:)])
            [settings setColorBurnTintMaskImage:mask];
        _blurView = [[CSBackdropView alloc] initWithFrame:CGRectMake((frame.size.width/2.0)-(width/2.0), (frame.size.height/2.0)-(height/2.0), width, height) autosizesToFitSuperview:NO settings:settings];
        _blurViewOverlay = [[UIImageView alloc] initWithFrame:CGRectMake(_blurView.frame.origin.x-0.5, _blurView.frame.origin.y-0.5, _blurView.frame.size.width+1.0, _blurView.frame.size.height+1.0)];
        [_blurViewOverlay setImage:[self generateOverlayForPercent:1.0]];
        _blurView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _blurViewOverlay.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:_blurView];
        [self addSubview:_blurViewOverlay];
        
        [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_batteryStatusChanged:) name:UIDeviceBatteryStateDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_batteryStatusChanged:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
        [self _batteryStatusChanged:nil];
        // Initialization code
    }
    return self;
}

- (UIImage *)generateMaskForPercent:(float)percentage {
    UIImage *mask = [UIImage imageNamed:@"CSModernBatteryMask"];
    CGRect maskFrame = CGRectMake(0, 0, mask.size.width, mask.size.height);
    UIGraphicsBeginImageContextWithOptions(mask.size, NO, 0.0);
    [[UIColor clearColor] setFill];
    UIRectFill(maskFrame);
    
    [mask drawInRect:maskFrame];
    
    UIImage *chargeMask = [[UIImage imageNamed:@"CSModernBatteryChargeMask"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [chargeMask drawInRect:CGRectMake(10, 10, (mask.size.width-37.0f)*percentage, mask.size.height-20.0f)];
    
    UIImage *generatedMask = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return generatedMask;
}

- (UIImage *)generateOverlayForPercent:(float)percentage {
    UIImage *overlay = [UIImage imageNamed:@"CSModernBatteryOverlay"];
    CGRect overlayFrame = CGRectMake(0, 0, overlay.size.width, overlay.size.height);
    UIGraphicsBeginImageContextWithOptions(overlay.size, NO, 0.0);
    [[UIColor clearColor] setFill];
    UIRectFill(overlayFrame);
    
    [overlay drawInRect:overlayFrame];
    
    UIImage *chargeOverlay = [[UIImage imageNamed:@"CSModernBatteryChargeOverlay"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [chargeOverlay drawInRect:CGRectMake(10, 10, (overlay.size.width-37.0f)*percentage, overlay.size.height-20.0f)];
    
    UIImage *generatedOverlay = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return generatedOverlay;
}

- (void)hide {
    _blurViewOverlay.alpha = 0;
    _blurView.alpha = 0;
}

- (void)show {
    _blurViewOverlay.alpha = 1;
    _blurView.alpha = 1;
}

- (void)_batteryStatusChanged:(id)sender {
    if (![SBAwayChargingView shouldShowDeviceBattery])
        [self hide];
    else
        [self show];
    float batteryLevel = [[UIDevice currentDevice] batteryLevel];
#if TARGET_IPHONE_SIMULATOR
    batteryLevel = 1.0f;
#endif
    _blurViewOverlay.image = [self generateOverlayForPercent:batteryLevel];
    _UIBackdropViewSettings *settings = getBackdropSettings();
    UIImage *mask = [self generateMaskForPercent:batteryLevel];
    [settings setFilterMaskImage:mask];
    [settings setGrayscaleTintMaskImage:mask];
    [settings setColorTintMaskImage:mask];
    if ([settings respondsToSelector:@selector(setDarkeningTintMaskImage:)])
        [settings setDarkeningTintMaskImage:mask];
    if ([settings respondsToSelector:@selector(setColorBurnTintMaskImage:)])
        [settings setColorBurnTintMaskImage:mask];
    [_blurView transitionToSettings:settings];
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
