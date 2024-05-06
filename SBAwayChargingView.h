//
//  SBAwayChargingView.h
//  ClassicLockScreen
//
//  Created by coolstar on 1/10/14.
//  Copyright (c) 2014 CoolStar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SBAwayChargingViewProtocol <NSObject>
- (void)hide;
- (void)show;
@end

@interface SBAwayChargingView : UIView {
    UIView<SBAwayChargingViewProtocol> *_chargingView;
}

@property (nonatomic, readonly) UIView<SBAwayChargingViewProtocol> *chargingView;

- (void)addChargingView;
- (void)hideChargingView;
+ (BOOL)shouldShowDeviceBattery;

@end
