@interface CSClassicLockScreenSettingsManager : NSObject {
	NSUserDefaults *_prefs;
}
+ (instancetype)sharedInstance;
- (BOOL)enabled;
- (BOOL)zuluClock;
- (BOOL)secondsEnabled;
- (BOOL)modern;
- (BOOL)altslider;
- (BOOL)darkmode;
- (BOOL)albumArtwork;
- (BOOL)advsettings;
- (BOOL)hidebgforartwork;
@end