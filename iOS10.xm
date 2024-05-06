#import "CSAwayController.h"
#import "CSClassicLockScreenSettingsManager.h"
#import "CSAwayNotificationController.h"
#import "BBBulletin.h"
#import "Headers.h"
#import <AudioToolbox/AudioToolbox.h>

extern "C" BOOL CLSShouldPlayLockSounds();

%group iOS10
%hook SBLockScreenManager
-(void)startUIUnlockFromSource:(int)arg1 withOptions:(id)arg2 {
	%orig;
	CSAwayController *awayController = [CSAwayController sharedAwayController];
	if ([awayController isLocked]){
		[awayController _sendToDeviceLockOwnerDeviceUnlockSucceeded];
		if (CLSShouldPlayLockSounds())
        	AudioServicesPlaySystemSound(1101);

        CSAwayView *awayView = awayController.awayView;
        if (awayView.passcodeFieldIsOpen){
        	[awayView hidePasscodeUI];
        }
		[awayController animateUnlock];
	}
}

-(BOOL)attemptUnlockWithPasscode:(id)arg1 {
	if (%orig){
		CSAwayController *awayController = [CSAwayController sharedAwayController];
		if ([awayController isLocked]){
			[awayController _sendToDeviceLockOwnerDeviceUnlockSucceeded];
			if (CLSShouldPlayLockSounds())
	        	AudioServicesPlaySystemSound(1101);

	        CSAwayView *awayView = awayController.awayView;
	        if (awayView.passcodeFieldIsOpen){
	        	[awayView hidePasscodeUI];
	        }
			[awayController animateUnlock];
		}
		return YES;
	}
	return NO;
}

-(BOOL)_attemptUnlockWithPasscode:(id)arg1 mesa:(BOOL)arg2 finishUIUnlock:(BOOL)arg3{
	if (%orig){
		CSAwayController *awayController = [CSAwayController sharedAwayController];
		if ([awayController isLocked]){
			[awayController _sendToDeviceLockOwnerDeviceUnlockSucceeded];
			if (CLSShouldPlayLockSounds())
	        	AudioServicesPlaySystemSound(1101);

	        CSAwayView *awayView = awayController.awayView;
	        if (awayView.passcodeFieldIsOpen){
	        	[awayView hidePasscodeUI];
	        }
			[awayController animateUnlock];
		}
		return YES;
	}
	return NO;
}
%end

%hook NCNotificationPriorityListViewController
//8.0+
- (BOOL)insertNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(id)arg2 {
	BOOL ret = %orig;
	if (![[%c(SBLockScreenManager) sharedInstance] isUILocked])
		return ret;
	BOOL enabled = [[CSClassicLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		BBBulletin *bulletin = request.bulletin;

		NSString *bundleID = bulletin.sectionID;
		SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:bundleID];
		SBApplicationIcon *icon = [[%c(SBApplicationIcon) alloc] initWithApplication:application];
		UIImage *image = [icon generateIconImage:0];

		[[CSAwayController sharedAwayController] showNotificationWithIcon:image title:bulletin.title message:bulletin.message bulletin:bulletin];
	}
	return ret;
}

- (void)removeNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(id)arg2 {
	%orig;
	if (![[%c(SBLockScreenManager) sharedInstance] isUILocked])
		return;
	BOOL enabled = [[CSClassicLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		BBBulletin *bulletin = request.bulletin;
		[[CSAwayNotificationController sharedInstance] removeNotificationWithBulletin:bulletin];
	}
}
%end

%hook SBScreenFadeAnimationController
- (void)prepareToFadeInForSource:(NSInteger)source timeAlpha:(CGFloat)timeAlpha dateAlpha:(CGFloat)dateAlpha statusBarAlpha:(CGFloat)statusBarAlpha delegate:(id)delegate existingDateView:(id)existingDateView completion:(id)completion {
	BOOL enabled = [[CSClassicLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		if (![[%c(SBLockScreenManager) sharedInstance] isUILocked])
			statusBarAlpha = 0.0f;
		%orig(source, 0.0, 0.0, statusBarAlpha, delegate, existingDateView, completion);
	}
	else
		%orig;
}
%end

%hook SBDashBoardScrollGestureController
- (void)setScrollingStrategy:(NSInteger)scrollingStrategy {
	BOOL enabled = [[CSClassicLockScreenSettingsManager sharedInstance] enabled];
	if (enabled)
		%orig(0);
	else
		%orig;
}

-(void)_updateForScrollingStrategy:(NSInteger)arg1 fromScrollingStrategy:(NSInteger)arg2 {
	BOOL enabled = [[CSClassicLockScreenSettingsManager sharedInstance] enabled];
	if (enabled)
		%orig(0,0);
	else
		%orig;
}
%end

%hook SBDashBoardViewController

%new
- (BOOL)unlock {
	BOOL success = [[%c(SBLockScreenManager) sharedInstance] attemptUnlockWithPasscode:nil];
	if (success){
		CSAwayController *controller = [CSAwayController sharedAwayController];
		[controller.view removeFromSuperview];
		controller.delegate = nil;
	}
	return success;
}

- (void)loadView {
	%orig;

	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		if (!selfVerify()){
			safeMode();
		}
		if (!deepVerifyUDID()){
			safeMode();
		}
	});

	BOOL enabled = [[CSClassicLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		for (UIView *x in [self dashBoardView].subviews){
			[x setAlpha:0];
		}

		CSAwayController *controller = [CSAwayController sharedAwayController];
		[controller.view removeFromSuperview];
		controller.view.alpha = 1;
		[controller lock];

		CGRect frame = [[self dashBoardView] bounds];
		controller.view.frame = frame;
		controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		controller.view.layer.zPosition = 100;
		controller.delegate = self;

		[[self dashBoardView] addSubview:controller.view];

		[controller viewDidAppear:NO];
	}
}

-(BOOL)handleMenuButtonTap {
	BOOL enabled = [[CSClassicLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		[[CSAwayController sharedAwayControllerIfExists] hideCamera];
		[[CSAwayController sharedAwayControllerIfExists] toggleMediaControls];
	}
	return YES;
}

- (void)activate {
	%orig;
	BOOL enabled = [[CSClassicLockScreenSettingsManager sharedInstance] enabled];

	if (enabled){
		for (UIView *x in [self dashBoardView].subviews){
			[x setAlpha:0];
		}

		CSAwayController *controller = [CSAwayController sharedAwayController];
		controller.view.alpha = 1;

		[controller viewDidAppear:NO];
		[[controller awayView] resetSlider];;
	}
}

- (BOOL)showsSpringBoardStatusBar {
	BOOL enabled = [[CSClassicLockScreenSettingsManager sharedInstance] enabled];
	if (enabled)
		return YES;
	return %orig;
}

- (BOOL)managesOwnStatusBarAtActivation {
	BOOL enabled = [[CSClassicLockScreenSettingsManager sharedInstance] enabled];
	if (enabled)
		return NO;
	return %orig;
}

-(void)setPasscodeLockVisible:(BOOL)visible animated:(BOOL)animated completion:(/*^block*/id)completion  {
	BOOL enabled = [[CSClassicLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		[UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
			CSAwayController *controller = [CSAwayController sharedAwayController];
			controller.view.alpha = visible ? 0.0 : 1.0;
		}];
	}
	%orig;
}
%end
%end

%ctor {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		if (kCFCoreFoundationVersionNumber > 1300){
			dlopen("/Library/MobileSubstrate/DynamicLibraries/LockGlyphX.dylib", RTLD_NOW);
			%init(iOS10);
			if (!deepVerifyUDID()){
				unlink("/var/mobile/Library/Preferences/org.coolstar.classiclockscreen.license");
				unlink("/var/mobile/Library/Preferences/org.coolstar.classiclockscreen.license.signed");
				safeMode();
			}
			if (!selfVerify()){
				unlink("/var/mobile/Library/Preferences/org.coolstar.classiclockscreen.license");
				unlink("/var/mobile/Library/Preferences/org.coolstar.classiclockscreen.license.signed");
				safeMode();
			}
		}
	});
}