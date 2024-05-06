//
//  SBBatteryChargingView.h
//  ClassicLockScreen
//
//  Created by coolstar on 1/9/14.
//  Copyright (c) 2014 CoolStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBAwayChargingView.h"

@interface SBBatteryChargingView : UIView <SBAwayChargingViewProtocol> {
    UIImageView *_topBatteryView;
}

- (void)hide;
- (void)show;
@end
