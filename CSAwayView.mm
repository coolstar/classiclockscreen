//
//  CSAwayView.m
//  ClassicLockScreen
//
//  Created by coolstar on 1/11/14.
//  Copyright (c) 2014 CoolStar. All rights reserved.
//

#import "CSAwayView.h"
#import "CSAwayController.h"
#import "SBAwayChargingView.h"
#import "SBAwayMediaControlsView.h"
#import "CSAwayNotificationController.h"
#import "CSClassicLockScreenSettingsManager.h"
#import "UIImage+ImageEffects.h"
#import "CSBackdropView.h"
#import "UIImage+AverageColorAddition.h"
#import <objc/runtime.h>
#import "Headers.h"
#import "MediaRemote.h"
#define kSettingsPath @"Library/Preferences/org.coolstar.classiclockscreen.plist"

extern "C" {

BOOL CSCLScheckModern(){
    return [[CSClassicLockScreenSettingsManager sharedInstance] modern];
}

BOOL CSCLScheckAltSlider(){
    return [[CSClassicLockScreenSettingsManager sharedInstance] altslider];
}

BOOL CSCLScheckDarkMode(){
    return [[CSClassicLockScreenSettingsManager sharedInstance] darkmode];
}

static BOOL checkShouldShowAlbumArtwork(){
    return [[CSClassicLockScreenSettingsManager sharedInstance] albumArtwork];
}

BOOL CLSShouldPlayLockSounds(){
    return YES;
}

UIImage *getWallpaper(){
/*#ifdef TARGET_IPHONE_SIMULATOR
    return [UIImage imageNamed:@"Frozen-Wallpaper.jpg"];
    //return [UIImage imageNamed:@"Vector-Wallpaper-1"];
#else*/
    SBWallpaperController* wpc = [objc_getClass("SBWallpaperController") sharedInstance];
    if (!wpc)
    	return nil;
	//SPCurrentLockscreenWallpaper = MSHookIvar<SBFStaticWallpaperView*>(wpc, "_lockscreenWallpaperView");
    SBFWallpaperView *currentLockScreenWallpaper = [wpc valueForKey:@"_lockscreenWallpaperView"];
    if (!currentLockScreenWallpaper)
    	return nil;
	UIImageView* content = [currentLockScreenWallpaper contentView];
	if (!content)
    	return nil;
	CGSize contentSize = content.bounds.size;
	if (contentSize.width == 0 || contentSize.height == 0){
		contentSize = CGSizeMake(1,1);
		return nil;
	}

	if (![content superview])
		return nil;

    UIGraphicsBeginImageContextWithOptions(contentSize, YES, 0.3);
    [content drawViewHierarchyInRect:content.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;


    //return [content image];
//#endif
    //UIImageView *bgView = [[[CSAwayController sharedAwayController] awayView] valueForKey:@"_backgroundView"];
    //return [bgView image];
}

BOOL shouldDarkenCL() {
	UIColor* averageColor = [getWallpaper() averageColor];
	if ([averageColor isColorLight])
        return YES;
	else return NO;
}

_UIBackdropViewSettings *getBackdropSettings(){
    _UIBackdropViewSettings *settings;
    if (!CSCLScheckDarkMode()){
        settings = [_UIBackdropViewSettings settingsForStyle:1000];
        [settings setGrayscaleTintAlpha:0];
        if ([settings respondsToSelector:@selector(setDarkeningTintAlpha:)])
        	[settings setDarkeningTintAlpha:0];
        [settings setColorTintAlpha:0];
    } else {
        settings = [_UIBackdropViewSettings settingsForStyle:2050];
        [settings setGrayscaleTintAlpha:0.5];
    }

    [settings setBlurRadius:25];
    if ([settings respondsToSelector:@selector(setColorBurnTintAlpha:)])
    	[settings setColorBurnTintAlpha:0];
    [settings setBlurQuality:@"low"];
    return settings;
}

}

@implementation CSAwayView

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
        self.autoresizesSubviews = YES;

        _backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
		_backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:_backgroundView];

		_chargingView = [[SBAwayChargingView alloc] initWithFrame:self.bounds];
		_chargingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_chargingView.contentMode = UIViewContentModeScaleAspectFit;
		[self addSubview:_chargingView];

#if TARGET_IPHONE_SIMULATOR
		UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleMediaControls)];
		_chargingView.userInteractionEnabled = YES;
		gestureRecognizer.cancelsTouchesInView = NO;
		[gestureRecognizer setNumberOfTapsRequired:1];
		[gestureRecognizer setDelegate:self];
		[_chargingView addGestureRecognizer:gestureRecognizer];
#endif

		_artworkView = [[UIImageView alloc] initWithFrame:self.bounds];
		_artworkView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_artworkView.contentMode = UIViewContentModeScaleAspectFit;
		_artworkView.alpha = 0;
		[self addSubview:_artworkView];

		_statusBarBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 20)];
		_statusBarBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[self addSubview:_statusBarBackgroundView];

#pragma mark time
		_topBackdropView = [[CSBackdropView alloc] initWithFrame:CGRectZero
	                                                       autosizesToFitSuperview:NO settings:getBackdropSettings()];
		_topBackdropView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[self addSubview:_topBackdropView];

		_topBackdropOverlayView = [[UIImageView alloc] initWithFrame:CGRectZero];
		_topBackdropOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[_topBackdropOverlayView setImage:[UIImage imageNamed:@"CSModernLockScreenTopOverlay"]];
		[self addSubview:_topBackdropOverlayView];

		_timeView = [[UIImageView alloc] initWithFrame:CGRectZero];
		_timeView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[self addSubview:_timeView];

		_timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_timeLabel.backgroundColor = [UIColor clearColor];
		_timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.75];
		_timeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		[_timeView addSubview:_timeLabel];

		_dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_dateLabel.backgroundColor = [UIColor clearColor];
		_dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.75];
		_dateLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		[_timeView addSubview:_dateLabel];

#pragma mark media controls
		_mediaControlsView = [[SBAwayMediaControlsView alloc] initWithFrame:CGRectZero];
	
		_mediaControlsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_mediaControlsView.alpha = 0;
		_mediaControlsView.artworkView = _artworkView;
		[self addSubview:_mediaControlsView];

#pragma mark notifications
		_notificationViews = [[UITableView alloc] initWithFrame:CGRectZero];
		_notificationViews.backgroundColor = [UIColor clearColor];
		_notificationViews.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
		_notificationViews.indicatorStyle = UIScrollViewIndicatorStyleWhite;
		_notificationViews.dataSource = [CSAwayNotificationController sharedInstance];
		_notificationViews.delegate = [CSAwayNotificationController sharedInstance];
		[[CSAwayNotificationController sharedInstance] setTableView:_notificationViews];
		[[CSAwayNotificationController sharedInstance] clearNotifications];
		[self addSubview:_notificationViews];

		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
			UIView *background = [[UIImageView alloc] initWithFrame:_notificationViews.bounds];
			background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			background.userInteractionEnabled = YES;
			if (!CSCLScheckModern()){
				UIImageView *backgroundImg = [[UIImageView alloc] initWithFrame:background.bounds];
				backgroundImg.image = [[UIImage imageNamed:@"BulletinListLockScreenBG"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 15, 20, 15)];
				backgroundImg.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
				[background addSubview:backgroundImg];
			} else {
				_UIBackdropViewSettings *backdropSettings = getBackdropSettings();
				CSBackdropView *notificationBackdrop = [[CSBackdropView alloc] initWithFrame:background.bounds autosizesToFitSuperview:YES settings:backdropSettings];
				notificationBackdrop.layer.cornerRadius = 15;
				notificationBackdrop.clipsToBounds = YES;
				[background addSubview:notificationBackdrop];
	            
				CSGradientView *backdropOverlayView = [[CSGradientView alloc] initWithFrame:background.bounds];
				backdropOverlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
				backdropOverlayView.layer.locations = @[@0,@1];
				if (!CSCLScheckDarkMode())
					backdropOverlayView.layer.colors = @[(id)[[UIColor colorWithWhite:1.0 alpha:0.4] CGColor],(id)[[UIColor colorWithWhite:1.0 alpha:0.2] CGColor]];
				else
					backdropOverlayView.layer.colors = @[(id)[[UIColor colorWithWhite:1.0 alpha:0.1] CGColor],(id)[[UIColor colorWithWhite:1.0 alpha:0] CGColor]];
				backdropOverlayView.layer.startPoint = CGPointMake(0.5, 0);
				backdropOverlayView.layer.endPoint = CGPointMake(0.5, 1);
				backdropOverlayView.layer.cornerRadius = 15.0f;
				[background addSubview:backdropOverlayView];
			}
			[_notificationViews addSubview:background];
			[_notificationViews sendSubviewToBack:background];
		} else {
			_UIBackdropViewSettings *backdropSettings = getBackdropSettings();
			_notificationsBackdropView = [[CSBackdropView alloc] initWithFrame:CGRectZero autosizesToFitSuperview:NO settings:backdropSettings];
			_notificationsBackdropView.autoresizingMask = _notificationViews.autoresizingMask;
			_notificationsBackdropView.alpha = 0;
			[[CSAwayNotificationController sharedInstance] setNotificationsBackdropView:_notificationsBackdropView];
			[self addSubview:_notificationsBackdropView];
			[self bringSubviewToFront:_notificationViews];
		}

		_notificationViews.alpha = 0;

#pragma mark lock bar
		_lockBar = [[CSAwayLockBar alloc] initWithFrame:CGRectZero];
		_lockBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
		_lockBar.delegate = self;
		[self addSubview:_lockBar];
	}
   	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];

	CSClassicLockScreenSettingsManager *settingsManager = [CSClassicLockScreenSettingsManager sharedInstance];

	BOOL isModern = [settingsManager modern];

	if (isModern)
		[_artworkView setBackgroundColor:[UIColor clearColor]];
	else
		[_artworkView setBackgroundColor:[UIColor blackColor]];
	
	if ([settingsManager hidebgforartwork])
		[_artworkView setBackgroundColor:[UIColor blackColor]];
	else
		[_artworkView setBackgroundColor:[UIColor clearColor]];

	if (isModern) {
		[_statusBarBackgroundView setBackgroundColor:[UIColor clearColor]];
	}
	else {
		if ([UIImage imageNamed:@"SBLockScreenStatusBackground"] != nil)
			[_statusBarBackgroundView setImage:[UIImage imageNamed:@"SBLockScreenStatusBackground"]];
		else
			[_statusBarBackgroundView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
	}

	if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) {
		_timeView.frame = CGRectMake(0, isModern ? 0 : 20,self.bounds.size.width, isModern ? 115 : 95);
		_timeLabel.frame = CGRectMake(0, isModern ? 25 : 5, self.bounds.size.width, 60);
		_dateLabel.frame = CGRectMake(0, isModern ? 80 : 60, self.bounds.size.width, 30);

		_mediaControlsView.frame = CGRectMake(0,20,self.bounds.size.width,133);
	}
	else {
		_timeView.frame = CGRectMake(0, isModern ? 0 : 20,self.bounds.size.width, isModern ? 128 : 108);
		_timeLabel.frame = CGRectMake(0, isModern ? 25 : 15, self.bounds.size.width, 60);
		_dateLabel.frame = CGRectMake(0, isModern ? 95 : 75, self.bounds.size.width, 30);

		_mediaControlsView.frame = CGRectMake(0,20,self.bounds.size.width,96);
	}

	if (isModern){
		_timeView.image = nil;
		_mediaControlsView.image = nil;

		_topBackdropView.frame = [self isShowingMediaControls] ? _mediaControlsView.frame : _timeView.frame;
		if (_topBackdropView.frame.origin.y != 0){
			CGRect frame = _topBackdropView.frame;
			frame.size.height += _topBackdropView.frame.origin.y;
			frame.origin.y = 0;
			_topBackdropView.frame = frame;
		}
		_topBackdropView.alpha = 1;

		_topBackdropOverlayView.frame = _topBackdropView.frame;
		_topBackdropOverlayView.alpha = 1;

		_timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:65];
		_dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
	} else {
		NSString *barLCDImage = @"/System/Library/PrivateFrameworks/TelephonyUI.framework/BarLCD~iphone.png";
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
			barLCDImage = @"/System/Library/PrivateFrameworks/TelephonyUI.framework/BarLCD~ipad.png";
		}
		_timeView.image = [UIImage imageWithContentsOfFile:barLCDImage];
		_topBackdropView.alpha = 0;
		_topBackdropOverlayView.alpha = 0;

		_mediaControlsView.image = [UIImage imageNamed:@"SBLockScreenControlsLCD"];;
		if (!_mediaControlsView.image)
			_mediaControlsView.image = _timeView.image;

		_timeLabel.font = [UIFont fontWithName:@"Helvetica Light" size:58];
		_dateLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
	}

	CGFloat notificationy = 115;
	CGFloat notificationheight = self.bounds.size.height - (115+95);
	CGFloat notificationwidth = 320;
	if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad)
		notificationwidth = self.frame.size.width;
	_notificationViews.frame = CGRectMake((self.frame.size.width - notificationwidth)/2.0, notificationy, notificationwidth, notificationheight);
	_notificationsBackdropView.frame = _notificationViews.frame;

	if (!CSCLScheckModern()){
		_notificationsBackdropView.alpha = 0;
	} else {
		_notificationsBackdropView.alpha = _notificationViews.alpha;
	}

	[[CSAwayNotificationController sharedInstance] adjustPosition];

	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
		_notificationViews.center = self.center;

	_lockBar.frame = CGRectMake(0, self.bounds.size.height-95, self.bounds.size.width, 95);
}

#if TARGET_IPHONE_SIMULATOR
- (BOOL)toggleMediaControls {
	if ([self isShowingMediaControls])
		[self hideMediaControls];
	else
		[self showMediaControls];
	return [self isShowingMediaControls];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return YES;
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
	return YES;
}
#endif

- (void)showNotificationWithIcon:(UIImage *)icon title:(NSString *)appTitle message:(NSString *)message bulletin:(BBBulletin *)bulletin {
	if (message.length > 236){
		message = [message substringWithRange:NSMakeRange(0, 236)];
		message = [message stringByAppendingString:@"..."];
	}
	if ([bulletin suppressesMessageForPrivacy]){
		message = @"Notification preview hidden.";
	}
	[_firstNotificationView stopBlinking];
	[_firstNotificationView removeFromSuperview];
	_firstNotificationView = nil;
	
	[_lockBar setSliderText:[[NSBundle mainBundle] localizedStringForKey:@"REMOTE_NOTIFICATIONS_LOCK_LABEL" value:@"slide to view" table:@"SpringBoard"]];
	
	[[CSAwayNotificationController sharedInstance] addNotificationWithIcon:icon title:appTitle message:message bulletin:bulletin];
	
	if ([[CSAwayNotificationController sharedInstance] notificationCount] < 2){
		_notificationViews.alpha = 0;
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
			_notificationViews.superview.alpha = 0;
		_firstNotificationView = [[SBAwayFirstAlertView alloc] initWithAppIcon:icon appTitle:appTitle notificationText:message bulletin:bulletin];
		_firstNotificationView.userInteractionEnabled = YES;
		[self addSubview:_firstNotificationView];
		[_firstNotificationView updatePosition];
		[_firstNotificationView startBlinking];
	} else {
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
			_notificationViews.superview.alpha = 1;
		_notificationViews.alpha = 1;
	}
	_notificationsBackdropView.alpha = _notificationViews.alpha;
	[[CSAwayController sharedAwayController] setBulletinToOpenAfterUnlock:bulletin];
	
	NSInteger count = [[CSAwayNotificationController sharedInstance] notificationCount];
	
	double delayInSeconds = 4.0;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		if (count == [[CSAwayNotificationController sharedInstance] notificationCount]){
			[_lockBar setSliderText:[[NSBundle mainBundle] localizedStringForKey:@"AWAY_LOCK_LABEL" value:@"slide to unlock" table:@"SpringBoard"]];
			[[CSAwayNotificationController sharedInstance] stopFirstCellBlinking];
			[_firstNotificationView stopBlinking];
			[[CSAwayController sharedAwayController] setBulletinToOpenAfterUnlock:nil];
		}
	});
}

- (void)updateDesktopImage:(UIImage *)image {
	_backgroundView.image = image;
}

- (void)updateTime {
	[_mediaControlsView update];

	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	BOOL secondsEnabled = [[CSClassicLockScreenSettingsManager sharedInstance] secondsEnabled];
	
	if (!secondsEnabled)
		[formatter setDateFormat:@"h:mm"];
	else
		[formatter setDateFormat:@"h:mm:ss"];
	_timeLabel.text = [formatter stringFromDate:[NSDate date]];
    if (CSCLScheckModern()){
        NSString *time = [formatter stringFromDate:[NSDate date]];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:time];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineHeightMultiple = 30.f;
        paragraphStyle.lineSpacing = 0.f;
        paragraphStyle.minimumLineHeight = 30.f;
        paragraphStyle.maximumLineHeight = 30.f;
        
        [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:65]} range:NSMakeRange(0, time.length)];
        [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle,NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-UltraLight" size:65]} range:[time rangeOfString:@":"]];
        if (secondsEnabled)
        	[attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle,NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-UltraLight" size:65]} range:[time rangeOfString:@":" options:NSBackwardsSearch]];
        [_timeLabel setAttributedText:attributedString];
    }
	
	[formatter setDateFormat:@"EEEE, MMMM d"];
	_dateLabel.text = [formatter stringFromDate:[NSDate date]];
}

- (void)resetLock {
	[[CSAwayNotificationController sharedInstance] clearNotifications];
	[_firstNotificationView removeFromSuperview];
	_firstNotificationView = nil;

	[_lockBar setSliderText:[[NSBundle mainBundle] localizedStringForKey:@"AWAY_LOCK_LABEL" value:@"slide to unlock" table:@"SpringBoard"]];
	
	if (!CSCLScheckModern()){
        if ([UIImage imageNamed:@"SBLockScreenStatusBackground"] != nil)
            [_statusBarBackgroundView setImage:[UIImage imageNamed:@"SBLockScreenStatusBackground"]];
        else
            [_statusBarBackgroundView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
    } else {
        [_statusBarBackgroundView setBackgroundColor:[UIColor clearColor]];
    }

	[_lockBar resetSlider];
	if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad)
		_timeView.alpha = 1;
	[self hideMediaControls];
	
	CGRect frame = _lockBar.frame;
	frame.origin.x = 0;
	frame.origin.y = self.bounds.size.height - frame.size.height;
	frame.size.width = self.bounds.size.width;
	
	CGRect frame2 = _timeView.frame;
	frame2.origin.y += (frame2.size.height + 30);
	frame2.size.width = self.bounds.size.width;
	
	CGRect frame3 = _mediaControlsView.frame;
	frame3.origin.y += (frame3.size.height + 30);
	frame3.size.width = self.bounds.size.width;
	
	CGRect frame4 = _lockBar.frame;
	frame4.origin.y = frame.origin.y;
	frame4.origin.x = -frame4.size.width;
	frame4.size.width = self.bounds.size.width;

	_lockBar.frame = frame;
	_timeView.frame = frame2;
	_mediaControlsView.frame = frame3;
    
    [self updateTopBlur];
}

/*- (void)showModernPasscodeUI {
	_passcodeFieldIsOpen = YES;
	[_modernPasscodeView removeFromSuperview];
	_modernPasscodeView = nil;
	_modernPasscodeViewPasscodeView = nil;
	_modernPasscodeView = [[UIView alloc] initWithFrame:self.bounds];
	_modernPasscodeView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[_modernPasscodeView setBackgroundColor:[UIColor clearColor]];
	_modernPasscodeView.layer.zPosition = 9001; //IT'S OVER 9000!

	UIImage *image = nil;
	UIImage *blurredImage = nil;
	
	SBWallpaperController *wallpaperController = (SBWallpaperController *)[objc_getClass("SBWallpaperController") sharedInstance];
	UIView *wallpaperView = [wallpaperController valueForKey:@"_wallpaperContainerView"];
	CGSize imageSize = CGSizeMake(wallpaperView.bounds.size.width,wallpaperView.bounds.size.height);
	UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0.3);
	[wallpaperView drawViewHierarchyInRect:CGRectMake(0,0,imageSize.width,imageSize.height) afterScreenUpdates:NO];
	image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	if (image == nil || ![image isKindOfClass:[UIImage class]]) {
		blurredImage = nil;
	}
	else {
		UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
		blurredImage = [image applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
	}
	
	UIImageView *blurredImageView = [[UIImageView alloc] initWithFrame:_modernPasscodeView.bounds];
	blurredImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[blurredImageView setImage:blurredImage];
	[_modernPasscodeView addSubview:blurredImageView];
	
	SBLockScreenManager *manager = [objc_getClass("SBLockScreenManager") sharedInstance];
	BOOL isAndroidLockEnabled = NO;
	if ([manager respondsToSelector:@selector(androidlockIsLocked)])
		isAndroidLockEnabled = [manager androidlockIsLocked];
	if (isAndroidLockEnabled){
		NSDictionary *ALSettings = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.zmaster.AndroidLock.plist"];
		_modernPasscodeViewPasscodeView = [[objc_getClass("PasscodeLockViewAndroidLock") alloc] initWithSettings:ALSettings];
	} else
		_modernPasscodeViewPasscodeView = [objc_getClass("SBUIPasscodeLockViewFactory") passcodeLockViewForUsersCurrentStyle];
	[_modernPasscodeViewPasscodeView setBackgroundAlpha:0.5];
	[_modernPasscodeViewPasscodeView setDelegate:self];
	[_modernPasscodeViewPasscodeView setShowsEmergencyCallButton:NO];
	_modernPasscodeViewPasscodeView.frame = self.bounds;
	_modernPasscodeViewPasscodeView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[_modernPasscodeView addSubview:_modernPasscodeViewPasscodeView];
	
	[self addSubview:_modernPasscodeView];
	_modernPasscodeView.alpha = 0.5;
	_modernPasscodeView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5);
	[UIView animateWithDuration:0.25 animations:^{
		_modernPasscodeView.alpha = 1.0;
		_modernPasscodeView.transform = CGAffineTransformIdentity;
	}];
}*/

- (void)showPasscodeUI {
	[self hideMediaControls];
	[_controller setPasscodeLockVisible:YES animated:YES completion:^(BOOL completed){
		[self resetSlider];
	}];
}

- (void)hideModernPasscodeUI {
	[_controller setPasscodeLockVisible:NO animated:YES completion:nil];
}

- (void)resetSlider {
	if ([self passcodeFieldIsOpen]){
		[self hidePasscodeUI];
	}
	CGRect frame4 = _lockBar.frame;
	frame4.origin.y = _lockBar.frame.origin.y;
	frame4.origin.x = -frame4.size.width;
	frame4.size.width = self.bounds.size.width;

	[_forecastView removeFromSuperview];
	_forecastView = nil;
	_forecastView = [objc_getClass("FCCurrentWeatherView") currentWeatherView];
	if (_forecastView != nil){
		[_forecastView removeFromSuperview];
		[self addSubview:_forecastView];
		CGRect frame = _forecastView.frame;
		if (frame.origin.x > self.bounds.size.width){
			frame.origin.x -= self.bounds.size.width;
		}
		if (frame.origin.y + frame.size.height > _lockBar.frame.origin.y){
			frame.origin.y = _lockBar.frame.origin.y - frame.size.height;
		}
		_forecastView.frame = frame;
		[self bringSubviewToFront:_notificationsBackdropView];
		[self bringSubviewToFront:_notificationViews];
		[self bringSubviewToFront:_firstNotificationView];
	}

	[_jellyLockView removeFromSuperview];
	_jellyLockView = nil;
	_jellyLockView = [objc_getClass("JLJellyLockView") currentJellyLockView];
	if (!_jellyLockView)
		_jellyLockView = (JLJellyLockView *)[objc_getClass("JLUJellyLockView") currentJellyLockView];
	if (_jellyLockView){
		[_jellyLockView removeFromSuperview];
		[self addSubview:_jellyLockView];

		CGRect frame = _jellyLockView.frame;
		if (frame.origin.x >= self.bounds.size.width){
			frame.origin.x -= self.bounds.size.width;
		}
		_jellyLockView.frame = frame;

		[self bringSubviewToFront:_jellyLockView];
		_lockBar.alpha = 0;
	} else {
		_lockBar.alpha = 1;
	}

	[_berryLockView removeFromSuperview];
	_berryLockView = nil;
	_berryLockView = [objc_getClass("BCBerryView") currentBerryLockView];
	if (_berryLockView){
		[_berryLockView removeFromSuperview];
		[self addSubview:_berryLockView];

		CGRect frame = _berryLockView.frame;
		if (frame.origin.x >= self.bounds.size.width){
			frame.origin.x -= self.bounds.size.width;
		}
		if (frame.origin.y + frame.size.height > _lockBar.frame.origin.y){
			frame.origin.y = _lockBar.frame.origin.y - frame.size.height;
		}
		_berryLockView.frame = frame;

		[self bringSubviewToFront:_berryLockView];
		[self bringSubviewToFront:_lockBar];
	}

	[_lockGlyphView removeFromSuperview];
	_lockGlyphView = nil;
	if ([objc_getClass("SBLockScreenViewController") respondsToSelector:@selector(getLockGlyphView)])
		_lockGlyphView = [objc_getClass("SBLockScreenViewController") getLockGlyphView];
	if (_lockGlyphView){
		[_lockGlyphView removeFromSuperview];
		[self addSubview:_lockGlyphView];

		CGRect frame = _lockGlyphView.frame;
		if (frame.origin.x >= self.bounds.size.width){
			frame.origin.x -= self.bounds.size.width;
		}
		if (frame.origin.y + frame.size.height + 3 > _lockBar.frame.origin.y){
			frame.origin.y = _lockBar.frame.origin.y - (frame.size.height + 3);
		}
		_lockGlyphView.frame = frame;

		[self bringSubviewToFront:_lockGlyphView];
	}

	_UIBackdropViewSettings *backdropSettings = getBackdropSettings();
	[_topBackdropView transitionToSettings:backdropSettings];
	[_notificationsBackdropView transitionToSettings:backdropSettings];

	[_lockBar resetSlider];
}

- (void)hidePasscodeUI {
	_passcodeFieldIsOpen = NO;
	[self hideMediaControls];
	
	if (!CSCLScheckModern()){
        if ([UIImage imageNamed:@"SBLockScreenStatusBackground"] != nil)
            [_statusBarBackgroundView setImage:[UIImage imageNamed:@"SBLockScreenStatusBackground"]];
        else
            [_statusBarBackgroundView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
    } else {
        [_statusBarBackgroundView setBackgroundColor:[UIColor clearColor]];
    }

    [self hideModernPasscodeUI];
}

- (void)lockBarUnlocked:(CSAwayLockBar *)lockBar {
	[_controller unlock];
}

- (BOOL) isShowingMediaControls {
	return _mediaControlsView.alpha == 1;
}

- (void)showChargingView {
	[_chargingView addChargingView];
}

- (void)hideChargingView {
	[_chargingView hideChargingView];
}

- (void)_hideMediaControls {
	[self hideMediaControls];
}

- (void)updateTopBlur {
    if (!CSCLScheckModern())
        return;
    if (_mediaControlsView.alpha != 0){
        _topBackdropView.frame = CGRectMake(0, 0, _mediaControlsView.frame.size.width, _mediaControlsView.frame.size.height+_mediaControlsView.frame.origin.y);
    } else {
        _topBackdropView.frame = _timeView.frame;
    }
    _topBackdropOverlayView.frame = _topBackdropView.frame;
}

- (void)hideMediaControls {
	_timeView.alpha = 1;
	_mediaControlsView.alpha = 0;
	if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad){
		CGFloat notificationy = 20+_timeView.frame.size.height;
		if (CSCLScheckModern())
			notificationy = _timeView.frame.size.height;
		CGFloat notificationheight = self.bounds.size.height - (notificationy+_lockBar.frame.size.height);
		CGFloat notificationwidth = 320;
		if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad)
			notificationwidth = self.frame.size.width;
		_notificationViews.frame = CGRectMake(0, notificationy, notificationwidth, notificationheight);
		_notificationsBackdropView.frame = _notificationViews.frame;
		[[CSAwayNotificationController sharedInstance] adjustPosition];
	}
    if (CSCLScheckModern()){
        _topBackdropView.frame = _timeView.frame;
        _topBackdropOverlayView.frame = _topBackdropView.frame;
    }
}

- (void)showMediaControls {
	_timeView.alpha = 0;
	_mediaControlsView.alpha = 1;
	if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad){
		CGFloat notificationy = 20+_mediaControlsView.frame.size.height;
		CGFloat notificationheight = self.bounds.size.height - (notificationy+_lockBar.frame.size.height);
		CGFloat notificationwidth = 320;
		if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad)
			notificationwidth = self.frame.size.width;
		_notificationViews.frame = CGRectMake(0, notificationy, notificationwidth, notificationheight);
		_notificationsBackdropView.frame = _notificationViews.frame;
		[[CSAwayNotificationController sharedInstance] adjustPosition];
	}
    if (CSCLScheckModern()){
        _topBackdropView.frame = CGRectMake(0, 0, _mediaControlsView.frame.size.width, _mediaControlsView.frame.size.height+_mediaControlsView.frame.origin.y);
        _topBackdropOverlayView.frame = _topBackdropView.frame;
    }
}

- (void)hideCamera {
	[_lockBar dismissCamera];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	[_controller restartDimTimer];
	return [super hitTest:point withEvent:event];
}

- (void)startUpdatingTime {
	[self updateTime];
    [_timeUpdater invalidate];
    _timeUpdater = nil;
    _timeUpdater = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                    target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
}

- (void)stopUpdatingTime {
    [_timeUpdater invalidate];
    _timeUpdater = nil;
}

@end
