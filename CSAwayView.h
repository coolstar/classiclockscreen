//
//  CSAwayView.h
//  ClassicLockScreen
//
//  Created by coolstar on 1/11/14.
//  Copyright (c) 2014 CoolStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSAwayLockBar.h"
#import "SBAwayFirstAlertView.h"
#import "BBBulletin.h"
#import "Headers.h"

@class CSAwayController, SBAwayMediaControlsView, SBAwayChargingView, CSBackdropView;
@interface CSAwayView : UIView <CSAwayLockBarDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, SBUIPasscodeLockViewDelegate> {
    __weak CSAwayController *_controller;

    UIImageView *_backgroundView;
    UIImageView *_artworkView;
    SBAwayChargingView *_chargingView;
    UIImageView *_statusBarBackgroundView;

    UIImageView *_timeView;
    UILabel *_timeLabel, *_dateLabel;
    CSBackdropView *_topBackdropView;
    UIImageView *_topBackdropOverlayView;
    SBAwayMediaControlsView *_mediaControlsView;

    SBAwayFirstAlertView *_firstNotificationView;
    UITableView *_notificationViews;
    CSBackdropView *_notificationsBackdropView;

    CSAwayLockBar *_lockBar;
    NSTimer *_timeUpdater;

    /*UIView *_modernPasscodeView;
    SBUIPasscodeLockViewBase *_modernPasscodeViewPasscodeView;
    BOOL _passcodeFieldIsOpen;*/

    UIView *_forecastView;
    UIView *_jellyLockView;
    UIView *_berryLockView;
    UIView *_lockGlyphView;
}

@property (nonatomic, readonly) SBAwayChargingView *chargingView;
@property (nonatomic, weak) CSAwayController *controller;
@property (nonatomic, readonly) BOOL passcodeFieldIsOpen;
@property (nonatomic, strong) SBAwayFirstAlertView *firstNotificationView;

- (void)updateTopBlur;
- (void)updateNowPlayingInfo:(id)sender;
- (void)hideCamera;
- (void)showChargingView;
- (void)hideChargingView;
- (void)hideMediaControls;
- (void)showMediaControls;
- (BOOL)isShowingMediaControls;
- (void)showPasscodeUI;
- (void)hidePasscodeUI;
- (void)resetLock;
- (void)resetSlider;
- (void)showNotificationWithIcon:(UIImage *)icon title:(NSString *)appTitle message:(NSString *)message bulletin:(BBBulletin *)bulletin;
- (void)startUpdatingTime;
- (void)stopUpdatingTime;

@end
