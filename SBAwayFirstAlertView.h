//
//  SBAwayFirstAlertView.h
//  ClassicLockScreen
//
//  Created by CoolStar Org. on 2/19/14.
//  Copyright (c) 2014 CoolStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBAwayLockBarLabel.h"
#import "CSGradientView.h"
#import "BBBulletin.h"

@interface SBAwayFirstAlertView : UIImageView {
    UIImageView *_appIconView;
    UILabel *_titleLabel;
    UILabel *_notificationView;
    NSTimer *_blinkTimer;
    SBAwayLockBarLabel *_unlockLabel;
    CSGradientView *_unlockSliderBorder;
    BBBulletin *_bulletin;
}
@property (nonatomic, readonly) UISlider *unlockSlider;
@property (nonatomic, retain) BBBulletin *bulletin;

- (id)initWithAppIcon:(UIImage *)icon appTitle:(NSString *)appTitle notificationText:(NSString *)notificationText bulletin:(BBBulletin *)bulletin;
- (void)startBlinking;
- (void)stopBlinking;
- (void)updatePosition ;

@end
