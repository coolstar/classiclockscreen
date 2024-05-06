/* How to Hook with Logos
Hooks are written with syntax similar to that of an Objective-C @implementation.
You don't need to #include <substrate.h>, it will be done automatically, as will
the generation of a class list and an automatic constructor.
*/

#import "CSAwayController.h"
#import "CSClassicLockScreenSettingsManager.h"
#import "CSAwayNotificationController.h"
#import "BBBulletin.h"
#import "Headers.h"
#import <AudioToolbox/AudioToolbox.h>

extern "C" BOOL CLSShouldPlayLockSounds();

%group iOS9

static JLJellyLockView *currentJellyLockView = nil;

//JellyLock7 Support
%hook JLJellyLockView
%new;
+ (JLJellyLockView *)currentJellyLockView {
	return currentJellyLockView;
}

-(id)initWithFrame:(CGRect)frame usingApplications:(id)applications andBadges:(id)badges withGrabberImage:(id)grabberImage cameraImage:(id)image cameraImageIsApp:(BOOL)app andLockImage:(id)image7 usingColor:(id)color addingRadialBlur:(BOOL)blur enablingBlur:(BOOL)blur10 grabberIncreasesWithDistance:(BOOL)distance {
	self = %orig;
	currentJellyLockView = self;
	return self;
}

-(void)resetGrabber:(BOOL)grabber {
	%orig;
	currentJellyLockView = self;
}
%end

//JellyLock Unified Support
%hook JLUJellyLockView
%new;
+ (JLJellyLockView *)currentJellyLockView {
	return currentJellyLockView;
}

-(id)initWithFrame:(CGRect)frame usingApplications:(id)applications andBadges:(id)badges withGrabberImage:(id)grabberImage cameraImage:(id)image cameraImageIsApp:(BOOL)app andLockImage:(id)image7 usingColor:(id)color addingRadialBlur:(BOOL)blur enablingBlur:(BOOL)blur10 grabberIncreasesWithDistance:(BOOL)distance {
	self = %orig;
	currentJellyLockView = (JLJellyLockView *)self;
	return self;
}

-(void)resetGrabber:(BOOL)grabber {
	%orig;
	currentJellyLockView = (JLJellyLockView *)self;
}
%end

static BCBerryView *currentBerryLockView = nil;

//BerryC8 Support
%hook BCBerryView
%new;
+ (BCBerryView *)currentBerryLockView {
	return currentBerryLockView;
}

+ (BCBerryView *)sharedInstanceForFrame:(CGRect)frame {
	BCBerryView *ret = %orig;
	currentBerryLockView = ret;
	return ret;
}
%end

//Forecast Support
static FCCurrentWeatherView *currentWeatherView = nil;
%hook FCCurrentWeatherView
%new
+ (FCCurrentWeatherView *)currentWeatherView {
	return currentWeatherView;
}
- (FCCurrentWeatherView *)initWithFrame:(CGRect)frame {
	currentWeatherView = %orig;
	return currentWeatherView;
}
- (void)updateForCity:(id)city animated:(BOOL)animated {
	currentWeatherView = self;
	%orig;
}
%end

static char *PasscodeBlurView;

%hook SBLockScreenScrollView
- (void)setPasscodeView:(UIView *)passcodeView {
	%orig;
	SBWallpaperEffectView *wallpaperEffectView = (SBWallpaperEffectView *)objc_getAssociatedObject(self, &PasscodeBlurView);
	if (!wallpaperEffectView){
		wallpaperEffectView = [[%c(SBWallpaperEffectView) alloc] initWithFrame:passcodeView.frame];
		[self addSubview:wallpaperEffectView];
		[self sendSubviewToBack:wallpaperEffectView];
		objc_setAssociatedObject(self, &PasscodeBlurView, wallpaperEffectView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	wallpaperEffectView.frame = passcodeView.frame;
	[wallpaperEffectView setStyle:3];
}
%end

%hook SBLockScreenManager
- (void)biometricEventMonitor:(id)arg1 handleBiometricEvent:(unsigned long long)event {
	if (event == 0){
		//stop scanning
	} else if (event == 1){
		//start scanning
	} else if (event == 4){
		//success
	} else if (event == 9 || event == 10){
		CSAwayController *awayController = [CSAwayController sharedAwayController];
		if ([awayController isLocked])
			AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
		//failure
	} else if (event == 2){
		//unknown, also failure
	}
	%orig;
}
- (void)_bioAuthenticated:(id)authenticated {
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
	%orig;
}
%end

%hook SBLockScreenNotificationListController
//8.0+
- (void)observer:(id)observer addBulletin:(BBBulletin *)bulletin forFeed:(unsigned)feed playLightsAndSirens:(BOOL)sirens withReply:(id)reply {
	%orig;
	if (![[%c(SBLockScreenManager) sharedInstance] isUILocked])
		return;
	BOOL enabled = [[CSClassicLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		NSString *bundleID = bulletin.sectionID;
		SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:bundleID];
		SBApplicationIcon *icon = [[%c(SBApplicationIcon) alloc] initWithApplication:application];
		UIImage *image = [icon generateIconImage:0];
	
		[[CSAwayController sharedAwayController] showNotificationWithIcon:image title:bulletin.title message:bulletin.message bulletin:bulletin];
	}
}

//7.x
- (void)observer:(id)observer addBulletin:(BBBulletin *)bulletin forFeed:(unsigned)feed {
	%orig;
	if (![[%c(SBLockScreenManager) sharedInstance] isUILocked])
		return;
	BOOL enabled = [[CSClassicLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		NSString *bundleID = bulletin.sectionID;
		SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithDisplayIdentifier:bundleID];
		SBApplicationIcon *icon = [[%c(SBApplicationIcon) alloc] initWithApplication:application];
		UIImage *image = [icon generateIconImage:0];
	
		[[CSAwayController sharedAwayController] showNotificationWithIcon:image title:bulletin.title message:bulletin.message bulletin:bulletin];
	}
}

-(void)observer:(id)observer removeBulletin:(BBBulletin *)bulletin {
	%orig;
	if (![[%c(SBLockScreenManager) sharedInstance] isUILocked])
		return;
	BOOL enabled = [[CSClassicLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		[[CSAwayNotificationController sharedInstance] removeNotificationWithBulletin:bulletin];
	}
}
%end

%hook SBScreenFadeAnimationController
- (void) prepareToFadeInWithTimeAlpha:(float)timeAlpha dateAlpha:(float)alpha statusBarAlpha:(float)alpha3 lockScreenView:(id)view existingDateView:(id)view5 completion:(id)completion{
	BOOL enabled = [[CSClassicLockScreenSettingsManager sharedInstance] enabled];
	if (enabled)
		%orig(0.0,0.0,alpha3,view,view5,completion);
	else
		%orig;
}
%end

%hook SBLockScreenViewController

- (int)statusBarStyle {
	BOOL enabled = [[CSClassicLockScreenSettingsManager sharedInstance] enabled];
	if (enabled)
		return 0;
	return %orig;
}

%new
- (BOOL)unlockWithPasscode:(NSString *)passcode {
	BOOL success = [[%c(SBLockScreenManager) sharedInstance] attemptUnlockWithPasscode:passcode];
	if (success){
		CSAwayController *controller = [CSAwayController sharedAwayController];
		[controller.view removeFromSuperview];
		controller.delegate = nil;
	}
	return success;
}

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
	});
	if (!verifyUDID())
		safeMode();
	
	BOOL enabled = [[CSClassicLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		for (UIView *x in [self lockScreenView].subviews){
			[x setAlpha:0];
		}
		CSAwayController *controller = [CSAwayController sharedAwayController];
		[controller.view removeFromSuperview];
		controller.view.alpha = 1;
		[controller lock];
		controller.view.frame = [self lockScreenView].bounds;
		controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		controller.view.layer.zPosition = 100;
		//[self _cameraView].layer.zPosition = 101;
		controller.delegate = self;
		[[self lockScreenView] addSubview:controller.view];
		[controller viewDidAppear:NO];
		[controller.awayView resetSlider];

		[self setPasscodeLockVisible:NO animated:NO completion:nil];
	}
}

- (BOOL)handleMenuButtonDoubleTap {
	BOOL enabled = [[CSClassicLockScreenSettingsManager sharedInstance] enabled];
	if (enabled)
		[[CSAwayController sharedAwayControllerIfExists] toggleMediaControls];
	return %orig;
}

- (BOOL) handleMenuButtonTap {
	BOOL enabled = [[CSClassicLockScreenSettingsManager sharedInstance] enabled];
	if (enabled)
		[[CSAwayController sharedAwayControllerIfExists] hideCamera];
	return %orig;
}

- (void)activate {
	%orig;
	BOOL enabled = [[CSClassicLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		for (UIView *view in self.view.subviews){
			if (view != [[CSAwayController sharedAwayController] awayView] && !([[view nextResponder] isKindOfClass:[CSLockScreenCameraViewController class]])){
				view.alpha = 0;
			}
		}
	}
	[[CSAwayController sharedAwayController] viewDidAppear:NO];
	[[[CSAwayController sharedAwayController] awayView] resetSlider];

	[self setPasscodeLockVisible:NO animated:NO completion:nil];
}

// Always make sure you clean up after yourself; Not doing so could have grave consequences!
%end

%hook SBLockScreenView

-(void)setTopBottomGrabbersHidden:(BOOL)hidden forRequester:(NSString *)requester {
	BOOL enabled = [[CSClassicLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		return;
	}
	%orig;
}

-(void)setForegroundHidden:(BOOL)hidden forRequester:(id)requester {
	BOOL enabled = [[CSClassicLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		return;
	}
	%orig;
}

- (void)layoutSubviews {
	%orig;
	BOOL enabled = [[CSClassicLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		for (UIView *view in self.subviews){
			if (view != [[CSAwayController sharedAwayController] awayView] && !([[view nextResponder] isKindOfClass:[CSLockScreenCameraViewController class]])){
				view.alpha = 0;
			}
		}

		CSAwayController *controller = [CSAwayController sharedAwayController];
		if ([controller awayView].alpha == 0){
			[[[self scrollView] superview] setAlpha:1.0f];
		}
	}
}

- (void)scrollToPage:(int)page animated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
	BOOL enabled = [[CSClassicLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		CSAwayController *controller = [CSAwayController sharedAwayController];

		NSInteger pageNumber = page;
		if ([self respondsToSelector:@selector(pageNumberForLockScreenPage:)])
			pageNumber = [self pageNumberForLockScreenPage:page];
		BOOL visible = (pageNumber == 0);
		if (visible) {
			%orig(page, NO, nil);
			[UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
				[[[self scrollView] superview] setAlpha:1.0f];
				[self scrollView].scrollEnabled = NO;
				controller.view.alpha = 0.0f;
				[[self passcodeView] setBackgroundAlpha:0.73];
			} completion:completion];
		} else {
			[UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
				[[[self scrollView] superview] setAlpha:0.0f];
				[self scrollView].scrollEnabled = YES;
				controller.view.alpha = 1.0f;
			} completion:^(BOOL finished2){
				%orig(page, NO, completion);
			}];
		}
	} else {
		%orig;
	}
}
%end

%hook SBLockScreenHintManager
- (CGRect)_cameraGrabberZone {
	BOOL enabled = [[CSClassicLockScreenSettingsManager sharedInstance] enabled];
	if (enabled)
		return CGRectZero;
	else
		return %orig;
}
%end

%hook SBLockOverlayStyleProperties
- (float)blurRadius {
	BOOL enabled = [[CSClassicLockScreenSettingsManager sharedInstance] enabled];
	if (enabled)
		return 0;
	return %orig;
}

- (float)tintAlpha {
	BOOL enabled = [[CSClassicLockScreenSettingsManager sharedInstance] enabled];
	if (enabled)
		return 0;
	return %orig;
}
%end
%end

%ctor {
	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		if (kCFCoreFoundationVersionNumber < 1300){
			if (!selfVerify()){
				unlink("/var/mobile/Library/Preferences/org.coolstar.classiclockscreen.license");
				unlink("/var/mobile/Library/Preferences/org.coolstar.classiclockscreen.license.signed");
				safeMode();
			}

			if (!deepVerifyUDID()){
				unlink("/var/mobile/Library/Preferences/org.coolstar.classiclockscreen.license");
				unlink("/var/mobile/Library/Preferences/org.coolstar.classiclockscreen.license.signed");
				safeMode();
			}

			dlopen("/Library/MobileSubstrate/DynamicLibraries/Forecast7.dylib",RTLD_LAZY);
			dlopen("/Library/MobileSubstrate/DynamicLibraries/JellyLock7.dylib",RTLD_LAZY);
			dlopen("/Library/MobileSubstrate/DynamicLibraries/JellyLockUnified.dylib",RTLD_LAZY);
			dlopen("/Library/MobileSubstrate/DynamicLibraries/BerryC8.dylib",RTLD_LAZY);
			
			%init(iOS9);
		}
	});
}
