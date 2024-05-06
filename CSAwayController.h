//
//  CSAwayController.h
//  ClassicLockScreen
//
//  Created by coolstar on 1/2/14.
//  Copyright (c) 2014 CoolStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSGradientView.h"
#import "CSAwayView.h"
#import "SBAwayMediaControlsView.h"

@interface CSAwayController : UIViewController{
    CSAwayView *_awayView;
    NSObject<CSAwayControllerDelegate> *_delegate;
    UIView *_notificationView;
    BOOL _isLocked;

    BBBulletin *_bulletinToOpenAfterUnlock;
}

@property (nonatomic, strong) NSObject<CSAwayControllerDelegate> *delegate;
@property (nonatomic, readonly) BOOL isLocked;
@property (nonatomic, strong) BBBulletin *bulletinToOpenAfterUnlock;
@property (nonatomic, strong) CSAwayView *awayView;

+ (id)sharedAwayController;
+ (id)sharedAwayControllerIfExists;
- (void)animateUnlock;
- (void)lock;
- (void)unlock;
- (BOOL)unlockWithPasscode:(NSString *)passcode;
- (void)setPasscodeLockVisible:(BOOL)visible animated:(BOOL)animated completion:(void (^)(BOOL success))completion;
- (BOOL) isShowingMediaControls;
- (BOOL)toggleMediaControls;
- (void)hideCamera;
- (void)restartDimTimer:(CGFloat)duration;
- (void)restartDimTimer;
- (void)cancelDimTimer;
- (void)showNotificationWithIcon:(UIImage *)icon title:(NSString *)appTitle message:(NSString *)message bulletin:(BBBulletin *)bulletin;
- (void)_sendToDeviceLockOwnerDeviceUnlockSucceeded;

@end
