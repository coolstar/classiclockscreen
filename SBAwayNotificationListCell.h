//
//  SBAwayNotificationListCell.h
//  ClassicLockScreen
//
//  Created by CoolStar Org. on 3/14/14.
//  Copyright (c) 2014 CoolStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBAwayLockBarLabel.h"
#import "CSGradientView.h"
#import "BBBulletin.h"

@interface SBAwayNotificationListCell : UITableViewCell {
    NSTimer *_blinkTimer;
    UISlider *_unlockSlider;
    SBAwayLockBarLabel *_unlockLabel;
    CSGradientView *_unlockSliderBorder;
    BBBulletin *_bulletin;
}
@property (nonatomic, retain) NSString *title, *message;
@property (nonatomic, retain) UIImageView *icon;
@property (nonatomic, readonly) UISlider *unlockSlider;
@property (nonatomic, retain) BBBulletin *bulletin;

- (void)startBlinking;
- (void)stopBlinking;
@end
