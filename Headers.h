#define VARIANT_LOCKSCREEN 0
#define VARIANT_HOMESCREEN 1

#import "BBBulletin.h"

@protocol CSAwayControllerDelegate <NSObject>
- (void)unlock;
- (BOOL)unlockWithPasscode:(NSString *)passcode;
- (void)setPasscodeLockVisible:(BOOL)visible animated:(BOOL)animated completion:(void (^)(BOOL success))completion;
@optional
- (void)setUnlockActionContext:(id)context;
- (void)setCustomLockScreenActionContext:(id)context;
@end

@protocol SBUIPasscodeLockView
- (void)setBackgroundAlpha:(CGFloat)alpha;
@end

@protocol SBUIPasscodeLockViewDelegate <NSObject>
@optional
-(void)passcodeLockViewPasscodeEnteredViaMesa:(id)mesa;
-(void)passcodeLockViewEmergencyCallButtonPressed:(id)pressed;
-(void)passcodeLockViewCancelButtonPressed:(id)pressed;
-(void)passcodeLockViewPasscodeEntered:(id)entered;
-(void)passcodeLockViewPasscodeDidChange:(id)passcodeLockViewPasscode;
@end

@interface SBBacklightController : NSObject
+ (instancetype) sharedInstance;
- (void)resetLockScreenIdleTimer;
- (void)cancelLockScreenIdleTimer;
- (void)resetLockScreenIdleTimerWithDuration:(CGFloat)duration;
@end

@interface SBDeviceLockController : NSObject
+ (SBDeviceLockController *)sharedController;
- (BOOL)isPasscodeLocked;
@end

@interface SBIcon : NSObject
- (void)launchFromLocation:(int)location;
- (void)launchFromLocation:(int)location context:(id)arg;
@end

@interface SBIconModel : NSObject
- (SBIcon *)expectedIconForDisplayIdentifier:(NSString *)displayIdentifier;
@end

@interface SBIconController : NSObject
+ (SBIconController *)sharedInstance;
- (SBIconModel *)model;
@end

@interface UIApplication (SpringBoard)
- (BOOL)_isDim;
@end

@interface MCPasscodeManager : NSObject
+ (instancetype)sharedManager;
- (NSDictionary *)_passcodeCharacteristics;
- (BOOL)unlockDeviceWithPasscode:(NSString *)passcode outError:(NSError **)error;
- (void)lockDeviceImmediately:(BOOL)lock;
- (BOOL)isPasscodeSet;
- (BOOL)isDeviceLocked;
@end

@interface SBLockScreenNotificationListController : UIViewController
- (UIScrollView *) lockScreenScrollView;
-(void)observer:(id)observer addBulletin:(BBBulletin *)bulletin forFeed:(unsigned)feed;
@end

@interface SBLockScreenScrollView : UIScrollView
@end

@class BBBulletin;
@interface SBLockScreenActionContext : NSObject
@property (nonatomic, strong) NSString * identifier;                      //@synthesize identifier=_identifier - In the implementation block
@property (nonatomic, strong) NSString * lockLabel;                       //@synthesize lockLabel=_lockLabel - In the implementation block
@property (nonatomic, strong) NSString * shortLockLabel;                  //@synthesize shortLockLabel=_shortLockLabel - In the implementation block
@property (nonatomic, copy) id action;                                    //@synthesize action=_action - In the implementation block
@property (assign, nonatomic) BOOL requiresUIUnlock;                      //@synthesize requiresUIUnlock=_requiresUIUnlock - In the implementation block
@property (assign, nonatomic) BOOL deactivateAwayController;              //@synthesize deactivateAwayController=_deactivateAwayController - In the implementation block
@property (assign, nonatomic) BOOL canBypassPinLock;                      //@synthesize canBypassPinLock=_canBypassPinLock - In the implementation block
@property (nonatomic, readonly) BOOL hasCustomUnlockLabel; 
@property (assign, nonatomic) BOOL requiresAuthentication;                //@synthesize requiresAuthentication=_requiresAuthentication - In the implementation block
@property (nonatomic, weak) BBBulletin *bulletin;               //@synthesize bulletin=_bulletin - In the implementation block
- (SBLockScreenActionContext *)initWithLockLabel:(NSString *)lockLabel shortLockLabel:(NSString *)shortLockLabel action:(/*^block*/id)action identifier:(NSString *)identifier;
@end

@interface SBMutableLockScreenActionContext  : SBLockScreenActionContext
@end

@interface SBLockScreenActionContextFactory : NSObject
+(SBLockScreenActionContextFactory *)sharedInstance;
- (SBLockScreenActionContext *)lockScreenActionContextForBulletin:(BBBulletin *)arg1 action:(id)arg2 origin:(int)arg3 pluginActionsAllowed:(BOOL)arg4 context:(id)arg5 completion:(/*^block*/id)arg6 ;
@end

@interface NCNotificationRequest : NSObject
@property (nonatomic, readonly) BBBulletin *bulletin;
@end

@class NCNotificationPriorityListViewController;
@interface SBDashBoardNotificationListViewController : UIViewController {
	NCNotificationPriorityListViewController *_listViewController;
}
@end

@interface SBLockScreenView : UIView
- (SBLockScreenScrollView *)scrollView;
- (UIView<SBUIPasscodeLockView> *) passcodeView;
- (NSInteger)pageNumberForLockScreenPage:(NSInteger)page;
@end

@interface SBLockScreenViewController : UIViewController <CSAwayControllerDelegate,SBUIPasscodeLockViewDelegate>
+ (UIView *)getLockGlyphView;
- (UIView *) lockScreenView;
- (UIView *) _cameraView;
- (void)activateCameraAnimated:(BOOL)animated;
- (SBLockScreenNotificationListController *) _notificationController;
-(void)finishUIUnlockFromSource:(int)source;
- (UIScrollView *)lockScreenScrollView;
@end

@interface SBDashBoardPageControl : UIPageControl
@end

@class SBDashBoardViewController;
@interface SBDashBoardView : UIView
- (UIView *)mainPageView;
- (UIScrollView *)scrollView;
- (UIPageControl *)pageControl;
- (NSInteger)_indexOfMainPage;
- (SBDashBoardViewController *)delegate;
@end

@interface SBDashBoardViewController : UIViewController <CSAwayControllerDelegate>
- (SBDashBoardView *) dashBoardView;
- (void)finishUIUnlockFromSource:(int)source;
- (BOOL)isPasscodeLockVisible;
- (void)CSMLS_updateStatusBarAlpha;
- (NSInteger)_indexOfMainPage;
- (void)activateCameraAnimated:(BOOL)arg1 withActions:(id)arg2;
-(void)activatePage:(NSUInteger)arg1 animated:(BOOL)arg2 withCompletion:(/*^block*/id)arg3 ;
@end

@interface SBDashBoardMainPageViewController : UIViewController
@end

@interface SBLockScreenDateViewController : UIViewController

@end

@interface SBScreenFadeAnimationController : NSObject

+ (id)sharedInstance;
- (void)hideDate;
- (void)setDateViewAlpha:(float)alpha;

@end

@interface SBApplication : NSObject
@end

@interface SBApplicationIcon : NSObject
- (id)initWithApplication:(SBApplication *)application;
- (UIImage *)generateIconImage:(NSInteger)image;

@end

@interface SBApplicationController : NSObject
+ (id)sharedInstance;
- (SBApplication *)applicationWithDisplayIdentifier:(NSString *)displayIdentifier;
- (SBApplication *)applicationWithBundleIdentifier:(NSString *)bundleIdentifier;
@end

@interface SBLockScreenManager : NSObject
+ (SBLockScreenManager *)sharedInstance;
- (BOOL)androidlockIsLocked;
- (void) startUIUnlockFromSource:(id)source withOptions:(id)options;
- (void) _finishUIUnlockFromSource:(id)source withOptions:(id)options;
- (BOOL)attemptUnlockWithPasscode:(NSString *)passcode;
- (BOOL) isUILocked;
@property(readonly, assign, nonatomic) SBLockScreenViewController* lockScreenViewController;
@property (nonatomic,readonly) SBDashBoardViewController * dashBoardViewController;
@end

@interface SBMediaController : NSObject
+ (id)sharedInstance;
- (NSDictionary *)_nowPlayingInfo;
- (BOOL)togglePlayPause;
- (void)changeTrack:(int)track;
//not Available in iOS 8
- (BOOL)isPlaying;
- (double)trackDuration;
- (double)trackElapsedTime;
- (void)setCurrentTrackTime:(float)time;
@end

@interface SBFWallpaperView : UIView
- (UIImage *)wallpaperImage;
- (UIImageView *)contentView;
@end

@interface SBFStaticWallpaperView : SBFWallpaperView
@end

@interface SBWallpaperEffectView : UIView
- (void)setStyle:(int)style;
- (id)initWithWallpaperVariant:(int)wallpaperVariant;
- (void)_updateWallpaperAverageColor:(id)fp8;
- (void)wallpaperDidChangeForVariant:(int)fp8;
- (void)wallpaperLegibilitySettingsDidChange:(id)fp8 forVariant:(int)fp12;
@end
@interface SBWallpaperController : NSObject
+(id)sharedInstance;
- (SBFWallpaperView *)_newWallpaperViewForProcedural:(id)procedural orImage:(UIImage *)image;
- (SBFWallpaperView *)_newWallpaperViewForProcedural:(id)procedural orImage:(UIImage *)image forVariant:(int)variant;
@end

@interface SBUIPasscodeLockViewBase : UIView
@property (nonatomic, retain) NSObject <SBUIPasscodeLockViewDelegate> *delegate;
@property (nonatomic, readonly) NSString *passcode;
@property(nonatomic) BOOL showsEmergencyCallButton;
- (void)setBackgroundAlpha:(CGFloat)alpha;
- (void)_resetForFailedPasscode:(BOOL)arg1;
@end

@interface PasscodeLockViewAndroidLock : SBUIPasscodeLockViewBase
- (PasscodeLockViewAndroidLock *)initWithSettings:(NSDictionary *)settings;
@end

@interface SBUIPasscodeLockViewFactory : NSObject {
}
+ (SBUIPasscodeLockViewBase *)passcodeLockViewForUsersCurrentStyle;
@end

@interface _SBFakeBlurView : UIView
+ (id)_imageForStyle:(int *)style withSource:(SBFStaticWallpaperView *)source;
@end

@interface AndroidLockView : UIView
@property (nonatomic, retain) NSObject *delegate;
@end

@interface FCCurrentWeatherView : UIView
+ (FCCurrentWeatherView *)currentWeatherView;
@end

@interface JLJellyLockView : UIView
+ (JLJellyLockView *)currentJellyLockView;
-(void)resetGrabber:(BOOL)grabber;
@end

@interface JLUJellyLockView : UIView
+ (JLUJellyLockView *)currentJellyLockView;
-(void)resetGrabber:(BOOL)grabber;
@end

@interface BCBerryView : UIView
+ (BCBerryView *)currentBerryLockView;
+ (BCBerryView *)sharedInstanceForFrame:(CGRect)frame;
- (void)resetViewAnimated:(BOOL)animated;
@end

@interface STPreferences : NSObject
@property(assign, nonatomic) BOOL enabled;
+(id)sharedInstance;
@end

@interface CVLockNotificationView : UIView
@end

@interface ASCSLSHandler : NSObject
+ (NSString *)clearCache;
+ (NSString *)cacheData;
-(void)runSynchronously:(NSString *)identifier;
@end