//
//  SBAwayChargingView.m
//  ClassicLockScreen
//
//  Created by coolstar on 1/10/14.
//  Copyright (c) 2014 CoolStar. All rights reserved.
//

#import "SBAwayChargingView.h"
#import "SBBatteryChargingView.h"
#import "CSModernBatteryChargingView.h"

extern BOOL CSCLScheckModern();

@implementation SBAwayChargingView

+ (BOOL)shouldShowDeviceBattery {
    //return YES;
    UIDeviceBatteryState state = [UIDevice currentDevice].batteryState;
    if (state == UIDeviceBatteryStateFull || state == UIDeviceBatteryStateCharging)
        return YES;
    return NO;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)addChargingView {
    [_chargingView removeFromSuperview];

    if (CSCLScheckModern())
        _chargingView = [[CSModernBatteryChargingView alloc] initWithFrame:self.bounds];
    else
        _chargingView = [[SBBatteryChargingView alloc] initWithFrame:self.bounds];
    _chargingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _chargingView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_chargingView];
    [_chargingView show];
}

- (void)hideChargingView {
    [_chargingView hide];
    [_chargingView removeFromSuperview];
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
