//
//  CSModernBatteryChargingView.h
//  ClassicLockScreen
//
//  Created by CoolStar on 7/14/14.
//  Copyright (c) 2014 CoolStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBAwayChargingView.h"
#import "CSBackdropView.h"

@interface CSModernBatteryChargingView : UIView <SBAwayChargingViewProtocol> {
    CSBackdropView *_blurView;
    UIImageView *_blurViewOverlay;
}

@end
