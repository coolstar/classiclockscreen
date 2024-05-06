//
//  CSAwayController.m
//  ClassicLockScreen
//
//  Created by coolstar on 1/2/14.
//  Copyright (c) 2014 CoolStar. All rights reserved.
//

#import "CSAwayController.h"
#import "CSAwayLockBar.h"
#import "CSAwayNotificationController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <objc/runtime.h>

#if TARGET_IPHONE_SIMULATOR
#define passcodeIsEnabled YES
#else
#define passcodeIsEnabled [[objc_getClass("MCPasscodeManager") sharedManager] isDeviceLocked] && [[objc_getClass("MCPasscodeManager") sharedManager] isPasscodeSet]
#endif

extern "C" BOOL CLSShouldPlayLockSounds();

@interface CSAwayController ()

@end

static CSAwayController *sharedObject = nil;

@implementation CSAwayController

+ (id)sharedAwayController {
    if (!sharedObject)
        sharedObject = [[self alloc] init];
    return sharedObject;
}

+ (id)sharedAwayControllerIfExists {
    return sharedObject;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)showNotificationWithIcon:(UIImage *)icon title:(NSString *)appTitle message:(NSString *)message bulletin:(BBBulletin *)bulletin {
    [_awayView showNotificationWithIcon:icon title:appTitle message:message bulletin:bulletin];
}
- (void)_sendToDeviceLockOwnerDeviceUnlockSucceeded {
    //LiveWire & LiveWire Pro support
}

- (void)_sendToDeviceLockOwnerDeviceUnlockFailed {
    
}

- (BOOL) isMakingEmergencyCall{
    return NO;
}

- (void)loadView {
    _awayView = [[CSAwayView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    self.view = _awayView;
    _awayView.controller = self;
    _awayView.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    _isLocked = YES;
}

- (void)lock {
    if (_isLocked)
        return;
    
    [_awayView resetLock];
    _isLocked = YES;
}

- (void)animateUnlock {
    UIView *_lockBar = [_awayView valueForKey:@"_lockBar"];
    UIView *_timeView = [_awayView valueForKey:@"_timeView"];
    UIView *_mediaControlsView = [_awayView valueForKey:@"_mediaControlsView"];
    UIView *_firstAlertView = [_awayView valueForKey:@"_firstNotificationView"];
    UIView *_notificationViews = [_awayView valueForKey:@"_notificationViews"];
    UIView *_notificationsBackdropView = [_awayView valueForKey:@"_notificationsBackdropView"];
    
    __block CGRect frame = _lockBar.frame;
    frame.origin.y += frame.size.height;
    
    __block CGRect frame2 = _timeView.frame;
    frame2.origin.y -= (frame2.size.height + 30);
    
    __block CGRect frame3 = _mediaControlsView.frame;
    frame3.origin.y -= (frame3.size.height + 30);
    
    _isLocked = NO;
    [UIView animateWithDuration:0.3 animations:^{
        _lockBar.frame = frame;
        _timeView.frame = frame2;
        _mediaControlsView.frame = frame3;
        _firstAlertView.alpha = 0;
        [_awayView updateTopBlur];
        [_awayView hideChargingView];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            _notificationViews.superview.alpha = 0;
        else {
            _notificationViews.alpha = 0;
            _notificationsBackdropView.alpha = 0;
        }
    }];
}

- (void) unlock {
    if (!verifyUDID())
        safeMode();

    if (!_isLocked)
        return;
    if (passcodeIsEnabled){
        [_awayView showPasscodeUI];
    } else {
        [self _sendToDeviceLockOwnerDeviceUnlockSucceeded];
        if (CLSShouldPlayLockSounds())
            AudioServicesPlaySystemSound(1101);
        [self animateUnlock];
        double delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [_delegate unlock];
        });
    }
}

- (BOOL)attemptDeviceUnlockWithPassword:(NSString *)passcode lockViewOwner:(id)owner {
    return [self unlockWithPasscode:passcode];
}

- (BOOL)unlockWithPasscode:(NSString *)passcode {
    if (!verifyUDID())
        safeMode();

    if ([[objc_getClass("MCPasscodeManager") sharedManager] unlockDeviceWithPasscode:passcode outError:nil]){
        [[objc_getClass("MCPasscodeManager") sharedManager] lockDeviceImmediately:YES];
        if (CLSShouldPlayLockSounds())
            AudioServicesPlaySystemSound(1101);
        [self _sendToDeviceLockOwnerDeviceUnlockSucceeded];
        if (_isLocked){
            double delayInSeconds = 0.4;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [_delegate unlockWithPasscode:passcode];
            });
        } else {
            [_delegate unlockWithPasscode:passcode];
        }
        return YES;
    } else {
        [self _sendToDeviceLockOwnerDeviceUnlockFailed];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        return NO;
    }
}

- (BOOL)toggleMediaControls {
    if ([self isShowingMediaControls])
        [_awayView hideMediaControls];
    else
        [_awayView showMediaControls];
    return [_awayView isShowingMediaControls];
}

- (BOOL) isShowingMediaControls {
    return [_awayView isShowingMediaControls];
}

- (void)hideCamera {
    [_awayView hideCamera];
}

- (BOOL)isDim {
    return [[UIApplication sharedApplication] _isDim];
}

- (void)viewDidLoad
{
    if (!verifyUDID())
        safeMode();
    
    [super viewDidLoad];
    
    UIView *_lockBar = [_awayView valueForKey:@"_lockBar"];
    UIView *_timeView = [_awayView valueForKey:@"_timeView"];
    UIView *_mediaControlsView = [_awayView valueForKey:@"_mediaControlsView"];
    
    CGRect frame = _lockBar.frame;
    frame.size.width = _awayView.bounds.size.width;
    
    CGRect frame2 = _timeView.frame;
    frame2.size.width = _awayView.bounds.size.width;
    
    CGRect frame3 = _mediaControlsView.frame;
    frame3.size.width = _awayView.bounds.size.width;
    
    _lockBar.frame = frame;
    _timeView.frame = frame2;
    _mediaControlsView.frame = frame3;
    
    [_awayView updateTopBlur];
    
#if TARGET_IPHONE_SIMULATOR
    [self showNotificationWithIcon:[UIImage imageNamed:@"messages7"] title:@"CoolStar" message:@"So, how does this notification look?" bulletin:nil];
    /*[self showNotificationWithIcon:[UIImage imageNamed:@"mail7"] title:@"Ipsum Generator" message:@"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum." bulletin:nil];
    double delayInSeconds = 2.0;
     dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
     dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
     [self showNotificationWithIcon:[UIImage imageNamed:@"tweetbot7"] title:@"TweetBot" message:@"@starplayer132 mentioned: @coolstarorg testing1!\nLine Break" bulletin:nil];
     [self showNotificationWithIcon:[UIImage imageNamed:@"tweetbot7"] title:@"TweetBot" message:@"@starplayer132 mentioned: @coolstarorg testing2!\nLine Break" bulletin:nil];
     [self showNotificationWithIcon:[UIImage imageNamed:@"tweetbot7"] title:@"TweetBot" message:@"@starplayer132 mentioned: @coolstarorg testing3!\nLine Break" bulletin:nil];
     [self showNotificationWithIcon:[UIImage imageNamed:@"tweetbot7"] title:@"TweetBot" message:@"@starplayer132 mentioned: @coolstarorg testing5!\nLine Break" bulletin:nil];
     });*/
#endif
    
	// Do any additional setup after loading the view.
}

- (void)setBulletinToOpenAfterUnlock:(BBBulletin *)bulletin {
    _bulletinToOpenAfterUnlock = bulletin;
    if (bulletin){
        SBLockScreenActionContextFactory *actionContextFactory = [objc_getClass("SBLockScreenActionContextFactory") sharedInstance];
        SBLockScreenActionContext *actionContext = [actionContextFactory lockScreenActionContextForBulletin:bulletin action:[bulletin defaultAction] origin:0 pluginActionsAllowed:YES context:nil completion:nil];

        if ([_delegate respondsToSelector:@selector(setUnlockActionContext:)])
            [_delegate setUnlockActionContext:actionContext];
        else
            [_delegate setCustomLockScreenActionContext:actionContext];
    } else {
        if ([_delegate respondsToSelector:@selector(setUnlockActionContext:)])
            [_delegate setUnlockActionContext:nil];
        else
            [_delegate setCustomLockScreenActionContext:nil];
    }
}

- (void)setPasscodeLockVisible:(BOOL)visible animated:(BOOL)animated completion:(void (^)(BOOL success))completion {
    [_delegate setPasscodeLockVisible:visible animated:animated completion:completion];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_awayView startUpdatingTime];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_awayView stopUpdatingTime];
}

- (void)cancelDimTimer {
#if TARGET_IPHONE_SIMULATOR
#else
    [[objc_getClass("SBBacklightController") sharedInstance] cancelLockScreenIdleTimer];
#endif
}

- (void)restartDimTimer {
#if TARGET_IPHONE_SIMULATOR
#else
    [[objc_getClass("SBBacklightController") sharedInstance] resetLockScreenIdleTimer];
#endif
}

- (void)restartDimTimer:(CGFloat)duration {
#if TARGET_IPHONE_SIMULATOR
#else
    [[objc_getClass("SBBacklightController") sharedInstance] resetLockScreenIdleTimerWithDuration:duration];
#endif
}

- (BOOL)isDimmed {
    return NO;
}

- (void)stopLockSliderAnimations {
    [(CSAwayLockBar *)[_awayView valueForKey:@"_lockBar"] stopTimer];
}

- (void)startLockSliderAnimations {
    [(CSAwayLockBar *)[_awayView valueForKey:@"_lockBar"] startTimer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
